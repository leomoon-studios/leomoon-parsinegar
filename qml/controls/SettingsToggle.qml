import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Control {
    id: control

    property string title: ""
    property string description: ""
    property bool checked: false
    readonly property alias toggleItem: toggle
    signal toggled(bool checked)

    implicitHeight: contentItem.implicitHeight
    leftPadding: 0
    rightPadding: 0
    topPadding: AppTheme.spacingTiny
    bottomPadding: AppTheme.spacingTiny

    contentItem: ColumnLayout {
        spacing: AppTheme.spacingTiny

        AppToggle {
            id: toggle
            Layout.fillWidth: true
            text: control.title
            checked: control.checked
            enabled: control.enabled
            Accessible.name: control.title
            Accessible.description: control.description
            onToggled: control.toggled(checked)
        }

        Label {
            Layout.fillWidth: true
            Layout.leftMargin: toggle.mirrored ? 0 : toggle.indicator.width + toggle.spacing
            Layout.rightMargin: toggle.mirrored ? toggle.indicator.width + toggle.spacing : 0
            visible: control.description !== ""
            text: control.description
            font.family: AppTheme.fontFamily
            font.pixelSize: AppTheme.fontCaption
            color: AppTheme.muted
            wrapMode: Text.Wrap
        }
    }
}
