import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

ApplicationWindow {
    id: root
    objectName: "mainWindow"

    readonly property bool bundledFontReady: typography.ready
    readonly property bool bundledFontError: typography.failed

    width: 900
    height: 640
    minimumWidth: 480
    minimumHeight: 360
    visible: true
    title: qsTr("ParsiNegar Desktop")
    color: AppTheme.background

    Typography {
        id: typography
        onFamilyChanged: AppTheme.fontFamily = family
    }

    Component.onCompleted: AppTheme.fontFamily = typography.family

    ColumnLayout {
        id: shell
        objectName: "contentLayout"
        anchors.fill: parent
        anchors.margins: AppTheme.spacingLarge
        spacing: AppTheme.spacingLarge

        RowLayout {
            Layout.fillWidth: true
            spacing: AppTheme.spacingMedium

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
                    text: qsTr("ParsiNegar Desktop")
                    font.family: AppTheme.fontFamily
                    font.pixelSize: AppTheme.fontHeading
                    font.weight: Font.DemiBold
                    color: AppTheme.foreground
                    elide: Text.ElideRight
                }

                Label {
                    Layout.fillWidth: true
                    text: qsTr("Persian text tools for every desktop")
                    font.family: AppTheme.fontFamily
                    font.pixelSize: AppTheme.fontCaption
                    color: AppTheme.muted
                    elide: Text.ElideRight
                }
            }

            AppButton {
                id: themeButton
                objectName: "themeButton"
                text: AppTheme.darkMode ? qsTr("Light theme") : qsTr("Dark theme")
                Accessible.name: text
                onClicked: AppTheme.darkMode = !AppTheme.darkMode
            }
        }

        ScrollView {
            id: foundationScroll
            objectName: "foundationScroll"
            Layout.fillWidth: true
            Layout.fillHeight: true
            contentWidth: availableWidth
            clip: true
            ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
            ScrollBar.vertical.policy: ScrollBar.AsNeeded

            Column {
                width: foundationScroll.availableWidth
                spacing: AppTheme.spacingMedium

                Rectangle {
                    width: parent.width
                    height: foundationContent.implicitHeight + AppTheme.spacingXLarge * 2
                    radius: AppTheme.cornerRadiusLarge
                    color: AppTheme.surface
                    border.color: AppTheme.border
                    border.width: AppTheme.borderWidth

                    ColumnLayout {
                        id: foundationContent
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.margins: AppTheme.spacingXLarge
                        spacing: AppTheme.spacingLarge

                        PageHeader {
                            Layout.fillWidth: true
                            title: qsTr("Desktop foundation ready")
                            subtitle: qsTr("The application now owns its window, typography, colors, focus treatment, and reusable controls. The editor arrives in the next implementation step.")
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            implicitHeight: AppTheme.borderWidth
                            color: AppTheme.border
                        }

                        GridLayout {
                            Layout.fillWidth: true
                            columns: width >= 660 ? 3 : 1
                            columnSpacing: AppTheme.spacingLarge
                            rowSpacing: AppTheme.spacingMedium

                            AppButton {
                                objectName: "primaryButton"
                                Layout.fillWidth: true
                                text: qsTr("Primary action")
                                accent: true
                            }

                            AppToggle {
                                objectName: "sampleToggle"
                                Layout.fillWidth: true
                                text: qsTr("Apply bidi ordering")
                                checked: true
                            }

                            NumericField {
                                objectName: "sampleNumberField"
                                Layout.fillWidth: true
                                text: "48"
                                placeholderText: qsTr("Font size")
                                minimumValue: 1
                                maximumValue: 4096
                            }
                        }

                        StatusMessage {
                            objectName: "foundationStatus"
                            Layout.fillWidth: true
                            level: typography.failed ? "warning" : "success"
                            message: typography.failed ? typography.errorMessage : qsTr("Bundled Vazirmatn and the desktop control theme loaded successfully.")
                        }
                    }
                }

                Label {
                    width: parent.width
                    horizontalAlignment: Text.AlignHCenter
                    text: qsTr("Standalone Qt 6 preview")
                    font.family: AppTheme.fontFamily
                    font.pixelSize: AppTheme.fontCaption
                    color: AppTheme.muted
                }
            }
        }
    }
}
