import QtQuick

QtObject {
    id: root

    property url fontSource: "qrc:/qt/qml/LeoMoon/ParsiNegar/assets/fonts/Vazirmatn%5Bwght%5D.ttf"
    property string fallbackFamily: "sans-serif"

    readonly property bool ready: bundledFont.status === FontLoader.Ready
    readonly property bool failed: bundledFont.status === FontLoader.Error
    readonly property string family: ready && bundledFont.name !== "" ? bundledFont.name : fallbackFamily
    readonly property string errorMessage: failed ? qsTr("Unable to load the bundled Vazirmatn font. A system sans-serif font is being used.") : ""
    signal loadFailed(string message)

    readonly property FontLoader fontLoader: FontLoader {
        id: bundledFont
        source: root.fontSource
        onStatusChanged: {
            if (status === FontLoader.Error)
                root.loadFailed(root.errorMessage)
        }
    }

    function sizedFont(pixelSize, weight) {
        return Qt.font({ family: root.family, pixelSize: pixelSize, weight: weight })
    }

    readonly property font titleFont: sizedFont(AppTheme.fontTitle, Font.DemiBold)
    readonly property font headingFont: sizedFont(AppTheme.fontHeading, Font.DemiBold)
    readonly property font bodyFont: sizedFont(AppTheme.fontBody, Font.Normal)
    readonly property font controlFont: sizedFont(AppTheme.fontControl, Font.Medium)
    readonly property font captionFont: sizedFont(AppTheme.fontCaption, Font.Normal)
    readonly property font badgeFont: sizedFont(AppTheme.fontBody, Font.Bold)
}
