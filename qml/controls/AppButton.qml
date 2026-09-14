import QtQuick
import QtQuick.Controls

Button {
    id: control

    property bool accent: false
    property bool selected: false
    property int textPixelSize: AppTheme.fontControl
    property int textWeight: Font.Medium
    readonly property bool focusIndicatorVisible: visualFocus

    hoverEnabled: true
    focusPolicy: Qt.StrongFocus
    implicitWidth: Math.max(96, contentItem.implicitWidth + leftPadding + rightPadding)
    implicitHeight: 42
    leftPadding: AppTheme.spacingLarge
    rightPadding: AppTheme.spacingLarge
    topPadding: AppTheme.spacingSmall
    bottomPadding: AppTheme.spacingSmall

    contentItem: Text {
        text: control.text
        font.family: AppTheme.fontFamily
        font.pixelSize: control.textPixelSize
        font.weight: control.textWeight
        color: control.accent ? AppTheme.accentText : AppTheme.foreground
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
    }

    background: Rectangle {
        color: control.accent
            ? (control.hovered ? AppTheme.accentHover : AppTheme.accent)
            : control.down || control.selected
                ? AppTheme.surfaceRaised
                : control.hovered
                    ? AppTheme.withAlpha(AppTheme.foreground, 0.08)
                    : AppTheme.surface
        border.color: control.visualFocus ? AppTheme.focus : control.selected ? AppTheme.accent : AppTheme.border
        border.width: control.visualFocus ? AppTheme.focusBorderWidth : AppTheme.borderWidth
        radius: AppTheme.cornerRadius
    }
}
