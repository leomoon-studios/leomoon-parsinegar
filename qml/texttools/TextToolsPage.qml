pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "qml/core/TextTools.js" as TextTools

FocusScope {
    id: root

    required property var controller
    required property Typography typography
    readonly property alias toolsScroll: toolsScroll
    readonly property real contentImplicitHeight: toolsContent.implicitHeight

    LayoutMirroring.enabled: controller.uiLanguage === "fa"
    LayoutMirroring.childrenInherit: true

    function uiText(key) {
        return controller.uiText(key)
    }

    function toolsForGroup(group) {
        return TextTools.TextTools.groups(group)
    }

    Keys.onEscapePressed: function(event) {
        controller.closeTextTools()
        event.accepted = true
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: AppTheme.spacingMedium

        PageHeader {
            Layout.fillWidth: true
            title: root.uiText("tools.title")
        }

        ScrollView {
            id: toolsScroll
            objectName: "textToolsScroll"
            Layout.fillWidth: true
            Layout.fillHeight: true
            contentWidth: availableWidth
            clip: true
            leftPadding: AppTheme.spacingLarge
            rightPadding: AppTheme.spacingLarge
            ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
            ScrollBar.vertical.policy: ScrollBar.AsNeeded

            Column {
                id: toolsContent
                width: toolsScroll.availableWidth
                spacing: AppTheme.spacingMedium

                Rectangle {
                    width: parent.width
                    implicitHeight: intro.implicitHeight + AppTheme.spacingLarge * 2
                    radius: AppTheme.cornerRadius
                    color: AppTheme.withAlpha(AppTheme.accent, 0.08)
                    border.color: AppTheme.withAlpha(AppTheme.accent, 0.4)
                    border.width: AppTheme.borderWidth

                    Label {
                        id: intro
                        anchors.fill: parent
                        anchors.margins: AppTheme.spacingLarge
                        text: root.uiText("tools.intro")
                        font.family: AppTheme.fontFamily
                        font.pixelSize: AppTheme.fontBody
                        color: AppTheme.foreground
                        wrapMode: Text.Wrap
                    }
                }

                Repeater {
                    model: ["persian", "cleanup", "alternate"]

                    delegate: Column {
                        id: groupColumn
                        required property string modelData
                        width: parent.width
                        spacing: AppTheme.spacingSmall

                        Label {
                            width: parent.width
                            text: root.uiText("tools.group." + groupColumn.modelData)
                            font.family: AppTheme.fontFamily
                            font.pixelSize: AppTheme.fontCaption
                            font.weight: Font.DemiBold
                            color: AppTheme.muted
                            horizontalAlignment: root.controller.uiLanguage === "fa" ? Text.AlignRight : Text.AlignLeft
                        }

                        Repeater {
                            model: root.toolsForGroup(groupColumn.modelData)

                            delegate: SettingsToggle {
                                required property var modelData
                                objectName: "textTool_" + modelData.id
                                width: parent.width
                                title: root.uiText(modelData.labelKey)
                                description: root.uiText(modelData.descriptionKey)
                                checked: root.controller.textToolEnabled(modelData.id)
                                onToggled: function(checked) {
                                    root.controller.toggleTextTool(modelData.id)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
