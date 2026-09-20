#include <QFile>
#include <QJSEngine>
#include <QJSValue>
#include <QStringList>
#include <QXmlStreamReader>
#include <QtTest>

class CoreTests final : public QObject
{
    Q_OBJECT

private slots:
    void productionCoreSuite();
    void exactFontSvgSuite();
};

void CoreTests::productionCoreSuite()
{
    QJSEngine engine;
    const QList<QPair<QString, QString>> translationModules {
        { QStringLiteral(":/qml/core/i18n/English.js"), QStringLiteral("EnglishStrings") },
        { QStringLiteral(":/qml/core/i18n/Persian.js"), QStringLiteral("PersianStrings") },
        { QStringLiteral(":/qml/core/i18n/Arabic.js"), QStringLiteral("ArabicStrings") },
    };
    for (const auto &[path, namespaceName] : translationModules) {
        QFile file(path);
        QVERIFY2(file.open(QIODevice::ReadOnly | QIODevice::Text), qPrintable(QStringLiteral("Could not load embedded script: %1").arg(path)));
        QStringList lines = QString::fromUtf8(file.readAll()).split(QLatin1Char('\n'));
        lines.removeIf([](const QString &line) { return line.trimmed().startsWith(QLatin1Char('.')); });
        const QJSValue result = engine.evaluate(lines.join(QLatin1Char('\n')), path);
        if (result.isError()) {
            const QString message = QStringLiteral("%1:%2: %3\n%4")
                                        .arg(path)
                                        .arg(result.property(QStringLiteral("lineNumber")).toInt())
                                        .arg(result.toString(), result.property(QStringLiteral("stack")).toString());
            QFAIL(qPrintable(message));
        }
        const QJSValue moduleValues = engine.globalObject().property(QStringLiteral("values"));
        QVERIFY2(moduleValues.isObject(), qPrintable(QStringLiteral("Translation module did not expose values: %1").arg(path)));
        QJSValue moduleNamespace = engine.newObject();
        moduleNamespace.setProperty(QStringLiteral("values"), moduleValues);
        engine.globalObject().setProperty(namespaceName, moduleNamespace);
    }

    {
        const QString path = QStringLiteral(":/qml/core/InterfaceStrings.js");
        QFile file(path);
        QVERIFY2(file.open(QIODevice::ReadOnly | QIODevice::Text), qPrintable(QStringLiteral("Could not load embedded script: %1").arg(path)));
        QStringList lines = QString::fromUtf8(file.readAll()).split(QLatin1Char('\n'));
        lines.removeIf([](const QString &line) { return line.trimmed().startsWith(QLatin1Char('.')); });
        const QJSValue result = engine.evaluate(lines.join(QLatin1Char('\n')), path);
        if (result.isError()) {
            const QString message = QStringLiteral("%1:%2: %3\n%4")
                                        .arg(path)
                                        .arg(result.property(QStringLiteral("lineNumber")).toInt())
                                        .arg(result.toString(), result.property(QStringLiteral("stack")).toString());
            QFAIL(qPrintable(message));
        }
    }

    const QStringList scripts {
        QStringLiteral(":/vendor/js-bidi.js"),
        QStringLiteral(":/vendor/js-parsi-reshaper.js"),
        QStringLiteral(":/qml/core/ParsiNegar.js"),
        QStringLiteral(":/qml/core/SourceHistory.js"),
        QStringLiteral(":/qml/core/TextTools.js"),
        QStringLiteral(":/qml/core/ReshaperSettings.js"),
        QStringLiteral(":/qml/core/ResourceLimits.js"),
        QStringLiteral(":/tests/fixtures/ParsiNegarFixtures.js"),
        QStringLiteral(":/tests/fixtures/TextToolsFixtures.js"),
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
    QCOMPARE(total.toInt(), 618);
}

void CoreTests::exactFontSvgSuite()
{
    QJSEngine engine;
    QFile font(QStringLiteral(":/assets/fonts/Vazirmatn[wght].ttf"));
    QVERIFY2(font.open(QIODevice::ReadOnly), "Could not load embedded Vazirmatn");
    engine.globalObject().setProperty(
        QStringLiteral("TestFontBytes"), engine.toScriptValue(font.readAll()));

    const QString maryamPath = qEnvironmentVariable("PARSINEGAR_MARYAM_TEST_FONT");
    if (!maryamPath.isEmpty()) {
        QFile maryam(maryamPath);
        QVERIFY2(maryam.open(QIODevice::ReadOnly), qPrintable(maryam.errorString()));
        engine.globalObject().setProperty(
            QStringLiteral("MaryamFontBytes"), engine.toScriptValue(maryam.readAll()));
    } else {
        engine.globalObject().setProperty(QStringLiteral("MaryamFontBytes"), QJSValue(QJSValue::NullValue));
    }

    const QStringList scripts {
        QStringLiteral(":/vendor/js-bidi.js"),
        QStringLiteral(":/vendor/js-parsi-reshaper.js"),
        QStringLiteral(":/vendor/typr.js"),
        QStringLiteral(":/qml/core/ParsiNegar.js"),
        QStringLiteral(":/qml/core/ResourceLimits.js"),
        QStringLiteral(":/qml/core/SvgCurveExporter.js"),
        QStringLiteral(":/tests/SvgCurveTests.js"),
    };
    for (const QString &path : scripts) {
        QFile script(path);
        QVERIFY2(script.open(QIODevice::ReadOnly | QIODevice::Text), qPrintable(path));
        const QJSValue result = engine.evaluate(QString::fromUtf8(script.readAll()), path);
        QVERIFY2(!result.isError(), qPrintable(result.toString() + QLatin1Char('\n')
                                               + result.property(QStringLiteral("stack")).toString()));
    }

    const QJSValue results = engine.globalObject().property(QStringLiteral("SvgCurveTestResults"));
    const QJSValue failures = results.property(QStringLiteral("failures"));
    QVERIFY(results.property(QStringLiteral("passed")).toInt() > 30);
    QVERIFY2(failures.property(QStringLiteral("length")).toInt() == 0,
             qPrintable(failures.property(0).toString()));

    const QString svg = results.property(QStringLiteral("sampleSvg")).toString();
    QVERIFY(!svg.isEmpty());
    QXmlStreamReader xml(svg);
    int pathCount = 0;
    while (!xml.atEnd()) {
        xml.readNext();
        if (!xml.isStartElement()) {
            continue;
        }
        const QStringView name = xml.name();
        QVERIFY(name != QStringLiteral("text"));
        QVERIFY(name != QStringLiteral("tspan"));
        QVERIFY(name != QStringLiteral("image"));
        if (name == QStringLiteral("path")) {
            pathCount++;
        }
    }
    QVERIFY2(!xml.hasError(), qPrintable(xml.errorString()));
    QCOMPARE(pathCount, 2);
}

QTEST_GUILESS_MAIN(CoreTests)

#include "core_tests.moc"
