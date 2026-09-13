import QtQuick

Item {
    id: root

    required property Typography typography
    property color foreground: AppTheme.accentText

    implicitWidth: 34
    implicitHeight: 34
    visible: typography.family !== ""

    TextMetrics {
        id: glyphMetrics
        font: letter.font
        text: letter.text
    }

    Text {
        id: letter
        objectName: "badgeLetter"
        anchors.centerIn: parent
        anchors.horizontalCenterOffset: (width - glyphMetrics.tightBoundingRect.width) / 2 - glyphMetrics.tightBoundingRect.x
        text: "پ"
        font: root.typography.badgeFont
        color: root.foreground
        renderType: Text.NativeRendering
    }
}
