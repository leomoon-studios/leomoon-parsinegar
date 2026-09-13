import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Control {
    id: control

    property string message: ""
    property string level: "info"
    property bool busy: false
    readonly property color statusColor: level === "error" ? AppTheme.urgent
        : level === "warning" ? AppTheme.warning
        : level === "success" ? AppTheme.success
        : AppTheme.accent

    visible: busy || message !== ""
    implicitHeight: contentItem.implicitHeight + topPadding + bottomPadding
    leftPadding: AppTheme.spacingMedium
    rightPadding: AppTheme.spacingMedium
    topPadding: AppTheme.spacingSmall
    bottomPadding: AppTheme.spacingSmall

    contentItem: RowLayout {
        spacing: AppTheme.spacingSmall

        BusySpinner {
            running: control.busy
            foreground: control.statusColor
            Layout.alignment: Qt.AlignVCenter
        }

        Label {
            Layout.fillWidth: true
            text: control.message
            font.family: AppTheme.fontFamily
            font.pixelSize: AppTheme.fontCaption
            color: control.statusColor
            wrapMode: Text.Wrap
        }
    }

    background: Rectangle {
        color: AppTheme.withAlpha(control.statusColor, AppTheme.darkMode ? 0.12 : 0.08)
        border.color: AppTheme.withAlpha(control.statusColor, 0.45)
        border.width: AppTheme.borderWidth
        radius: AppTheme.cornerRadiusSmall
    }
}
