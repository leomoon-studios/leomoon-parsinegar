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
            property QtObject fileMock: QtObject {
                function readBundledFontAsync(requestId) { return true }
                function readFontAsync(requestId, url) { return true }
                function writeSvgAsync(requestId, destination, svg) { return true }
                function localFileUrl(path) { return "file://" + path }
                function localFilePath(url) { return String(url) }
                function readTextDocument(url) { return { ok: false, code: "DOCUMENT_NOT_FOUND", message: "Missing" } }
                function writeTextDocument(url, text) { return { ok: true, path: String(url) } }
                function isReadableFontFile(path) { return true }
            }
            fileService: fileMock
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
        var controller = applicationWindow.editorController
        var convertButton = findChild(applicationWindow, "convertButton")
        var exportButton = findChild(applicationWindow, "exportButton")
        var textToolsButton = findChild(applicationWindow, "textToolsButton")
        var settingsButton = findChild(applicationWindow, "settingsButton")
        var documentButton = findChild(applicationWindow, "documentButton")
        var undoButton = findChild(applicationWindow, "undoButton")
        var redoButton = findChild(applicationWindow, "redoButton")
        var sourceEditor = findChild(applicationWindow, "sourceEditor")
        var editorCursor = findChild(applicationWindow, "editorCursor")
        var conversionStatus = findChild(applicationWindow, "conversionStatus")
        var statusSlot = findChild(applicationWindow, "statusSlot")
        var themeButton = findChild(applicationWindow, "themeButton")
        verify(convertButton !== null)
        verify(exportButton !== null)
        verify(textToolsButton !== null)
        verify(documentButton !== null)
        verify(settingsButton !== null)
        verify(undoButton !== null)
        verify(redoButton !== null)
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
        compare(documentButton.glyph, AppTheme.iconDocument)
        compare(exportButton.glyph, AppTheme.iconExport)
        compare(textToolsButton.glyph, AppTheme.iconTools)
        compare(undoButton.glyph, AppTheme.iconUndo)
        compare(redoButton.glyph, AppTheme.iconRedo)
        verify(textToolsButton.glyph !== "")
        verify(exportButton.glyph !== "")
        compare(exportButton.contentItem.font.family, AppTheme.iconFontFamily)
        compare(themeButton.contentItem.font.family, AppTheme.iconFontFamily)
        compare(settingsButton.width, themeButton.width)
        compare(documentButton.width, themeButton.width)
        compare(textToolsButton.width, themeButton.width)
        compare(undoButton.width, themeButton.width)
        compare(redoButton.width, themeButton.width)
        verify(!undoButton.enabled)
        verify(!redoButton.enabled)

        controller.sourceText = "one"
        verify(undoButton.enabled)
        undoButton.click()
        compare(controller.sourceText, "")
        verify(!undoButton.enabled)
        verify(redoButton.enabled)
        applicationWindow.requestActivate()
        tryCompare(applicationWindow, "active", true, 2000)
        tryCompare(sourceEditor, "activeFocus", true)
        keyClick(Qt.Key_Y, Qt.ControlModifier)
        compare(controller.sourceText, "one")
        verify(undoButton.enabled)
        verify(!redoButton.enabled)

        var originalMode = AppTheme.darkMode
        var originalThemeGlyph = themeButton.glyph
        themeButton.click()
        compare(AppTheme.darkMode, !originalMode)
        verify(themeButton.glyph !== originalThemeGlyph)
        themeButton.click()
        compare(AppTheme.darkMode, originalMode)
    }

    function test_documentMenuOpensAndDismissesWithApplicableActions() {
        var applicationWindow = createMainWindow()
        var controller = applicationWindow.editorController
        var documentButton = findChild(applicationWindow, "documentButton")
        var documentMenu = findChild(applicationWindow, "documentMenu")
        var newItem = findChild(applicationWindow, "newDocumentMenuItem")
        var saveItem = findChild(applicationWindow, "saveDocumentMenuItem")
        verify(documentButton !== null)
        verify(documentMenu !== null)
        verify(newItem !== null)
        verify(saveItem !== null)
        verify(!saveItem.enabled)
        compare(saveItem.opacity, 0.42)
        verify(saveItem.background.border.width > 0)

        documentButton.click()
        tryCompare(documentMenu, "visible", true)
        controller.sourceText = "draft"
        verify(saveItem.enabled)
        controller.resetDocument("", "")
        newItem.click()
        tryCompare(documentMenu, "visible", false)
        compare(controller.sourceText, "")
        verify(!controller.documentDirty)
    }

    function test_textToolsPageNavigationAndMirroring() {
        var applicationWindow = createMainWindow()
        var controller = applicationWindow.editorController
        var toolsButton = findChild(applicationWindow, "textToolsButton")
        var toolsPage = findChild(applicationWindow, "textToolsPage")
        var toolsScroll = findChild(applicationWindow, "textToolsScroll")
        var backButton = findChild(applicationWindow, "headerBackButton")
        verify(toolsButton !== null)
        verify(toolsPage !== null)
        verify(toolsScroll !== null)

        toolsButton.click()
        compare(controller.page, "tools")
        verify(toolsPage.visible)
        tryVerify(function() { return toolsPage.height > 0 && toolsPage.contentImplicitHeight > toolsPage.height })
        verify(backButton.visible)
        compare(backButton.glyph, AppTheme.iconBack)
        compare(toolsScroll.leftPadding, AppTheme.spacingLarge)
        compare(toolsScroll.rightPadding, AppTheme.spacingLarge)

        controller.toggleTextTool("persianDigits")
        compare(controller.textToolEnabled("persianDigits"), true)
        controller.toggleTextTool("englishDigits")
        compare(controller.textToolEnabled("englishDigits"), true)
        compare(controller.textToolEnabled("persianDigits"), false)

        controller.setUiLanguage("fa")
        compare(backButton.glyph, AppTheme.iconForward)
        backButton.click()
        compare(controller.page, "editor")
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
        var fontSize = findChild(applicationWindow, "exportFontSize")
        var lineSpacing = findChild(applicationWindow, "exportLineSpacing")
        var moreOptions = findChild(applicationWindow, "exportMoreOptionsButton")
        verify(exportButton !== null)
        verify(exportPage !== null)
        verify(headerBackButton !== null)
        verify(exportScroll !== null)
        verify(alignLeft !== null)
        verify(alignCenter !== null)
        verify(alignRight !== null)
        verify(compatibility !== null)
        verify(saveButton !== null)
        verify(fontSize !== null)
        verify(lineSpacing !== null)
        verify(moreOptions !== null)

        controller.sourceText = "draft متن"
        controller.setExportSettings({ fontSize: "64", lineSpacing: "1.4", alignment: "center" })
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
        compare(fontSize.text, "64")
        compare(lineSpacing.text, "1.4")
        verify(alignCenter.selected)
        moreOptions.click()
        compare(controller.exportSettings.advancedVisible, true)
        alignLeft.click()
        compare(controller.exportSettings.alignment, "left")
        fontSize.text = "72"
        fontSize.editingFinished()
        compare(controller.exportSettings.fontSize, "72")
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

    function test_exportDoesNotApplyEnabledTextTools() {
        var applicationWindow = createMainWindow()
        var controller = applicationWindow.editorController
        var exportPage = findChild(applicationWindow, "exportPage")
        var exportController = applicationWindow.svgExportController
        var source = "می روم 12%"

        controller.sourceText = source
        controller.toggleTextTool("repairZwnj")
        controller.toggleTextTool("persianDigits")
        controller.openExport()
        var historyLength = controller.sourceHistory.undo.length
        exportPage.chosenDestination = "file:///tmp/text-tools-export-test.svg"

        verify(exportPage.beginExport())
        compare(exportController.pendingText, source)
        compare(controller.sourceText, source)
        compare(controller.sourceHistory.undo.length, historyLength)
        verify(exportController.cancel())
    }
}
