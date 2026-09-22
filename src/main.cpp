#include "services/ClipboardBridge.h"
#include "services/ClipboardKeeper.h"
#include "services/FileBridge.h"
#include "services/SettingsStore.h"
#include "services/TextDirectionBridge.h"

#include <QCoreApplication>
#include <QElapsedTimer>
#include <QFile>
#include <QGuiApplication>
#include <QIcon>
#include <QRawFont>
#include <QQmlApplicationEngine>
#include <QQuickStyle>
#include <QTimer>
#include <QVariant>
#include <qqml.h>

#include <array>
#include <cstdio>
#include <cstring>

namespace {

constexpr auto workerScriptConnectionWarning =
    "QObject::connect(QJSEngine, QtObject): invalid nullptr parameter";

void applicationMessageHandler(
    QtMsgType type,
    const QMessageLogContext &context,
    const QString &message)
{
    // Qt 6.11 emits this from its private WorkerScript engine while creating
    // the isolated JavaScript global object. The workers remain functional.
    if (type == QtWarningMsg
        && message == QLatin1StringView(workerScriptConnectionWarning)) {
        return;
    }

    qt_message_output(type, context, message);
}

bool verifyEmbeddedResources()
{
    constexpr std::array resources {
        ":/qt/qml/LeoMoon/ParsiNegar/assets/fonts/Vazirmatn[wght].ttf",
        ":/qt/qml/LeoMoon/ParsiNegar/assets/fonts/MaterialSymbolsRounded.ttf",
        ":/qt/qml/LeoMoon/ParsiNegar/assets/app-icon.svg",
        ":/qt/qml/LeoMoon/ParsiNegar/vendor/js-bidi.js",
        ":/qt/qml/LeoMoon/ParsiNegar/vendor/js-parsi-reshaper.js",
        ":/qt/qml/LeoMoon/ParsiNegar/vendor/typr.js",
        ":/qt/qml/LeoMoon/ParsiNegar/qml/core/InterfaceStrings.js",
        ":/qt/qml/LeoMoon/ParsiNegar/ConversionWorker.js",
        ":/qt/qml/LeoMoon/ParsiNegar/SvgCurveWorker.js",
        ":/qt/qml/LeoMoon/ParsiNegar/qml/core/SvgCurveExporter.js",
        ":/qt/qml/LeoMoon/ParsiNegar/qml/core/ParsiNegar.js",
        ":/qt/qml/LeoMoon/ParsiNegar/qml/core/ReshaperSettings.js",
        ":/qt/qml/LeoMoon/ParsiNegar/qml/core/ResourceLimits.js",
        ":/qt/qml/LeoMoon/ParsiNegar/qml/core/SourceHistory.js",
        ":/qt/qml/LeoMoon/ParsiNegar/qml/core/TextTools.js",
    };

    for (const auto *resource : resources) {
        QFile file(QString::fromUtf8(resource));
        if (!file.exists() || file.size() <= 0) {
            qCritical("Required embedded resource is missing or empty: %s", resource);
            return false;
        }
    }

    QFile iconFontFile(QStringLiteral(":/qt/qml/LeoMoon/ParsiNegar/assets/fonts/MaterialSymbolsRounded.ttf"));
    if (!iconFontFile.open(QIODevice::ReadOnly)) {
        qCritical("Bundled icon font could not be opened");
        return false;
    }

    const QRawFont iconFont(iconFontFile.readAll(), 24.0, QFont::PreferNoHinting);
    constexpr std::array<quint32, 12> requiredIconGlyphs {
        0xE15A, 0xE166, 0xE2C4, 0xE312, 0xE518, 0xE51C, 0xE5C4, 0xE5C8, 0xE5D5, 0xE873, 0xE8B8, 0xF10B
    };
    if (!iconFont.isValid()) {
        qCritical("Bundled icon font is invalid");
        return false;
    }
    for (const auto codePoint : requiredIconGlyphs) {
        if (!iconFont.supportsCharacter(codePoint)) {
            qCritical("Bundled icon font is missing required glyph U+%04X", codePoint);
            return false;
        }
    }

    return true;
}

} // namespace

int main(int argc, char *argv[])
{
    for (int index = 1; index < argc; ++index) {
        if (std::strcmp(argv[index], "--version") == 0) {
            std::printf("LeoMoon ParsiNegar %s\n", PARSINEGAR_VERSION);
            return EXIT_SUCCESS;
        }
    }

    QCoreApplication::setOrganizationName(QStringLiteral("LeoMoon Studios"));
    QCoreApplication::setOrganizationDomain(QStringLiteral("leomoon-studios.com"));
    QCoreApplication::setApplicationName(QStringLiteral("LeoMoon ParsiNegar"));
    QCoreApplication::setApplicationVersion(QStringLiteral(PARSINEGAR_VERSION));
    qInstallMessageHandler(applicationMessageHandler);

#if defined(Q_OS_LINUX)
    if (qEnvironmentVariableIsSet("APPIMAGE")) {
        // Use the bundled portal theme instead of an unbundled host theme such as gtk3.
        qputenv("QT_QPA_PLATFORMTHEME", "xdgdesktopportal");
    }
#endif

    QGuiApplication application(argc, argv);
    application.setWindowIcon(QIcon(QStringLiteral(":/qt/qml/LeoMoon/ParsiNegar/assets/app-icon.svg")));

    QString clipboardTransferPath;
    if (ClipboardKeeper::invocationTransferPath(application.arguments(), &clipboardTransferPath)) {
        return ClipboardKeeper::run(clipboardTransferPath);
    }

    QQuickStyle::setStyle(QStringLiteral("Basic"));

    if (!verifyEmbeddedResources()) {
        return EXIT_FAILURE;
    }

    ClipboardBridge clipboardBridge;
    SettingsStore settingsStore;
    FileBridge fileBridge;
    TextDirectionBridge textDirectionBridge;
    fileBridge.scanInstalledFontsAsync();
    qmlRegisterSingletonInstance("LeoMoon.ParsiNegar.Native", 1, 0, "ClipboardBridge", &clipboardBridge);
    qmlRegisterSingletonInstance("LeoMoon.ParsiNegar.Native", 1, 0, "SettingsStore", &settingsStore);
    qmlRegisterSingletonInstance("LeoMoon.ParsiNegar.Native", 1, 0, "FileBridge", &fileBridge);

    application.setQuitOnLastWindowClosed(false);
    QObject::connect(&application, &QGuiApplication::lastWindowClosed, &clipboardBridge, [&application, &clipboardBridge]() {
        if (!clipboardBridge.persistCopiedText()) {
            qWarning("Could not preserve clipboard text after closing the window: %s",
                     qPrintable(clipboardBridge.lastError()));
        }
        application.quit();
    });

    QQmlApplicationEngine engine;
    engine.setInitialProperties({
        {QStringLiteral("clipboardService"), QVariant::fromValue(&clipboardBridge)},
        {QStringLiteral("settingsService"), QVariant::fromValue(&settingsStore)},
        {QStringLiteral("fileService"), QVariant::fromValue(&fileBridge)},
        {QStringLiteral("textDirectionService"), QVariant::fromValue(&textDirectionBridge)},
    });
    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreationFailed,
        &application,
        []() { QCoreApplication::exit(EXIT_FAILURE); },
        Qt::QueuedConnection);
    engine.loadFromModule(QStringLiteral("LeoMoon.ParsiNegar"), QStringLiteral("Main"));

    if (engine.rootObjects().isEmpty()) {
        return EXIT_FAILURE;
    }

    const bool smokeTest = application.arguments().contains(QStringLiteral("--smoke-test"));
    if (smokeTest) {
        auto *timer = new QTimer(&application);
        auto *elapsed = new QElapsedTimer;
        elapsed->start();
        timer->setInterval(25);
        QObject::connect(timer, &QTimer::timeout, &application, [timer, elapsed, &engine]() {
            const auto roots = engine.rootObjects();
            if (roots.isEmpty()) {
                delete elapsed;
                QCoreApplication::exit(EXIT_FAILURE);
                return;
            }

            const QObject *root = roots.constFirst();
            if (root->property("bundledFontReady").toBool()
                && root->property("bundledIconFontReady").toBool()) {
                timer->stop();
                delete elapsed;
                QCoreApplication::exit(EXIT_SUCCESS);
            } else if (root->property("bundledFontError").toBool()
                       || root->property("bundledIconFontError").toBool()
                       || elapsed->elapsed() >= 5000) {
                timer->stop();
                delete elapsed;
                QCoreApplication::exit(EXIT_FAILURE);
            }
        });
        timer->start();
    }

    return application.exec();
}
