import QtQuick
import QtQuick.Controls

TextField {
    id: control

    property real minimumValue: 0
    property real maximumValue: 1000000
    readonly property bool acceptableNumber: acceptableInput && text.trim() !== ""
    readonly property bool focusIndicatorVisible: activeFocus

    focusPolicy: Qt.StrongFocus
    selectByMouse: true
    horizontalAlignment: TextInput.AlignLeft
    inputMethodHints: Qt.ImhFormattedNumbersOnly
    implicitHeight: 42
    leftPadding: AppTheme.spacingMedium
    rightPadding: AppTheme.spacingMedium
    font.family: AppTheme.fontFamily
    font.pixelSize: AppTheme.fontControl
    color: AppTheme.foreground
    placeholderTextColor: AppTheme.muted
    selectionColor: AppTheme.accent
    selectedTextColor: AppTheme.accentText

    validator: DoubleValidator {
        bottom: control.minimumValue
        top: control.maximumValue
        notation: DoubleValidator.StandardNotation
    }

    background: Rectangle {
        color: AppTheme.surface
        border.color: control.focusIndicatorVisible ? AppTheme.focus : control.acceptableInput ? AppTheme.border : AppTheme.urgent
        border.width: control.focusIndicatorVisible ? AppTheme.focusBorderWidth : AppTheme.borderWidth
        radius: AppTheme.cornerRadius
    }
}
