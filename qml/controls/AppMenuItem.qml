import QtQuick
import QtQuick.Controls

MenuItem {
    id: control

    property string shortcutText: ""
    property string glyph: ""
    property string toolTip: ""
    property bool rightToLeft: false
    readonly property alias actionLabel: actionLabel
    readonly property alias shortcutLabel: shortcutLabel

    implicitWidth: 230
    implicitHeight: 42
    leftPadding: AppTheme.spacingMedium
    rightPadding: AppTheme.spacingMedium
    hoverEnabled: true
    opacity: enabled ? 1 : 0.42

    contentItem: Item {
        width: control.availableWidth
        height: control.availableHeight
        implicitWidth: glyphLabel.implicitWidth + actionLabel.implicitWidth + shortcutLabel.implicitWidth + AppTheme.spacingLarge * 2
        implicitHeight: Math.max(glyphLabel.implicitHeight, actionLabel.implicitHeight, shortcutLabel.implicitHeight)

        Label {
            id: glyphLabel
            x: control.rightToLeft ? parent.width - width : 0
            width: visible ? implicitWidth : 0
            height: parent.height
            visible: control.glyph !== ""
            text: control.glyph
            font.family: AppTheme.iconFontFamily
            font.pixelSize: AppTheme.fontControl
            color: AppTheme.foreground
            horizontalAlignment: control.rightToLeft ? Text.AlignRight : Text.AlignLeft
            verticalAlignment: Text.AlignVCenter
        }

        Label {
            id: actionLabel
            x: control.rightToLeft
                ? (shortcutLabel.visible ? shortcutLabel.width + AppTheme.spacingLarge : 0)
                : (glyphLabel.visible ? glyphLabel.width + AppTheme.spacingSmall : 0)
            width: Math.max(0, parent.width - (shortcutLabel.visible
                ? shortcutLabel.width + AppTheme.spacingLarge
                : 0) - (glyphLabel.visible ? glyphLabel.width + AppTheme.spacingSmall : 0))
            height: parent.height
            text: control.text
            font.family: AppTheme.fontFamily
            font.pixelSize: AppTheme.fontControl
            color: AppTheme.foreground
            horizontalAlignment: control.rightToLeft ? Text.AlignRight : Text.AlignLeft
            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideRight
        }

        Label {
            id: shortcutLabel
            x: control.rightToLeft ? 0 : parent.width - width
            width: visible ? implicitWidth : 0
            height: parent.height
            visible: control.shortcutText !== ""
            text: control.shortcutText
            font.family: AppTheme.fontFamily
            font.pixelSize: AppTheme.fontCaption
            color: AppTheme.muted
        }
    }

    background: Rectangle {
        color: !control.enabled
            ? AppTheme.withAlpha(AppTheme.foreground, AppTheme.darkMode ? 0.045 : 0.035)
            : control.highlighted
                ? AppTheme.surfaceRaised
                : "transparent"
        border.color: !control.enabled
            ? AppTheme.withAlpha(AppTheme.border, 0.65)
            : "transparent"
        border.width: !control.enabled ? AppTheme.borderWidth : 0
        radius: AppTheme.cornerRadiusSmall
    }

    Accessible.name: control.text

    ToolTip.visible: control.toolTip !== "" && control.hovered
    ToolTip.text: control.toolTip
}
