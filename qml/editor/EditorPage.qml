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
    readonly property alias editorItem: editor
    readonly property alias editorScroll: editorScroll

    LayoutMirroring.enabled: controller.uiLanguage === "fa"
    LayoutMirroring.childrenInherit: true

    function uiText(key) {
        return controller.uiText(key)
    }

    function focusEditor() {
        editor.forceActiveFocus()
    }

    function updateParagraphDirections() {
        if (textDirectionService !== null)
            textDirectionService.applyAutomaticDirection(editor.textDocument)
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
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: AppTheme.spacingMedium

        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.minimumHeight: 180
            radius: AppTheme.cornerRadiusLarge
            color: AppTheme.surface
            border.color: AppTheme.border
            border.width: AppTheme.borderWidth

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: AppTheme.spacingLarge
                spacing: AppTheme.spacingMedium

                RowLayout {
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
                        }
                        font.family: AppTheme.fontFamily
                        font.pixelSize: AppTheme.fontBody
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
                    }
                }

                RowLayout {
                    id: conversionActions
                    objectName: "conversionActions"
                    Layout.fillWidth: true
                    Layout.maximumHeight: implicitHeight
                    spacing: AppTheme.spacingMedium
                    layoutDirection: root.controller.uiLanguage === "fa" ? Qt.RightToLeft : Qt.LeftToRight
                    LayoutMirroring.enabled: false
                    LayoutMirroring.childrenInherit: false

                    ColumnLayout {
                        Layout.fillWidth: true
                        Layout.preferredWidth: 0
                        spacing: AppTheme.spacingSmall

                        ModeCard {
                            objectName: "unicodeButton"
                            Layout.fillWidth: true
                            LayoutMirroring.enabled: root.controller.uiLanguage === "fa"
                            LayoutMirroring.childrenInherit: true
                            title: root.uiText("mode.unicode")
                            description: root.uiText("mode.unicodeDescription")
                            selected: root.controller.conversionMode === "unicode"
                            onClicked: root.controller.setConversionMode("unicode")
                        }

                        ModeCard {
                            objectName: "compatibilityButton"
                            Layout.fillWidth: true
                            LayoutMirroring.enabled: root.controller.uiLanguage === "fa"
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
                        Layout.minimumWidth: 140
                        Layout.preferredWidth: 220
                        Layout.maximumWidth: 280
                        text: root.controller.busy ? root.uiText("status.converting") : root.uiText("button.convert")
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
