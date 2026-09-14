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
        tryCompare(applicationWindow, "bundledIconFontReady", true, 5000)
        return applicationWindow
    }

    function test_windowResizesWithoutClipping() {
        var applicationWindow = createMainWindow()
        var contentLayout = findChild(applicationWindow, "contentLayout")
        var editorPage = findChild(applicationWindow, "editorPage")
        var editorScroll = findChild(applicationWindow, "editorScroll")
        var conversionActions = findChild(applicationWindow, "conversionActions")
        verify(contentLayout !== null)
        verify(editorPage !== null)
        verify(editorScroll !== null)
        verify(conversionActions !== null)
        verify(findChild(applicationWindow, "editorPageScroll") === null)

        applicationWindow.width = applicationWindow.minimumWidth
        applicationWindow.height = applicationWindow.minimumHeight
        wait(0)
        verify(contentLayout.x >= 0)
        verify(contentLayout.y >= 0)
        verify(contentLayout.x + contentLayout.width <= applicationWindow.contentItem.width + 0.5)
        verify(contentLayout.y + contentLayout.height <= applicationWindow.contentItem.height + 0.5)
        verify(editorPage.width > 0)
        verify(editorPage.height > 0)
        verify(editorScroll.height > 0)
        var compactEditorHeight = editorScroll.height
        var compactActionsHeight = conversionActions.height

        applicationWindow.width = 1100
        applicationWindow.height = 760
        wait(0)
        verify(contentLayout.x + contentLayout.width <= applicationWindow.contentItem.width + 0.5)
        verify(contentLayout.y + contentLayout.height <= applicationWindow.contentItem.height + 0.5)
        verify(editorScroll.height > compactEditorHeight)
        verify(conversionActions.height <= compactActionsHeight)
        verify(editorScroll.height > conversionActions.height)
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
        var exportButton = findChild(applicationWindow, "exportButton")
        var settingsButton = findChild(applicationWindow, "settingsButton")
        var sourceEditor = findChild(applicationWindow, "sourceEditor")
        var editorCursor = findChild(applicationWindow, "editorCursor")
        var conversionStatus = findChild(applicationWindow, "conversionStatus")
        var statusSlot = findChild(applicationWindow, "statusSlot")
        var themeButton = findChild(applicationWindow, "themeButton")
        verify(convertButton !== null)
        verify(exportButton !== null)
        verify(settingsButton !== null)
        verify(sourceEditor !== null)
        verify(editorCursor !== null)
        sourceEditor.forceActiveFocus()
        tryCompare(sourceEditor, "activeFocus", true)
        verify(editorCursor.visible)
        compare(editorCursor.x, sourceEditor.cursorRectangle.x)
        compare(sourceEditor.horizontalAlignment, TextEdit.AlignRight)
        verify(conversionStatus !== null)
        verify(statusSlot !== null)
        compare(statusSlot.height, 44)
        verify(!conversionStatus.visible)
        verify(convertButton.accent)
        verify(convertButton.width >= 120)
        verify(convertButton.width <= 200)
        compare(convertButton.contentItem.font.pixelSize, AppTheme.fontHeading)
        compare(convertButton.contentItem.font.weight, Font.Bold)
        verify(findChild(applicationWindow, "profile_standardPersianArabic") === null)
        verify(findChild(applicationWindow, "bidiToggle") === null)
        compare(settingsButton.glyph, AppTheme.iconSettings)
        compare(exportButton.glyph, AppTheme.iconExport)
        verify(exportButton.glyph !== "")
        compare(exportButton.contentItem.font.family, AppTheme.iconFontFamily)
        compare(themeButton.contentItem.font.family, AppTheme.iconFontFamily)
        compare(settingsButton.width, themeButton.width)

        var originalMode = AppTheme.darkMode
        var originalThemeGlyph = themeButton.glyph
        themeButton.click()
        compare(AppTheme.darkMode, !originalMode)
        verify(themeButton.glyph !== originalThemeGlyph)
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

    function test_exportPageNavigationAndResponsiveControls() {
        var applicationWindow = createMainWindow()
        var controller = applicationWindow.editorController
        var exportButton = findChild(applicationWindow, "exportButton")
        var exportPage = findChild(applicationWindow, "exportPage")
        var headerBackButton = findChild(applicationWindow, "headerBackButton")
        var exportScroll = findChild(applicationWindow, "exportScroll")
        var alignLeft = findChild(applicationWindow, "exportAlignLeft")
        var alignCenter = findChild(applicationWindow, "exportAlignCenter")
        var alignRight = findChild(applicationWindow, "exportAlignRight")
        var compatibility = findChild(applicationWindow, "exportCompatibilityButton")
        var saveButton = findChild(applicationWindow, "saveSvgButton")
        verify(exportButton !== null)
        verify(exportPage !== null)
        verify(headerBackButton !== null)
        verify(exportScroll !== null)
        verify(alignLeft !== null)
        verify(alignCenter !== null)
        verify(alignRight !== null)
        verify(compatibility !== null)
        verify(saveButton !== null)

        controller.sourceText = "draft متن"
        exportButton.click()
        compare(controller.page, "export")
        verify(exportPage.visible)
        verify(findChild(applicationWindow, "headerActions").visible)
        verify(headerBackButton.visible)
        compare(headerBackButton.glyph, AppTheme.iconBack)
        compare(exportScroll.leftPadding, AppTheme.spacingLarge)
        compare(exportScroll.rightPadding, AppTheme.spacingLarge)
        verify(Math.abs(alignLeft.width - alignCenter.width) <= 1)
        verify(Math.abs(alignCenter.width - alignRight.width) <= 1)
        verify(alignRight.selected)
        compare(exportPage.fontDisplayName(), controller.uiText("export.bundledFont"))
        verify(exportPage.validateBeforeSave())

        compatibility.click()
        compare(controller.conversionMode, "compatibility")
        verify(!exportPage.validateBeforeSave())
        compare(exportPage.statusText, controller.uiText("export.error.fontRequired"))

        headerBackButton.click()
        compare(controller.page, "editor")
        compare(controller.sourceText, "draft متن")
    }
}
