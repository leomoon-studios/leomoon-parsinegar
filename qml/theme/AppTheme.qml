pragma Singleton

import QtQuick

QtObject {
    id: root

    property bool darkMode: Application.styleHints.colorScheme !== Qt.Light
    property string accentPreset: "purple"
    readonly property var accentPresets: ["purple", "slate", "faint", "blue", "teal", "rose"]
    readonly property var accentPalettes: ({
        purple: {
            dark: { accent: "#9b8cff", hover: "#afa3ff", text: "#151024", focus: "#b9aeff" },
            light: { accent: "#5941d8", hover: "#4932c4", text: "#ffffff", focus: "#4932c4" }
        },
        slate: {
            dark: { accent: "#929bad", hover: "#aab3c2", text: "#151922", focus: "#b7c0cf" },
            light: { accent: "#475569", hover: "#334155", text: "#ffffff", focus: "#334155" }
        },
        faint: {
            dark: { accent: "#4e535f", hover: "#5e6470", text: "#f3f4f8", focus: "#777e8c" },
            light: { accent: "#c7ccd5", hover: "#b8bec9", text: "#191b22", focus: "#8d95a3" }
        },
        blue: {
            dark: { accent: "#78b8ff", hover: "#99c9ff", text: "#101c2b", focus: "#a7d0ff" },
            light: { accent: "#2563b4", hover: "#1d5096", text: "#ffffff", focus: "#1d5096" }
        },
        teal: {
            dark: { accent: "#65cbbb", hover: "#89d9cc", text: "#10221f", focus: "#9ce1d5" },
            light: { accent: "#087b6d", hover: "#066457", text: "#ffffff", focus: "#066457" }
        },
        rose: {
            dark: { accent: "#f19ab5", hover: "#f5b3c8", text: "#2a1420", focus: "#f8bfd1" },
            light: { accent: "#a23661", hover: "#862b50", text: "#ffffff", focus: "#862b50" }
        }
    })
    readonly property var activeAccentPalette: accentPalettes[accentPreset] || accentPalettes.purple
    readonly property var activeAccentColors: darkMode ? activeAccentPalette.dark : activeAccentPalette.light
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
    readonly property string iconUndo: "\ue166"
    readonly property string iconRedo: "\ue15a"
    readonly property string iconRefresh: "\ue5d5"
    readonly property string iconKeyboard: "\ue312"
    readonly property string iconDocument: "\ue873"
    readonly property string iconHelp: "\ue8fd"
    readonly property string iconDonate: "\ue87d"

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
    readonly property color accent: activeAccentColors.accent
    readonly property color accentHover: activeAccentColors.hover
    readonly property color accentText: activeAccentColors.text
    readonly property color focus: activeAccentColors.focus
    readonly property color success: darkMode ? "#66d6a0" : "#147a4c"
    readonly property color warning: darkMode ? "#f4c66a" : "#8a5700"
    readonly property color urgent: darkMode ? "#ff929b" : "#b4232f"
    readonly property color donationHeart: darkMode ? "#ef4444" : "#c62828"

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
