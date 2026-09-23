pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtTest
import LeoMoon.ParsiNegar

TestCase {
    id: testCase
    name: "SettingsWorkflow"
    when: windowShown

    SignalSpy { id: openDocumentSpy; signalName: "openDocumentDialogRequested" }
    SignalSpy { id: saveDocumentSpy; signalName: "saveDocumentDialogRequested" }
    SignalSpy { id: unsavedChangesSpy; signalName: "unsavedChangesRequested" }
    SignalSpy { id: applicationCloseSpy; signalName: "applicationCloseApproved" }

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
        property var documents: ({})
        property bool acceptDocumentWrites: true
        function fontPathExists(path) {
            return existingPaths[path] === true
        }
        function localFileUrl(path) { return "file://" + path }
        function localFilePath(url) { return String(url).replace("file://", "") }
        function readTextDocument(url) {
            var path = localFilePath(url)
            return Object.prototype.hasOwnProperty.call(documents, path)
                ? { ok: true, path: path, data: documents[path] }
                : { ok: false, code: "DOCUMENT_NOT_FOUND", message: "Missing test document." }
        }
        function writeTextDocument(url, text) {
            if (!acceptDocumentWrites)
                return { ok: false, code: "DOCUMENT_WRITE_FAILED", message: "Test write failure." }
            var path = localFilePath(url)
            var next = Object.assign({}, documents)
            next[path] = text
            documents = next
            return { ok: true, path: path }
        }
        function reset() {
            existingPaths = ({
                "/fonts/unicode.ttf": true,
                "/fonts/compatibility.otf": true
            })
            documents = ({ "/tmp/existing.txt": "first\r\n\r\nپارسی\r\n" })
            acceptDocumentWrites = true
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

    function verifyScrollGutter(scroll, rightToLeft) {
        verify(scroll !== null)
        var scrollBar = scroll.ScrollBar.vertical
        verify(scrollBar !== null)
        compare(scroll.scrollGutter, scroll.overflowing ? scrollBar.width + 6 : 0)
        compare(scroll.leftPadding,
            rightToLeft ? scroll.scrollGutter : 0)
        compare(scroll.rightPadding,
            rightToLeft ? 0 : scroll.scrollGutter)
        if (scroll.overflowing) {
            verify(scrollBar.size < 1)
            var barX = scrollBar.mapToItem(scroll, 0, 0).x
            if (rightToLeft)
                verify(Math.abs(barX) < 1)
            else
                verify(Math.abs(barX + scrollBar.width - scroll.width) < 1)
        } else {
            verify(scrollBar.size >= 0.999)
        }
    }

    function verifyLigatureGutter(list, rightToLeft) {
        var scrollBar = list.ScrollBar.vertical
        verify(scrollBar !== null)
        compare(list.scrollGutter, list.overflowing ? scrollBar.width + 6 : 0)
        var wrapper = list.itemAtIndex(0)
        verify(wrapper !== null)
        var toggle = findChild(wrapper, "ligatureRow_0")
        verify(toggle !== null)
        compare(toggle.x, rightToLeft ? list.scrollGutter : 0)
        compare(toggle.width, Math.max(0, list.width - list.scrollGutter))
        if (list.overflowing) {
            verify(scrollBar.size < 1)
            var barX = scrollBar.mapToItem(list, 0, 0).x
            if (rightToLeft)
                verify(Math.abs(barX) < 1)
            else
                verify(Math.abs(barX + scrollBar.width - list.width) < 1)
        } else {
            verify(scrollBar.size >= 0.999)
        }
    }

    function test_languageAndPreferenceRoundTrips_data() {
        return [
            { tag: "english", language: "en" },
            { tag: "persian", language: "fa" },
            { tag: "arabic", language: "ar" }
        ]
    }

    function test_languageAndPreferenceRoundTrips(data) {
        var controller = createController()
        controller.sourceText = "private draft متن"
        compare(controller.keyboardDrawerOpen, false)
        controller.setUiLanguage(data.language)
        controller.setShapingProfile("kurdishUrdu")
        controller.setConversionMode("compatibility")
        controller.setReverseWords(false)
        controller.setVideoStudioPro(true)
        controller.setEditorFontSize(22)
        controller.setKeyboardDrawerOpen(true)
        verify(controller.setAccentPreset("faint"))
        verify(!controller.setAccentPreset("not-a-color"))
        controller.setBaseOption("deleteTatweel", true)
        controller.toggleLigature("ARABIC LIGATURE AKBAR")
        controller.toggleLigature("RIAL SIGN")
        controller.toggleTextTool("persianDigits")
        controller.toggleTextTool("englishDigits")
        controller.toggleTextTool("repairZwnj")
        controller.setExportSettings({
            advancedVisible: true,
            automaticWidth: false,
            automaticHeight: false,
            alignment: "center",
            fontSize: "72",
            lineSpacing: "1.5",
            width: "900",
            height: "400",
            padding: "24",
            precision: "4",
            fontIndex: "2",
            fill: "#12345678",
            axes: "400, 75"
        })
        verify(controller.setFontPath("unicode", "/fonts/unicode.ttf"))
        verify(controller.setFontPath("compatibility", "/fonts/compatibility.otf"))

        var saved = JSON.parse(settingsStoreMock.data)
        compare(saved.schemaVersion, 1)
        compare(saved.uiLanguage, data.language)
        compare(saved.shapingProfile, "kurdishUrdu")
        compare(saved.desktop.conversionMode, "compatibility")
        compare(saved.desktop.reverseWords, false)
        compare(saved.desktop.videoStudioPro, true)
        compare(saved.desktop.fontPaths.unicode, "/fonts/unicode.ttf")
        compare(saved.desktop.fontPaths.compatibility, "/fonts/compatibility.otf")
        compare(saved.settings.deleteTatweel, true)
        compare(saved.settings.ligatures["ARABIC LIGATURE AKBAR"], true)
        compare(saved.settings.ligatures["RIAL SIGN"], false)
        verify(saved.settings.language === undefined)
        compare(saved.desktop.exportSettings.advancedVisible, true)
        compare(saved.desktop.exportSettings.automaticWidth, false)
        compare(saved.desktop.exportSettings.automaticHeight, false)
        compare(saved.desktop.exportSettings.alignment, "center")
        compare(saved.desktop.exportSettings.fontSize, "72")
        compare(saved.desktop.editorFontSize, 22)
        compare(saved.desktop.keyboardDrawerOpen, true)
        compare(saved.desktop.accentPreset, "faint")
        compare(saved.desktop.exportSettings.lineSpacing, "1.5")
        compare(saved.desktop.exportSettings.width, "900")
        compare(saved.desktop.exportSettings.height, "400")
        compare(saved.desktop.exportSettings.padding, "24")
        compare(saved.desktop.exportSettings.precision, "4")
        compare(saved.desktop.exportSettings.fontIndex, "2")
        compare(saved.desktop.exportSettings.fill, "#12345678")
        compare(saved.desktop.exportSettings.axes, "400, 75")
        compare(saved.textTools.persianDigits, false)
        compare(saved.textTools.englishDigits, true)
        compare(saved.textTools.repairZwnj, true)
        verify(settingsStoreMock.data.indexOf("private draft") === -1)
        verify(settingsStoreMock.data.indexOf("sourceText") === -1)
        verify(settingsStoreMock.data.indexOf("convertedText") === -1)
        verify(settingsStoreMock.data.indexOf("clipboardText") === -1)
        verify(settingsStoreMock.data.indexOf("statusText") === -1)

        var restored = createController()
        compare(restored.uiLanguage, data.language)
        compare(restored.shapingProfile, "kurdishUrdu")
        compare(restored.conversionMode, "compatibility")
        compare(restored.reverseWords, false)
        compare(restored.videoStudioPro, true)
        compare(restored.baseOption("deleteTatweel"), true)
        compare(restored.ligatureEnabled("ARABIC LIGATURE AKBAR"), true)
        compare(restored.ligatureEnabled("RIAL SIGN"), false)
        compare(restored.textToolEnabled("persianDigits"), false)
        compare(restored.textToolEnabled("englishDigits"), true)
        compare(restored.textToolEnabled("repairZwnj"), true)
        compare(restored.exportSettings.advancedVisible, true)
        compare(restored.exportSettings.automaticWidth, false)
        compare(restored.exportSettings.automaticHeight, false)
        compare(restored.exportSettings.alignment, "center")
        compare(restored.exportSettings.fontSize, "72")
        compare(restored.editorFontSize, 22)
        compare(restored.keyboardDrawerOpen, true)
        compare(restored.accentPreset, "faint")
        compare(AppTheme.accentPreset, "faint")
        compare(restored.exportSettings.lineSpacing, "1.5")
        compare(restored.exportSettings.width, "900")
        compare(restored.exportSettings.height, "400")
        compare(restored.exportSettings.padding, "24")
        compare(restored.exportSettings.precision, "4")
        compare(restored.exportSettings.fontIndex, "2")
        compare(restored.exportSettings.fill, "#12345678")
        compare(restored.exportSettings.axes, "400, 75")
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

    function test_documentWorkflowPreservesTextHistoryAndDirtyState() {
        var controller = createController()
        openDocumentSpy.target = controller
        saveDocumentSpy.target = controller
        unsavedChangesSpy.target = controller
        applicationCloseSpy.target = controller
        openDocumentSpy.clear()
        saveDocumentSpy.clear()
        unsavedChangesSpy.clear()
        applicationCloseSpy.clear()

        compare(controller.documentDisplayName, controller.uiText("document.untitled"))
        verify(!controller.documentDirty)
        controller.sourceText = "draft\n\n"
        verify(controller.documentDirty)
        verify(controller.windowTitle.indexOf("*") === 0)

        controller.openDocument()
        compare(unsavedChangesSpy.count, 1)
        compare(openDocumentSpy.count, 0)
        controller.resolveUnsavedChanges("cancel")
        compare(controller.sourceText, "draft\n\n")

        controller.openDocument()
        controller.resolveUnsavedChanges("discard")
        compare(openDocumentSpy.count, 1)
        verify(controller.openDocumentUrl("file:///tmp/existing.txt"))
        compare(controller.sourceText, "first\n\nپارسی\n")
        compare(controller.documentPath, "/tmp/existing.txt")
        verify(!controller.documentDirty)
        verify(!controller.canUndo)
        verify(controller.saveDocumentAsUrl("file:///tmp/roundtrip.txt"))
        compare(fileBridgeMock.documents["/tmp/roundtrip.txt"], "first\r\n\r\nپارسی\r\n")

        controller.sourceText = "changed\n\n"
        verify(controller.saveDocument())
        compare(fileBridgeMock.documents["/tmp/roundtrip.txt"], "changed\r\n\r\n")
        verify(!controller.documentDirty)

        controller.sourceText = "save as"
        controller.saveDocumentAs()
        compare(saveDocumentSpy.count, 1)
        verify(controller.saveDocumentAsUrl("file:///tmp/copy.txt"))
        compare(fileBridgeMock.documents["/tmp/copy.txt"], "save as")
        compare(controller.documentPath, "/tmp/copy.txt")
        verify(!controller.documentDirty)

        controller.sourceText = "unsafe"
        fileBridgeMock.acceptDocumentWrites = false
        verify(!controller.saveDocument())
        compare(controller.sourceText, "unsafe")
        verify(controller.documentDirty)
        verify(controller.canUndo)

        controller.requestApplicationClose()
        compare(unsavedChangesSpy.count, 3)
        compare(applicationCloseSpy.count, 0)
        controller.resolveUnsavedChanges("cancel")
        compare(controller.sourceText, "unsafe")

        controller.newDocument()
        controller.resolveUnsavedChanges("discard")
        compare(controller.sourceText, "")
        compare(controller.documentPath, "")
        verify(!controller.documentDirty)
        verify(!controller.canUndo)
        verify(!controller.canRedo)

        controller.requestApplicationClose()
        compare(applicationCloseSpy.count, 1)

        openDocumentSpy.target = null
        saveDocumentSpy.target = null
        unsavedChangesSpy.target = null
        applicationCloseSpy.target = null
    }

    function test_settingsPageNavigationMirroringAndHebrewVisibility() {
        var applicationWindow = createTemporaryObject(mainWindowComponent, null)
        verify(applicationWindow !== null)
        tryCompare(applicationWindow, "bundledFontReady", true, 5000)
        tryCompare(applicationWindow, "bundledIconFontReady", true, 5000)
        var controller = applicationWindow.editorController
        var documentButton = findChild(applicationWindow, "documentButton")
        var settingsButton = findChild(applicationWindow, "settingsButton")
        var textToolsButton = findChild(applicationWindow, "textToolsButton")
        var exportButton = findChild(applicationWindow, "exportButton")
        var helpButton = findChild(applicationWindow, "helpButton")
        var headerBackButton = findChild(applicationWindow, "headerBackButton")
        var headerActions = findChild(applicationWindow, "headerActions")
        var settingsPage = findChild(applicationWindow, "settingsPage")
        var englishButton = findChild(applicationWindow, "languageEnglishButton")
        var persianButton = findChild(applicationWindow, "languagePersianButton")
        var arabicButton = findChild(applicationWindow, "languageArabicButton")
        var standardButton = findChild(applicationWindow, "settingsProfileStandard")
        var kurdishButton = findChild(applicationWindow, "settingsProfileKurdish")
        var hebrewButton = findChild(applicationWindow, "settingsProfileHebrew")
        var deleteHarakat = findChild(applicationWindow, "base_deleteHarakat")
        var sentencesButton = findChild(applicationWindow, "ligatureGroup_sentences")
        var wordsButton = findChild(applicationWindow, "ligatureGroup_words")
        var lettersButton = findChild(applicationWindow, "ligatureGroup_letters")
        var ligatureList = findChild(applicationWindow, "ligatureList")
        var unicodeButton = findChild(applicationWindow, "unicodeButton")
        var convertButton = findChild(applicationWindow, "convertButton")

        verify(documentButton !== null)
        verify(settingsButton !== null)
        verify(textToolsButton !== null)
        verify(exportButton !== null)
        verify(helpButton !== null)
        verify(headerBackButton !== null)
        verify(headerActions.visible)
        verify(documentButton.x < exportButton.x)
        verify(exportButton.x < textToolsButton.x)
        verify(textToolsButton.x < settingsButton.x)
        verify(settingsButton.x < helpButton.x)
        settingsButton.click()
        compare(controller.page, "settings")
        verify(settingsPage.visible)
        tryVerify(function() { return settingsPage.settingsScroll.height > 0 })
        verify(headerActions.visible)
        verify(headerBackButton.visible)
        verifyScrollGutter(settingsPage.settingsScroll, false)
        compare(englishButton.width, persianButton.width)
        compare(persianButton.width, arabicButton.width)
        compare(standardButton.width, kurdishButton.width)
        compare(kurdishButton.width, hebrewButton.width)

        persianButton.click()
        compare(controller.uiLanguage, "fa")
        verifyScrollGutter(settingsPage.settingsScroll, true)
        verify(settingsPage.LayoutMirroring.enabled)
        verify(headerActions.LayoutMirroring.enabled)
        compare(headerBackButton.glyph, AppTheme.iconForward)

        arabicButton.click()
        compare(controller.uiLanguage, "ar")
        verifyScrollGutter(settingsPage.settingsScroll, true)
        verify(settingsPage.LayoutMirroring.enabled)
        verify(headerActions.LayoutMirroring.enabled)
        compare(headerBackButton.glyph, AppTheme.iconForward)

        sentencesButton.click()
        compare(settingsPage.ligatureGroupId, "sentences")
        compare(ligatureList.count, 3)
        tryVerify(function() { return ligatureList.height > 0 })
        tryCompare(ligatureList, "overflowing", false)
        verifyLigatureGutter(ligatureList, true)
        headerBackButton.click()

        wordsButton.click()
        compare(settingsPage.ligatureGroupId, "words")
        compare(ligatureList.count, 9)
        tryVerify(function() { return ligatureList.itemAtIndex(0) !== null })
        verifyLigatureGutter(ligatureList, true)
        var firstWordToggle = findChild(ligatureList.itemAtIndex(0), "ligatureRow_0")
        compare(firstWordToggle.leftPadding, AppTheme.spacingLarge)
        compare(firstWordToggle.rightPadding, AppTheme.spacingLarge)
        headerBackButton.click()
        compare(settingsPage.ligatureGroupId, "")

        lettersButton.click()
        compare(ligatureList.count, 274)
        tryCompare(ligatureList, "overflowing", true)
        tryVerify(function() { return ligatureList.itemAtIndex(0) !== null })
        verifyLigatureGutter(ligatureList, true)
        ligatureList.contentY = 200
        tryVerify(function() { return ligatureList.ScrollBar.vertical.position > 0 })
        ligatureList.contentY = 0
        tryVerify(function() { return ligatureList.itemAtIndex(0) !== null })
        controller.setUiLanguage("en")
        verifyLigatureGutter(ligatureList, false)
        controller.setUiLanguage("ar")
        settingsPage.closeGroup()
        hebrewButton.click()
        compare(controller.shapingProfile, "hebrew")
        verify(!deleteHarakat.visible)
        verify(!wordsButton.visible)
        standardButton.click()
        verify(deleteHarakat.visible)
        verify(wordsButton.visible)

        headerBackButton.click()
        compare(controller.page, "editor")
        wait(0)
        verify(headerActions.visible)
        verify(!headerBackButton.visible)
        verify(documentButton.x > exportButton.x)
        verify(exportButton.x > textToolsButton.x)
        verify(textToolsButton.x > settingsButton.x)
        verify(settingsButton.x > helpButton.x)
        verify(convertButton.mapToItem(applicationWindow.contentItem, 0, 0).x
            < unicodeButton.mapToItem(applicationWindow.contentItem, 0, 0).x)

        var mirroredContainer = createTemporaryObject(mirroredNumberComponent, null)
        verify(mirroredContainer !== null)
        var numberField = findChild(mirroredContainer, "mirroredNumberField")
        compare(numberField.horizontalAlignment, TextInput.AlignLeft)
        compare(numberField.text, "48")
    }
}
