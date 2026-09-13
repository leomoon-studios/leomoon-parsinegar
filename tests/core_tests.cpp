#include <QFile>
#include <QJSEngine>
#include <QJSValue>
#include <QStringList>
#include <QtTest>

class CoreTests final : public QObject
{
    Q_OBJECT

private slots:
    void productionCoreSuite();
};

void CoreTests::productionCoreSuite()
{
    QJSEngine engine;
    const QStringList scripts {
        QStringLiteral(":/vendor/js-bidi.js"),
        QStringLiteral(":/vendor/js-parsi-reshaper.js"),
        QStringLiteral(":/qml/core/ParsiNegar.js"),
        QStringLiteral(":/qml/core/ReshaperSettings.js"),
        QStringLiteral(":/qml/core/InterfaceStrings.js"),
        QStringLiteral(":/qml/core/ResourceLimits.js"),
        QStringLiteral(":/tests/fixtures/ParsiNegarFixtures.js"),
        QStringLiteral(":/tests/CoreTests.js"),
    };

    for (const QString &path : scripts) {
        QFile file(path);
        QVERIFY2(file.open(QIODevice::ReadOnly | QIODevice::Text), qPrintable(QStringLiteral("Could not load embedded script: %1").arg(path)));
        const QJSValue result = engine.evaluate(QString::fromUtf8(file.readAll()), path);
        if (result.isError()) {
            const QString message = QStringLiteral("%1:%2: %3\n%4")
                                        .arg(path)
                                        .arg(result.property(QStringLiteral("lineNumber")).toInt())
                                        .arg(result.toString(), result.property(QStringLiteral("stack")).toString());
            QFAIL(qPrintable(message));
        }
    }

    const QJSValue passed = engine.evaluate(QStringLiteral("CoreTestResults.passed"));
    const QJSValue total = engine.evaluate(QStringLiteral("CoreTestResults.total"));
    QVERIFY(passed.isNumber());
    QVERIFY(total.isNumber());
    QCOMPARE(passed.toInt(), total.toInt());
    QCOMPARE(total.toInt(), 592);
}

QTEST_GUILESS_MAIN(CoreTests)

#include "core_tests.moc"
