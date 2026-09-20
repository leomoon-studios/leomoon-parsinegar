import QtQuick
import QtQuick.Controls

Menu {
    id: root

    required property var controller
    required property var editorPage
    property bool exportBusy: false
    readonly property bool rightToLeft: controller.uiLanguage === "fa" || controller.uiLanguage === "ar"

    objectName: "documentMenu"
    width: 230
    topPadding: AppTheme.spacingSmall
    bottomPadding: AppTheme.spacingSmall
    leftPadding: AppTheme.spacingSmall
    rightPadding: AppTheme.spacingSmall
    modal: true
    dim: false
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

    background: Rectangle {
        color: AppTheme.surface
        border.color: AppTheme.border
        border.width: AppTheme.borderWidth
        radius: AppTheme.cornerRadius
    }

    AppMenuItem {
        objectName: "newDocumentMenuItem"
        text: root.controller.uiText("document.new")
        shortcutText: "Ctrl+N"
        rightToLeft: root.rightToLeft
        enabled: !root.controller.busy
        onTriggered: root.controller.newDocument()
    }

    AppMenuItem {
        objectName: "openDocumentMenuItem"
        text: root.controller.uiText("document.open")
        shortcutText: "Ctrl+O"
        rightToLeft: root.rightToLeft
        enabled: !root.controller.busy
        onTriggered: root.controller.openDocument()
    }

    MenuSeparator { }

    AppMenuItem {
        objectName: "saveDocumentMenuItem"
        text: root.controller.uiText("document.save")
        shortcutText: "Ctrl+S"
        rightToLeft: root.rightToLeft
        enabled: root.controller.documentDirty && !root.controller.busy
        onTriggered: root.controller.saveDocument()
    }

    AppMenuItem {
        objectName: "saveAsDocumentMenuItem"
        text: root.controller.uiText("document.saveAs")
        shortcutText: "Ctrl+Shift+S"
        rightToLeft: root.rightToLeft
        enabled: !root.controller.busy
        onTriggered: root.controller.saveDocumentAs()
    }

    MenuSeparator { }

    AppMenuItem {
        objectName: "undoDocumentMenuItem"
        text: root.controller.uiText("history.undo")
        glyph: AppTheme.iconUndo
        toolTip: root.controller.uiText("history.undo")
        shortcutText: "Ctrl+Z"
        rightToLeft: root.rightToLeft
        enabled: root.controller.canUndo && !root.controller.busy && !root.exportBusy
        onTriggered: {
            if (root.controller.undoSourceEdit())
                Qt.callLater(root.editorPage.focusEditor)
        }
    }

    AppMenuItem {
        objectName: "redoDocumentMenuItem"
        text: root.controller.uiText("history.redo")
        glyph: AppTheme.iconRedo
        toolTip: root.controller.uiText("history.redo")
        shortcutText: "Ctrl+Y"
        rightToLeft: root.rightToLeft
        enabled: root.controller.canRedo && !root.controller.busy && !root.exportBusy
        onTriggered: {
            if (root.controller.redoSourceEdit())
                Qt.callLater(root.editorPage.focusEditor)
        }
    }
}
