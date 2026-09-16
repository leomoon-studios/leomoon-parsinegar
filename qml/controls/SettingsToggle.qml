import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: control

    property string title: ""
    property string description: ""
    property bool checked: false
    readonly property alias toggleItem: toggle
    readonly property alias titleItem: titleLabel
    readonly property alias descriptionItem: descriptionLabel
    signal toggled(bool checked)

    property real leftPadding: AppTheme.spacingLarge
    property real rightPadding: AppTheme.spacingLarge
    property real topPadding: AppTheme.spacingMedium
    property real bottomPadding: AppTheme.spacingMedium
    implicitHeight: Math.max(toggle.implicitHeight, labels.implicitHeight)
        + topPadding + bottomPadding

    color: AppTheme.surface
    border.color: toggle.visualFocus ? AppTheme.focus : AppTheme.border
    border.width: toggle.visualFocus ? AppTheme.focusBorderWidth : AppTheme.borderWidth
    radius: AppTheme.cornerRadius

    Item {
        anchors.fill: parent
        anchors.leftMargin: control.leftPadding
        anchors.rightMargin: control.rightPadding
        anchors.topMargin: control.topPadding
        anchors.bottomMargin: control.bottomPadding

        Column {
            id: labels
            // Define the geometry once in LTR. LayoutMirroring swaps these
            // anchors for Persian, placing the labels to the switch's right.
            anchors.left: parent.left
            anchors.right: toggle.left
            anchors.rightMargin: AppTheme.spacingLarge
            anchors.verticalCenter: parent.verticalCenter
            spacing: AppTheme.spacingTiny

            Label {
                id: titleLabel
                width: parent.width
                text: control.title
                font.family: AppTheme.fontFamily
                font.pixelSize: AppTheme.fontBody
                font.weight: Font.DemiBold
                color: control.enabled ? AppTheme.foreground : AppTheme.muted
                // Logical left becomes effective right when the page is mirrored.
                horizontalAlignment: Text.AlignLeft
                wrapMode: Text.Wrap
            }

            Label {
                id: descriptionLabel
                width: parent.width
                visible: control.description !== ""
                text: control.description
                font.family: AppTheme.fontFamily
                font.pixelSize: AppTheme.fontCaption
                color: AppTheme.muted
                horizontalAlignment: Text.AlignLeft
                wrapMode: Text.Wrap
            }
        }

        AppToggle {
            id: toggle
            width: 42
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            text: ""
            checked: control.checked
            enabled: control.enabled
            Accessible.name: control.title
            Accessible.description: control.description
            onToggled: control.toggled(checked)
        }
    }
}
