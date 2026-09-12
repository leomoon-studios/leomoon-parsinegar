import QtQuick
import QtQuick.Controls

ApplicationWindow {
    id: root

    readonly property bool bundledFontReady: bundledFont.status === FontLoader.Ready
    readonly property bool bundledFontError: bundledFont.status === FontLoader.Error

    width: 900
    height: 640
    minimumWidth: 480
    minimumHeight: 360
    visible: true
    title: qsTr("ParsiNegar Desktop")

    FontLoader {
        id: bundledFont
        source: "qrc:/qt/qml/LeoMoon/ParsiNegar/assets/fonts/Vazirmatn%5Bwght%5D.ttf"
    }

    Label {
        anchors.centerIn: parent
        text: qsTr("ParsiNegar Desktop")
        font.family: bundledFont.name
        font.pixelSize: 28
    }
}
