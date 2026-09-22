import QtQuick
import QtQuick.Controls
import QtTest
import LeoMoon.ParsiNegar
import LeoMoon.ParsiNegar.Test

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
            textDirectionService: NativeTextDirectionBridge
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
        var editorPageScroll = findChild(applicationWindow, "editorPageScroll")
        var editorWorkspaceHover = findChild(applicationWindow, "editorWorkspaceHover")
        var editorWorkspace = findChild(applicationWindow, "editorWorkspace")
        var editorPageContent = findChild(applicationWindow, "editorPageContent")
        var editorScroll = findChild(applicationWindow, "editorScroll")
        var conversionActions = findChild(applicationWindow, "conversionActions")
        var statusSlot = findChild(applicationWindow, "statusSlot")
        var applicationTitle = findChild(applicationWindow, "applicationTitle")
        verify(contentLayout !== null)
        verify(editorPage !== null)
        verify(editorPageScroll !== null)
        verify(editorWorkspaceHover !== null)
        verify(editorWorkspace !== null)
        verify(editorPageContent !== null)
        verify(editorScroll !== null)
        verify(conversionActions !== null)
        verify(statusSlot !== null)
        verify(applicationTitle !== null)

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
        compare(editorPage.heightDeficit,
            Math.max(0, applicationWindow.minimumHeight - applicationWindow.usableScreenHeight))
        compare(applicationWindow.calculateHeightDeficit(450, 600, 600), 0)
        compare(applicationWindow.calculateHeightDeficit(735, 600, 600), 135)
        compare(applicationWindow.calculateHeightDeficit(735, 735, 600), 135)
        verify(!editorPage.constrainedHeight)
        compare(editorPageScroll.policy, ScrollBar.AlwaysOff)
        compare(editorWorkspace.scrollContentHeight, editorWorkspace.viewportHeight)
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

        var headerY = applicationTitle.mapToItem(applicationWindow.contentItem, 0, 0).y
        var statusY = statusSlot.mapToItem(applicationWindow.contentItem, 0, 0).y
        editorPage.heightDeficit = 100
        tryCompare(editorPage, "constrainedHeight", true)
        compare(editorPageScroll.policy, ScrollBar.AsNeeded)
        verify(editorWorkspace.scrollContentHeight >= editorWorkspace.viewportHeight + 100)
        verify(editorPageScroll.size < 1)
        mouseMove(editorWorkspace, editorWorkspace.width / 2,
            editorWorkspace.contentMargin / 2)
        tryCompare(editorWorkspaceHover, "hovered", true)
        tryCompare(editorPageScroll, "active", true)
        editorPageScroll.position = 1 - editorPageScroll.size
        verify(editorPageContent.y < editorWorkspace.contentMargin)
        compare(applicationTitle.mapToItem(applicationWindow.contentItem, 0, 0).y, headerY)
        compare(statusSlot.mapToItem(applicationWindow.contentItem, 0, 0).y, statusY)
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
        verify(findChild(applicationWindow, "keyboardShortcut") !== null)

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

        keyClick(Qt.Key_K, Qt.ControlModifier)
        compare(controller.keyboardDrawerOpen, true)
        keyClick(Qt.Key_K, Qt.ControlModifier)
        compare(controller.keyboardDrawerOpen, false)

        controller.sourceText = "shortcut test"
        keyClick(Qt.Key_Return, Qt.ControlModifier)
        tryCompare(controller, "busy", false, 20000)
        compare(clipboard.text, "shortcut test")
    }

    function test_lightAndDarkPalettesRemainLegible() {
        var originalMode = AppTheme.darkMode
        var originalAccent = AppTheme.accentPreset
        var modes = [true, false]
        for (var index = 0; index < modes.length; index++) {
            AppTheme.darkMode = modes[index]
            verify(AppTheme.contrastRatio(AppTheme.foreground, AppTheme.background) >= 4.5)
            verify(AppTheme.contrastRatio(AppTheme.foreground, AppTheme.surface) >= 4.5)
            verify(AppTheme.contrastRatio(AppTheme.muted, AppTheme.background) >= 4.5)
            for (var accentIndex = 0; accentIndex < AppTheme.accentPresets.length; accentIndex++) {
                AppTheme.accentPreset = AppTheme.accentPresets[accentIndex]
                verify(AppTheme.contrastRatio(AppTheme.accentText, AppTheme.accent) >= 4.5)
                if (AppTheme.accentPreset === "faint") {
                    verify(AppTheme.contrastRatio(AppTheme.accent, AppTheme.surface) < 2.5)
                    verify(AppTheme.contrastRatio(AppTheme.focus, AppTheme.surface) >= 3)
                }
            }
        }
        AppTheme.accentPreset = originalAccent
        AppTheme.darkMode = originalMode
    }

    function test_accentColorButtonsUpdateThemeAndSettings() {
        var applicationWindow = createMainWindow()
        var controller = applicationWindow.editorController
        var choices = findChild(applicationWindow, "accentColorChoices")
        verify(choices !== null)
        compare(choices.count, AppTheme.accentPresets.length)
        var purpleButton = choices.itemAt(0)
        var slateButton = choices.itemAt(1)
        var faintButton = choices.itemAt(2)
        verify(purpleButton !== null)
        verify(slateButton !== null)
        verify(faintButton !== null)
        compare(controller.accentPreset, "purple")
        verify(purpleButton.selected)

        controller.openSettings()
        slateButton.click()
        compare(controller.accentPreset, "slate")
        compare(AppTheme.accentPreset, "slate")
        verify(slateButton.selected)
        verify(!purpleButton.selected)

        controller.setUiLanguage("fa")
        compare(slateButton.text, "خاکستری")
        controller.setUiLanguage("ar")
        compare(slateButton.text, "رمادي")
        controller.setUiLanguage("en")
        compare(slateButton.text, "Slate")

        faintButton.click()
        compare(controller.accentPreset, "faint")
        verify(faintButton.selected)
        controller.setUiLanguage("fa")
        compare(faintButton.text, "کم‌رنگ")
        controller.setUiLanguage("ar")
        compare(faintButton.text, "باهت")
        controller.setUiLanguage("en")
        compare(faintButton.text, "Faint")
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
        var undoItem = findChild(applicationWindow, "undoDocumentMenuItem")
        var redoItem = findChild(applicationWindow, "redoDocumentMenuItem")
        var sourceEditor = findChild(applicationWindow, "sourceEditor")
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
        verify(undoItem !== null)
        verify(redoItem !== null)
        verify(findChild(applicationWindow, "undoButton") === null)
        verify(findChild(applicationWindow, "redoButton") === null)
        verify(settingsPage !== null)
        verify(lightThemeButton !== null)
        verify(darkThemeButton !== null)
        verify(sourceEditor !== null)
        sourceEditor.forceActiveFocus()
        tryCompare(sourceEditor, "activeFocus", true)
        tryCompare(sourceEditor, "cursorVisible", true)
        var editorCursor = findChild(applicationWindow, "editorCursor")
        verify(editorCursor !== null)
        verify(editorCursor.visible)
        verify(Math.abs(editorCursor.x - sourceEditor.cursorRectangle.x) <= 2)
        verify(editorCursor.height > 0)
        compare(sourceEditor.horizontalAlignment, TextEdit.AlignRight)
        verify(conversionStatus !== null)
        verify(statusSlot !== null)
        compare(statusSlot.height, 44)
        verify(conversionStatus.visible)
        verify(conversionStatus.idle)
        compare(conversionStatus.displayMessage, controller.uiText("status.ready"))
        compare(conversionStatus.background.color, AppTheme.surface)
        verify(!convertButton.accent)
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
        compare(undoItem.glyph, AppTheme.iconUndo)
        compare(redoItem.glyph, AppTheme.iconRedo)
        verify(textToolsButton.glyph !== "")
        verify(exportButton.glyph !== "")
        compare(exportButton.contentItem.font.family, AppTheme.iconFontFamily)
        compare(settingsButton.contentItem.font.family, AppTheme.iconFontFamily)
        compare(documentButton.width, settingsButton.width)
        compare(helpButton.width, settingsButton.width)
        compare(textToolsButton.width, settingsButton.width)
        verify(!undoItem.enabled)
        verify(!redoItem.enabled)

        controller.sourceText = "one"
        verify(undoItem.enabled)
        documentButton.click()
        undoItem.click()
        compare(controller.sourceText, "")
        verify(!undoItem.enabled)
        verify(redoItem.enabled)
        applicationWindow.requestActivate()
        tryCompare(applicationWindow, "active", true, 2000)
        tryCompare(sourceEditor, "activeFocus", true)
        keyClick(Qt.Key_Y, Qt.ControlModifier)
        compare(controller.sourceText, "one")
        verify(undoItem.enabled)
        verify(!redoItem.enabled)

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
        var undoItem = findChild(applicationWindow, "undoDocumentMenuItem")
        var redoItem = findChild(applicationWindow, "redoDocumentMenuItem")
        verify(documentButton !== null)
        verify(documentMenu !== null)
        verify(newItem !== null)
        verify(saveItem !== null)
        verify(undoItem !== null)
        verify(redoItem !== null)
        verify(!saveItem.enabled)
        verify(!undoItem.enabled)
        verify(!redoItem.enabled)
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

    function test_onScreenKeyboardDrawerTogglesLayersAndInsertsText() {
        var applicationWindow = createMainWindow()
        var controller = applicationWindow.editorController
        var keyboardButton = findChild(applicationWindow, "keyboardButton")
        var keyboard = findChild(applicationWindow, "onScreenKeyboard")
        var editorPage = findChild(applicationWindow, "editorPage")
        var editorPageScroll = findChild(applicationWindow, "editorPageScroll")
        var editorPageWheelTop = findChild(applicationWindow, "editorPageWheelTop")
        var editorPageWheelBottom = findChild(applicationWindow, "editorPageWheelBottom")
        var editorPageWheelLeft = findChild(applicationWindow, "editorPageWheelLeft")
        var editorPageWheelRight = findChild(applicationWindow, "editorPageWheelRight")
        var editorWorkspace = findChild(applicationWindow, "editorWorkspace")
        var conversionActions = findChild(applicationWindow, "conversionActions")
        var editor = findChild(applicationWindow, "sourceEditor")
        var primaryLayer = findChild(applicationWindow, "keyboardPrimaryLayer")
        var symbolsLayer = findChild(applicationWindow, "keyboardSymbolsAdvancedLayer")
        var backspace = findChild(applicationWindow, "keyboardBackspaceButton")
        var space = findChild(applicationWindow, "keyboardSpaceButton")
        var enter = findChild(applicationWindow, "keyboardEnterButton")
        verify(keyboardButton !== null)
        verify(keyboard !== null)
        verify(editorPage !== null)
        verify(editorPageScroll !== null)
        verify(editorPageWheelTop !== null)
        verify(editorPageWheelBottom !== null)
        verify(editorPageWheelLeft !== null)
        verify(editorPageWheelRight !== null)
        verify(editorWorkspace !== null)
        verify(conversionActions !== null)
        compare(editorPageWheelTop.parent, editorWorkspace)
        compare(editorPageWheelBottom.parent, editorWorkspace)
        compare(editorPageWheelLeft.parent, editorWorkspace)
        compare(editorPageWheelRight.parent, editorWorkspace)
        verify(!keyboard.visible)
        compare(applicationWindow.minimumHeight, applicationWindow.standardMinimumHeight)
        compare(keyboardButton.glyph, AppTheme.iconKeyboard)

        controller.sourceText = "a"
        editor.cursorPosition = controller.sourceText.length
        var closedNaturalContentHeight = editorWorkspace.naturalContentHeight
        applicationWindow.height = applicationWindow.standardMinimumHeight
        tryCompare(applicationWindow, "height", applicationWindow.standardMinimumHeight)
        keyboardButton.click()
        tryCompare(keyboard, "visible", true)
        compare(controller.keyboardDrawerOpen, true)
        compare(applicationWindow.minimumHeight, applicationWindow.keyboardMinimumHeight)
        tryVerify(function() {
            return editorWorkspace.naturalContentHeight > closedNaturalContentHeight
        })
        verify(applicationWindow.height >= applicationWindow.keyboardMinimumHeight)
        verify(keyboardButton.selected)
        tryCompare(editor, "activeFocus", true)
        compare(keyboard.primaryRows.length, 4)

        var pe = findChild(keyboard, "keyboardKey_پ")
        var zaad = findChild(keyboard, "keyboardKey_ض")
        var che = findChild(keyboard, "keyboardKey_چ")
        verify(pe !== null)
        verify(zaad !== null)
        verify(che !== null)
        verify(zaad.mapToItem(keyboard, 0, 0).x < che.mapToItem(keyboard, 0, 0).x)
        editorPage.heightDeficit = 100
        tryCompare(editorPage, "constrainedHeight", true)
        var initialPageScrollPosition = editorPageScroll.position
        mouseWheel(keyboard, keyboard.width / 2, keyboard.height / 2,
            0, -120, Qt.NoButton, Qt.NoModifier)
        verify(editorPageScroll.position > initialPageScrollPosition)

        editorPageScroll.position = 1 - editorPageScroll.size
        var conversionScrollPosition = editorPageScroll.position
        mouseWheel(conversionActions,
            conversionActions.width / 2, conversionActions.height / 2,
            0, 120, Qt.NoButton, Qt.NoModifier)
        verify(editorPageScroll.position < conversionScrollPosition)

        editorPageScroll.position = 0
        mouseWheel(editorWorkspace,
            editorWorkspace.contentMargin / 2, editorWorkspace.height / 2,
            0, -120, Qt.NoButton, Qt.NoModifier)
        verify(editorPageScroll.position > 0)

        var pagePositionBeforeEditorWheel = editorPageScroll.position
        mouseWheel(editor, editor.width / 2, editor.height / 2,
            0, -120, Qt.NoButton, Qt.NoModifier)
        compare(editorPageScroll.position, pagePositionBeforeEditorWheel)

        editorPageScroll.position = 0
        mouseClick(pe, pe.width / 2, pe.height / 2)
        compare(controller.sourceText, "aپ")
        editorPage.heightDeficit = 0

        symbolsLayer.click()
        compare(keyboard.activeLayer, "symbols")
        compare(keyboard.symbolsRows.length, 4)
        var quote = findChild(keyboard, "keyboardKey_«")
        var quoteClose = findChild(keyboard, "keyboardKey_»")
        verify(quote !== null)
        verify(quoteClose !== null)
        compare(keyboard.visualDirection, "ltr")
        compare(quote.text, "«")
        compare(quoteClose.text, "»")
        controller.setUiLanguage("fa")
        controller.sourceText = "پ"
        compare(NativeTextDirectionBridge.plainText(editor.textDocument), "پ")
        editor.cursorPosition = editor.length
        tryCompare(keyboard, "visualDirection", "rtl")
        quote = findChild(keyboard, "keyboardKey_«")
        quoteClose = findChild(keyboard, "keyboardKey_»")
        compare(quote.text, "»")
        compare(quoteClose.text, "«")
        controller.sourceText = "aپ"
        controller.setUiLanguage("en")
        compare(NativeTextDirectionBridge.plainText(editor.textDocument), "aپ")
        editor.cursorPosition = editor.length
        tryCompare(keyboard, "visualDirection", "ltr")
        quote = findChild(keyboard, "keyboardKey_«")
        quote.click()
        compare(controller.sourceText, "aپ«")

        var zwnj = findChild(keyboard, "keyboardKey_ZWNJ")
        verify(zwnj !== null)
        compare(zwnj.toolTipText, "Zero-width non-joiner (U+200C)")
        zwnj.click()
        compare(controller.sourceText, "aپ«‌")
        backspace.click()
        compare(controller.sourceText, "aپ«")
        space.click()
        enter.click()
        compare(controller.sourceText, "aپ« \n")

        primaryLayer.click()
        zaad = findChild(keyboard, "keyboardKey_ض")
        che = findChild(keyboard, "keyboardKey_چ")
        verify(zaad !== null)
        verify(che !== null)
        controller.setUiLanguage("fa")
        wait(0)
        verify(zaad.mapToItem(keyboard, 0, 0).x < che.mapToItem(keyboard, 0, 0).x)
        symbolsLayer.click()
        zwnj = findChild(keyboard, "keyboardKey_ZWNJ")
        compare(zwnj.toolTipText, "نویسهٔ نامرئیِ فاصلهٔ مجازی (U+200C)")
        controller.setUiLanguage("en")
        applicationWindow.width = applicationWindow.minimumWidth
        applicationWindow.height = applicationWindow.minimumHeight
        wait(0)
        verify(keyboard.width > 0)
        verify(keyboard.height > 0)
        verify(keyboard.height <= applicationWindow.contentItem.height)
        verify(keyboard.mapToItem(applicationWindow.contentItem, 0, 0).x >= 0)
        verify(keyboard.mapToItem(applicationWindow.contentItem, 0, 0).y >= 0)

        keyboardButton.click()
        tryCompare(keyboard, "visible", false)
        compare(controller.keyboardDrawerOpen, false)
        compare(applicationWindow.minimumHeight, applicationWindow.standardMinimumHeight)

        var secondClosedNaturalContentHeight = editorWorkspace.naturalContentHeight
        keyboardButton.click()
        tryCompare(keyboard, "visible", true)
        compare(applicationWindow.activeMinimumHeight,
            applicationWindow.keyboardMinimumHeight)
        tryVerify(function() {
            return editorWorkspace.naturalContentHeight > secondClosedNaturalContentHeight
        })
        keyboardButton.click()
        tryCompare(keyboard, "visible", false)
        compare(applicationWindow.activeMinimumHeight,
            applicationWindow.standardMinimumHeight)
    }

    function test_keyboardDirectionFollowsCursorParagraph() {
        var applicationWindow = createMainWindow()
        var controller = applicationWindow.editorController
        var editor = findChild(applicationWindow, "sourceEditor")
        var keyboardButton = findChild(applicationWindow, "keyboardButton")
        var keyboard = findChild(applicationWindow, "onScreenKeyboard")
        var primaryLayer = findChild(applicationWindow, "keyboardPrimaryLayer")
        var symbolsLayer = findChild(applicationWindow, "keyboardSymbolsAdvancedLayer")
        verify(editor !== null)
        verify(keyboardButton !== null)
        verify(keyboard !== null)
        verify(primaryLayer !== null)
        verify(symbolsLayer !== null)

        function verifyPairPositions(rightToLeft) {
            var pairs = [["«", "»"], ["(", ")"], ["[", "]"], ["{", "}"]]
            for (var i = 0; i < pairs.length; ++i) {
                var opener = findChild(keyboard, "keyboardKey_" + pairs[i][0])
                var closer = findChild(keyboard, "keyboardKey_" + pairs[i][1])
                verify(opener !== null)
                verify(closer !== null)
                compare(opener.insertionText, pairs[i][0])
                compare(closer.insertionText, pairs[i][1])
                var openX = opener.mapToItem(keyboard, 0, 0).x
                var closeX = closer.mapToItem(keyboard, 0, 0).x
                verify(rightToLeft ? openX > closeX : openX < closeX)
            }
        }

        function verifyOrnatePosition() {
            var opener = findChild(keyboard, "keyboardKey_﴿")
            var closer = findChild(keyboard, "keyboardKey_﴾")
            verify(opener !== null)
            verify(closer !== null)
            verify(opener.mapToItem(keyboard, 0, 0).x
                > closer.mapToItem(keyboard, 0, 0).x)
        }

        controller.setUiLanguage("en")
        controller.sourceText = "English"
        editor.cursorPosition = 0
        keyboardButton.click()
        tryCompare(keyboard, "visible", true)
        symbolsLayer.click()
        var quote = findChild(keyboard, "keyboardKey_«")
        verify(quote !== null)
        tryCompare(keyboard, "visualDirection", "ltr")
        verifyPairPositions(false)
        verifyOrnatePosition()
        controller.sourceText = "سلام"
        tryCompare(keyboard, "visualDirection", "rtl")
        verifyPairPositions(true)
        verifyOrnatePosition()

        var source = "English\nسلام\n\nLatin"
        controller.sourceText = source
        compare(NativeTextDirectionBridge.plainText(editor.textDocument), source)

        editor.cursorPosition = 0
        tryCompare(keyboard, "visualDirection", "ltr")
        quote = findChild(keyboard, "keyboardKey_«")
        compare(quote.text, "«")
        verifyPairPositions(false)
        editor.cursorPosition = source.indexOf("سلام")
        tryCompare(keyboard, "visualDirection", "rtl")
        quote = findChild(keyboard, "keyboardKey_«")
        compare(quote.text, "»")
        verifyPairPositions(true)
        editor.cursorPosition = source.indexOf("\n\n") + 1
        tryCompare(keyboard, "visualDirection", "rtl")
        editor.cursorPosition = source.indexOf("Latin")
        tryCompare(keyboard, "visualDirection", "ltr")
        quote = findChild(keyboard, "keyboardKey_«")
        compare(quote.text, "«")
        verifyPairPositions(false)

        controller.setUiLanguage("fa")
        editor.cursorPosition = source.indexOf("سلام")
        tryCompare(keyboard, "visualDirection", "rtl")
        verifyPairPositions(true)
        editor.cursorPosition = source.indexOf("Latin")
        tryCompare(keyboard, "visualDirection", "ltr")
        verifyPairPositions(false)

        primaryLayer.click()
        verifyOrnatePosition()
        editor.cursorPosition = source.indexOf("سلام")
        tryCompare(keyboard, "visualDirection", "rtl")
        verifyOrnatePosition()
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
        var exportStatus = findChild(applicationWindow, "exportStatus")
        var exportStatusSlot = findChild(applicationWindow, "exportStatusSlot")
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
        var fillField = findChild(applicationWindow, "exportFill")
        var axesField = findChild(applicationWindow, "exportAxes")
        verify(exportButton !== null)
        verify(exportPage !== null)
        verify(headerBackButton !== null)
        verify(exportScroll !== null)
        verify(exportStatus !== null)
        verify(exportStatusSlot !== null)
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
        verify(fillField !== null)
        verify(axesField !== null)
        compare(refreshFonts.glyph, AppTheme.iconRefresh)

        controller.sourceText = "draft متن"
        controller.setExportSettings({ fontSize: "64", lineSpacing: "1.4", alignment: "center" })
        exportButton.click()
        compare(controller.page, "export")
        verify(exportPage.visible)
        verify(exportStatus.visible)
        verify(exportStatus.idle)
        compare(exportStatus.displayMessage, controller.uiText("status.ready"))
        compare(exportStatusSlot.height, 44)
        verify(findChild(applicationWindow, "headerActions").visible)
        verify(headerBackButton.visible)
        compare(headerBackButton.glyph, AppTheme.iconBack)
        compare(exportScroll.leftPadding, AppTheme.spacingLarge)
        compare(exportScroll.rightPadding, AppTheme.spacingLarge)
        verify(Math.abs(alignLeft.width - alignCenter.width) <= 1)
        verify(Math.abs(alignCenter.width - alignRight.width) <= 1)
        controller.setUiLanguage("fa")
        wait(0)
        compare(exportStatus.displayMessage, controller.uiText("status.ready"))
        verify(alignLeft.mapToItem(exportPage, 0, 0).x < alignCenter.mapToItem(exportPage, 0, 0).x)
        verify(alignCenter.mapToItem(exportPage, 0, 0).x < alignRight.mapToItem(exportPage, 0, 0).x)
        controller.setUiLanguage("ar")
        wait(0)
        compare(exportStatus.displayMessage, controller.uiText("status.ready"))
        verify(alignLeft.mapToItem(exportPage, 0, 0).x < alignCenter.mapToItem(exportPage, 0, 0).x)
        verify(alignCenter.mapToItem(exportPage, 0, 0).x < alignRight.mapToItem(exportPage, 0, 0).x)
        controller.setUiLanguage("en")
        compare(fontSize.text, "64")
        compare(lineSpacing.text, "1.4")
        verify(alignCenter.selected)
        moreOptions.click()
        compare(controller.exportSettings.advancedVisible, true)
        compare(fillField.background.color, AppTheme.surface)
        compare(axesField.background.color, AppTheme.surface)
        compare(fillField.color, AppTheme.foreground)
        compare(axesField.color, AppTheme.foreground)
        compare(fillField.implicitHeight, fontSize.implicitHeight)
        compare(axesField.implicitHeight, fontSize.implicitHeight)
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
        compare(exportStatus.displayMessage, controller.uiText("export.loadingFonts"))
        verify(!exportStatus.idle)
        applicationWindow.fileMock.fontEntries = applicationWindow.fileMock.fontEntries.concat([
            { family: "LMN Refreshed", style: "Regular", display: "LMN Refreshed", path: "/fonts/lmn-refreshed.ttf" }
        ])
        applicationWindow.fileMock.fontCatalogScanning = false
        tryCompare(refreshFonts, "enabled", true)
        compare(exportPage.compatibilityFontEntries.length, 3)
        compare(exportPage.statusText, "")
        compare(exportStatus.displayMessage, controller.uiText("status.ready"))
        verify(exportStatus.idle)

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
