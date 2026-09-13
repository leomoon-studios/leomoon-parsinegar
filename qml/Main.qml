import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

ApplicationWindow {
    id: root
    objectName: "mainWindow"

    readonly property bool bundledFontReady: typography.ready
    readonly property bool bundledFontError: typography.failed
    readonly property alias editorController: controller
    required property var clipboardService

    width: 900
    height: 720
    minimumWidth: 480
    minimumHeight: 420
    visible: true
    title: qsTr("ParsiNegar Desktop")
    color: AppTheme.background

    Typography {
        id: typography
        onFamilyChanged: AppTheme.fontFamily = family
    }

    EditorController {
        id: controller
        objectName: "editorController"
        clipboardBridge: root.clipboardService
    }

    Component.onCompleted: {
        AppTheme.fontFamily = typography.family
        editorPage.focusEditor()
    }

    ColumnLayout {
        id: shell
        objectName: "contentLayout"
        anchors.fill: parent
        anchors.margins: AppTheme.spacingLarge
        spacing: AppTheme.spacingLarge

        RowLayout {
            Layout.fillWidth: true
            spacing: AppTheme.spacingMedium

            Rectangle {
                implicitWidth: 44
                implicitHeight: 44
                radius: AppTheme.cornerRadius
                color: AppTheme.accent

                LetterBadge {
                    anchors.centerIn: parent
                    typography: typography
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 0

                Label {
                    Layout.fillWidth: true
                    text: qsTr("ParsiNegar Desktop")
                    font.family: AppTheme.fontFamily
                    font.pixelSize: AppTheme.fontHeading
                    font.weight: Font.DemiBold
                    color: AppTheme.foreground
                    elide: Text.ElideRight
                }

                Label {
                    Layout.fillWidth: true
                    text: qsTr("Persian text tools for every desktop")
                    font.family: AppTheme.fontFamily
                    font.pixelSize: AppTheme.fontCaption
                    color: AppTheme.muted
                    elide: Text.ElideRight
                }
            }

            AppButton {
                id: themeButton
                objectName: "themeButton"
                text: AppTheme.darkMode ? qsTr("Light theme") : qsTr("Dark theme")
                Accessible.name: text
                onClicked: AppTheme.darkMode = !AppTheme.darkMode
            }
        }

        EditorPage {
            id: editorPage
            objectName: "editorPage"
            Layout.fillWidth: true
            Layout.fillHeight: true
            controller: controller
            typography: typography
        }
    }
}
