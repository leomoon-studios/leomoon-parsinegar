#pragma once

#include <QString>
#include <QVariantMap>

class UnicodeSvgExporter final
{
public:
    // Call on the GUI thread after QGuiApplication and the QML resources exist.
    static bool initialize();
    static bool isReady();
    static QVariantMap render(const QString &text, const QVariantMap &options,
                              const QString &selectedFontPath = {},
                              const QString &expectedFamily = {},
                              const QString &expectedStyle = {});
};
