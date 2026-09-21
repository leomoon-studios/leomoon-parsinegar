pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

FocusScope {
    id: root

    required property var controller
    required property Typography typography
    property var textDirectionService: null
    property bool syncingEditor: false
    property real heightDeficit: 0
    readonly property alias editorItem: editor
    readonly property alias editorScroll: editorScroll
    readonly property bool rightToLeft: controller.uiLanguage === "fa" || controller.uiLanguage === "ar"
    readonly property bool constrainedHeight: heightDeficit > 0.5
        || editorWorkspace.contentOverflow

    LayoutMirroring.enabled: rightToLeft
    LayoutMirroring.childrenInherit: true

    function uiText(key) {
        return controller.uiText(key)
    }

    function focusEditor() {
        editor.forceActiveFocus()
    }

    function insertOnScreenText(text) {
        var changed = controller.insertSourceText(text, editor.selectionStart, editor.selectionEnd)
        editor.forceActiveFocus()
        return changed
    }

    function deleteOnScreenBackward() {
        var changed = controller.deleteSourceBackward(editor.selectionStart, editor.selectionEnd)
        editor.forceActiveFocus()
        return changed
    }

    function insertOnScreenNewline() {
        return insertOnScreenText("\n")
    }

    function scrollWorkspaceBy(delta) {
        if (!constrainedHeight || editorWorkspace.scrollRange <= 0 || delta === 0)
            return false

        var offset = editorPageScroll.position * editorWorkspace.scrollContentHeight
        var nextOffset = Math.max(0,
            Math.min(editorWorkspace.scrollRange, offset - delta))
        editorPageScroll.position = nextOffset / editorWorkspace.scrollContentHeight
        return nextOffset !== offset
    }

    function pastePlainText() {
        if (controller.clipboardBridge === null
                || typeof controller.clipboardBridge.readText !== "function")
            return false

        var clipboardText = controller.clipboardBridge.readText()
        if (clipboardText === undefined || clipboardText === null || clipboardText === "")
            return false

        var source = textDirectionService !== null
            ? textDirectionService.plainText(editor.textDocument)
            : editor.text
        var selectionStart = Math.min(editor.selectionStart, editor.selectionEnd)
        var selectionEnd = Math.max(editor.selectionStart, editor.selectionEnd)
        var pastedText = String(clipboardText)
        var cursor = selectionStart + pastedText.length

        controller.replaceSourceText(
            source.slice(0, selectionStart) + pastedText + source.slice(selectionEnd),
            cursor,
            cursor)
        editor.forceActiveFocus()
        return true
    }

    function updateParagraphDirections() {
        if (textDirectionService !== null)
            textDirectionService.applyAutomaticDirection(editor.textDocument)
    }

    function reportEditorSelection() {
        if (!syncingEditor)
            controller.updateSourceSelection(editor.cursorPosition, editor.selectionStart, editor.selectionEnd)
    }

    function restoreEditorSelection(cursor, anchor) {
        syncingEditor = true
        try {
            editor.cursorPosition = Math.max(0, Math.min(editor.length, anchor))
            if (cursor !== anchor)
                editor.moveCursorSelection(Math.max(0, Math.min(editor.length, cursor)), TextEdit.SelectCharacters)
        } finally {
            syncingEditor = false
        }
        reportEditorSelection()
    }

    function syncEditorFromController() {
        if (textDirectionService !== null) {
            if (textDirectionService.plainText(editor.textDocument) !== controller.sourceText) {
                syncingEditor = true
                try {
                    textDirectionService.setPlainText(editor.textDocument, controller.sourceText)
                } finally {
                    syncingEditor = false
                }
            }
        } else if (editor.text !== controller.sourceText) {
            syncingEditor = true
            try {
                editor.text = controller.sourceText
            } finally {
                syncingEditor = false
            }
        }
    }

    Component.onCompleted: {
        syncEditorFromController()
        updateParagraphDirections()
    }

    Connections {
        target: root.controller
        function onSourceTextChanged() {
            root.syncEditorFromController()
        }
        function onSourceHistoryRestored(cursor, anchor) {
            root.restoreEditorSelection(cursor, anchor)
        }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: AppTheme.spacingMedium

        Rectangle {
            id: editorWorkspace
            objectName: "editorWorkspace"
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.minimumHeight: 180
            clip: root.constrainedHeight
            radius: AppTheme.cornerRadiusLarge
            color: AppTheme.surface
            border.color: AppTheme.border
            border.width: AppTheme.borderWidth

            readonly property real contentMargin: AppTheme.spacingLarge
            readonly property real viewportHeight: Math.max(0, height - contentMargin * 2)
            readonly property real naturalContentHeight: sourceHeader.implicitHeight
                + editorScroll.Layout.minimumHeight
                + conversionActions.implicitHeight
                + editorContent.spacing * 2
                + (onScreenKeyboard.visible
                    ? onScreenKeyboard.implicitHeight + editorContent.spacing : 0)
            readonly property bool contentOverflow: naturalContentHeight > viewportHeight + 0.5
            readonly property real scrollContentHeight: root.constrainedHeight
                ? Math.max(viewportHeight + root.heightDeficit, naturalContentHeight)
                : viewportHeight
            readonly property real scrollRange: Math.max(0, scrollContentHeight - viewportHeight)
            readonly property real editorViewportX: editorContent.x + editorScroll.x
            readonly property real editorViewportY: editorContent.y + editorScroll.y
            readonly property real editorViewportRight: editorViewportX + editorScroll.width
            readonly property real editorViewportBottom: editorViewportY + editorScroll.height

            function handlePageWheel(wheel) {
                var delta = wheel.pixelDelta.y !== 0
                    ? wheel.pixelDelta.y : wheel.angleDelta.y / 2
                wheel.accepted = root.scrollWorkspaceBy(delta)
            }

            ColumnLayout {
                id: editorContent
                objectName: "editorPageContent"
                x: editorWorkspace.contentMargin
                y: editorWorkspace.contentMargin
                    - editorPageScroll.position * editorWorkspace.scrollContentHeight
                width: editorWorkspace.width - editorWorkspace.contentMargin * 2
                    - (editorPageScroll.visible ? editorPageScroll.width + AppTheme.spacingSmall : 0)
                height: editorWorkspace.scrollContentHeight
                spacing: AppTheme.spacingMedium

                RowLayout {
                    id: sourceHeader
                    Layout.fillWidth: true
                    spacing: AppTheme.spacingMedium

                    Label {
                        Layout.fillWidth: true
                        text: root.uiText("editor.source")
                        font.family: AppTheme.fontFamily
                        font.pixelSize: AppTheme.fontBody
                        font.weight: Font.DemiBold
                        color: AppTheme.foreground
                    }

                    Label {
                        text: root.uiText("editor.characterCount").arg(root.controller.sourceText.length).arg(root.controller.maximumTextLength)
                        horizontalAlignment: Text.AlignRight
                        font.family: AppTheme.fontFamily
                        font.pixelSize: AppTheme.fontCaption
                        color: root.controller.sourceText.length > root.controller.maximumTextLength ? AppTheme.urgent : AppTheme.muted
                    }
                }

                ScrollView {
                    id: editorScroll
                    objectName: "editorScroll"
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.minimumHeight: 64
                    clip: true
                    ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
                    ScrollBar.vertical.policy: ScrollBar.AsNeeded
                    LayoutMirroring.enabled: false
                    LayoutMirroring.childrenInherit: true

                    TextArea {
                        id: editor
                        objectName: "sourceEditor"
                        text: ""
                        onTextChanged: {
                            var source = root.textDirectionService !== null
                                ? root.textDirectionService.plainText(textDocument)
                                : text
                            if (root.controller.sourceText !== source)
                                root.controller.sourceText = source
                            if (!root.syncingEditor)
                                root.updateParagraphDirections()
                            root.reportEditorSelection()
                        }
                        onCursorPositionChanged: root.reportEditorSelection()
                        onSelectionStartChanged: root.reportEditorSelection()
                        onSelectionEndChanged: root.reportEditorSelection()
                        font.family: AppTheme.fontFamily
                        font.pixelSize: root.controller.editorFontSize
                        placeholderText: root.uiText("placeholder")
                        placeholderTextColor: AppTheme.muted
                        color: AppTheme.foreground
                        selectionColor: AppTheme.accent
                        selectedTextColor: AppTheme.accentText
                        cursorVisible: false
                        horizontalAlignment: length === 0 ? TextEdit.AlignRight : TextEdit.AlignLeft
                        wrapMode: TextEdit.Wrap
                        textFormat: root.textDirectionService !== null
                            ? TextEdit.RichText
                            : TextEdit.PlainText
                        selectByMouse: true
                        persistentSelection: true
                        padding: AppTheme.spacingMedium
                        Accessible.name: qsTr("Source text editor")

                        Keys.onPressed: function(event) {
                            var primaryModifier = Qt.platform.os === "osx" ? Qt.MetaModifier : Qt.ControlModifier
                            var hasPrimaryModifier = (event.modifiers & primaryModifier) !== 0
                            var hasShift = (event.modifiers & Qt.ShiftModifier) !== 0
                            var undoShortcut = event.matches(StandardKey.Undo)
                                || (hasPrimaryModifier && !hasShift && event.key === Qt.Key_Z)
                            var redoShortcut = event.matches(StandardKey.Redo)
                                || (hasPrimaryModifier && !hasShift && event.key === Qt.Key_Y)
                                || (hasPrimaryModifier && hasShift && event.key === Qt.Key_Z)

                            if (undoShortcut) {
                                root.controller.undoSourceEdit()
                                event.accepted = true
                            } else if (redoShortcut) {
                                root.controller.redoSourceEdit()
                                event.accepted = true
                            } else if (event.matches(StandardKey.Paste)
                                    || (hasPrimaryModifier && !hasShift && event.key === Qt.Key_V)) {
                                root.pastePlainText()
                                event.accepted = true
                            }
                        }

                        Rectangle {
                            id: editorCursor
                            objectName: "editorCursor"
                            x: editor.cursorRectangle.x
                            y: editor.cursorRectangle.y
                            width: Math.max(1, AppTheme.focusBorderWidth)
                            height: editor.cursorRectangle.height
                            color: AppTheme.foreground
                            visible: editor.activeFocus && editor.selectionStart === editor.selectionEnd
                            z: 1
                        }

                        background: Rectangle {
                            color: AppTheme.withAlpha(AppTheme.foreground, AppTheme.darkMode ? 0.035 : 0.02)
                            border.color: editor.activeFocus ? AppTheme.focus : AppTheme.border
                            border.width: editor.activeFocus ? AppTheme.focusBorderWidth : AppTheme.borderWidth
                            radius: AppTheme.cornerRadius
                        }

                        TextEditorContextMenu {
                            id: editorContextMenu
                            editor: editor
                            controller: root.controller
                            pasteHandler: root.pastePlainText
                            rightToLeft: root.rightToLeft
                        }

                        MouseArea {
                            id: contextMenuMouseArea
                            objectName: "editorContextMenuMouseArea"
                            anchors.fill: parent
                            acceptedButtons: Qt.RightButton
                            preventStealing: true
                            z: 2
                            onPressed: function(mouse) {
                                editor.forceActiveFocus()
                                editorContextMenu.openAt(editor, mouse.x, mouse.y)
                                mouse.accepted = true
                            }
                            onWheel: function(wheel) {
                                var primaryModifier = Qt.platform.os === "osx"
                                    ? Qt.MetaModifier : Qt.ControlModifier
                                if ((wheel.modifiers & primaryModifier) === 0) {
                                    wheel.accepted = false
                                    return
                                }
                                var delta = wheel.angleDelta.y !== 0
                                    ? wheel.angleDelta.y : wheel.pixelDelta.y
                                if (delta === 0) {
                                    wheel.accepted = false
                                    return
                                }
                                root.controller.adjustEditorFontSize(delta)
                                wheel.accepted = true
                            }
                        }
                    }
                }

                OnScreenKeyboard {
                    id: onScreenKeyboard
                    objectName: "onScreenKeyboard"
                    Layout.fillWidth: true
                    visible: root.controller.keyboardDrawerOpen
                    controller: root.controller
                    onTextRequested: function(text) { root.insertOnScreenText(text) }
                    onBackspaceRequested: root.deleteOnScreenBackward()
                    onNewlineRequested: root.insertOnScreenNewline()
                }

                RowLayout {
                    id: conversionActions
                    objectName: "conversionActions"
                    Layout.fillWidth: true
                    Layout.maximumHeight: implicitHeight
                    spacing: AppTheme.spacingMedium
                    layoutDirection: root.rightToLeft ? Qt.RightToLeft : Qt.LeftToRight
                    LayoutMirroring.enabled: false
                    LayoutMirroring.childrenInherit: false

                    ColumnLayout {
                        Layout.fillWidth: true
                        Layout.preferredWidth: 0
                        spacing: AppTheme.spacingSmall

                        ModeCard {
                            objectName: "unicodeButton"
                            Layout.fillWidth: true
                            LayoutMirroring.enabled: root.rightToLeft
                            LayoutMirroring.childrenInherit: true
                            title: root.uiText("mode.unicode")
                            description: root.uiText("mode.unicodeDescription")
                            selected: root.controller.conversionMode === "unicode"
                            onClicked: root.controller.setConversionMode("unicode")
                        }

                        ModeCard {
                            objectName: "compatibilityButton"
                            Layout.fillWidth: true
                            LayoutMirroring.enabled: root.rightToLeft
                            LayoutMirroring.childrenInherit: true
                            title: root.uiText("mode.compatibility")
                            description: root.uiText("mode.compatibilityDescription")
                            selected: root.controller.conversionMode === "compatibility"
                            enabled: !root.controller.hebrewProfile
                            onClicked: root.controller.setConversionMode("compatibility")
                        }
                    }

                    AppButton {
                        id: convertButton
                        objectName: "convertButton"
                        Layout.fillHeight: true
                        Layout.minimumWidth: 120
                        Layout.preferredWidth: 170
                        Layout.maximumWidth: 200
                        text: root.controller.busy ? root.uiText("status.converting") : root.uiText("button.convert")
                        textPixelSize: AppTheme.fontHeading
                        textWeight: Font.Bold
                        accent: true
                        enabled: !root.controller.busy && root.typography.ready
                        Accessible.name: root.uiText("button.convert")
                        onClicked: {
                            root.controller.convertAndCopy()
                            root.focusEditor()
                        }
                    }
                }
            }

            MouseArea {
                id: editorPageWheelTop
                objectName: "editorPageWheelTop"
                x: 0
                y: 0
                width: editorWorkspace.width
                height: Math.max(0, Math.min(editorWorkspace.height,
                    editorWorkspace.editorViewportY))
                enabled: root.constrainedHeight && editorWorkspace.scrollRange > 0
                acceptedButtons: Qt.NoButton
                z: 1
                onWheel: function(wheel) { editorWorkspace.handlePageWheel(wheel) }
            }

            MouseArea {
                id: editorPageWheelBottom
                objectName: "editorPageWheelBottom"
                x: 0
                y: Math.max(0, Math.min(editorWorkspace.height,
                    editorWorkspace.editorViewportBottom))
                width: editorWorkspace.width
                height: Math.max(0, editorWorkspace.height - y)
                enabled: root.constrainedHeight && editorWorkspace.scrollRange > 0
                acceptedButtons: Qt.NoButton
                z: 1
                onWheel: function(wheel) { editorWorkspace.handlePageWheel(wheel) }
            }

            MouseArea {
                id: editorPageWheelLeft
                objectName: "editorPageWheelLeft"
                x: 0
                y: Math.max(0, editorWorkspace.editorViewportY)
                width: Math.max(0, Math.min(editorWorkspace.width,
                    editorWorkspace.editorViewportX))
                height: Math.max(0, Math.min(editorWorkspace.height,
                    editorWorkspace.editorViewportBottom) - y)
                enabled: root.constrainedHeight && editorWorkspace.scrollRange > 0
                acceptedButtons: Qt.NoButton
                z: 1
                onWheel: function(wheel) { editorWorkspace.handlePageWheel(wheel) }
            }

            MouseArea {
                id: editorPageWheelRight
                objectName: "editorPageWheelRight"
                x: Math.max(0, Math.min(editorWorkspace.width,
                    editorWorkspace.editorViewportRight))
                y: Math.max(0, editorWorkspace.editorViewportY)
                width: Math.max(0, editorWorkspace.width - x)
                height: Math.max(0, Math.min(editorWorkspace.height,
                    editorWorkspace.editorViewportBottom) - y)
                enabled: root.constrainedHeight && editorWorkspace.scrollRange > 0
                acceptedButtons: Qt.NoButton
                z: 1
                onWheel: function(wheel) { editorWorkspace.handlePageWheel(wheel) }
            }

            HoverHandler {
                id: editorWorkspaceHover
                objectName: "editorWorkspaceHover"
                acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
            }

            ScrollBar {
                id: editorPageScroll
                objectName: "editorPageScroll"
                anchors.top: parent.top
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                anchors.topMargin: editorWorkspace.contentMargin
                anchors.rightMargin: AppTheme.spacingSmall
                anchors.bottomMargin: editorWorkspace.contentMargin
                z: 2
                orientation: Qt.Vertical
                policy: root.constrainedHeight ? ScrollBar.AsNeeded : ScrollBar.AlwaysOff
                active: editorWorkspaceHover.hovered || hovered || pressed
                size: editorWorkspace.scrollContentHeight > 0
                    ? Math.min(1, editorWorkspace.viewportHeight / editorWorkspace.scrollContentHeight)
                    : 1
                visible: policy !== ScrollBar.AlwaysOff && size < 1
                onVisibleChanged: {
                    if (!visible)
                        position = 0
                }
            }
        }

        Item {
            id: statusSlot
            objectName: "statusSlot"
            Layout.fillWidth: true
            Layout.minimumHeight: 44
            Layout.preferredHeight: 44
            Layout.maximumHeight: 44

            StatusMessage {
                id: conversionStatus
                objectName: "conversionStatus"
                anchors.fill: parent
                message: root.controller.statusText !== "" || root.controller.busy
                    ? root.controller.statusText
                    : root.controller.settingsStatusText
                level: root.controller.statusText !== "" || root.controller.busy
                    ? root.controller.statusLevel
                    : root.controller.settingsStatusLevel
                busy: root.controller.busy
            }
        }
    }
}
