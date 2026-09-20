#include "SettingsStore.h"

#include <QDir>
#include <QFile>
#include <QFileInfo>
#include <QJsonArray>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonParseError>
#include <QJsonValue>
#include <QSaveFile>
#include <QStandardPaths>

namespace {

constexpr auto settingsFileName = "settings.json";
constexpr auto configDirectoryName = "leomoon-parsinegar";

bool isProhibitedKey(const QString &key)
{
    return key == QStringLiteral("draftText") || key == QStringLiteral("sourceText")
        || key == QStringLiteral("convertedText") || key == QStringLiteral("clipboardText");
}

} // namespace

SettingsStore::SettingsStore(QObject *parent)
    : SettingsStore(
        QDir(QStandardPaths::writableLocation(QStandardPaths::GenericConfigLocation))
            .filePath(QString::fromUtf8(configDirectoryName)),
        parent)
{
}

SettingsStore::SettingsStore(const QString &configDirectory, QObject *parent)
    : QObject(parent)
    , m_configDirectory(QDir::cleanPath(configDirectory))
    , m_settingsFilePath(QDir(m_configDirectory).filePath(QString::fromUtf8(settingsFileName)))
{
}

QString SettingsStore::configDirectory() const
{
    return m_configDirectory;
}

QString SettingsStore::settingsFilePath() const
{
    return m_settingsFilePath;
}

QString SettingsStore::lastError() const
{
    return m_lastError;
}

QVariantMap SettingsStore::load()
{
    const QFileInfo info(m_settingsFilePath);
    if (!info.exists()) {
        emit loaded(m_settingsFilePath);
        return success({ { QStringLiteral("exists"), false }, { QStringLiteral("data"), QString() } });
    }
    if (!info.isFile()) {
        return failure(QStringLiteral("SETTINGS_NOT_FILE"), QStringLiteral("The settings path is not a regular file."));
    }
    if (info.size() > maximumSettingsBytes) {
        return failure(QStringLiteral("SETTINGS_TOO_LARGE"), QStringLiteral("The settings file exceeds the supported size."));
    }

    QFile file(m_settingsFilePath);
    if (!file.open(QIODevice::ReadOnly)) {
        return failure(QStringLiteral("SETTINGS_READ_FAILED"), file.errorString());
    }
    const QByteArray bytes = file.read(maximumSettingsBytes + 1);
    if (bytes.size() > maximumSettingsBytes) {
        return failure(QStringLiteral("SETTINGS_TOO_LARGE"), QStringLiteral("The settings file exceeds the supported size."));
    }

    emit loaded(m_settingsFilePath);
    return success({ { QStringLiteral("exists"), true }, { QStringLiteral("data"), QString::fromUtf8(bytes) } });
}

QVariantMap SettingsStore::save(const QString &json)
{
    const QByteArray bytes = json.toUtf8();
    if (bytes.size() > maximumSettingsBytes) {
        return failure(QStringLiteral("SETTINGS_TOO_LARGE"), QStringLiteral("The settings data exceeds the supported size."));
    }

    QJsonParseError parseError;
    const QJsonDocument document = QJsonDocument::fromJson(bytes, &parseError);
    if (parseError.error != QJsonParseError::NoError || !document.isObject()) {
        return failure(QStringLiteral("INVALID_SETTINGS_JSON"), QStringLiteral("Settings must be a valid JSON object."));
    }
    if (containsProhibitedState(document.object())) {
        return failure(QStringLiteral("PROHIBITED_SETTINGS_DATA"), QStringLiteral("Settings cannot contain draft or clipboard text."));
    }
    if (!QDir().mkpath(m_configDirectory)) {
        return failure(QStringLiteral("SETTINGS_DIRECTORY_FAILED"), QStringLiteral("The settings directory could not be created."));
    }

    QSaveFile file(m_settingsFilePath);
    if (!file.open(QIODevice::WriteOnly)) {
        return failure(QStringLiteral("SETTINGS_WRITE_FAILED"), file.errorString());
    }
    if (file.write(bytes) != bytes.size()) {
        file.cancelWriting();
        return failure(QStringLiteral("SETTINGS_WRITE_FAILED"), file.errorString());
    }
    if (!file.commit()) {
        return failure(QStringLiteral("SETTINGS_WRITE_FAILED"), file.errorString());
    }

    emit saved(m_settingsFilePath);
    return success({ { QStringLiteral("path"), m_settingsFilePath } });
}

bool SettingsStore::containsProhibitedState(const QJsonValue &value)
{
    if (value.isObject()) {
        const QJsonObject object = value.toObject();
        for (auto iterator = object.constBegin(); iterator != object.constEnd(); ++iterator) {
            if (isProhibitedKey(iterator.key()) || containsProhibitedState(iterator.value())) {
                return true;
            }
        }
    } else if (value.isArray()) {
        const QJsonArray array = value.toArray();
        for (const QJsonValue &item : array) {
            if (containsProhibitedState(item)) {
                return true;
            }
        }
    }
    return false;
}

QVariantMap SettingsStore::success(const QVariantMap &values)
{
    if (!m_lastError.isEmpty()) {
        m_lastError.clear();
        emit lastErrorChanged();
    }
    QVariantMap result = values;
    result.insert(QStringLiteral("ok"), true);
    return result;
}

QVariantMap SettingsStore::failure(const QString &code, const QString &message)
{
    if (m_lastError != message) {
        m_lastError = message;
        emit lastErrorChanged();
    }
    emit operationFailed(code, message);
    return {
        { QStringLiteral("ok"), false },
        { QStringLiteral("code"), code },
        { QStringLiteral("message"), message },
    };
}
