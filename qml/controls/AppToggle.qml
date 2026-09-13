import QtQuick
import QtQuick.Controls

Switch {
    id: control

    hoverEnabled: true
    focusPolicy: Qt.StrongFocus
    spacing: AppTheme.spacingMedium
    implicitHeight: Math.max(38, contentItem.implicitHeight + topPadding + bottomPadding)
    topPadding: AppTheme.spacingSmall
    bottomPadding: AppTheme.spacingSmall

    indicator: Rectangle {
        implicitWidth: 42
        implicitHeight: 24
        x: control.mirrored ? control.width - width - control.rightPadding : control.leftPadding
        y: control.topPadding + (control.availableHeight - height) / 2
        radius: height / 2
        color: control.checked ? AppTheme.accent : AppTheme.surfaceRaised
        border.color: control.visualFocus ? AppTheme.focus : control.checked ? AppTheme.accent : AppTheme.border
        border.width: control.visualFocus ? AppTheme.focusBorderWidth : AppTheme.borderWidth

        Rectangle {
            width: 16
            height: 16
            radius: 8
            y: 4
            x: control.checked ? parent.width - width - 4 : 4
            color: control.checked ? AppTheme.accentText : AppTheme.muted

            Behavior on x {
                NumberAnimation { duration: 120 }
            }
        }
    }

    contentItem: Text {
        leftPadding: control.mirrored ? 0 : control.indicator.width + control.spacing
        rightPadding: control.mirrored ? control.indicator.width + control.spacing : 0
        text: control.text
        font.family: AppTheme.fontFamily
        font.pixelSize: AppTheme.fontBody
        color: control.enabled ? AppTheme.foreground : AppTheme.muted
        verticalAlignment: Text.AlignVCenter
        wrapMode: Text.Wrap
    }
}
