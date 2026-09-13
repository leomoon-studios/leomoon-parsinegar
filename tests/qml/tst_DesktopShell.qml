import QtQuick
import QtQuick.Controls
import QtTest
import LeoMoon.ParsiNegar

TestCase {
    id: testCase
    name: "DesktopShell"
    when: windowShown

    Component {
        id: mainWindowComponent
        Main {
            visible: true
            property QtObject clipboardMock: QtObject {
                property string text: ""
                property string lastError: ""
                function copyText(value) {
                    text = value
                    return true
                }
            }
            clipboardService: clipboardMock
        }
    }

    Component {
        id: brokenTypographyComponent
        Typography {
            fontSource: "qrc:/fonts/does-not-exist.ttf"
            fallbackFamily: "sans-serif"
        }
    }

    function createMainWindow() {
        var applicationWindow = createTemporaryObject(mainWindowComponent, null)
        verify(applicationWindow !== null)
        tryCompare(applicationWindow, "bundledFontReady", true, 5000)
        return applicationWindow
    }

    function test_windowResizesWithoutClipping() {
        var applicationWindow = createMainWindow()
        var contentLayout = findChild(applicationWindow, "contentLayout")
        var editorPageScroll = findChild(applicationWindow, "editorPageScroll")
        verify(contentLayout !== null)
        verify(editorPageScroll !== null)

        applicationWindow.width = applicationWindow.minimumWidth
        applicationWindow.height = applicationWindow.minimumHeight
        wait(0)
        verify(contentLayout.x >= 0)
        verify(contentLayout.y >= 0)
        verify(contentLayout.x + contentLayout.width <= applicationWindow.contentItem.width + 0.5)
        verify(contentLayout.y + contentLayout.height <= applicationWindow.contentItem.height + 0.5)
        verify(editorPageScroll.width > 0)
        verify(editorPageScroll.height > 0)

        applicationWindow.width = 1100
        applicationWindow.height = 760
        wait(0)
        verify(contentLayout.x + contentLayout.width <= applicationWindow.contentItem.width + 0.5)
        verify(contentLayout.y + contentLayout.height <= applicationWindow.contentItem.height + 0.5)
    }

    function test_keyboardFocusHasVisibleTreatment() {
        var applicationWindow = createMainWindow()
        var themeButton = findChild(applicationWindow, "themeButton")
        verify(themeButton !== null)

        applicationWindow.requestActivate()
        tryCompare(applicationWindow, "active", true, 2000)
        themeButton.forceActiveFocus(Qt.TabFocusReason)
        tryCompare(themeButton, "activeFocus", true)
        verify(themeButton.focusIndicatorVisible)
        compare(themeButton.background.border.width, AppTheme.focusBorderWidth)
        compare(themeButton.background.border.color, AppTheme.focus)
    }

    function test_lightAndDarkPalettesRemainLegible() {
        var originalMode = AppTheme.darkMode
        var modes = [true, false]
        for (var index = 0; index < modes.length; index++) {
            AppTheme.darkMode = modes[index]
            verify(AppTheme.contrastRatio(AppTheme.foreground, AppTheme.background) >= 4.5)
            verify(AppTheme.contrastRatio(AppTheme.foreground, AppTheme.surface) >= 4.5)
            verify(AppTheme.contrastRatio(AppTheme.muted, AppTheme.background) >= 4.5)
            verify(AppTheme.contrastRatio(AppTheme.accentText, AppTheme.accent) >= 4.5)
        }
        AppTheme.darkMode = originalMode
    }

    function test_reusableControlsAndThemeSwitch() {
        var applicationWindow = createMainWindow()
        var convertButton = findChild(applicationWindow, "convertButton")
        var bidiToggle = findChild(applicationWindow, "bidiToggle")
        var sourceEditor = findChild(applicationWindow, "sourceEditor")
        var conversionStatus = findChild(applicationWindow, "conversionStatus")
        var themeButton = findChild(applicationWindow, "themeButton")
        verify(convertButton !== null)
        verify(bidiToggle !== null)
        verify(sourceEditor !== null)
        verify(conversionStatus !== null)
        verify(convertButton.accent)
        verify(bidiToggle.checked)
        compare(sourceEditor.horizontalAlignment, TextEdit.AlignRight)

        var originalMode = AppTheme.darkMode
        themeButton.click()
        compare(AppTheme.darkMode, !originalMode)
        themeButton.click()
        compare(AppTheme.darkMode, originalMode)
    }

    function test_typographyFallsBackWhenBundledFontFails() {
        var typography = createTemporaryObject(brokenTypographyComponent, null)
        verify(typography !== null)
        tryCompare(typography, "failed", true, 5000)
        compare(typography.family, "sans-serif")
        verify(typography.errorMessage.length > 0)
    }
}
