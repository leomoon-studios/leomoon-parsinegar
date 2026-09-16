import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs as Dialogs

ApplicationWindow {
    id: root
    objectName: "mainWindow"

    readonly property bool bundledFontReady: typography.ready
    readonly property bool bundledFontError: typography.failed
    readonly property bool bundledIconFontReady: AppTheme.iconFontReady
    readonly property bool bundledIconFontError: AppTheme.iconFontFailed
    readonly property alias editorController: controller
    readonly property alias svgExportController: exportController
    required property var clipboardService
    property var settingsService: null
    property var fileService: null
    property var textDirectionService: null
    property bool allowApplicationClose: false
    readonly property bool rightToLeft: controller.uiLanguage === "fa" || controller.uiLanguage === "ar"

    width: 900
    height: 720
    minimumWidth: 640
    minimumHeight: 450
    visible: true
    title: controller.windowTitle
    color: AppTheme.background

    onClosing: function(close) {
        if (allowApplicationClose)
            return
        close.accepted = false
        controller.requestApplicationClose()
    }

    function togglePage(target) {
        if (controller.page === target) {
            if (target === "settings")
                settingsPage.closeGroup()
            if (target === "export")
                controller.closeExport()
            else if (target === "tools")
                controller.closeTextTools()
            else if (target === "help")
                controller.closeHelp()
            else
                controller.closeSettings()
            Qt.callLater(editorPage.focusEditor)
            return
        }

        if (target === "settings") {
            settingsPage.closeGroup()
            controller.openSettings()
        } else if (target === "export") {
            controller.openExport()
        } else if (target === "tools") {
            controller.openTextTools()
        } else if (target === "help") {
            controller.openHelp()
        }
        Qt.callLater(headerBackButton.forceActiveFocus)
    }

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

    SvgCurveExportController {
        id: exportController
        objectName: "svgExportController"
        fileBridge: root.fileService
    }

    Connections {
        target: controller

        function onOpenDocumentDialogRequested() {
            openDocumentDialog.open()
        }

        function onSaveDocumentDialogRequested() {
            saveDocumentDialog.open()
        }

        function onUnsavedChangesRequested() {
            unsavedChangesDialog.open()
        }

        function onApplicationCloseApproved() {
            root.allowApplicationClose = true
            Qt.callLater(root.close)
        }
    }

    Shortcut {
        sequences: [StandardKey.New]
        context: Qt.WindowShortcut
        enabled: controller.page === "editor" && !controller.busy && !exportController.busy
        onActivated: controller.newDocument()
    }

    Shortcut {
        sequences: [StandardKey.Open]
        context: Qt.WindowShortcut
        enabled: controller.page === "editor" && !controller.busy && !exportController.busy
        onActivated: controller.openDocument()
    }

    Shortcut {
        sequences: [StandardKey.Save]
        context: Qt.WindowShortcut
        enabled: controller.page === "editor" && controller.documentDirty && !controller.busy && !exportController.busy
        onActivated: controller.saveDocument()
    }

    Shortcut {
        sequences: [StandardKey.SaveAs]
        context: Qt.WindowShortcut
        enabled: controller.page === "editor" && !controller.busy && !exportController.busy
        onActivated: controller.saveDocumentAs()
    }

    Shortcut {
        objectName: "convertShortcut"
        sequences: ["Ctrl+Return", "Ctrl+Enter"]
        context: Qt.WindowShortcut
        enabled: controller.page === "editor" && controller.settingsReady
            && !controller.busy && !exportController.busy && typography.ready
        onActivated: {
            controller.convertAndCopy()
            editorPage.focusEditor()
        }
    }

    Shortcut {
        objectName: "settingsShortcut"
        sequence: "Ctrl+,"
        context: Qt.WindowShortcut
        enabled: controller.settingsReady && !controller.busy && !exportController.busy
        onActivated: root.togglePage("settings")
    }

    Shortcut {
        objectName: "textToolsShortcut"
        sequence: "Ctrl+T"
        context: Qt.WindowShortcut
        enabled: controller.settingsReady && !controller.busy && !exportController.busy
        onActivated: root.togglePage("tools")
    }

    Shortcut {
        objectName: "exportShortcut"
        sequence: "Ctrl+E"
        context: Qt.WindowShortcut
        enabled: controller.settingsReady && !controller.busy && !exportController.busy
        onActivated: root.togglePage("export")
    }

    Shortcut {
        objectName: "helpShortcut"
        sequence: "Ctrl+H"
        context: Qt.WindowShortcut
        enabled: controller.settingsReady && !controller.busy && !exportController.busy
        onActivated: root.togglePage("help")
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
            LayoutMirroring.enabled: root.rightToLeft
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
                spacing: AppTheme.spacingSmall
                LayoutMirroring.enabled: root.rightToLeft
                LayoutMirroring.childrenInherit: true

                IconButton {
                    id: headerBackButton
                    objectName: "headerBackButton"
                    visible: controller.page !== "editor"
                    enabled: visible && (controller.page !== "export" || !exportController.busy)
                    glyph: root.rightToLeft ? AppTheme.iconForward : AppTheme.iconBack
                    toolTip: controller.uiText("button.back")
                    onClicked: {
                        if (controller.page === "export") {
                            controller.closeExport()
                        } else if (controller.page === "tools") {
                            controller.closeTextTools()
                        } else if (controller.page === "help") {
                            controller.closeHelp()
                        } else if (settingsPage.ligatureGroupId !== "") {
                            settingsPage.closeGroup()
                        } else {
                            controller.closeSettings()
                        }
                    }
                }

                IconButton {
                    id: documentButton
                    objectName: "documentButton"
                    visible: controller.page === "editor"
                    glyph: AppTheme.iconDocument
                    toolTip: controller.uiText("document.menu")
                    enabled: controller.settingsReady && !controller.busy && !exportController.busy
                    onClicked: documentMenu.popup(documentButton,
                        root.rightToLeft ? documentButton.width - documentMenu.width : 0,
                        documentButton.height + AppTheme.spacingSmall)
                }

                IconButton {
                    id: undoButton
                    objectName: "undoButton"
                    visible: controller.page === "editor"
                    glyph: AppTheme.iconUndo
                    toolTip: controller.uiText("history.undo")
                    enabled: controller.canUndo && !controller.busy && !exportController.busy
                    onClicked: {
                        controller.undoSourceEdit()
                        editorPage.focusEditor()
                    }
                }

                IconButton {
                    id: redoButton
                    objectName: "redoButton"
                    visible: controller.page === "editor"
                    glyph: AppTheme.iconRedo
                    toolTip: controller.uiText("history.redo")
                    enabled: controller.canRedo && !controller.busy && !exportController.busy
                    onClicked: {
                        controller.redoSourceEdit()
                        editorPage.focusEditor()
                    }
                }

                IconButton {
                    id: exportButton
                    objectName: "exportButton"
                    visible: controller.page === "editor"
                    glyph: AppTheme.iconExport
                    toolTip: controller.uiText("export.title") + " (Ctrl+E)"
                    enabled: controller.settingsReady && !controller.busy && !exportController.busy
                    onClicked: controller.openExport()
                }

                IconButton {
                    id: textToolsButton
                    objectName: "textToolsButton"
                    visible: controller.page === "editor"
                    glyph: AppTheme.iconTools
                    toolTip: controller.uiText("tools.title") + " (Ctrl+T)"
                    enabled: controller.settingsReady && !controller.busy && !exportController.busy
                    onClicked: controller.openTextTools()
                }

                IconButton {
                    id: settingsButton
                    objectName: "settingsButton"
                    visible: controller.page === "editor"
                    glyph: AppTheme.iconSettings
                    toolTip: controller.uiText("button.settings") + " (Ctrl+,)"
                    enabled: controller.settingsReady && !controller.busy
                    onClicked: controller.openSettings()
                }

                IconButton {
                    id: helpButton
                    objectName: "helpButton"
                    visible: controller.page === "editor"
                    glyph: AppTheme.iconHelp
                    toolTip: controller.uiText("help.title") + " (Ctrl+H)"
                    enabled: controller.settingsReady && !controller.busy && !exportController.busy
                    onClicked: controller.openHelp()
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
            navigationBackButton: headerBackButton
        }

        HelpPage {
            id: helpPage
            objectName: "helpPage"
            Layout.fillWidth: true
            Layout.fillHeight: true
            visible: controller.page === "help"
            enabled: visible
            controller: controller
            typography: typography
            settingsFilePath: root.settingsService
                && typeof root.settingsService.settingsFilePath === "string"
                ? root.settingsService.settingsFilePath : ""
        }

        TextToolsPage {
            id: textToolsPage
            objectName: "textToolsPage"
            Layout.fillWidth: true
            Layout.fillHeight: true
            visible: controller.page === "tools"
            enabled: visible
            controller: controller
            typography: typography
        }

        ExportPage {
            id: exportPage
            objectName: "exportPage"
            Layout.fillWidth: true
            Layout.fillHeight: true
            visible: controller.page === "export"
            enabled: visible
            controller: controller
            exportController: exportController
            fileBridge: root.fileService
            typography: typography
        }
    }

    DocumentMenu {
        id: documentMenu
        controller: controller
    }

    Dialogs.FileDialog {
        id: openDocumentDialog
        title: controller.uiText("document.open")
        fileMode: Dialogs.FileDialog.OpenFile
        nameFilters: ["Text files (*.txt)", "All files (*)"]
        onAccepted: controller.openDocumentUrl(selectedFile)
        onRejected: controller.cancelOpenDocumentDialog()
    }

    Dialogs.FileDialog {
        id: saveDocumentDialog
        title: controller.uiText("document.saveAs")
        fileMode: Dialogs.FileDialog.SaveFile
        defaultSuffix: "txt"
        nameFilters: ["Text files (*.txt)", "All files (*)"]
        onAccepted: controller.saveDocumentAsUrl(selectedFile)
        onRejected: controller.cancelSaveDocumentDialog()
    }

    Dialog {
        id: unsavedChangesDialog
        objectName: "unsavedChangesDialog"
        anchors.centerIn: parent
        width: Math.min(480, root.width - AppTheme.spacingXLarge * 2)
        modal: true
        closePolicy: Popup.NoAutoClose
        title: controller.uiText("document.unsavedTitle")
        standardButtons: Dialog.NoButton

        background: Rectangle {
            color: AppTheme.surface
            border.color: AppTheme.border
            border.width: AppTheme.borderWidth
            radius: AppTheme.cornerRadiusLarge
        }

        contentItem: ColumnLayout {
            spacing: AppTheme.spacingLarge
            LayoutMirroring.enabled: root.rightToLeft
            LayoutMirroring.childrenInherit: true

            Label {
                Layout.fillWidth: true
                text: controller.uiText("document.unsavedMessage").arg(controller.documentDisplayName)
                wrapMode: Text.Wrap
                font.family: AppTheme.fontFamily
                font.pixelSize: AppTheme.fontBody
                color: AppTheme.foreground
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: AppTheme.spacingSmall

                AppButton {
                    objectName: "discardUnsavedButton"
                    text: controller.uiText("document.discard")
                    onClicked: {
                        unsavedChangesDialog.close()
                        controller.resolveUnsavedChanges("discard")
                    }
                }

                Item { Layout.fillWidth: true }

                AppButton {
                    objectName: "cancelUnsavedButton"
                    text: controller.uiText("button.cancel")
                    onClicked: {
                        unsavedChangesDialog.close()
                        controller.resolveUnsavedChanges("cancel")
                    }
                }

                AppButton {
                    objectName: "saveUnsavedButton"
                    text: controller.uiText("document.save")
                    accent: true
                    onClicked: {
                        unsavedChangesDialog.close()
                        controller.resolveUnsavedChanges("save")
                    }
                }
            }
        }
    }

}
