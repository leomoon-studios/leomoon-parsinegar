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
                property var fontEntries: [
                    { family: "Noto Sans", style: "Regular", display: "Noto Sans", path: "/fonts/noto.ttf" },
                    { family: "Roboto Mono", style: "Bold", display: "Roboto Mono — Bold", path: "/fonts/roboto-mono-bold.ttf" },
                    { family: "LMU Avvali", style: "Regular", display: "LMU Avvali", path: "/fonts/lmu-avvali.ttf" },
                    { family: "F_Test", style: "Regular", display: "F_Test", path: "/fonts/f-test.ttf" },
                    { family: "LMN Test", style: "Regular", display: "LMN Test", path: "/fonts/lmn-test.ttf" }
                ]
                property var fontCatalog: fontEntries
                property bool fontCatalogReady: true
                property bool fontCatalogScanning: false
                function readBundledFontAsync(requestId) { return true }
                function readFontAsync(requestId, url) { return true }
                function writeSvgAsync(requestId, destination, svg) { return true }
                function localFileUrl(path) { return "file://" + path }
                function localFilePath(url) { return String(url) }
                function scanInstalledFontsAsync() { return false }
                function refreshInstalledFontsAsync() {
                    if (fontCatalogScanning)
                        return false
                    fontCatalogScanning = true
                    return true
                }
                function fontPathExists(path) { return String(path).indexOf("/fonts/") === 0 }
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

    function test_headerDisplaysApplicationVersion() {
        var applicationWindow = createMainWindow()
        var applicationTitle = findChild(applicationWindow, "applicationTitle")
        var applicationVersion = findChild(applicationWindow, "applicationVersion")
        verify(applicationTitle !== null)
        verify(applicationVersion !== null)
        compare(applicationVersion.text, "v" + Qt.application.version)
        verify(applicationVersion.x >= applicationTitle.x + applicationTitle.width)
    }

    function test_keyboardFocusHasVisibleTreatment() {
        var applicationWindow = createMainWindow()
        var settingsButton = findChild(applicationWindow, "settingsButton")
        verify(settingsButton !== null)

        applicationWindow.requestActivate()
        tryCompare(applicationWindow, "active", true, 2000)
        settingsButton.forceActiveFocus(Qt.TabFocusReason)
        tryCompare(settingsButton, "activeFocus", true)
        verify(settingsButton.focusIndicatorVisible)
        compare(settingsButton.background.border.width, AppTheme.focusBorderWidth)
        compare(settingsButton.background.border.color, AppTheme.focus)
    }

    function test_pageAndConversionShortcuts() {
        var applicationWindow = createMainWindow()
        var controller = applicationWindow.editorController
        var clipboard = applicationWindow.clipboardMock
        verify(findChild(applicationWindow, "convertShortcut") !== null)
        verify(findChild(applicationWindow, "settingsShortcut") !== null)
        verify(findChild(applicationWindow, "textToolsShortcut") !== null)
        verify(findChild(applicationWindow, "exportShortcut") !== null)
        verify(findChild(applicationWindow, "helpShortcut") !== null)

        applicationWindow.requestActivate()
        tryCompare(applicationWindow, "active", true, 2000)

        keyClick(Qt.Key_T, Qt.ControlModifier)
        compare(controller.page, "tools")
        keyClick(Qt.Key_T, Qt.ControlModifier)
        compare(controller.page, "editor")

        keyClick(Qt.Key_E, Qt.ControlModifier)
        compare(controller.page, "export")
        keyClick(Qt.Key_E, Qt.ControlModifier)
        compare(controller.page, "editor")

        keyClick(Qt.Key_H, Qt.ControlModifier)
        compare(controller.page, "help")
        keyClick(Qt.Key_H, Qt.ControlModifier)
        compare(controller.page, "editor")

        keyClick(Qt.Key_Comma, Qt.ControlModifier)
        compare(controller.page, "settings")
        keyClick(Qt.Key_Comma, Qt.ControlModifier)
        compare(controller.page, "editor")

        controller.sourceText = "shortcut test"
        keyClick(Qt.Key_Return, Qt.ControlModifier)
        tryCompare(controller, "busy", false, 20000)
        compare(clipboard.text, "shortcut test")
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
        var helpButton = findChild(applicationWindow, "helpButton")
        var textToolsButton = findChild(applicationWindow, "textToolsButton")
        var settingsButton = findChild(applicationWindow, "settingsButton")
        var documentButton = findChild(applicationWindow, "documentButton")
        var undoButton = findChild(applicationWindow, "undoButton")
        var redoButton = findChild(applicationWindow, "redoButton")
        var sourceEditor = findChild(applicationWindow, "sourceEditor")
        var editorCursor = findChild(applicationWindow, "editorCursor")
        var conversionStatus = findChild(applicationWindow, "conversionStatus")
        var statusSlot = findChild(applicationWindow, "statusSlot")
        var settingsPage = findChild(applicationWindow, "settingsPage")
        var lightThemeButton = findChild(applicationWindow, "settingsLightThemeButton")
        var darkThemeButton = findChild(applicationWindow, "settingsDarkThemeButton")
        verify(convertButton !== null)
        verify(exportButton !== null)
        verify(helpButton !== null)
        verify(textToolsButton !== null)
        verify(documentButton !== null)
        verify(settingsButton !== null)
        verify(undoButton !== null)
        verify(redoButton !== null)
        verify(settingsPage !== null)
        verify(lightThemeButton !== null)
        verify(darkThemeButton !== null)
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
        compare(helpButton.glyph, AppTheme.iconHelp)
        compare(documentButton.glyph, AppTheme.iconDocument)
        compare(exportButton.glyph, AppTheme.iconExport)
        compare(textToolsButton.glyph, AppTheme.iconTools)
        compare(undoButton.glyph, AppTheme.iconUndo)
        compare(redoButton.glyph, AppTheme.iconRedo)
        verify(textToolsButton.glyph !== "")
        verify(exportButton.glyph !== "")
        compare(exportButton.contentItem.font.family, AppTheme.iconFontFamily)
        compare(settingsButton.contentItem.font.family, AppTheme.iconFontFamily)
        compare(documentButton.width, settingsButton.width)
        compare(helpButton.width, settingsButton.width)
        compare(textToolsButton.width, settingsButton.width)
        compare(undoButton.width, settingsButton.width)
        compare(redoButton.width, settingsButton.width)
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
        settingsButton.click()
        compare(controller.page, "settings")
        compare(lightThemeButton.selected, !originalMode)
        compare(darkThemeButton.selected, originalMode)
        lightThemeButton.click()
        compare(AppTheme.darkMode, false)
        compare(lightThemeButton.selected, true)
        compare(darkThemeButton.selected, false)
        darkThemeButton.click()
        compare(AppTheme.darkMode, true)
        compare(lightThemeButton.selected, false)
        compare(darkThemeButton.selected, true)
        AppTheme.darkMode = originalMode

        controller.setUiLanguage("fa")
        compare(lightThemeButton.text, "پوستهٔ روشن")
        compare(darkThemeButton.text, "پوستهٔ تیره")
        controller.setUiLanguage("en")
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
        controller.setUiLanguage("fa")
        compare(newItem.actionLabel.effectiveHorizontalAlignment, Text.AlignRight)
        verify(newItem.actionLabel.mapToItem(applicationWindow.contentItem, 0, 0).x
            > newItem.shortcutLabel.mapToItem(applicationWindow.contentItem, 0, 0).x)
        controller.setUiLanguage("en")
        controller.sourceText = "draft"
        verify(saveItem.enabled)
        controller.resetDocument("", "")
        newItem.click()
        tryCompare(documentMenu, "visible", false)
        compare(controller.sourceText, "")
        verify(!controller.documentDirty)
    }

    function test_editorContextMenuUsesTheMousePositionAndAppStyle() {
        var applicationWindow = createMainWindow()
        var sourceEditor = findChild(applicationWindow, "sourceEditor")
        var contextMenu = findChild(applicationWindow, "editorContextMenu")
        var contextUndo = findChild(applicationWindow, "contextUndoAction")
        var contextPaste = findChild(applicationWindow, "contextPasteAction")
        verify(sourceEditor !== null)
        verify(contextMenu !== null)
        verify(contextUndo !== null)
        verify(contextPaste !== null)

        var mouseX = 120
        var mouseY = 80
        mousePress(sourceEditor, mouseX, mouseY, Qt.RightButton)
        tryCompare(contextMenu, "visible", true)
        compare(contextMenu.requestedX, mouseX)
        compare(contextMenu.requestedY, mouseY)
        compare(contextMenu.background.color, AppTheme.surface)
        verify(!contextUndo.enabled)
        compare(contextUndo.opacity, 0.42)
        mouseRelease(sourceEditor, mouseX, mouseY, Qt.RightButton)
        contextMenu.close()
        tryCompare(contextMenu, "visible", false)
        applicationWindow.editorController.setUiLanguage("fa")
        mousePress(sourceEditor, mouseX, mouseY, Qt.RightButton)
        tryCompare(contextMenu, "visible", true)
        compare(contextUndo.actionLabel.effectiveHorizontalAlignment, Text.AlignRight)
        verify(contextUndo.actionLabel.mapToItem(applicationWindow.contentItem, 0, 0).x
            > contextUndo.shortcutLabel.mapToItem(applicationWindow.contentItem, 0, 0).x)
        mouseRelease(sourceEditor, mouseX, mouseY, Qt.RightButton)
        contextMenu.close()
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
        tryVerify(function() { return toolsPage.firstGroupHeading !== null })
        compare(toolsPage.firstGroupHeading.effectiveHorizontalAlignment, Text.AlignRight)
        backButton.click()
        compare(controller.page, "editor")
    }

    function test_helpPageNavigationAndMirroring() {
        var applicationWindow = createMainWindow()
        var controller = applicationWindow.editorController
        var helpButton = findChild(applicationWindow, "helpButton")
        var helpPage = findChild(applicationWindow, "helpPage")
        var helpScroll = findChild(applicationWindow, "helpScroll")
        var backButton = findChild(applicationWindow, "headerBackButton")
        verify(helpButton !== null)
        verify(helpPage !== null)
        verify(helpScroll !== null)

        helpButton.click()
        compare(controller.page, "help")
        verify(helpPage.visible)
        verify(backButton.visible)
        tryVerify(function() { return helpPage.contentImplicitHeight > helpScroll.height })
        var englishShortcutSections = helpPage.englishSections.filter(function(section) {
            return section.heading === "Keyboard shortcuts"
        })
        compare(englishShortcutSections.length, 1)
        verify(englishShortcutSections[0].body.indexOf("Ctrl+Enter: Convert") >= 0)
        verify(englishShortcutSections[0].body.indexOf("Ctrl+Scroll up") >= 0)
        verify(englishShortcutSections[0].body.indexOf("Ctrl+Scroll down") >= 0)
        verify(englishShortcutSections[0].body.indexOf("Ctrl+Shift+S: Save As") >= 0)

        controller.setUiLanguage("fa")
        compare(backButton.glyph, AppTheme.iconForward)
        tryVerify(function() { return helpPage.firstSectionHeading !== null && helpPage.firstSectionBody !== null })
        compare(helpPage.firstSectionHeading.effectiveHorizontalAlignment, Text.AlignRight)
        compare(helpPage.firstSectionBody.effectiveHorizontalAlignment, Text.AlignRight)
        var persianShortcutSections = helpPage.persianSections.filter(function(section) {
            return section.heading === "میان‌برهای صفحه‌کلید"
        })
        compare(persianShortcutSections.length, 1)
        verify(persianShortcutSections[0].body.indexOf("تبدیل: \u2066Ctrl+Enter\u2069") >= 0)
        verify(persianShortcutSections[0].body.indexOf("باز یا بستن تنظیمات: \u2066Ctrl+,\u2069") >= 0)
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
        var fontSelector = findChild(applicationWindow, "exportFontSelector")
        var refreshFonts = findChild(applicationWindow, "refreshExportFontsButton")
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
        verify(fontSelector !== null)
        verify(refreshFonts !== null)
        compare(refreshFonts.glyph, AppTheme.iconRefresh)

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
        compare(fontSelector.searchField.font.family, AppTheme.fontFamily)
        compare(fontSelector.previewText, exportPage.unicodeFontPreview)
        verify(fontSelector.previewText.indexOf("The quick brown fox") >= 0)
        verify(fontSelector.previewText.indexOf("روباه قهوه‌ای سریع") >= 0)
        verify(exportPage.validateBeforeSave())

        fontSelector.openList()
        fontSelector.filter("lmu")
        compare(fontSelector.filteredFonts.length, 1)
        compare(fontSelector.filteredFonts[0].family, "LMU Avvali")
        fontSelector.filter("rmono")
        compare(fontSelector.filteredFonts.length, 1)
        compare(fontSelector.filteredFonts[0].family, "Roboto Mono")
        fontSelector.searchField.forceActiveFocus()
        tryCompare(fontSelector.searchField, "activeFocus", true)
        fontSelector.searchField.accepted()
        compare(controller.unicodeFontPath, "/fonts/roboto-mono-bold.ttf")

        compatibility.click()
        compare(controller.conversionMode, "compatibility")
        compare(fontSelector.searchField.font.family, AppTheme.fontFamily)
        compare(fontSelector.previewText, exportPage.compatibilityFontPreview)
        verify(fontSelector.previewText.indexOf("0123456789") === 0)
        compare(exportPage.compatibilityFontEntries.length, 2)
        tryCompare(controller, "compatibilityFontPath", "/fonts/f-test.ttf")
        fontSelector.openList()
        fontSelector.filter("lmn")
        compare(fontSelector.filteredFonts.length, 1)
        compare(fontSelector.filteredFonts[0].family, "LMN Test")
        fontSelector.searchField.accepted()
        compare(controller.compatibilityFontPath, "/fonts/lmn-test.ttf")
        verify(exportPage.validateBeforeSave())

        refreshFonts.click()
        compare(applicationWindow.fileMock.fontCatalogScanning, true)
        verify(!refreshFonts.enabled)
        compare(exportPage.statusText, controller.uiText("export.loadingFonts"))
        applicationWindow.fileMock.fontEntries = applicationWindow.fileMock.fontEntries.concat([
            { family: "LMN Refreshed", style: "Regular", display: "LMN Refreshed", path: "/fonts/lmn-refreshed.ttf" }
        ])
        applicationWindow.fileMock.fontCatalogScanning = false
        tryCompare(refreshFonts, "enabled", true)
        compare(exportPage.compatibilityFontEntries.length, 3)
        compare(exportPage.statusText, "")

        applicationWindow.fileMock.fontEntries = [
            { family: "Noto Sans", style: "Regular", display: "Noto Sans", path: "/fonts/noto.ttf" }
        ]
        exportPage.applyFontCatalog(applicationWindow.fileMock.fontEntries)
        compare(exportPage.compatibilityFontEntries.length, 0)
        verify(!saveButton.enabled)
        verify(!exportPage.validateBeforeSave())
        compare(exportPage.statusText, controller.uiText("export.error.noCompatibilityFonts"))

        headerBackButton.click()
        compare(controller.page, "editor")
        compare(controller.sourceText, "draft متن")
    }

    function test_exportPageShowsAsyncFontCatalogState() {
        var applicationWindow = createMainWindow()
        var controller = applicationWindow.editorController
        var exportPage = findChild(applicationWindow, "exportPage")
        var loadingLabel = findChild(applicationWindow, "exportFontCatalogLoading")
        var saveButton = findChild(applicationWindow, "saveSvgButton")

        applicationWindow.fileMock.fontCatalogReady = false
        applicationWindow.fileMock.fontEntries = []
        controller.openExport()
        compare(controller.page, "export")
        verify(exportPage.visible)
        verify(loadingLabel.visible)
        compare(exportPage.statusText, controller.uiText("export.loadingFonts"))
        verify(!saveButton.enabled)

        applicationWindow.fileMock.fontCatalogReady = true
        tryCompare(loadingLabel, "visible", false)
        verify(saveButton.enabled)
        compare(exportPage.statusText, "")
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
