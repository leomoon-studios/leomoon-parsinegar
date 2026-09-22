import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Control {
    id: control

    property string message: ""
    property string idleMessage: ""
    property string level: "info"
    property bool busy: false
    readonly property bool idle: !busy && message === "" && idleMessage !== ""
    readonly property string displayMessage: idle ? idleMessage : message
    readonly property color statusColor: idle ? AppTheme.muted
        : level === "error" ? AppTheme.urgent
        : level === "warning" ? AppTheme.warning
        : level === "success" ? AppTheme.success
        : AppTheme.accent

    visible: busy || message !== "" || idleMessage !== ""
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
            text: control.displayMessage
            font.family: AppTheme.fontFamily
            font.pixelSize: AppTheme.fontCaption
            color: control.statusColor
            wrapMode: Text.Wrap
        }
    }

    background: Rectangle {
        color: control.idle ? AppTheme.surface
            : AppTheme.withAlpha(control.statusColor, AppTheme.darkMode ? 0.12 : 0.08)
        border.color: control.idle ? AppTheme.border
            : AppTheme.withAlpha(control.statusColor, 0.45)
        border.width: AppTheme.borderWidth
        radius: AppTheme.cornerRadiusSmall
    }
}
