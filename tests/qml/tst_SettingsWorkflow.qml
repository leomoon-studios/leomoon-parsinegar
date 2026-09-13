pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtTest
import LeoMoon.ParsiNegar

TestCase {
    id: testCase
    name: "SettingsWorkflow"
    when: windowShown

    QtObject {
        id: settingsStoreMock
        property bool exists: false
        property string data: ""
        property string loadCode: ""
        property bool acceptSaves: true
        property int saveCount: 0

        function load() {
            if (loadCode !== "")
                return { ok: false, code: loadCode, message: "Test load failure." }
            return { ok: true, exists: exists, data: data }
        }

        function save(json) {
            saveCount++
            if (!acceptSaves)
                return { ok: false, code: "SETTINGS_WRITE_FAILED", message: "Test save failure." }
            data = json
            exists = true
            return { ok: true, path: "/tmp/settings.json" }
        }

        function reset() {
            exists = false
            data = ""
            loadCode = ""
            acceptSaves = true
            saveCount = 0
        }
    }

    QtObject {
        id: fileBridgeMock
        property var existingPaths: ({})
        function fontPathExists(path) {
            return existingPaths[path] === true
        }
        function reset() {
            existingPaths = ({
                "/fonts/unicode.ttf": true,
                "/fonts/compatibility.otf": true
            })
        }
    }

    QtObject {
        id: clipboardMock
        property string text: ""
        property string lastError: ""
        function copyText(value) {
            text = value
            return true
        }
    }

    Component {
        id: controllerComponent
        EditorController {
            settingsStore: settingsStoreMock
            fileBridge: fileBridgeMock
            clipboardBridge: clipboardMock
        }
    }

    Component {
        id: mainWindowComponent
        Main {
            visible: true
            clipboardService: clipboardMock
            settingsService: settingsStoreMock
            fileService: fileBridgeMock
        }
    }

    Component {
        id: mirroredNumberComponent
        Item {
            width: 200
            height: 60
            LayoutMirroring.enabled: true
            LayoutMirroring.childrenInherit: true
            NumericField {
                objectName: "mirroredNumberField"
                width: parent.width
                text: "48"
            }
        }
    }

    function init() {
        settingsStoreMock.reset()
        fileBridgeMock.reset()
        clipboardMock.text = ""
    }

    function createController() {
        var controller = createTemporaryObject(controllerComponent, null)
        verify(controller !== null)
        tryCompare(controller, "settingsReady", true)
        return controller
    }

    function test_languageAndPreferenceRoundTrips_data() {
        return [
            { tag: "english", language: "en" },
            { tag: "persian", language: "fa" }
        ]
    }

    function test_languageAndPreferenceRoundTrips(data) {
        var controller = createController()
        controller.sourceText = "private draft متن"
        controller.setUiLanguage(data.language)
        controller.setShapingProfile("kurdishUrdu")
        controller.setConversionMode("compatibility")
        controller.setEditorDirection(false)
        controller.setReverseWords(false)
        controller.setVideoStudioPro(true)
        controller.setBaseOption("deleteTatweel", true)
        controller.toggleLigature("ARABIC LIGATURE AKBAR")
        controller.toggleLigature("RIAL SIGN")
        verify(controller.setFontPath("unicode", "/fonts/unicode.ttf"))
        verify(controller.setFontPath("compatibility", "/fonts/compatibility.otf"))

        var saved = JSON.parse(settingsStoreMock.data)
        compare(saved.schemaVersion, 1)
        compare(saved.uiLanguage, data.language)
        compare(saved.shapingProfile, "kurdishUrdu")
        compare(saved.desktop.conversionMode, "compatibility")
        compare(saved.desktop.editorRtl, false)
        compare(saved.desktop.reverseWords, false)
        compare(saved.desktop.videoStudioPro, true)
        compare(saved.desktop.fontPaths.unicode, "/fonts/unicode.ttf")
        compare(saved.desktop.fontPaths.compatibility, "/fonts/compatibility.otf")
        compare(saved.settings.deleteTatweel, true)
        compare(saved.settings.ligatures["ARABIC LIGATURE AKBAR"], true)
        compare(saved.settings.ligatures["RIAL SIGN"], false)
        verify(settingsStoreMock.data.indexOf("private draft") === -1)
        verify(settingsStoreMock.data.indexOf("sourceText") === -1)
        verify(settingsStoreMock.data.indexOf("convertedText") === -1)
        verify(settingsStoreMock.data.indexOf("clipboardText") === -1)
        verify(settingsStoreMock.data.indexOf("statusText") === -1)

        var restored = createController()
        compare(restored.uiLanguage, data.language)
        compare(restored.shapingProfile, "kurdishUrdu")
        compare(restored.conversionMode, "compatibility")
        compare(restored.editorRtl, false)
        compare(restored.reverseWords, false)
        compare(restored.videoStudioPro, true)
        compare(restored.baseOption("deleteTatweel"), true)
        compare(restored.ligatureEnabled("ARABIC LIGATURE AKBAR"), true)
        compare(restored.ligatureEnabled("RIAL SIGN"), false)
        compare(restored.unicodeFontPath, "/fonts/unicode.ttf")
        compare(restored.compatibilityFontPath, "/fonts/compatibility.otf")
        compare(restored.sourceText, "")
        compare(restored.lastOutput, "")
        compare(restored.statusText, "")
    }

    function test_invalidAndOversizedSettingsRecoverAtomically() {
        settingsStoreMock.exists = true
        settingsStoreMock.data = "{not json"
        var malformed = createController()
        compare(malformed.settingsStatusLevel, "warning")
        compare(malformed.settingsStatusText, malformed.uiText("settings.status.recovered"))
        compare(malformed.shapingProfile, "standardPersianArabic")
        compare(malformed.ligatureEnabled("RIAL SIGN"), true)
        compare(JSON.parse(settingsStoreMock.data).schemaVersion, 1)

        settingsStoreMock.reset()
        settingsStoreMock.loadCode = "SETTINGS_TOO_LARGE"
        var oversized = createController()
        compare(oversized.settingsStatusLevel, "warning")
        compare(oversized.settingsStatusText, oversized.uiText("settings.status.recovered"))
        compare(oversized.baseOption("deleteHarakat"), false)
        compare(oversized.ligatureEnabled("RIAL SIGN"), true)
        compare(settingsStoreMock.saveCount, 1)
    }

    function test_removedFontPathsAreClearedOnRestart() {
        var controller = createController()
        verify(controller.setFontPath("unicode", "/fonts/unicode.ttf"))
        verify(controller.setFontPath("compatibility", "/fonts/compatibility.otf"))
        fileBridgeMock.existingPaths = ({})

        var restored = createController()
        compare(restored.unicodeFontPath, "")
        compare(restored.compatibilityFontPath, "")
        compare(restored.settingsStatusLevel, "warning")
        var repaired = JSON.parse(settingsStoreMock.data)
        compare(repaired.desktop.fontPaths.unicode, "")
        compare(repaired.desktop.fontPaths.compatibility, "")
    }

    function test_saveFailureIsLocalizedAndResetRestoresPinnedDefaults() {
        var controller = createController()
        controller.setShapingProfile("hebrew")
        controller.setBaseOption("deleteHarakat", true)
        controller.setBaseOption("supportZWJ", false)
        controller.toggleLigature("RIAL SIGN")
        controller.resetReshaperSettings()
        compare(controller.shapingProfile, "standardPersianArabic")
        compare(controller.baseOption("deleteHarakat"), false)
        compare(controller.baseOption("shiftHarakatPosition"), false)
        compare(controller.baseOption("deleteTatweel"), false)
        compare(controller.baseOption("supportZWJ"), true)
        compare(controller.baseOption("useUnshapedInsteadOfIsolated"), false)
        compare(controller.baseOption("supportLigatures"), true)
        compare(controller.ligatureEnabled("RIAL SIGN"), true)
        compare(controller.ligatureEnabled("ARABIC LIGATURE ALLAH"), true)

        settingsStoreMock.acceptSaves = false
        controller.setUiLanguage("fa")
        compare(controller.settingsStatusLevel, "error")
        verify(controller.settingsStatusText.indexOf(controller.uiText("settings.status.saveFailure")) === 0)
        verify(controller.settingsStatusText.indexOf("Test save failure.") !== -1)
    }

    function test_settingsPageNavigationMirroringAndHebrewVisibility() {
        var applicationWindow = createTemporaryObject(mainWindowComponent, null)
        verify(applicationWindow !== null)
        tryCompare(applicationWindow, "bundledFontReady", true, 5000)
        tryCompare(applicationWindow, "bundledIconFontReady", true, 5000)
        var controller = applicationWindow.editorController
        var settingsButton = findChild(applicationWindow, "settingsButton")
        var headerActions = findChild(applicationWindow, "headerActions")
        var settingsPage = findChild(applicationWindow, "settingsPage")
        var englishButton = findChild(applicationWindow, "languageEnglishButton")
        var persianButton = findChild(applicationWindow, "languagePersianButton")
        var standardButton = findChild(applicationWindow, "settingsProfileStandard")
        var kurdishButton = findChild(applicationWindow, "settingsProfileKurdish")
        var hebrewButton = findChild(applicationWindow, "settingsProfileHebrew")
        var deleteHarakat = findChild(applicationWindow, "base_deleteHarakat")
        var sentencesButton = findChild(applicationWindow, "ligatureGroup_sentences")
        var wordsButton = findChild(applicationWindow, "ligatureGroup_words")
        var lettersButton = findChild(applicationWindow, "ligatureGroup_letters")
        var groupBackButton = findChild(applicationWindow, "ligatureGroupBackButton")
        var ligatureList = findChild(applicationWindow, "ligatureList")
        var ltrButton = findChild(applicationWindow, "ltrButton")
        var rtlButton = findChild(applicationWindow, "rtlButton")

        verify(settingsButton !== null)
        verify(headerActions.visible)
        settingsButton.click()
        compare(controller.page, "settings")
        verify(settingsPage.visible)
        verify(!headerActions.visible)
        compare(settingsPage.settingsScroll.leftPadding, AppTheme.spacingLarge)
        compare(settingsPage.settingsScroll.rightPadding, AppTheme.spacingLarge)
        compare(englishButton.width, persianButton.width)
        compare(standardButton.width, kurdishButton.width)
        compare(kurdishButton.width, hebrewButton.width)

        persianButton.click()
        compare(controller.uiLanguage, "fa")
        verify(settingsPage.LayoutMirroring.enabled)

        sentencesButton.click()
        compare(settingsPage.ligatureGroupId, "sentences")
        compare(ligatureList.count, 3)
        groupBackButton.click()

        wordsButton.click()
        compare(settingsPage.ligatureGroupId, "words")
        compare(ligatureList.count, 9)
        verify(ligatureList.itemAtIndex(0) !== null)
        compare(ligatureList.itemAtIndex(0).leftPadding, AppTheme.spacingLarge)
        compare(ligatureList.itemAtIndex(0).rightPadding, AppTheme.spacingLarge)
        groupBackButton.click()
        compare(settingsPage.ligatureGroupId, "")

        lettersButton.click()
        compare(ligatureList.count, 274)
        settingsPage.closeGroup()
        hebrewButton.click()
        compare(controller.shapingProfile, "hebrew")
        verify(!deleteHarakat.visible)
        verify(!wordsButton.visible)
        standardButton.click()
        verify(deleteHarakat.visible)
        verify(wordsButton.visible)

        var settingsBackButton = findChild(applicationWindow, "settingsBackButton")
        settingsBackButton.click()
        compare(controller.page, "editor")
        verify(headerActions.visible)
        verify(ltrButton.x < rtlButton.x)

        var mirroredContainer = createTemporaryObject(mirroredNumberComponent, null)
        verify(mirroredContainer !== null)
        var numberField = findChild(mirroredContainer, "mirroredNumberField")
        compare(numberField.horizontalAlignment, TextInput.AlignLeft)
        compare(numberField.text, "48")
    }
}
