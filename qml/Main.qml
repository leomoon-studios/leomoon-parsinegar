import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

ApplicationWindow {
    id: root
    objectName: "mainWindow"

    readonly property bool bundledFontReady: typography.ready
    readonly property bool bundledFontError: typography.failed
    readonly property bool bundledIconFontReady: AppTheme.iconFontReady
    readonly property bool bundledIconFontError: AppTheme.iconFontFailed
    readonly property alias editorController: controller
    required property var clipboardService
    property var settingsService: null
    property var fileService: null
    property var textDirectionService: null

    width: 900
    height: 720
    minimumWidth: 640
    minimumHeight: 450
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
        settingsStore: root.settingsService
        fileBridge: root.fileService
    }

    Component.onCompleted: {
        AppTheme.fontFamily = typography.family
        if (controller.page === "editor")
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
            LayoutMirroring.enabled: controller.uiLanguage === "fa"
            LayoutMirroring.childrenInherit: true

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
                    text: controller.uiText("app.title")
                    font.family: AppTheme.fontFamily
                    font.pixelSize: AppTheme.fontHeading
                    font.weight: Font.DemiBold
                    color: AppTheme.foreground
                    elide: Text.ElideRight
                }

                Label {
                    Layout.fillWidth: true
                    text: controller.uiText("app.subtitle")
                    font.family: AppTheme.fontFamily
                    font.pixelSize: AppTheme.fontCaption
                    color: AppTheme.muted
                    elide: Text.ElideRight
                }
            }

            RowLayout {
                id: headerActions
                objectName: "headerActions"
                visible: controller.page === "editor"
                enabled: visible
                spacing: AppTheme.spacingSmall
                LayoutMirroring.enabled: false
                LayoutMirroring.childrenInherit: true

                IconButton {
                    id: settingsButton
                    objectName: "settingsButton"
                    glyph: AppTheme.iconSettings
                    toolTip: controller.uiText("button.settings")
                    enabled: controller.settingsReady && !controller.busy
                    onClicked: controller.openSettings()
                }

                IconButton {
                    id: themeButton
                    objectName: "themeButton"
                    glyph: AppTheme.darkMode ? AppTheme.iconLightMode : AppTheme.iconDarkMode
                    toolTip: AppTheme.darkMode ? controller.uiText("theme.light") : controller.uiText("theme.dark")
                    onClicked: AppTheme.darkMode = !AppTheme.darkMode
                }
            }
        }

        EditorPage {
            id: editorPage
            objectName: "editorPage"
            Layout.fillWidth: true
            Layout.fillHeight: true
            visible: controller.page === "editor"
            enabled: visible
            controller: controller
            typography: typography
            textDirectionService: root.textDirectionService
        }

        SettingsPage {
            id: settingsPage
            objectName: "settingsPage"
            Layout.fillWidth: true
            Layout.fillHeight: true
            visible: controller.page === "settings"
            enabled: visible
            controller: controller
            typography: typography
        }
    }
}
