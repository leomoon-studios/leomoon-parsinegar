import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

MenuItem {
    id: control

    property string shortcutText: ""
    property bool rightToLeft: false

    implicitWidth: 230
    implicitHeight: 42
    leftPadding: AppTheme.spacingMedium
    rightPadding: AppTheme.spacingMedium
    hoverEnabled: true
    opacity: enabled ? 1 : 0.42

    contentItem: RowLayout {
        spacing: AppTheme.spacingLarge
        LayoutMirroring.enabled: control.rightToLeft
        LayoutMirroring.childrenInherit: true

        Label {
            Layout.fillWidth: true
            text: control.text
            font.family: AppTheme.fontFamily
            font.pixelSize: AppTheme.fontControl
            color: AppTheme.foreground
            horizontalAlignment: control.rightToLeft ? Text.AlignRight : Text.AlignLeft
        }

        Label {
            visible: text !== ""
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
}
