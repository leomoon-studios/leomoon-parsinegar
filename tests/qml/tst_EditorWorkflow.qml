import QtQuick
import QtQuick.Controls
import QtTest
import LeoMoon.ParsiNegar

TestCase {
    id: testCase
    name: "EditorWorkflow"
    when: windowShown

    Component {
        id: mainWindowComponent
        Main {
            visible: true
            property QtObject clipboardMock: QtObject {
                property string text: ""
                property string lastError: ""
                property int writeCount: 0
                property bool acceptWrites: true

                function copyText(value) {
                    writeCount++
                    if (!acceptWrites) {
                        lastError = "Test clipboard failure."
                        return false
                    }
                    text = value
                    lastError = ""
                    return true
                }
            }
            clipboardService: clipboardMock
        }
    }

    function createMainWindow() {
        var applicationWindow = createTemporaryObject(mainWindowComponent, null)
        verify(applicationWindow !== null)
        tryCompare(applicationWindow, "bundledFontReady", true, 5000)
        verify(applicationWindow.editorController !== null)
        return applicationWindow
    }

    function convertAndCompare(controller, source, expected) {
        controller.sourceText = source
        verify(controller.convertAndCopy())
        verify(controller.busy)
        tryCompare(controller, "busy", false, 20000)
        compare(controller.clipboardBridge.text, expected)
        compare(controller.lastOutput, expected)
        compare(controller.sourceText, source)
        compare(controller.statusLevel, "success")
        compare(controller.statusText, controller.uiText("status.converted"))
    }

    function repeated(character, count) {
        return new Array(count + 1).join(character)
    }

    function test_profileModeAndDirectionControls() {
        var applicationWindow = createMainWindow()
        var controller = applicationWindow.editorController
        var sourceEditor = findChild(applicationWindow, "sourceEditor")
        var settingsButton = findChild(applicationWindow, "settingsButton")
        verify(settingsButton !== null)
        var unicodeButton = findChild(applicationWindow, "unicodeButton")
        var compatibilityButton = findChild(applicationWindow, "compatibilityButton")
        var convertButton = findChild(applicationWindow, "convertButton")
        var standardProfile = findChild(applicationWindow, "settingsProfileStandard")
        var hebrewProfile = findChild(applicationWindow, "settingsProfileHebrew")
        var videoStudioToggle = findChild(applicationWindow, "settingsVideoToggle")
        var bidiToggle = findChild(applicationWindow, "settingsBidiToggle")
        var headerBackButton = findChild(applicationWindow, "headerBackButton")

        verify(sourceEditor !== null)
        verify(unicodeButton !== null)
        verify(compatibilityButton !== null)
        verify(convertButton !== null)
        verify(standardProfile !== null)
        verify(hebrewProfile !== null)
        verify(videoStudioToggle !== null)
        verify(bidiToggle !== null)
        verify(headerBackButton !== null)

        compare(unicodeButton.width, compatibilityButton.width)
        compare(unicodeButton.height, compatibilityButton.height)
        verify(unicodeButton.y < compatibilityButton.y)
        verify(convertButton.mapToItem(applicationWindow.contentItem, 0, 0).x
            > unicodeButton.mapToItem(applicationWindow.contentItem, 0, 0).x)
        compare(unicodeButton.title, controller.uiText("mode.unicode"))
        compare(unicodeButton.description, controller.uiText("mode.unicodeDescription"))
        compare(compatibilityButton.description, controller.uiText("mode.compatibilityDescription"))
        verify(unicodeButton.selected)
        verify(!compatibilityButton.selected)
        compatibilityButton.click()
        compare(controller.conversionMode, "compatibility")
        verify(!unicodeButton.selected)
        verify(compatibilityButton.selected)
        settingsButton.click()
        compare(controller.page, "settings")
        verify(headerBackButton.visible)
        verify(videoStudioToggle.enabled)
        hebrewProfile.click()
        compare(controller.shapingProfile, "hebrew")
        compare(controller.conversionMode, "unicode")
        verify(!compatibilityButton.enabled)
        verify(!videoStudioToggle.enabled)
        standardProfile.click()
        compare(controller.shapingProfile, "standardPersianArabic")
        compare(controller.conversionMode, "compatibility")

        verify(controller.reverseWords)
        bidiToggle.toggleItem.click()
        compare(controller.reverseWords, false)

        headerBackButton.click()
        compare(controller.page, "editor")
        verify(compatibilityButton.enabled)
    }

    function test_exactClipboardConversionsAcrossScriptsAndModes() {
        var applicationWindow = createMainWindow()
        var controller = applicationWindow.editorController
        var statusSlot = findChild(applicationWindow, "statusSlot")
        var editorScroll = findChild(applicationWindow, "editorScroll")
        var initialStatusHeight = statusSlot.height
        var initialEditorHeight = editorScroll.height
        controller.reverseWords = false

        controller.setShapingProfile("standardPersianArabic")
        controller.setConversionMode("unicode")
        convertAndCompare(controller, "سلام", "\ufeb3\ufefc\ufee1")
        compare(statusSlot.height, initialStatusHeight)
        compare(editorScroll.height, initialEditorHeight)
        convertAndCompare(controller, "تت", "\ufe97\ufe96")

        controller.setShapingProfile("kurdishUrdu")
        convertAndCompare(controller, "ب", "ب")

        controller.setShapingProfile("hebrew")
        controller.reverseWords = true
        convertAndCompare(controller, "אב", "בא")

        controller.setShapingProfile("standardPersianArabic")
        controller.reverseWords = true
        convertAndCompare(controller, "پ abc 12", "abc 12 \ufb56")
        convertAndCompare(controller, "سلام.\nsalam.\nچطوری؟", ".ﻡﻼﺳ\nsalam.\n؟ﯼﺭﻮﻄﭼ")

        controller.reverseWords = false
        convertAndCompare(controller, "\nپ\n\nت\n", "\n\ufb56\n\n\ufe95\n")

        controller.setConversionMode("compatibility")
        controller.videoStudioPro = true
        convertAndCompare(controller, "فف", "\u00ce\u00fe")

        controller.setConversionMode("unicode")
        convertAndCompare(controller, "", "")
        compare(controller.clipboardBridge.writeCount, 9)
    }

    function test_oversizedWorkerAndClipboardFailuresAreVisible() {
        var applicationWindow = createMainWindow()
        var controller = applicationWindow.editorController

        controller.uiLanguage = "fa"
        controller.sourceText = repeated("پ", controller.maximumTextLength + 1)
        verify(!controller.convertAndCopy())
        verify(!controller.busy)
        compare(controller.statusLevel, "error")
        compare(controller.statusText, controller.uiText("status.textTooLarge"))
        compare(controller.clipboardBridge.writeCount, 0)

        controller.uiLanguage = "en"
        controller.sourceText = "\u2066x\u2069"
        controller.reverseWords = true
        verify(controller.convertAndCopy())
        tryCompare(controller, "busy", false, 20000)
        compare(controller.statusLevel, "error")
        verify(controller.statusText.indexOf(controller.uiText("status.failure")) === 0)
        compare(controller.clipboardBridge.writeCount, 0)

        controller.clipboardBridge.acceptWrites = false
        controller.sourceText = "پ"
        controller.reverseWords = false
        verify(controller.convertAndCopy())
        tryCompare(controller, "busy", false, 20000)
        compare(controller.statusLevel, "error")
        verify(controller.statusText.indexOf("Test clipboard failure.") !== -1)
        compare(controller.sourceText, "پ")
    }

    function test_enabledTextToolsUpdateSourceBeforeConversionAndCanBeUndone() {
        var applicationWindow = createMainWindow()
        var controller = applicationWindow.editorController
        controller.reverseWords = false
        controller.toggleTextTool("repairZwnj")
        controller.toggleTextTool("persianDigits")
        controller.sourceText = "می روم\n\nمیدان 12%"

        verify(controller.convertAndCopy())
        compare(controller.sourceText, "می‌روم\n\nمیدان ۱۲٪")
        tryCompare(controller, "busy", false, 20000)
        verify(controller.statusText.indexOf(controller.uiText("tools.appliedStatus")) !== -1)
        verify(controller.textToolsUndoText !== "")
        verify(controller.undoTextTools())
        compare(controller.sourceText, "می روم\n\nمیدان 12%")
        compare(controller.statusText, controller.uiText("tools.undoStatus"))
    }

    function test_maximumRequestKeepsSceneResponsiveAndRejectsRaces() {
        var applicationWindow = createMainWindow()
        var controller = applicationWindow.editorController
        var source = repeated("پ", controller.maximumTextLength)
        var expected = "\ufb58" + repeated("\ufb59", controller.maximumTextLength - 2) + "\ufb57"
        var heartbeat = false
        var busyAtHeartbeat = false

        controller.reverseWords = false
        controller.sourceText = source
        controller.clipboardBridge.text = "sentinel"
        verify(controller.convertAndCopy())
        var activeId = controller.conversionRequestId
        verify(controller.busy)
        verify(!controller.convertAndCopy())
        compare(controller.conversionRequestId, activeId)
        verify(!controller.finishConversion({ id: activeId - 1, ok: true, output: "stale" }))
        compare(controller.clipboardBridge.text, "sentinel")
        verify(controller.busy)

        Qt.callLater(function() {
            heartbeat = true
            busyAtHeartbeat = controller.busy
        })
        tryVerify(function() { return heartbeat }, 5000)
        verify(busyAtHeartbeat)
        tryCompare(controller, "busy", false, 30000)
        compare(controller.clipboardBridge.text, expected)
        compare(controller.sourceText, source)
        compare(controller.clipboardBridge.writeCount, 1)
    }
}
