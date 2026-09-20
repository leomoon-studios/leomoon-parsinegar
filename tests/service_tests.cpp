#include "services/ClipboardBridge.h"
#include "services/ClipboardKeeper.h"
#include "services/FileBridge.h"
#include "services/SettingsStore.h"
#include "services/TextDirectionBridge.h"

#include <QCoreApplication>
#include <QDir>
#include <QFile>
#include <QGuiApplication>
#include <QQmlComponent>
#include <QQmlEngine>
#include <QQuickItem>
#include <QQuickTextDocument>
#include <QQuickWindow>
#include <QSignalSpy>
#include <QStandardPaths>
#include <QTemporaryDir>
#include <QTest>
#include <QTextBlock>
#include <QTextDocument>
#include <QTextLayout>
#include <QTextOption>
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
    void fileBridgeCatalogsInstalledFonts();
    void fileBridgeRejectsInvalidAndOversizedFonts();
    void fileBridgeReadsAndWritesExactUtf8Documents();
    void fileBridgeRejectsUnsafeDocuments();
    void fileBridgeWritesSvgAtomically();
    void fileBridgeReportsWriteFailuresAndLimits();
    void fileBridgeCompletesFontAndSvgWorkAsynchronously();
    void textDirectionBridgeAlignsRenderedParagraphs();
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
    QCoreApplication::setApplicationName(QStringLiteral("LeoMoon ParsiNegar Tests"));
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
#if !defined(Q_OS_LINUX)
    QSKIP("The detached clipboard keeper is only used on Linux ownership-based clipboards.");
#else
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
#endif
}

void ServiceTests::settingsUsePlatformLocation()
{
    SettingsStore store;
    const QString expectedDirectory = QDir(QStandardPaths::writableLocation(QStandardPaths::GenericConfigLocation))
                                          .filePath(QStringLiteral("leomoon-parsinegar"));

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
    QVERIFY(bridge.fontPathExists(path));
    QCOMPARE(readSpy.count(), 1);
    QCOMPARE(failureSpy.count(), 0);
}

void ServiceTests::fileBridgeCatalogsInstalledFonts()
{
    FileBridge bridge;
    QSignalSpy catalogSpy(&bridge, &FileBridge::fontCatalogChanged);
    QSignalSpy readySpy(&bridge, &FileBridge::fontCatalogReadyChanged);
    QSignalSpy scanningSpy(&bridge, &FileBridge::fontCatalogScanningChanged);
    QVERIFY(!bridge.fontCatalogReady());
    QVERIFY(!bridge.fontCatalogScanning());
    QVERIFY(bridge.scanInstalledFontsAsync());
    QVERIFY(bridge.fontCatalogScanning());
    QVERIFY(!bridge.scanInstalledFontsAsync());
    QTRY_COMPARE_WITH_TIMEOUT(readySpy.count(), 1, 10000);
    QCOMPARE(catalogSpy.count(), 1);
    QCOMPARE(scanningSpy.count(), 2);
    QVERIFY(bridge.fontCatalogReady());
    QVERIFY(!bridge.fontCatalogScanning());

    const QVariantList fonts = bridge.fontCatalog();
    QVERIFY(!fonts.isEmpty());
    QVERIFY(!bridge.scanInstalledFontsAsync());

    for (const QVariant &value : fonts) {
        const QVariantMap font = value.toMap();
        QVERIFY(!font.value(QStringLiteral("family")).toString().isEmpty());
        QVERIFY(!font.value(QStringLiteral("display")).toString().isEmpty());
        QVERIFY(bridge.fontPathExists(font.value(QStringLiteral("path")).toString()));
    }

    QVERIFY(bridge.refreshInstalledFontsAsync());
    QVERIFY(bridge.fontCatalogScanning());
    QVERIFY(!bridge.refreshInstalledFontsAsync());
    QTRY_COMPARE_WITH_TIMEOUT(catalogSpy.count(), 2, 10000);
    QCOMPARE(readySpy.count(), 1);
    QCOMPARE(scanningSpy.count(), 4);
    QVERIFY(bridge.fontCatalogReady());
    QVERIFY(!bridge.fontCatalogScanning());
    QCOMPARE(bridge.fontCatalog(), fonts);
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
    QVERIFY(!bridge.fontPathExists(unsupportedPath));
    QVERIFY(!bridge.fontPathExists(temporaryDirectory.filePath(QStringLiteral("missing.ttf"))));

    const QString oversizedPath = temporaryDirectory.filePath(QStringLiteral("oversized.ttf"));
    QFile oversized(oversizedPath);
    QVERIFY(oversized.open(QIODevice::WriteOnly));
    QVERIFY(oversized.resize(FileBridge::maximumFontBytes + 1));
    oversized.close();
    QCOMPARE(errorCode(bridge.readFont(QUrl::fromLocalFile(oversizedPath))), QStringLiteral("FONT_TOO_LARGE"));
    QCOMPARE(failureSpy.count(), 4);
}

void ServiceTests::fileBridgeReadsAndWritesExactUtf8Documents()
{
    QTemporaryDir temporaryDirectory;
    QVERIFY(temporaryDirectory.isValid());
    FileBridge bridge;
    QSignalSpy readSpy(&bridge, &FileBridge::textDocumentRead);
    QSignalSpy writtenSpy(&bridge, &FileBridge::textDocumentWritten);
    const QString text = QStringLiteral("first\r\n\r\nپارسی\n");
    const QString path = temporaryDirectory.filePath(QStringLiteral("document.txt"));

    const QVariantMap writeResult = bridge.writeTextDocument(QUrl::fromLocalFile(path), text);
    QVERIFY(succeeded(writeResult));
    QCOMPARE(writeResult.value(QStringLiteral("path")).toString(), path);
    QCOMPARE(writtenSpy.count(), 1);

    QFile exactFile(path);
    QVERIFY(exactFile.open(QIODevice::ReadOnly));
    QCOMPARE(exactFile.readAll(), text.toUtf8());

    const QVariantMap readResult = bridge.readTextDocument(QUrl::fromLocalFile(path));
    QVERIFY(succeeded(readResult));
    QCOMPARE(readResult.value(QStringLiteral("data")).toString(), text);
    QCOMPARE(readResult.value(QStringLiteral("characterCount")).toLongLong(), text.size());
    QCOMPARE(readResult.value(QStringLiteral("byteCount")).toLongLong(), text.toUtf8().size());
    QCOMPARE(readSpy.count(), 1);
}

void ServiceTests::fileBridgeRejectsUnsafeDocuments()
{
    QTemporaryDir temporaryDirectory;
    QVERIFY(temporaryDirectory.isValid());
    FileBridge bridge;
    QSignalSpy failureSpy(&bridge, &FileBridge::operationFailed);

    QCOMPARE(errorCode(bridge.readTextDocument(QUrl(QStringLiteral("https://example.com/document.txt")))), QStringLiteral("INVALID_LOCAL_URL"));
    QCOMPARE(errorCode(bridge.readTextDocument(QUrl::fromLocalFile(temporaryDirectory.filePath(QStringLiteral("missing.txt"))))), QStringLiteral("DOCUMENT_NOT_FOUND"));

    const QString invalidPath = temporaryDirectory.filePath(QStringLiteral("invalid.txt"));
    writeBytes(invalidPath, QByteArray::fromHex("c328"));
    QCOMPARE(errorCode(bridge.readTextDocument(QUrl::fromLocalFile(invalidPath))), QStringLiteral("DOCUMENT_INVALID_UTF8"));

    const QString oversizedPath = temporaryDirectory.filePath(QStringLiteral("oversized.txt"));
    QFile oversized(oversizedPath);
    QVERIFY(oversized.open(QIODevice::WriteOnly));
    QVERIFY(oversized.resize(FileBridge::maximumDocumentBytes + 1));
    oversized.close();
    QCOMPARE(errorCode(bridge.readTextDocument(QUrl::fromLocalFile(oversizedPath))), QStringLiteral("DOCUMENT_TOO_LARGE"));

    const QString oversizedText(FileBridge::maximumDocumentCharacters + 1, QLatin1Char('x'));
    QCOMPARE(errorCode(bridge.writeTextDocument(QUrl::fromLocalFile(temporaryDirectory.filePath(QStringLiteral("large.txt"))), oversizedText)), QStringLiteral("DOCUMENT_TOO_LARGE"));
    QCOMPARE(errorCode(bridge.writeTextDocument(QUrl::fromLocalFile(temporaryDirectory.filePath(QStringLiteral("missing/draft.txt"))), QStringLiteral("draft"))), QStringLiteral("DOCUMENT_DIRECTORY_NOT_FOUND"));
    QCOMPARE(failureSpy.count(), 6);
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

void ServiceTests::fileBridgeCompletesFontAndSvgWorkAsynchronously()
{
    QTemporaryDir temporaryDirectory;
    QVERIFY(temporaryDirectory.isValid());
    FileBridge bridge;
    QSignalSpy fontSpy(&bridge, &FileBridge::fontReadCompleted);
    QSignalSpy writeSpy(&bridge, &FileBridge::svgWriteCompleted);

    const QString sourceDirectory = QString::fromUtf8(PARSINEGAR_TEST_SOURCE_DIR);
    const QUrl fontUrl = QUrl::fromLocalFile(
        QDir(sourceDirectory).filePath(QStringLiteral("assets/fonts/Vazirmatn[wght].ttf")));
    QVERIFY(!bridge.readFontAsync(0, fontUrl));
    QVERIFY(bridge.readFontAsync(41, fontUrl));
    QTRY_COMPARE_WITH_TIMEOUT(fontSpy.count(), 1, 10000);
    QCOMPARE(fontSpy.at(0).at(0).toInt(), 41);
    const QVariantMap fontResult = fontSpy.at(0).at(1).toMap();
    QVERIFY(succeeded(fontResult));
    QVERIFY(fontResult.value(QStringLiteral("byteCount")).toLongLong() > 0);

    QVERIFY(bridge.readBundledFontAsync(42));
    QTRY_COMPARE_WITH_TIMEOUT(fontSpy.count(), 2, 10000);
    QCOMPARE(fontSpy.at(1).at(0).toInt(), 42);
    const QVariantMap bundledResult = fontSpy.at(1).at(1).toMap();
    QVERIFY(succeeded(bundledResult));
    QCOMPARE(bundledResult.value(QStringLiteral("data")).toByteArray(),
             fontResult.value(QStringLiteral("data")).toByteArray());

    const QString svg = QStringLiteral("<svg xmlns=\"http://www.w3.org/2000/svg\"><path d=\"M0 0Z\"/></svg>\n");
    const QUrl destination = QUrl::fromLocalFile(
        temporaryDirectory.filePath(QStringLiteral("async-curves")));
    QVERIFY(!bridge.writeSvgAsync(0, destination, svg));
    QVERIFY(bridge.writeSvgAsync(43, destination, svg));
    QTRY_COMPARE_WITH_TIMEOUT(writeSpy.count(), 1, 10000);
    QCOMPARE(writeSpy.at(0).at(0).toInt(), 43);
    const QVariantMap writeResult = writeSpy.at(0).at(1).toMap();
    QVERIFY(succeeded(writeResult));
    QFile output(writeResult.value(QStringLiteral("path")).toString());
    QVERIFY(output.open(QIODevice::ReadOnly));
    QCOMPARE(output.readAll(), svg.toUtf8());

    QCOMPARE(bridge.localFilePath(destination), QDir::cleanPath(destination.toLocalFile()));
    QCOMPARE(bridge.localFileUrl(destination.toLocalFile()), destination);
    QVERIFY(bridge.localFilePath(QUrl(QStringLiteral("https://example.com/font.ttf"))).isEmpty());
    QVERIFY(bridge.localFileUrl(QStringLiteral("relative/font.ttf")).isEmpty());
}

void ServiceTests::textDirectionBridgeAlignsRenderedParagraphs()
{
    QQmlEngine engine;
    QQmlComponent component(&engine);
    component.setData(R"(
        import QtQuick
        TextEdit {
            width: 560
            height: 180
            wrapMode: TextEdit.Wrap
            textFormat: TextEdit.RichText
            font.pixelSize: 28
        }
    )", QUrl());
    QScopedPointer<QObject> editor(component.create());
    QVERIFY2(editor, qPrintable(component.errorString()));
    auto *editorItem = qobject_cast<QQuickItem *>(editor.data());
    QVERIFY(editorItem);

    QQuickWindow window;
    window.setGeometry(0, 0, 600, 220);
    editorItem->setParentItem(window.contentItem());
    editorItem->setPosition(QPointF(20, 20));
    window.show();

    const QString source = QStringLiteral(
        "English.\nسلام.\n123 سلام.\n123 English.\n...");
    auto *wrapper = qobject_cast<QQuickTextDocument *>(
        editor->property("textDocument").value<QObject *>());
    QVERIFY(wrapper);
    QTextDocument *document = wrapper->textDocument();
    QVERIFY(document);

    TextDirectionBridge bridge;
    QVERIFY(!bridge.applyAutomaticDirection(nullptr));
    QVERIFY(!bridge.setPlainText(nullptr, source));
    QVERIFY(bridge.plainText(nullptr).isEmpty());

    QVERIFY(bridge.setPlainText(wrapper, QStringLiteral(".")));
    QVERIFY(bridge.applyAutomaticDirection(wrapper));
    QTRY_COMPARE(document->begin().blockFormat().alignment(), Qt::AlignRight | Qt::AlignAbsolute);
    QVERIFY(bridge.setPlainText(wrapper, QStringLiteral("E")));
    QVERIFY(bridge.applyAutomaticDirection(wrapper));
    QTRY_COMPARE(document->begin().blockFormat().alignment(), Qt::AlignLeft | Qt::AlignAbsolute);
    QVERIFY(bridge.setPlainText(wrapper, QStringLiteral("س")));
    QVERIFY(bridge.applyAutomaticDirection(wrapper));
    QTRY_COMPARE(document->begin().blockFormat().alignment(), Qt::AlignRight | Qt::AlignAbsolute);
    QTest::qWait(50);
    QCOMPARE(document->begin().blockFormat().alignment(), Qt::AlignRight | Qt::AlignAbsolute);

    QVERIFY(bridge.setPlainText(wrapper, source));
    QVERIFY(bridge.applyAutomaticDirection(wrapper));
    QTRY_COMPARE(
        document->findBlockByNumber(1).blockFormat().alignment(),
        Qt::AlignRight | Qt::AlignAbsolute);
    QTest::qWait(50);
    QCOMPARE(
        document->findBlockByNumber(1).blockFormat().alignment(),
        Qt::AlignRight | Qt::AlignAbsolute);
    QCOMPARE(bridge.plainText(wrapper), source);

    const QList<Qt::LayoutDirection> expectedDirections {
        Qt::LeftToRight,
        Qt::RightToLeft,
        Qt::RightToLeft,
        Qt::LeftToRight,
        Qt::LeftToRight,
    };
    int blockIndex = 0;
    for (QTextBlock block = document->begin(); block.isValid(); block = block.next()) {
        QVERIFY(blockIndex < expectedDirections.size());
        const Qt::LayoutDirection expectedDirection = expectedDirections.at(blockIndex);
        const Qt::Alignment expectedAlignment = (expectedDirection == Qt::RightToLeft
                ? Qt::AlignRight
                : Qt::AlignLeft)
            | Qt::AlignAbsolute;
        QCOMPARE(block.blockFormat().layoutDirection(), expectedDirection);
        QCOMPARE(block.blockFormat().alignment(), expectedAlignment);
        QCOMPARE(block.layout()->textOption().textDirection(), expectedDirection);
        QCOMPARE(block.layout()->textOption().alignment(), expectedAlignment);
        blockIndex++;
    }
    QCOMPARE(blockIndex, expectedDirections.size());

    const auto cursorX = [&editor](int position) {
        QRectF rectangle;
        const bool invoked = QMetaObject::invokeMethod(
            editor.data(),
            "positionToRectangle",
            Q_RETURN_ARG(QRectF, rectangle),
            Q_ARG(int, position));
        return invoked ? rectangle.x() : -1.0;
    };
    QVERIFY(cursorX(0) < 50.0);
    QVERIFY(cursorX(9) > 500.0);
    const qreal rtlPeriodCenter = (cursorX(13) + cursorX(14)) / 2.0;
    const qreal rtlWordLeftEdge = qMin(
        qMin(cursorX(9), cursorX(10)),
        qMin(cursorX(11), qMin(cursorX(12), cursorX(13))));
    QVERIFY(rtlPeriodCenter < rtlWordLeftEdge);
}

QTEST_MAIN(ServiceTests)

#include "service_tests.moc"
