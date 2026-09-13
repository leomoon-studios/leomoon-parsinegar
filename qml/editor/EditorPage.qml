pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

FocusScope {
    id: root

    required property var controller
    required property Typography typography
    readonly property alias editorItem: editor
    readonly property alias editorPageScroll: pageScroll

    function uiText(key) {
        return controller.uiText(key)
    }

    function focusEditor() {
        editor.forceActiveFocus()
    }

    ScrollView {
        id: pageScroll
        objectName: "editorPageScroll"
        anchors.fill: parent
        contentWidth: availableWidth
        clip: true
        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
        ScrollBar.vertical.policy: ScrollBar.AsNeeded

        Column {
            width: pageScroll.availableWidth
            spacing: AppTheme.spacingMedium

            PageHeader {
                width: parent.width
                title: root.uiText("editor.title")
                subtitle: qsTr("Shape text for applications that need presentation or cannot provide native right-to-left support.")
            }

            Rectangle {
                width: parent.width
                height: editorContent.implicitHeight + AppTheme.spacingXLarge * 2
                radius: AppTheme.cornerRadiusLarge
                color: AppTheme.surface
                border.color: AppTheme.border
                border.width: AppTheme.borderWidth

                ColumnLayout {
                    id: editorContent
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.margins: AppTheme.spacingXLarge
                    spacing: AppTheme.spacingLarge

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: AppTheme.spacingMedium

                        Label {
                            Layout.fillWidth: true
                            text: qsTr("Source text")
                            font.family: AppTheme.fontFamily
                            font.pixelSize: AppTheme.fontBody
                            font.weight: Font.DemiBold
                            color: AppTheme.foreground
                        }

                        AppButton {
                            id: ltrButton
                            objectName: "ltrButton"
                            text: root.uiText("button.ltr")
                            selected: !root.controller.editorRtl
                            Accessible.name: text
                            onClicked: {
                                root.controller.setEditorDirection(false)
                                root.focusEditor()
                            }
                        }

                        AppButton {
                            id: rtlButton
                            objectName: "rtlButton"
                            text: root.uiText("button.rtl")
                            selected: root.controller.editorRtl
                            Accessible.name: text
                            onClicked: {
                                root.controller.setEditorDirection(true)
                                root.focusEditor()
                            }
                        }
                    }

                    ScrollView {
                        id: editorScroll
                        objectName: "editorScroll"
                        Layout.fillWidth: true
                        Layout.preferredHeight: 230
                        clip: true
                        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
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

                    Label {
                        Layout.fillWidth: true
                        text: qsTr("%1 of %2 characters").arg(root.controller.sourceText.length).arg(root.controller.maximumTextLength)
                        horizontalAlignment: Text.AlignRight
                        font.family: AppTheme.fontFamily
                        font.pixelSize: AppTheme.fontCaption
                        color: root.controller.sourceText.length > root.controller.maximumTextLength ? AppTheme.urgent : AppTheme.muted
                    }

                    Label {
                        Layout.fillWidth: true
                        text: qsTr("Shaping profile")
                        font.family: AppTheme.fontFamily
                        font.pixelSize: AppTheme.fontCaption
                        font.weight: Font.DemiBold
                        color: AppTheme.muted
                    }

                    GridLayout {
                        Layout.fillWidth: true
                        columns: width >= 700 ? 3 : 1
                        columnSpacing: AppTheme.spacingSmall
                        rowSpacing: AppTheme.spacingSmall

                        AppButton {
                            objectName: "profile_standardPersianArabic"
                            Layout.fillWidth: true
                            text: root.uiText("settings.profileLabel.standardPersianArabic")
                            selected: root.controller.shapingProfile === "standardPersianArabic"
                            Accessible.name: text
                            onClicked: root.controller.setShapingProfile("standardPersianArabic")
                        }

                        AppButton {
                            objectName: "profile_kurdishUrdu"
                            Layout.fillWidth: true
                            text: root.uiText("settings.profileLabel.kurdishUrdu")
                            selected: root.controller.shapingProfile === "kurdishUrdu"
                            Accessible.name: text
                            onClicked: root.controller.setShapingProfile("kurdishUrdu")
                        }

                        AppButton {
                            objectName: "profile_hebrew"
                            Layout.fillWidth: true
                            text: root.uiText("settings.profileLabel.hebrew")
                            selected: root.controller.shapingProfile === "hebrew"
                            Accessible.name: text
                            onClicked: root.controller.setShapingProfile("hebrew")
                        }
                    }

                    Label {
                        Layout.fillWidth: true
                        text: qsTr("Conversion mode")
                        font.family: AppTheme.fontFamily
                        font.pixelSize: AppTheme.fontCaption
                        font.weight: Font.DemiBold
                        color: AppTheme.muted
                    }

                    GridLayout {
                        Layout.fillWidth: true
                        columns: 2
                        columnSpacing: AppTheme.spacingSmall

                        AppButton {
                            id: unicodeButton
                            objectName: "unicodeButton"
                            Layout.fillWidth: true
                            text: root.uiText("mode.unicode")
                            selected: root.controller.conversionMode === "unicode"
                            Accessible.name: text
                            onClicked: root.controller.setConversionMode("unicode")
                        }

                        AppButton {
                            id: compatibilityButton
                            objectName: "compatibilityButton"
                            Layout.fillWidth: true
                            text: root.uiText("mode.compatibility")
                            selected: root.controller.conversionMode === "compatibility"
                            enabled: !root.controller.hebrewProfile
                            Accessible.name: text
                            onClicked: root.controller.setConversionMode("compatibility")
                        }
                    }

                    GridLayout {
                        Layout.fillWidth: true
                        columns: width >= 700 ? 2 : 1
                        columnSpacing: AppTheme.spacingLarge
                        rowSpacing: AppTheme.spacingSmall

                        AppToggle {
                            id: bidiToggle
                            objectName: "bidiToggle"
                            Layout.fillWidth: true
                            text: root.uiText("toggle.reverse")
                            checked: root.controller.reverseWords
                            Accessible.description: root.uiText("toggle.reverseDescription")
                            onToggled: root.controller.reverseWords = checked
                        }

                        AppToggle {
                            id: videoStudioToggle
                            objectName: "videoStudioToggle"
                            Layout.fillWidth: true
                            text: root.uiText("toggle.video")
                            checked: root.controller.videoStudioPro
                            enabled: root.controller.conversionMode === "compatibility" && !root.controller.hebrewProfile
                            Accessible.description: root.uiText("toggle.videoDescription")
                            onToggled: root.controller.videoStudioPro = checked
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
                width: parent.width
                horizontalAlignment: Text.AlignHCenter
                text: qsTr("Converted text is copied to the clipboard. Your source stays in the editor.")
                wrapMode: Text.Wrap
                font.family: AppTheme.fontFamily
                font.pixelSize: AppTheme.fontCaption
                color: AppTheme.muted
            }
        }
    }
}
