#pragma once

#include <QObject>
#include <QString>
#include <QVariantMap>

class QJsonValue;

class SettingsStore final : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString configDirectory READ configDirectory CONSTANT)
    Q_PROPERTY(QString settingsFilePath READ settingsFilePath CONSTANT)
    Q_PROPERTY(QString lastError READ lastError NOTIFY lastErrorChanged)

public:
    static constexpr qsizetype maximumSettingsBytes = 1024 * 1024;

    explicit SettingsStore(QObject *parent = nullptr);
    explicit SettingsStore(const QString &configDirectory, QObject *parent = nullptr);

    [[nodiscard]] QString configDirectory() const;
    [[nodiscard]] QString settingsFilePath() const;
    [[nodiscard]] QString lastError() const;

    Q_INVOKABLE QVariantMap load();
    Q_INVOKABLE QVariantMap save(const QString &json);

signals:
    void loaded(const QString &path);
    void saved(const QString &path);
    void operationFailed(const QString &code, const QString &message);
    void lastErrorChanged();

private:
    [[nodiscard]] static bool containsProhibitedState(const QJsonValue &value);
    [[nodiscard]] QVariantMap success(const QVariantMap &values = {});
    [[nodiscard]] QVariantMap failure(const QString &code, const QString &message);

    QString m_configDirectory;
    QString m_settingsFilePath;
    QString m_lastError;
};
