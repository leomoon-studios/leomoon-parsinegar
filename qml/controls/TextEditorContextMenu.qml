import QtQuick
import QtQuick.Controls

Menu {
    id: root

    required property var editor
    required property var controller
    property bool rightToLeft: false
    property real requestedX: 0
    property real requestedY: 0

    objectName: "editorContextMenu"
    width: 224
    topPadding: AppTheme.spacingSmall
    bottomPadding: AppTheme.spacingSmall
    leftPadding: AppTheme.spacingSmall
    rightPadding: AppTheme.spacingSmall
    modal: false
    dim: false
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

    function openAt(item, positionX, positionY) {
        requestedX = positionX
        requestedY = positionY
        popup(item, positionX, positionY)
    }

    background: Rectangle {
        color: AppTheme.surface
        border.color: AppTheme.border
        border.width: AppTheme.borderWidth
        radius: AppTheme.cornerRadius
    }

    AppMenuItem {
        objectName: "contextUndoAction"
        text: root.controller.uiText("history.undo")
        shortcutText: "Ctrl+Z"
        rightToLeft: root.rightToLeft
        enabled: root.controller.canUndo
        onTriggered: {
            root.controller.undoSourceEdit()
            root.editor.forceActiveFocus()
        }
    }

    AppMenuItem {
        objectName: "contextRedoAction"
        text: root.controller.uiText("history.redo")
        shortcutText: "Ctrl+Y"
        rightToLeft: root.rightToLeft
        enabled: root.controller.canRedo
        onTriggered: {
            root.controller.redoSourceEdit()
            root.editor.forceActiveFocus()
        }
    }

    MenuSeparator { }

    AppMenuItem {
        objectName: "contextCutAction"
        text: root.controller.uiText("edit.cut")
        shortcutText: "Ctrl+X"
        rightToLeft: root.rightToLeft
        enabled: !root.editor.readOnly && root.editor.selectionStart !== root.editor.selectionEnd
        onTriggered: {
            root.editor.cut()
            root.editor.forceActiveFocus()
        }
    }

    AppMenuItem {
        objectName: "contextCopyAction"
        text: root.controller.uiText("edit.copy")
        shortcutText: "Ctrl+C"
        rightToLeft: root.rightToLeft
        enabled: root.editor.selectionStart !== root.editor.selectionEnd
        onTriggered: {
            root.editor.copy()
            root.editor.forceActiveFocus()
        }
    }

    AppMenuItem {
        objectName: "contextPasteAction"
        text: root.controller.uiText("edit.paste")
        shortcutText: "Ctrl+V"
        rightToLeft: root.rightToLeft
        enabled: !root.editor.readOnly && root.editor.canPaste
        onTriggered: {
            root.editor.paste()
            root.editor.forceActiveFocus()
        }
    }

    AppMenuItem {
        objectName: "contextDeleteAction"
        text: root.controller.uiText("edit.delete")
        shortcutText: "Del"
        rightToLeft: root.rightToLeft
        enabled: !root.editor.readOnly && root.editor.selectionStart !== root.editor.selectionEnd
        onTriggered: {
            root.editor.remove(root.editor.selectionStart, root.editor.selectionEnd)
            root.editor.forceActiveFocus()
        }
    }

    MenuSeparator { }

    AppMenuItem {
        objectName: "contextSelectAllAction"
        text: root.controller.uiText("edit.selectAll")
        shortcutText: "Ctrl+A"
        rightToLeft: root.rightToLeft
        enabled: root.editor.length > 0
        onTriggered: {
            root.editor.selectAll()
            root.editor.forceActiveFocus()
        }
    }
}
