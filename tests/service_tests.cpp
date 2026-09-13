#include "services/ClipboardBridge.h"
#include "services/ClipboardKeeper.h"
#include "services/FileBridge.h"
#include "services/SettingsStore.h"

#include <QCoreApplication>
#include <QDir>
#include <QFile>
#include <QGuiApplication>
#include <QSignalSpy>
#include <QStandardPaths>
#include <QTemporaryDir>
#include <QTest>
#include <QUrl>
#include <QVariantMap>

class ServiceTests final : public QObject
{
    Q_OBJECT

private slots:
    void initTestCase();
    void clipboardRoundTrip();
    void clipboardKeeperHandoff();
    void settingsUsePlatformLocation();
    void settingsRoundTripAtomically();
    void settingsDelegateSchemaRecovery();
    void settingsRejectUnsafeData();
    void settingsReportsAtomicWriteFailure();
    void fileBridgeReadsExactFontBytes();
    void fileBridgeRejectsInvalidAndOversizedFonts();
    void fileBridgeWritesSvgAtomically();
    void fileBridgeReportsWriteFailuresAndLimits();
};

namespace {

bool succeeded(const QVariantMap &result)
{
    return result.value(QStringLiteral("ok")).toBool();
}

QString errorCode(const QVariantMap &result)
{
    return result.value(QStringLiteral("code")).toString();
}

void writeBytes(const QString &path, const QByteArray &bytes)
{
    QFile file(path);
    QVERIFY2(file.open(QIODevice::WriteOnly), qPrintable(file.errorString()));
    QCOMPARE(file.write(bytes), bytes.size());
}

} // namespace

void ServiceTests::initTestCase()
{
    QStandardPaths::setTestModeEnabled(true);
    QCoreApplication::setOrganizationName(QStringLiteral("LeoMoon Studios"));
    QCoreApplication::setOrganizationDomain(QStringLiteral("leomoon-studios.com"));
    QCoreApplication::setApplicationName(QStringLiteral("ParsiNegar Desktop Tests"));
}

void ServiceTests::clipboardRoundTrip()
{
    ClipboardBridge bridge;
    QSignalSpy copiedSpy(&bridge, &ClipboardBridge::copied);
    QSignalSpy failureSpy(&bridge, &ClipboardBridge::operationFailed);
    const QString sample = QStringLiteral("پارسی نگار\nשלום 123");

    QVERIFY(bridge.copyText(sample));
    QCOMPARE(bridge.readText(), sample);
    QCOMPARE(copiedSpy.count(), 1);
    QCOMPARE(failureSpy.count(), 0);
    QVERIFY(bridge.lastError().isEmpty());
}

void ServiceTests::clipboardKeeperHandoff()
{
    QString errorMessage;
    const QString sample = QStringLiteral("پارسی نگار\nשלום 123");
    bool hasCustomLifetime = false;
    const int customLifetime = qEnvironmentVariableIntValue(
        "PARSINEGAR_KEEPER_TEST_LIFETIME_MS", &hasCustomLifetime);
    const int lifetimeMilliseconds = hasCustomLifetime ? customLifetime : 50;
    QVERIFY2(
        ClipboardKeeper::startDetached(
            sample,
            &errorMessage,
            lifetimeMilliseconds,
            QString::fromUtf8(PARSINEGAR_TEST_APP_PATH)),
        qPrintable(errorMessage));
    QVERIFY(errorMessage.isEmpty());

    const QString oversized(ClipboardKeeper::maximumPayloadBytes + 1, QLatin1Char('x'));
    QVERIFY(!ClipboardKeeper::startDetached(
        oversized, &errorMessage, 50, QString::fromUtf8(PARSINEGAR_TEST_APP_PATH)));
    QVERIFY(!errorMessage.isEmpty());
    QVERIFY(!ClipboardKeeper::startDetached(
        sample, &errorMessage, -1, QString::fromUtf8(PARSINEGAR_TEST_APP_PATH)));
    QVERIFY(!errorMessage.isEmpty());
}

void ServiceTests::settingsUsePlatformLocation()
{
    SettingsStore store;
    const QString expectedDirectory = QDir::cleanPath(QStandardPaths::writableLocation(QStandardPaths::AppConfigLocation));

    QCOMPARE(store.configDirectory(), expectedDirectory);
    QCOMPARE(store.settingsFilePath(), QDir(expectedDirectory).filePath(QStringLiteral("settings.json")));
}

void ServiceTests::settingsRoundTripAtomically()
{
    QTemporaryDir temporaryDirectory;
    QVERIFY(temporaryDirectory.isValid());
    SettingsStore store(temporaryDirectory.path() + QStringLiteral("/config"));
    QSignalSpy savedSpy(&store, &SettingsStore::saved);
    QSignalSpy loadedSpy(&store, &SettingsStore::loaded);
    QSignalSpy failureSpy(&store, &SettingsStore::operationFailed);
    const QString json = QStringLiteral("{\"schemaVersion\":1,\"settings\":{\"deleteHarakat\":false}}");

    const QVariantMap saveResult = store.save(json);
    QVERIFY(succeeded(saveResult));
    QCOMPARE(saveResult.value(QStringLiteral("path")).toString(), store.settingsFilePath());
    QCOMPARE(savedSpy.count(), 1);

    const QVariantMap loadResult = store.load();
    QVERIFY(succeeded(loadResult));
    QVERIFY(loadResult.value(QStringLiteral("exists")).toBool());
    QCOMPARE(loadResult.value(QStringLiteral("data")).toString(), json);
    QCOMPARE(loadedSpy.count(), 1);
    QCOMPARE(failureSpy.count(), 0);
    QCOMPARE(QDir(store.configDirectory()).entryList(QDir::Files | QDir::NoDotAndDotDot), QStringList { QStringLiteral("settings.json") });
}

void ServiceTests::settingsDelegateSchemaRecovery()
{
    QTemporaryDir temporaryDirectory;
    QVERIFY(temporaryDirectory.isValid());
    SettingsStore store(temporaryDirectory.path());

    const QString unknownSchema = QStringLiteral("{\"schemaVersion\":999,\"settings\":{\"unknown\":true}}");
    QVERIFY(succeeded(store.save(unknownSchema)));

    writeBytes(store.settingsFilePath(), QByteArrayLiteral("{not valid json"));
    const QVariantMap loadResult = store.load();
    QVERIFY(succeeded(loadResult));
    QCOMPARE(loadResult.value(QStringLiteral("data")).toString(), QStringLiteral("{not valid json"));
}

void ServiceTests::settingsRejectUnsafeData()
{
    QTemporaryDir temporaryDirectory;
    QVERIFY(temporaryDirectory.isValid());
    SettingsStore store(temporaryDirectory.path());
    QSignalSpy failureSpy(&store, &SettingsStore::operationFailed);

    QCOMPARE(errorCode(store.save(QStringLiteral("not json"))), QStringLiteral("INVALID_SETTINGS_JSON"));
    QCOMPARE(errorCode(store.save(QStringLiteral("{\"nested\":{\"draftText\":\"secret\"}}"))), QStringLiteral("PROHIBITED_SETTINGS_DATA"));
    const QString oversized(SettingsStore::maximumSettingsBytes + 1, QLatin1Char('x'));
    QCOMPARE(errorCode(store.save(oversized)), QStringLiteral("SETTINGS_TOO_LARGE"));
    QCOMPARE(failureSpy.count(), 3);
    QVERIFY(!QFile::exists(store.settingsFilePath()));

    writeBytes(store.settingsFilePath(), QByteArray(SettingsStore::maximumSettingsBytes + 1, 'x'));
    QCOMPARE(errorCode(store.load()), QStringLiteral("SETTINGS_TOO_LARGE"));
}

void ServiceTests::settingsReportsAtomicWriteFailure()
{
    QTemporaryDir temporaryDirectory;
    QVERIFY(temporaryDirectory.isValid());
    SettingsStore store(temporaryDirectory.path());
    QSignalSpy failureSpy(&store, &SettingsStore::operationFailed);

    QVERIFY(QDir().mkdir(store.settingsFilePath()));
    const QVariantMap result = store.save(QStringLiteral("{\"schemaVersion\":1,\"settings\":{}}"));
    QCOMPARE(errorCode(result), QStringLiteral("SETTINGS_WRITE_FAILED"));
    QVERIFY(QFileInfo(store.settingsFilePath()).isDir());
    QCOMPARE(failureSpy.count(), 1);
}

void ServiceTests::fileBridgeReadsExactFontBytes()
{
    FileBridge bridge;
    QSignalSpy readSpy(&bridge, &FileBridge::fontRead);
    QSignalSpy failureSpy(&bridge, &FileBridge::operationFailed);
    const QString sourceDirectory = QString::fromUtf8(PARSINEGAR_TEST_SOURCE_DIR);
    const QString path = QDir(sourceDirectory).filePath(QStringLiteral("assets/fonts/Vazirmatn[wght].ttf"));
    QFile expectedFile(path);
    QVERIFY(expectedFile.open(QIODevice::ReadOnly));
    const QByteArray expected = expectedFile.readAll();

    const QVariantMap result = bridge.readFont(QUrl::fromLocalFile(path));
    QVERIFY(succeeded(result));
    QCOMPARE(result.value(QStringLiteral("path")).toString(), QDir::cleanPath(path));
    QCOMPARE(result.value(QStringLiteral("data")).toByteArray(), expected);
    QCOMPARE(result.value(QStringLiteral("byteCount")).toLongLong(), expected.size());
    QCOMPARE(readSpy.count(), 1);
    QCOMPARE(failureSpy.count(), 0);
}

void ServiceTests::fileBridgeRejectsInvalidAndOversizedFonts()
{
    QTemporaryDir temporaryDirectory;
    QVERIFY(temporaryDirectory.isValid());
    FileBridge bridge;
    QSignalSpy failureSpy(&bridge, &FileBridge::operationFailed);

    QCOMPARE(errorCode(bridge.readFont(QUrl(QStringLiteral("https://example.com/font.ttf")))), QStringLiteral("INVALID_LOCAL_URL"));
    QCOMPARE(errorCode(bridge.readFont(QUrl::fromLocalFile(temporaryDirectory.filePath(QStringLiteral("missing.ttf"))))), QStringLiteral("FONT_NOT_FOUND"));
    const QString unsupportedPath = temporaryDirectory.filePath(QStringLiteral("font.txt"));
    writeBytes(unsupportedPath, QByteArrayLiteral("font"));
    QCOMPARE(errorCode(bridge.readFont(QUrl::fromLocalFile(unsupportedPath))), QStringLiteral("UNSUPPORTED_FONT_TYPE"));

    const QString oversizedPath = temporaryDirectory.filePath(QStringLiteral("oversized.ttf"));
    QFile oversized(oversizedPath);
    QVERIFY(oversized.open(QIODevice::WriteOnly));
    QVERIFY(oversized.resize(FileBridge::maximumFontBytes + 1));
    oversized.close();
    QCOMPARE(errorCode(bridge.readFont(QUrl::fromLocalFile(oversizedPath))), QStringLiteral("FONT_TOO_LARGE"));
    QCOMPARE(failureSpy.count(), 4);
}

void ServiceTests::fileBridgeWritesSvgAtomically()
{
    QTemporaryDir temporaryDirectory;
    QVERIFY(temporaryDirectory.isValid());
    FileBridge bridge;
    QSignalSpy writtenSpy(&bridge, &FileBridge::svgWritten);
    QSignalSpy failureSpy(&bridge, &FileBridge::operationFailed);
    const QString svg = QStringLiteral("<svg xmlns=\"http://www.w3.org/2000/svg\"><path d=\"M0 0Z\"/></svg>\n");
    const QString requestedPath = temporaryDirectory.filePath(QStringLiteral("curves"));

    const QVariantMap result = bridge.writeSvg(QUrl::fromLocalFile(requestedPath), svg);
    QVERIFY(succeeded(result));
    const QString writtenPath = requestedPath + QStringLiteral(".svg");
    QCOMPARE(result.value(QStringLiteral("path")).toString(), writtenPath);
    QFile file(writtenPath);
    QVERIFY(file.open(QIODevice::ReadOnly));
    QCOMPARE(file.readAll(), svg.toUtf8());
    QCOMPARE(writtenSpy.count(), 1);
    QCOMPARE(failureSpy.count(), 0);
    QCOMPARE(QDir(temporaryDirectory.path()).entryList(QDir::Files | QDir::NoDotAndDotDot), QStringList { QStringLiteral("curves.svg") });
}

void ServiceTests::fileBridgeReportsWriteFailuresAndLimits()
{
    QTemporaryDir temporaryDirectory;
    QVERIFY(temporaryDirectory.isValid());
    FileBridge bridge;
    QSignalSpy failureSpy(&bridge, &FileBridge::operationFailed);

    QCOMPARE(errorCode(bridge.writeSvg(QUrl(QStringLiteral("data:image/svg+xml,test")), QStringLiteral("<svg/>"))), QStringLiteral("INVALID_LOCAL_URL"));
    const QString oversized(FileBridge::maximumSvgBytes + 1, QLatin1Char('x'));
    QCOMPARE(errorCode(bridge.writeSvg(QUrl::fromLocalFile(temporaryDirectory.filePath(QStringLiteral("large.svg"))), oversized)), QStringLiteral("SVG_TOO_LARGE"));

    const QString blockedPath = temporaryDirectory.filePath(QStringLiteral("blocked.svg"));
    QVERIFY(QDir().mkdir(blockedPath));
    QCOMPARE(errorCode(bridge.writeSvg(QUrl::fromLocalFile(blockedPath), QStringLiteral("<svg/>"))), QStringLiteral("SVG_WRITE_FAILED"));
    QVERIFY(QFileInfo(blockedPath).isDir());
    QCOMPARE(failureSpy.count(), 3);
}

QTEST_MAIN(ServiceTests)

#include "service_tests.moc"
