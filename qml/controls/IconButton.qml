import QtQuick
import QtQuick.Controls

Button {
    id: control

    property string glyph: ""
    property color glyphColor: AppTheme.foreground
    property string toolTip: ""
    property bool selected: false
    readonly property bool focusIndicatorVisible: visualFocus

    hoverEnabled: true
    focusPolicy: Qt.StrongFocus
    implicitWidth: 44
    implicitHeight: 44
    padding: 0
    opacity: enabled ? 1 : 0.45
    Accessible.name: toolTip

    contentItem: Text {
        text: control.glyph
        font.family: AppTheme.iconFontFamily
        font.pixelSize: 24
        font.weight: Font.Normal
        color: control.enabled ? control.glyphColor : AppTheme.muted
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }

    background: Rectangle {
        color: control.down || control.selected
            ? AppTheme.surfaceRaised
            : control.hovered
                ? AppTheme.withAlpha(AppTheme.foreground, 0.08)
                : AppTheme.surface
        border.color: !control.enabled
            ? AppTheme.withAlpha(AppTheme.border, 0.65)
            : control.visualFocus
                ? AppTheme.focus
                : control.selected
                    ? AppTheme.accent
                    : AppTheme.border
        border.width: control.visualFocus ? AppTheme.focusBorderWidth : AppTheme.borderWidth
        radius: AppTheme.cornerRadius
    }

    ToolTip.visible: hovered && toolTip !== ""
    ToolTip.delay: 500
    ToolTip.text: toolTip
}
