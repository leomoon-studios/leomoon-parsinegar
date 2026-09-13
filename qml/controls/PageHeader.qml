import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Control {
    id: control

    property string title: ""
    property string subtitle: ""

    implicitHeight: contentItem.implicitHeight
    padding: 0

    contentItem: ColumnLayout {
        spacing: AppTheme.spacingTiny

        Label {
            Layout.fillWidth: true
            text: control.title
            font.family: AppTheme.fontFamily
            font.pixelSize: AppTheme.fontHeading
            font.weight: Font.DemiBold
            color: AppTheme.foreground
            wrapMode: Text.Wrap
        }

        Label {
            Layout.fillWidth: true
            visible: text !== ""
            text: control.subtitle
            font.family: AppTheme.fontFamily
            font.pixelSize: AppTheme.fontBody
            color: AppTheme.muted
            wrapMode: Text.Wrap
        }
    }
}
