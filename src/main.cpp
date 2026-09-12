#include <QCoreApplication>
#include <QElapsedTimer>
#include <QFile>
#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQuickStyle>
#include <QTimer>
#include <QVariant>

#include <array>

namespace {

constexpr auto applicationId = "com.leomoon-studios.parsinegar-desktop";

bool verifyEmbeddedResources()
{
    constexpr std::array resources {
        ":/qt/qml/LeoMoon/ParsiNegar/assets/fonts/Vazirmatn[wght].ttf",
        ":/qt/qml/LeoMoon/ParsiNegar/vendor/js-bidi.js",
        ":/qt/qml/LeoMoon/ParsiNegar/vendor/js-parsi-reshaper.js",
        ":/qt/qml/LeoMoon/ParsiNegar/vendor/typr.js",
        ":/qt/qml/LeoMoon/ParsiNegar/qml/core/InterfaceStrings.js",
        ":/qt/qml/LeoMoon/ParsiNegar/qml/core/ParsiNegar.js",
        ":/qt/qml/LeoMoon/ParsiNegar/qml/core/ReshaperSettings.js",
        ":/qt/qml/LeoMoon/ParsiNegar/qml/core/ResourceLimits.js",
    };

    for (const auto *resource : resources) {
        QFile file(QString::fromUtf8(resource));
        if (!file.exists() || file.size() <= 0) {
            qCritical("Required embedded resource is missing or empty: %s", resource);
            return false;
        }
    }

    return true;
}

} // namespace

int main(int argc, char *argv[])
{
    QGuiApplication application(argc, argv);
    QCoreApplication::setOrganizationName(QStringLiteral("LeoMoon Studios"));
    QCoreApplication::setOrganizationDomain(QStringLiteral("leomoon-studios.com"));
    QCoreApplication::setApplicationName(QStringLiteral("ParsiNegar Desktop"));
    QCoreApplication::setApplicationVersion(QStringLiteral("0.1.0"));
    application.setDesktopFileName(QString::fromUtf8(applicationId));

    QQuickStyle::setStyle(QStringLiteral("Basic"));

    if (!verifyEmbeddedResources()) {
        return EXIT_FAILURE;
    }

    QQmlApplicationEngine engine;
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
            if (root->property("bundledFontReady").toBool()) {
                timer->stop();
                delete elapsed;
                QCoreApplication::exit(EXIT_SUCCESS);
            } else if (root->property("bundledFontError").toBool() || elapsed->elapsed() >= 5000) {
                timer->stop();
                delete elapsed;
                QCoreApplication::exit(EXIT_FAILURE);
            }
        });
        timer->start();
    }

    return application.exec();
}
