pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

FocusScope {
    id: root

    required property var controller
    required property Typography typography
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

    ColumnLayout {
        anchors.fill: parent
        spacing: AppTheme.spacingMedium

        StatusMessage {
            objectName: "editorSettingsStatus"
            Layout.fillWidth: true
            visible: root.controller.settingsStatusLevel !== "info"
            message: root.controller.settingsStatusText
            level: root.controller.settingsStatusLevel
        }

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
                        text: root.controller.sourceText
                        onTextChanged: {
                            if (root.controller.sourceText !== text)
                                root.controller.sourceText = text
                        }
                        font.family: AppTheme.fontFamily
                        font.pixelSize: AppTheme.fontBody
                        placeholderText: root.uiText("placeholder")
                        placeholderTextColor: AppTheme.muted
                        color: AppTheme.foreground
                        selectionColor: AppTheme.accent
                        selectedTextColor: AppTheme.accentText
                        wrapMode: TextEdit.Wrap
                        textFormat: TextEdit.PlainText
                        selectByMouse: true
                        persistentSelection: true
                        horizontalAlignment: root.controller.editorRtl ? TextEdit.AlignRight : TextEdit.AlignLeft
                        padding: AppTheme.spacingMedium
                        Accessible.name: qsTr("Source text editor")

                        background: Rectangle {
                            color: AppTheme.withAlpha(AppTheme.foreground, AppTheme.darkMode ? 0.035 : 0.02)
                            border.color: editor.activeFocus ? AppTheme.focus : AppTheme.border
                            border.width: editor.activeFocus ? AppTheme.focusBorderWidth : AppTheme.borderWidth
                            radius: AppTheme.cornerRadius
                        }
                    }
                }

                StatusMessage {
                    id: conversionStatus
                    objectName: "conversionStatus"
                    Layout.fillWidth: true
                    message: root.controller.statusText
                    level: root.controller.statusLevel
                    busy: root.controller.busy
                }

                GridLayout {
                    Layout.fillWidth: true
                    columns: 2
                    columnSpacing: AppTheme.spacingSmall
                    rowSpacing: AppTheme.spacingSmall

                    AppButton {
                        objectName: "unicodeButton"
                        Layout.fillWidth: true
                        Layout.preferredWidth: 0
                        text: root.uiText("mode.unicode")
                        selected: root.controller.conversionMode === "unicode"
                        onClicked: root.controller.setConversionMode("unicode")
                    }

                    AppButton {
                        objectName: "compatibilityButton"
                        Layout.fillWidth: true
                        Layout.preferredWidth: 0
                        text: root.uiText("mode.compatibility")
                        selected: root.controller.conversionMode === "compatibility"
                        enabled: !root.controller.hebrewProfile
                        onClicked: root.controller.setConversionMode("compatibility")
                    }
                }

                AppButton {
                    id: convertButton
                    objectName: "convertButton"
                    Layout.fillWidth: true
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

        Label {
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
            text: root.uiText("editor.footer")
            wrapMode: Text.Wrap
            font.family: AppTheme.fontFamily
            font.pixelSize: AppTheme.fontCaption
            color: AppTheme.muted
        }
    }
}
