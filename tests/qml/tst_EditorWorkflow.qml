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
        var ltrButton = findChild(applicationWindow, "ltrButton")
        var rtlButton = findChild(applicationWindow, "rtlButton")
        var compatibilityButton = findChild(applicationWindow, "compatibilityButton")
        var standardProfile = findChild(applicationWindow, "profile_standardPersianArabic")
        var hebrewProfile = findChild(applicationWindow, "profile_hebrew")
        var videoStudioToggle = findChild(applicationWindow, "videoStudioToggle")
        var bidiToggle = findChild(applicationWindow, "bidiToggle")

        verify(sourceEditor !== null)
        verify(ltrButton !== null)
        verify(rtlButton !== null)
        verify(compatibilityButton !== null)
        verify(standardProfile !== null)
        verify(hebrewProfile !== null)
        verify(videoStudioToggle !== null)
        verify(bidiToggle !== null)

        compare(sourceEditor.horizontalAlignment, TextEdit.AlignRight)
        ltrButton.click()
        compare(controller.editorRtl, false)
        compare(sourceEditor.horizontalAlignment, TextEdit.AlignLeft)
        rtlButton.click()
        compare(controller.editorRtl, true)

        compatibilityButton.click()
        compare(controller.conversionMode, "compatibility")
        verify(videoStudioToggle.enabled)
        hebrewProfile.click()
        compare(controller.shapingProfile, "hebrew")
        compare(controller.conversionMode, "unicode")
        verify(!compatibilityButton.enabled)
        verify(!videoStudioToggle.enabled)
        standardProfile.click()
        compare(controller.shapingProfile, "standardPersianArabic")
        compare(controller.conversionMode, "compatibility")
        verify(compatibilityButton.enabled)

        verify(controller.reverseWords)
        bidiToggle.click()
        compare(controller.reverseWords, false)
    }

    function test_exactClipboardConversionsAcrossScriptsAndModes() {
        var applicationWindow = createMainWindow()
        var controller = applicationWindow.editorController
        controller.reverseWords = false

        controller.setShapingProfile("standardPersianArabic")
        controller.setConversionMode("unicode")
        convertAndCompare(controller, "سلام", "\ufeb3\ufefc\ufee1")
        convertAndCompare(controller, "تت", "\ufe97\ufe96")

        controller.setShapingProfile("kurdishUrdu")
        convertAndCompare(controller, "ب", "ب")

        controller.setShapingProfile("hebrew")
        controller.reverseWords = true
        convertAndCompare(controller, "אב", "בא")

        controller.setShapingProfile("standardPersianArabic")
        controller.reverseWords = true
        convertAndCompare(controller, "پ abc 12", "abc 12 \ufb56")

        controller.reverseWords = false
        convertAndCompare(controller, "\nپ\n\nت\n", "\n\ufb56\n\n\ufe95\n")

        controller.setConversionMode("compatibility")
        controller.videoStudioPro = true
        convertAndCompare(controller, "فف", "\u00ce\u00fe")

        controller.setConversionMode("unicode")
        convertAndCompare(controller, "", "")
        compare(controller.clipboardBridge.writeCount, 8)
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
