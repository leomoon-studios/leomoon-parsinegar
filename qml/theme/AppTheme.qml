pragma Singleton

import QtQuick

QtObject {
    id: root

    property bool darkMode: Application.styleHints.colorScheme !== Qt.Light
    property string fontFamily: "sans-serif"
    readonly property FontLoader iconFontLoader: FontLoader {
        source: "qrc:/qt/qml/LeoMoon/ParsiNegar/assets/fonts/MaterialSymbolsRounded.ttf"
    }
    readonly property bool iconFontReady: iconFontLoader.status === FontLoader.Ready
    readonly property bool iconFontFailed: iconFontLoader.status === FontLoader.Error
    readonly property string iconFontFamily: iconFontReady ? iconFontLoader.name : fontFamily
    readonly property string iconLightMode: "\ue518"
    readonly property string iconDarkMode: "\ue51c"
    readonly property string iconSettings: "\ue8b8"
    readonly property string iconExport: "\ue2c4"
    readonly property string iconTools: "\uf10b"
    readonly property string iconBack: "\ue5c4"
    readonly property string iconForward: "\ue5c8"

    readonly property int spacingUnit: 4
    readonly property int spacingTiny: spacingUnit
    readonly property int spacingSmall: spacingUnit * 2
    readonly property int spacingMedium: spacingUnit * 3
    readonly property int spacingLarge: spacingUnit * 5
    readonly property int spacingXLarge: spacingUnit * 7

    readonly property int fontCaption: 12
    readonly property int fontBody: 14
    readonly property int fontControl: 14
    readonly property int fontHeading: 20
    readonly property int fontTitle: 27

    readonly property real cornerRadiusSmall: 7
    readonly property real cornerRadius: 11
    readonly property real cornerRadiusLarge: 17
    readonly property int borderWidth: 1
    readonly property int focusBorderWidth: 2

    readonly property color background: darkMode ? "#11131a" : "#f5f6fa"
    readonly property color surface: darkMode ? "#191c25" : "#ffffff"
    readonly property color surfaceRaised: darkMode ? "#222632" : "#eceef5"
    readonly property color foreground: darkMode ? "#f3f4f8" : "#191b22"
    readonly property color muted: darkMode ? "#aeb5c3" : "#596170"
    readonly property color border: darkMode ? "#343946" : "#d5d9e3"
    readonly property color accent: darkMode ? "#9b8cff" : "#5941d8"
    readonly property color accentHover: darkMode ? "#afa3ff" : "#4932c4"
    readonly property color accentText: darkMode ? "#151024" : "#ffffff"
    readonly property color focus: darkMode ? "#b9aeff" : "#4932c4"
    readonly property color success: darkMode ? "#66d6a0" : "#147a4c"
    readonly property color warning: darkMode ? "#f4c66a" : "#8a5700"
    readonly property color urgent: darkMode ? "#ff929b" : "#b4232f"

    function spacing(multiplier) {
        return Math.round(spacingUnit * multiplier)
    }

    function withAlpha(color, alpha) {
        return Qt.rgba(color.r, color.g, color.b, alpha)
    }

    function linearChannel(channel) {
        return channel <= 0.04045 ? channel / 12.92 : Math.pow((channel + 0.055) / 1.055, 2.4)
    }

    function luminance(color) {
        return 0.2126 * linearChannel(color.r) + 0.7152 * linearChannel(color.g) + 0.0722 * linearChannel(color.b)
    }

    function contrastRatio(first, second) {
        var firstLuminance = luminance(first)
        var secondLuminance = luminance(second)
        var lighter = Math.max(firstLuminance, secondLuminance)
        var darker = Math.min(firstLuminance, secondLuminance)
        return (lighter + 0.05) / (darker + 0.05)
    }
}
