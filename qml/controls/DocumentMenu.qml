import QtQuick
import QtQuick.Controls

Menu {
    id: root

    required property var controller
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
}
