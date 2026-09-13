import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Button {
    id: control

    property string title: ""
    property string description: ""
    property bool selected: false
    readonly property bool focusIndicatorVisible: visualFocus

    hoverEnabled: true
    focusPolicy: Qt.StrongFocus
    implicitHeight: contentItem.implicitHeight + topPadding + bottomPadding
    leftPadding: AppTheme.spacingLarge
    rightPadding: AppTheme.spacingLarge
    topPadding: AppTheme.spacingSmall
    bottomPadding: AppTheme.spacingSmall
    opacity: enabled ? 1 : 0.5
    Accessible.role: Accessible.RadioButton
    Accessible.name: title
    Accessible.description: description
    Accessible.checked: selected

    contentItem: RowLayout {
        spacing: AppTheme.spacingMedium

        Rectangle {
            Layout.alignment: Qt.AlignVCenter
            implicitWidth: 18
            implicitHeight: 18
            radius: width / 2
            color: "transparent"
            border.color: control.selected ? AppTheme.accent : AppTheme.muted
            border.width: control.selected ? AppTheme.focusBorderWidth : AppTheme.borderWidth

            Rectangle {
                anchors.centerIn: parent
                width: 8
                height: 8
                radius: width / 2
                visible: control.selected
                color: AppTheme.accent
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
            spacing: AppTheme.spacingTiny

            Label {
                Layout.fillWidth: true
                text: control.title
                font.family: AppTheme.fontFamily
                font.pixelSize: AppTheme.fontBody
                font.weight: Font.DemiBold
                color: AppTheme.foreground
                wrapMode: Text.NoWrap
                maximumLineCount: 1
                elide: Text.ElideRight
            }

            Label {
                id: descriptionLabel
                objectName: "descriptionLabel"
                Layout.fillWidth: true
                text: control.description
                font.family: AppTheme.fontFamily
                font.pixelSize: AppTheme.fontCaption
                color: AppTheme.muted
                wrapMode: Text.NoWrap
                maximumLineCount: 1
                elide: Text.ElideRight
            }
        }
    }

    ToolTip.visible: hovered && descriptionLabel.truncated
    ToolTip.delay: 500
    ToolTip.text: description

    background: Rectangle {
        color: control.selected
            ? AppTheme.withAlpha(AppTheme.accent, AppTheme.darkMode ? 0.14 : 0.09)
            : control.down || control.hovered
                ? AppTheme.surfaceRaised
                : AppTheme.withAlpha(AppTheme.foreground, AppTheme.darkMode ? 0.035 : 0.02)
        border.color: control.visualFocus ? AppTheme.focus : control.selected ? AppTheme.accent : AppTheme.border
        border.width: control.visualFocus || control.selected ? AppTheme.focusBorderWidth : AppTheme.borderWidth
        radius: AppTheme.cornerRadius
    }
}
