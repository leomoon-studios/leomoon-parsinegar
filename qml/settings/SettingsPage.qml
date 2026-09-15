pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

FocusScope {
    id: root

    required property var controller
    required property Typography typography
    property var navigationBackButton: null
    property string ligatureGroupId: ""
    readonly property alias settingsScroll: settingsScroll
    readonly property alias ligatureList: ligatureList

    LayoutMirroring.enabled: controller.uiLanguage === "fa"
    LayoutMirroring.childrenInherit: true

    function uiText(key) {
        return controller.uiText(key)
    }

    function groupById(id) {
        var groups = controller.reshaperMetadata.ligatureGroups
        for (var index = 0; index < groups.length; index++) {
            if (groups[index].id === id)
                return groups[index]
        }
        return null
    }

    function groupCount(id) {
        var group = groupById(id)
        return group ? group.ligatures.length : 0
    }

    function showGroup(id) {
        if (controller.hebrewProfile)
            return
        ligatureGroupId = id
        if (navigationBackButton !== null)
            Qt.callLater(function() { navigationBackButton.forceActiveFocus() })
    }

    function closeGroup() {
        ligatureGroupId = ""
        if (navigationBackButton !== null)
            Qt.callLater(function() { navigationBackButton.forceActiveFocus() })
    }

    Keys.onEscapePressed: function(event) {
        if (ligatureGroupId !== "")
            closeGroup()
        else
            controller.closeSettings()
        event.accepted = true
    }

    Connections {
        target: root.controller
        function onHebrewProfileChanged() {
            if (root.controller.hebrewProfile)
                root.ligatureGroupId = ""
        }
    }

    ColumnLayout {
        anchors.fill: parent
        visible: root.ligatureGroupId === ""
        enabled: visible
        spacing: AppTheme.spacingMedium

        PageHeader {
            Layout.fillWidth: true
            title: root.uiText("settings.title")
            subtitle: root.uiText("settings.interfaceLanguageDescription")
        }

        StatusMessage {
            objectName: "settingsStatus"
            Layout.fillWidth: true
            message: root.controller.settingsStatusText
            level: root.controller.settingsStatusLevel
        }

        ScrollView {
            id: settingsScroll
            objectName: "settingsScroll"
            Layout.fillWidth: true
            Layout.fillHeight: true
            contentWidth: availableWidth
            clip: true
            leftPadding: AppTheme.spacingLarge
            rightPadding: AppTheme.spacingLarge
            ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
            ScrollBar.vertical.policy: ScrollBar.AsNeeded

            Column {
                width: settingsScroll.availableWidth
                spacing: AppTheme.spacingMedium

                SectionHeading {
                    width: parent.width
                    label: root.uiText("settings.interfaceLanguage")
                }

                GridLayout {
                    width: parent.width
                    columns: 2
                    columnSpacing: AppTheme.spacingSmall

                    AppButton {
                        objectName: "languageEnglishButton"
                        Layout.fillWidth: true
                        Layout.preferredWidth: 0
                        text: root.uiText("language.english")
                        selected: root.controller.uiLanguage === "en"
                        onClicked: root.controller.setUiLanguage("en")
                    }

                    AppButton {
                        objectName: "languagePersianButton"
                        Layout.fillWidth: true
                        Layout.preferredWidth: 0
                        text: root.uiText("language.persian")
                        selected: root.controller.uiLanguage === "fa"
                        onClicked: root.controller.setUiLanguage("fa")
                    }
                }

                SectionHeading {
                    width: parent.width
                    label: root.uiText("settings.appearance")
                }

                SettingsToggle {
                    id: darkThemeToggle
                    objectName: "settingsDarkThemeToggle"
                    width: parent.width
                    title: root.uiText("settings.darkTheme")
                    description: root.uiText("settings.darkThemeDescription")
                    checked: AppTheme.darkMode
                    onToggled: function(checked) { AppTheme.darkMode = checked }
                }

                SectionHeading {
                    width: parent.width
                    label: root.uiText("settings.language")
                }

                GridLayout {
                    width: parent.width
                    columns: width >= 700 ? 3 : 1
                    columnSpacing: AppTheme.spacingSmall
                    rowSpacing: AppTheme.spacingSmall

                    AppButton {
                        objectName: "settingsProfileStandard"
                        Layout.fillWidth: true
                        Layout.preferredWidth: 0
                        text: root.uiText("settings.profileLabel.standardPersianArabic")
                        selected: root.controller.shapingProfile === "standardPersianArabic"
                        onClicked: root.controller.setShapingProfile("standardPersianArabic")
                    }

                    AppButton {
                        objectName: "settingsProfileKurdish"
                        Layout.fillWidth: true
                        Layout.preferredWidth: 0
                        text: root.uiText("settings.profileLabel.kurdishUrdu")
                        selected: root.controller.shapingProfile === "kurdishUrdu"
                        onClicked: root.controller.setShapingProfile("kurdishUrdu")
                    }

                    AppButton {
                        objectName: "settingsProfileHebrew"
                        Layout.fillWidth: true
                        Layout.preferredWidth: 0
                        text: root.uiText("settings.profileLabel.hebrew")
                        selected: root.controller.shapingProfile === "hebrew"
                        onClicked: root.controller.setShapingProfile("hebrew")
                    }
                }

                Label {
                    width: parent.width
                    text: root.uiText("settings.profileDescription." + root.controller.shapingProfile)
                    font.family: AppTheme.fontFamily
                    font.pixelSize: AppTheme.fontCaption
                    color: AppTheme.muted
                    wrapMode: Text.Wrap
                }

                Rectangle {
                    width: parent.width
                    height: hebrewNotice.implicitHeight + AppTheme.spacingLarge * 2
                    visible: root.controller.hebrewProfile
                    radius: AppTheme.cornerRadius
                    color: AppTheme.withAlpha(AppTheme.accent, 0.08)
                    border.color: AppTheme.withAlpha(AppTheme.accent, 0.4)
                    border.width: AppTheme.borderWidth

                    ColumnLayout {
                        id: hebrewNotice
                        anchors.fill: parent
                        anchors.margins: AppTheme.spacingLarge
                        spacing: AppTheme.spacingTiny

                        Label {
                            Layout.fillWidth: true
                            text: root.uiText("settings.hebrewNoticeTitle")
                            font.family: AppTheme.fontFamily
                            font.pixelSize: AppTheme.fontBody
                            font.weight: Font.DemiBold
                            color: AppTheme.foreground
                            wrapMode: Text.Wrap
                        }

                        Label {
                            Layout.fillWidth: true
                            text: root.uiText("settings.hebrewNoticeDescription")
                            font.family: AppTheme.fontFamily
                            font.pixelSize: AppTheme.fontCaption
                            color: AppTheme.muted
                            wrapMode: Text.Wrap
                        }
                    }
                }

                SectionHeading {
                    width: parent.width
                    label: root.uiText("settings.textShaping")
                }

                SettingsToggle {
                    objectName: "settingsBidiToggle"
                    width: parent.width
                    title: root.uiText("toggle.reverse")
                    description: root.uiText("toggle.reverseDescription")
                    checked: root.controller.reverseWords
                    onToggled: function(checked) { root.controller.setReverseWords(checked) }
                }

                SettingsToggle {
                    objectName: "settingsVideoToggle"
                    width: parent.width
                    visible: !root.controller.hebrewProfile
                    title: root.uiText("toggle.video")
                    description: root.uiText("toggle.videoDescription")
                    checked: root.controller.videoStudioPro
                    enabled: root.controller.conversionMode === "compatibility"
                    onToggled: function(checked) { root.controller.setVideoStudioPro(checked) }
                }

                SettingsToggle {
                    objectName: "base_deleteHarakat"
                    width: parent.width
                    visible: !root.controller.hebrewProfile
                    title: root.uiText("settings.deleteHarakat")
                    description: root.uiText("settings.deleteHarakatDescription")
                    checked: root.controller.baseOption("deleteHarakat")
                    onToggled: function(checked) { root.controller.setBaseOption("deleteHarakat", checked) }
                }

                SettingsToggle {
                    objectName: "base_shiftHarakatPosition"
                    width: parent.width
                    visible: !root.controller.hebrewProfile
                    title: root.uiText("settings.shiftHarakat")
                    description: root.uiText("settings.shiftHarakatDescription")
                    checked: root.controller.baseOption("shiftHarakatPosition")
                    onToggled: function(checked) { root.controller.setBaseOption("shiftHarakatPosition", checked) }
                }

                SettingsToggle {
                    objectName: "base_deleteTatweel"
                    width: parent.width
                    visible: !root.controller.hebrewProfile
                    title: root.uiText("settings.deleteTatweel")
                    description: root.uiText("settings.deleteTatweelDescription")
                    checked: root.controller.baseOption("deleteTatweel")
                    onToggled: function(checked) { root.controller.setBaseOption("deleteTatweel", checked) }
                }

                SettingsToggle {
                    objectName: "base_supportZWJ"
                    width: parent.width
                    visible: !root.controller.hebrewProfile
                    title: root.uiText("settings.supportZWJ")
                    description: root.uiText("settings.supportZWJDescription")
                    checked: root.controller.baseOption("supportZWJ")
                    onToggled: function(checked) { root.controller.setBaseOption("supportZWJ", checked) }
                }

                SettingsToggle {
                    objectName: "base_useUnshapedInsteadOfIsolated"
                    width: parent.width
                    visible: !root.controller.hebrewProfile
                    title: root.uiText("settings.unshapedIsolated")
                    description: root.uiText("settings.unshapedIsolatedDescription")
                    checked: root.controller.baseOption("useUnshapedInsteadOfIsolated")
                    onToggled: function(checked) { root.controller.setBaseOption("useUnshapedInsteadOfIsolated", checked) }
                }

                SettingsToggle {
                    objectName: "base_supportLigatures"
                    width: parent.width
                    visible: !root.controller.hebrewProfile
                    title: root.uiText("settings.supportLigatures")
                    description: root.uiText("settings.supportLigaturesDescription")
                    checked: root.controller.baseOption("supportLigatures")
                    onToggled: function(checked) { root.controller.setBaseOption("supportLigatures", checked) }
                }

                SectionHeading {
                    width: parent.width
                    visible: !root.controller.hebrewProfile
                    label: root.uiText("settings.namedLigatures")
                }

                Label {
                    width: parent.width
                    visible: !root.controller.hebrewProfile
                    text: root.uiText("settings.fontNotice")
                    textFormat: Text.PlainText
                    font.family: AppTheme.fontFamily
                    font.pixelSize: AppTheme.fontCaption
                    color: AppTheme.muted
                    wrapMode: Text.Wrap
                }

                AppButton {
                    objectName: "ligatureGroup_sentences"
                    width: parent.width
                    visible: !root.controller.hebrewProfile
                    text: root.uiText("settings.group.sentences") + " (" + root.groupCount("sentences") + ")"
                    enabled: root.controller.baseOption("supportLigatures")
                    onClicked: root.showGroup("sentences")
                }

                AppButton {
                    objectName: "ligatureGroup_words"
                    width: parent.width
                    visible: !root.controller.hebrewProfile
                    text: root.uiText("settings.group.words") + " (" + root.groupCount("words") + ")"
                    enabled: root.controller.baseOption("supportLigatures")
                    onClicked: root.showGroup("words")
                }

                AppButton {
                    objectName: "ligatureGroup_letters"
                    width: parent.width
                    visible: !root.controller.hebrewProfile
                    text: root.uiText("settings.group.letters") + " (" + root.groupCount("letters") + ")"
                    enabled: root.controller.baseOption("supportLigatures")
                    onClicked: root.showGroup("letters")
                }

                AppButton {
                    objectName: "settingsResetButton"
                    width: parent.width
                    visible: !root.controller.hebrewProfile
                    text: root.uiText("settings.reset")
                    onClicked: root.controller.resetReshaperSettings()
                }
            }
        }
    }

    ColumnLayout {
        anchors.fill: parent
        visible: root.ligatureGroupId !== ""
        enabled: visible
        spacing: AppTheme.spacingMedium

        PageHeader {
            Layout.fillWidth: true
            title: {
                var group = root.groupById(root.ligatureGroupId)
                return root.uiText("settings.breadcrumb")
                    + (group ? root.uiText("settings.group." + group.id) : root.uiText("settings.namedLigatures"))
            }
            subtitle: root.uiText("settings.fontNotice")
        }

        ListView {
            id: ligatureList
            objectName: "ligatureList"
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            spacing: AppTheme.spacingSmall
            boundsBehavior: Flickable.StopAtBounds
            model: {
                var group = root.groupById(root.ligatureGroupId)
                return group ? group.ligatures : []
            }
            ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }

            delegate: SettingsToggle {
                required property var modelData
                required property int index
                objectName: "ligatureRow_" + index
                width: ligatureList.width
                leftPadding: AppTheme.spacingLarge
                rightPadding: AppTheme.spacingLarge
                title: modelData.name
                description: modelData.name === "RIAL SIGN" ? root.uiText("settings.rialDescription") : ""
                checked: root.controller.ligatureEnabled(modelData.name)
                enabled: root.controller.baseOption("supportLigatures")
                onToggled: root.controller.toggleLigature(modelData.name)
            }
        }
    }
}
