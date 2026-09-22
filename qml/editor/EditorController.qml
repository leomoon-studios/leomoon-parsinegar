import QtQuick
import "qml/core/InterfaceStrings.js" as Strings
import "qml/core/ReshaperSettings.js" as Settings
import "qml/core/ResourceLimits.js" as Limits
import "qml/core/SourceHistory.js" as History
import "qml/core/TextTools.js" as TextTools

Item {
    id: root

    visible: false
    width: 0
    height: 0

    property var clipboardBridge: null
    property var settingsStore: null
    property var fileBridge: null
    property string sourceText: ""
    property bool reverseWords: true
    property bool videoStudioPro: false
    property int editorFontSize: Settings.ReshaperSettings.desktopDefaults().editorFontSize
    property bool keyboardDrawerOpen: Settings.ReshaperSettings.desktopDefaults().keyboardDrawerOpen
    property string accentPreset: Settings.ReshaperSettings.desktopDefaults().accentPreset
    onAccentPresetChanged: AppTheme.accentPreset = accentPreset
    property string uiLanguage: "en"
    property string unicodeFontPath: ""
    property string compatibilityFontPath: ""
    property var reshaperSettings: Settings.ReshaperSettings.defaults(Settings.ReshaperSettings.metadata)
    property var textTools: TextTools.TextTools.defaults()
    property var exportSettings: Settings.ReshaperSettings.desktopDefaults().exportSettings
    property var lastAppliedTextTools: []
    property string page: "editor"
    property int settingsRevision: 0
    property int sourceHistoryLimit: 100
    property var sourceHistory: History.SourceHistory.create({ text: "", cursor: 0, anchor: 0 }, sourceHistoryLimit)
    property bool restoringSourceHistory: false
    property string documentPath: ""
    property string savedDocumentText: ""
    property string savedDocumentFileText: ""
    property string documentLineEnding: "\n"

    readonly property var reshaperMetadata: Settings.ReshaperSettings.metadata
    readonly property string shapingProfile: state.shapingProfile
    readonly property string conversionMode: state.conversionMode
    readonly property bool hebrewProfile: shapingProfile === "hebrew"
    readonly property bool busy: state.busy
    readonly property int conversionRequestId: state.requestId
    readonly property string statusText: state.statusText
    readonly property string statusLevel: state.statusLevel
    readonly property string lastOutput: state.lastOutput
    readonly property int maximumTextLength: Limits.ResourceLimits.values.maxConversionTextLength
    readonly property bool settingsReady: state.settingsReady
    readonly property bool canUndo: History.SourceHistory.canUndo(sourceHistory)
    readonly property bool canRedo: History.SourceHistory.canRedo(sourceHistory)
    readonly property bool documentDirty: sourceText !== savedDocumentText
    readonly property string documentDisplayName: documentPath === "" ? uiText("document.untitled") : fileName(documentPath)
    readonly property string windowTitle: (documentDirty ? "*" : "") + documentDisplayName + " - " + uiText("app.title")
    readonly property string settingsStatusText: state.settingsMessageKey === ""
        ? ""
        : uiText(state.settingsMessageKey) + state.settingsMessageDetail
    readonly property string settingsStatusLevel: state.settingsStatusLevel

    signal conversionFinished(bool ok, string output)
    signal settingsWritten(string json)
    signal sourceHistoryRestored(int cursor, int anchor)
    signal openDocumentDialogRequested()
    signal saveDocumentDialogRequested()
    signal unsavedChangesRequested()
    signal applicationCloseApproved()

    function uiText(key) {
        return Strings.InterfaceStrings.text(uiLanguage, key)
    }

    function fileName(path) {
        var normalized = String(path).replace(/\\/g, "/")
        var parts = normalized.split("/")
        return parts.length > 0 && parts[parts.length - 1] !== "" ? parts[parts.length - 1] : uiText("document.untitled")
    }

    function resetDocument(text, path) {
        var fileText = String(text === undefined || text === null ? "" : text)
        var nextText = normalizedDocumentText(fileText)
        restoringSourceHistory = true
        sourceText = nextText
        sourceHistory = History.SourceHistory.create({ text: nextText, cursor: 0, anchor: 0 }, sourceHistoryLimit)
        restoringSourceHistory = false
        documentPath = String(path || "")
        savedDocumentText = nextText
        savedDocumentFileText = fileText
        documentLineEnding = detectedLineEnding(fileText)
        clearStatus()
        sourceHistoryRestored(0, 0)
    }

    function detectedLineEnding(text) {
        var value = String(text)
        var crlf = value.indexOf("\r\n")
        var lf = value.indexOf("\n")
        var cr = value.indexOf("\r")
        if (crlf >= 0 && (lf < 0 || crlf <= lf) && (cr < 0 || crlf <= cr))
            return "\r\n"
        if (cr >= 0 && (lf < 0 || cr < lf))
            return "\r"
        return "\n"
    }

    function normalizedDocumentText(text) {
        return String(text).replace(/\r\n/g, "\n").replace(/\r/g, "\n")
    }

    function documentTextForWrite() {
        if (sourceText === savedDocumentText)
            return savedDocumentFileText
        var normalized = normalizedDocumentText(sourceText)
        return documentLineEnding === "\n" ? normalized : normalized.replace(/\n/g, documentLineEnding)
    }

    function requestUnsavedAction(action) {
        if (!documentDirty) {
            executeDocumentAction(action)
            return true
        }
        state.pendingDocumentAction = action
        unsavedChangesRequested()
        return false
    }

    function executeDocumentAction(action) {
        state.pendingDocumentAction = ""
        if (action === "new") {
            resetDocument("", "")
        } else if (action === "open") {
            openDocumentDialogRequested()
        } else if (action === "close") {
            applicationCloseApproved()
        }
    }

    function newDocument() {
        return requestUnsavedAction("new")
    }

    function openDocument() {
        return requestUnsavedAction("open")
    }

    function saveDocument() {
        if (documentPath === "") {
            saveDocumentDialogRequested()
            return false
        }
        if (!fileBridge || typeof fileBridge.localFileUrl !== "function") {
            setDocumentFailure("document.error.save")
            state.pendingDocumentAction = ""
            return false
        }
        return writeDocument(fileBridge.localFileUrl(documentPath))
    }

    function saveDocumentAs() {
        saveDocumentDialogRequested()
    }

    function openDocumentUrl(url) {
        if (!fileBridge || typeof fileBridge.readTextDocument !== "function") {
            setDocumentFailure("document.error.open")
            return false
        }
        var result = fileBridge.readTextDocument(url)
        if (!result || result.ok !== true) {
            setDocumentFailure("document.error.open", result)
            return false
        }
        resetDocument(result.data, result.path)
        state.statusText = uiText("document.status.opened")
        state.statusLevel = "success"
        return true
    }

    function writeDocument(url) {
        if (!fileBridge || typeof fileBridge.writeTextDocument !== "function") {
            setDocumentFailure("document.error.save")
            state.pendingDocumentAction = ""
            return false
        }
        var fileText = documentTextForWrite()
        var result = fileBridge.writeTextDocument(url, fileText)
        if (!result || result.ok !== true) {
            setDocumentFailure("document.error.save", result)
            state.pendingDocumentAction = ""
            return false
        }
        documentPath = String(result.path || fileBridge.localFilePath(url) || "")
        savedDocumentText = sourceText
        savedDocumentFileText = fileText
        state.statusText = uiText("document.status.saved")
        state.statusLevel = "success"
        if (state.pendingDocumentAction !== "")
            executeDocumentAction(state.pendingDocumentAction)
        return true
    }

    function saveDocumentAsUrl(url) {
        return writeDocument(url)
    }

    function cancelOpenDocumentDialog() {
        state.pendingDocumentAction = ""
    }

    function cancelSaveDocumentDialog() {
        state.pendingDocumentAction = ""
    }

    function resolveUnsavedChanges(choice) {
        if (state.pendingDocumentAction === "")
            return
        if (choice === "discard") {
            executeDocumentAction(state.pendingDocumentAction)
        } else if (choice === "save") {
            saveDocument()
        } else {
            state.pendingDocumentAction = ""
        }
    }

    function requestApplicationClose() {
        return requestUnsavedAction("close")
    }

    function setDocumentFailure(key, result) {
        var detail = result && result.message ? " " + String(result.message) : ""
        state.statusText = uiText(key) + detail
        state.statusLevel = "error"
    }

    function openSettings() {
        page = "settings"
    }

    function openHelp() {
        page = "help"
    }

    function closeHelp() {
        page = "editor"
    }

    function openExport() {
        page = "export"
    }

    function openTextTools() {
        page = "tools"
    }

    function closeTextTools() {
        page = "editor"
    }

    function closeExport() {
        page = "editor"
    }

    function closeSettings() {
        page = "editor"
    }

    function textToolEnabled(id) {
        return textTools && textTools[id] === true
    }

    function toggleTextTool(id) {
        textTools = TextTools.TextTools.withToggled(textTools, id)
        saveSettings()
    }

    function setExportSettings(value) {
        var next = Settings.ReshaperSettings.sanitizeExportSettings(value)
        if (JSON.stringify(exportSettings) === JSON.stringify(next))
            return
        exportSettings = next
        saveSettings()
    }

    function applyTextToolsToSource() {
        var input = sourceText
        var result = TextTools.TextTools.applyEnabled(input, textTools)
        lastAppliedTextTools = result.applied
        if (result.text !== input)
            replaceSourceText(result.text, sourceHistory.current.cursor, sourceHistory.current.anchor)
        return result
    }

    function selectionAnchor(cursor, selectionStart, selectionEnd) {
        if (selectionStart === selectionEnd)
            return cursor
        return cursor === selectionStart ? selectionEnd : selectionStart
    }

    function updateSourceSelection(cursor, selectionStart, selectionEnd) {
        var anchor = selectionAnchor(cursor, selectionStart, selectionEnd)
        sourceHistory = History.SourceHistory.updateSelection(sourceHistory, cursor, anchor)
    }

    function replaceSourceText(text, cursor, anchor) {
        var nextText = String(text === undefined || text === null ? "" : text)
        if (sourceText === nextText) {
            var previousCursor = sourceHistory.current.cursor
            var previousAnchor = sourceHistory.current.anchor
            sourceHistory = History.SourceHistory.updateSelection(sourceHistory, cursor, anchor)
            if (sourceHistory.current.cursor !== previousCursor
                    || sourceHistory.current.anchor !== previousAnchor)
                sourceHistoryRestored(sourceHistory.current.cursor, sourceHistory.current.anchor)
            return false
        }
        sourceText = nextText
        sourceHistory = History.SourceHistory.updateSelection(sourceHistory, cursor, anchor)
        sourceHistoryRestored(sourceHistory.current.cursor, sourceHistory.current.anchor)
        return true
    }

    function insertSourceText(text, selectionStart, selectionEnd) {
        var insertedText = String(text === undefined || text === null ? "" : text)
        var start = Math.max(0, Math.min(sourceText.length, Math.min(selectionStart, selectionEnd)))
        var end = Math.max(start, Math.min(sourceText.length, Math.max(selectionStart, selectionEnd)))
        var nextText = sourceText.slice(0, start) + insertedText + sourceText.slice(end)
        if (nextText.length > maximumTextLength) {
            state.statusText = uiText("status.textTooLarge")
            state.statusLevel = "error"
            return false
        }
        var cursor = start + insertedText.length
        return replaceSourceText(nextText, cursor, cursor)
    }

    function deleteSourceBackward(selectionStart, selectionEnd) {
        var start = Math.max(0, Math.min(sourceText.length, Math.min(selectionStart, selectionEnd)))
        var end = Math.max(start, Math.min(sourceText.length, Math.max(selectionStart, selectionEnd)))
        if (start === end && start > 0)
            start--
        return replaceSourceText(sourceText.slice(0, start) + sourceText.slice(end), start, start)
    }

    function restoreSourceHistory(result) {
        if (!result.changed)
            return false
        restoringSourceHistory = true
        sourceHistory = result.history
        sourceText = result.state.text
        restoringSourceHistory = false
        sourceHistoryRestored(result.state.cursor, result.state.anchor)
        return true
    }

    function undoSourceEdit() {
        return restoreSourceHistory(History.SourceHistory.undo(sourceHistory))
    }

    function redoSourceEdit() {
        return restoreSourceHistory(History.SourceHistory.redo(sourceHistory))
    }

    function setReverseWords(enabled) {
        reverseWords = enabled === true
        saveSettings()
    }

    function setVideoStudioPro(enabled) {
        videoStudioPro = conversionMode === "compatibility" && !hebrewProfile && enabled === true
        saveSettings()
    }

    function setUiLanguage(language) {
        var nextLanguage = Settings.ReshaperSettings.sanitizeUiLanguage(language)
        if (uiLanguage === nextLanguage)
            return
        uiLanguage = nextLanguage
        saveSettings()
    }

    function setConversionMode(mode) {
        if (mode !== "unicode" && mode !== "compatibility")
            return false
        if (hebrewProfile && mode === "compatibility")
            return false
        state.conversionMode = mode
        state.lastNonHebrewMode = mode
        if (mode !== "compatibility")
            videoStudioPro = false
        clearStatus()
        saveSettings()
        return true
    }

    function setShapingProfile(profile) {
        var nextProfile = Settings.ReshaperSettings.sanitizeShapingProfile(reshaperMetadata, profile)
        if (nextProfile === state.shapingProfile)
            return

        if (nextProfile === "hebrew") {
            state.lastNonHebrewMode = state.conversionMode
            state.conversionMode = "unicode"
            videoStudioPro = false
        }

        var nextSettings = Settings.ReshaperSettings.copy(reshaperSettings)
        var language = Settings.ReshaperSettings.profileLanguage(reshaperMetadata, nextProfile)
        if (language !== null)
            nextSettings.language = language
        reshaperSettings = Settings.ReshaperSettings.sanitize(reshaperMetadata, nextSettings)
        settingsRevision++
        state.shapingProfile = nextProfile

        if (nextProfile !== "hebrew")
            state.conversionMode = state.lastNonHebrewMode
        clearStatus()
        saveSettings()
    }

    function baseOption(name) {
        settingsRevision
        return reshaperSettings[name] === true
    }

    function setBaseOption(name, enabled) {
        if (Settings.ReshaperSettings.flags.indexOf(name) === -1 || baseOption(name) === (enabled === true))
            return
        var next = Settings.ReshaperSettings.copy(reshaperSettings)
        next[name] = enabled === true
        reshaperSettings = Settings.ReshaperSettings.sanitize(reshaperMetadata, next)
        settingsRevision++
        saveSettings()
    }

    function toggleBaseOption(name) {
        setBaseOption(name, !baseOption(name))
    }

    function ligatureEnabled(name) {
        settingsRevision
        return reshaperSettings.ligatures[name] === true
    }

    function toggleLigature(name) {
        if (!Object.prototype.hasOwnProperty.call(reshaperSettings.ligatures, name))
            return
        var next = Settings.ReshaperSettings.copy(reshaperSettings)
        next.ligatures[name] = !ligatureEnabled(name)
        reshaperSettings = Settings.ReshaperSettings.sanitize(reshaperMetadata, next)
        settingsRevision++
        saveSettings()
    }

    function resetReshaperSettings() {
        state.shapingProfile = "standardPersianArabic"
        state.conversionMode = state.lastNonHebrewMode
        reshaperSettings = Settings.ReshaperSettings.defaults(reshaperMetadata)
        settingsRevision++
        saveSettings()
    }

    function setFontPath(mode, path) {
        if (mode !== "unicode" && mode !== "compatibility")
            return false
        var nextPath = validFontPath(path) ? path : ""
        if (mode === "unicode")
            unicodeFontPath = nextPath
        else
            compatibilityFontPath = nextPath
        saveSettings()
        return nextPath !== "" || path === ""
    }

    function validFontPath(path) {
        if (typeof path !== "string" || path === "")
            return false
        return fileBridge && typeof fileBridge.fontPathExists === "function"
            ? fileBridge.fontPathExists(path)
            : false
    }

    function setEditorFontSize(value) {
        var next = Math.max(10, Math.min(48, Math.round(Number(value))))
        if (!isFinite(next) || editorFontSize === next)
            return false
        editorFontSize = next
        saveSettings()
        return true
    }

    function adjustEditorFontSize(delta) {
        return setEditorFontSize(editorFontSize + (delta < 0 ? -1 : 1))
    }

    function setKeyboardDrawerOpen(open) {
        var next = open === true
        if (keyboardDrawerOpen === next)
            return false
        keyboardDrawerOpen = next
        saveSettings()
        return true
    }

    function setAccentPreset(preset) {
        if (AppTheme.accentPresets.indexOf(preset) === -1 || accentPreset === preset)
            return false
        accentPreset = preset
        saveSettings()
        return true
    }

    function desktopSettings() {
        return {
            conversionMode: conversionMode,
            reverseWords: reverseWords,
            videoStudioPro: videoStudioPro,
            editorFontSize: editorFontSize,
            keyboardDrawerOpen: keyboardDrawerOpen,
            accentPreset: accentPreset,
            fontPaths: {
                unicode: unicodeFontPath,
                compatibility: compatibilityFontPath
            },
            exportSettings: exportSettings
        }
    }

    function saveSettings() {
        if (!state.settingsReady || !settingsStore || typeof settingsStore.save !== "function")
            return false
        var json = Settings.ReshaperSettings.serialize(
            reshaperMetadata, reshaperSettings, uiLanguage, shapingProfile, desktopSettings(), textTools)
        var result = settingsStore.save(json)
        if (!result || result.ok !== true) {
            state.settingsMessageKey = "settings.status.saveFailure"
            state.settingsMessageDetail = result && result.message ? String(result.message) : ""
            state.settingsStatusLevel = "error"
            return false
        }
        if (state.settingsStatusLevel === "error") {
            state.settingsMessageKey = ""
            state.settingsMessageDetail = ""
            state.settingsStatusLevel = "info"
        }
        settingsWritten(json)
        return true
    }

    function applyLoadedSettings(parsed) {
        uiLanguage = parsed.uiLanguage
        state.shapingProfile = parsed.shapingProfile
        reshaperSettings = Settings.ReshaperSettings.sanitize(reshaperMetadata, parsed.settings)
        textTools = TextTools.TextTools.copyState(parsed.textTools)
        settingsRevision++

        var desktop = Settings.ReshaperSettings.sanitizeDesktop(parsed.desktop)
        reverseWords = desktop.reverseWords
        state.lastNonHebrewMode = desktop.conversionMode
        state.conversionMode = hebrewProfile ? "unicode" : desktop.conversionMode
        videoStudioPro = !hebrewProfile && state.conversionMode === "compatibility"
            ? desktop.videoStudioPro
            : false
        editorFontSize = desktop.editorFontSize
        keyboardDrawerOpen = desktop.keyboardDrawerOpen
        accentPreset = desktop.accentPreset
        exportSettings = Settings.ReshaperSettings.sanitizeExportSettings(desktop.exportSettings)
        unicodeFontPath = validFontPath(desktop.fontPaths.unicode) ? desktop.fontPaths.unicode : ""
        compatibilityFontPath = validFontPath(desktop.fontPaths.compatibility) ? desktop.fontPaths.compatibility : ""
        return unicodeFontPath !== desktop.fontPaths.unicode
            || compatibilityFontPath !== desktop.fontPaths.compatibility
            || state.conversionMode !== desktop.conversionMode
    }

    function initializeSettings() {
        if (state.settingsInitialized)
            return
        state.settingsInitialized = true

        if (!settingsStore || typeof settingsStore.load !== "function") {
            state.settingsReady = true
            return
        }

        var result = settingsStore.load()
        if (!result || result.ok !== true) {
            applyLoadedSettings(Settings.ReshaperSettings.parse(reshaperMetadata, ""))
            state.settingsReady = true
            if (result && result.code === "SETTINGS_TOO_LARGE") {
                saveSettings()
                state.settingsMessageKey = "settings.status.recovered"
                state.settingsMessageDetail = ""
                state.settingsStatusLevel = "warning"
            } else {
                state.settingsMessageKey = "settings.status.loadFailure"
                state.settingsMessageDetail = result && result.message ? String(result.message) : ""
                state.settingsStatusLevel = "error"
            }
            return
        }

        if (result.exists !== true) {
            applyLoadedSettings(Settings.ReshaperSettings.parse(reshaperMetadata, ""))
            state.settingsReady = true
            saveSettings()
            return
        }

        var parsed
        try {
            Limits.ResourceLimits.assertSettingsSize(result.data)
            parsed = Settings.ReshaperSettings.parse(reshaperMetadata, result.data)
        } catch (error) {
            parsed = Settings.ReshaperSettings.parse(reshaperMetadata, "")
        }
        var repairedDesktop = applyLoadedSettings(parsed)
        state.settingsReady = true
        if (parsed.recovered || repairedDesktop) {
            saveSettings()
            state.settingsMessageKey = "settings.status.recovered"
            state.settingsMessageDetail = ""
            state.settingsStatusLevel = "warning"
        }
    }

    function clearStatus() {
        if (state.busy)
            return
        state.statusText = ""
        state.statusLevel = "info"
    }

    function conversionOptions() {
        return {
            reverseWords: reverseWords,
            autoParagraphDirection: true,
            videoStudioPro: videoStudioPro,
            shapingProfile: shapingProfile,
            reshaperOptions: reshaperSettings
        }
    }

    function convertAndCopy() {
        if (state.busy)
            return false

        var prepared = applyTextToolsToSource()
        try {
            Limits.ResourceLimits.assertTextLength(prepared.text, maximumTextLength, "CONVERSION_TEXT_TOO_LARGE")
        } catch (error) {
            state.statusText = error && error.code === "CONVERSION_TEXT_TOO_LARGE"
                ? uiText("status.textTooLarge")
                : uiText("status.failure") + String(error && error.message || error)
            state.statusLevel = "error"
            conversionFinished(false, "")
            return false
        }

        state.busy = true
        state.requestId++
        state.activeRequestId = state.requestId
        state.statusText = uiText("status.converting")
        state.statusLevel = "info"
        conversionWorker.sendMessage({
            id: state.activeRequestId,
            text: prepared.text,
            mode: conversionMode,
            options: conversionOptions(),
            maxOutputLength: maximumTextLength,
            sizeErrorCode: "CONVERSION_TEXT_TOO_LARGE"
        })
        return true
    }

    function finishConversion(message) {
        if (!state.busy || !message || message.id !== state.activeRequestId)
            return false

        state.busy = false
        state.activeRequestId = 0
        if (!message.ok) {
            state.statusText = message.code === "CONVERSION_TEXT_TOO_LARGE"
                ? uiText("status.textTooLarge")
                : uiText("status.failure") + String(message.message || "")
            state.statusLevel = "error"
            conversionFinished(false, "")
            return true
        }

        if (!clipboardBridge || typeof clipboardBridge.copyText !== "function" || !clipboardBridge.copyText(message.output)) {
            var clipboardMessage = clipboardBridge && clipboardBridge.lastError
                ? clipboardBridge.lastError
                : "The system clipboard is unavailable."
            state.statusText = uiText("status.failure") + clipboardMessage
            state.statusLevel = "error"
            conversionFinished(false, "")
            return true
        }

        state.lastOutput = message.output
        state.statusText = lastAppliedTextTools.length > 0
            ? uiText("status.converted") + " " + uiText("tools.appliedStatus")
            : uiText("status.converted")
        state.statusLevel = "success"
        conversionFinished(true, message.output)
        return true
    }

    onSourceTextChanged: {
        if (!restoringSourceHistory) {
            clearStatus()
            sourceHistory = History.SourceHistory.record(sourceHistory, {
                text: sourceText,
                cursor: sourceHistory.current.cursor,
                anchor: sourceHistory.current.anchor
            })
        }
    }
    Component.onCompleted: {
        AppTheme.accentPreset = accentPreset
        initializeSettings()
    }

    WorkerScript {
        id: conversionWorker
        source: Qt.resolvedUrl("ConversionWorker.js")
        onMessage: function(message) {
            root.finishConversion(message)
        }
    }

    QtObject {
        id: state
        property string shapingProfile: "standardPersianArabic"
        property string conversionMode: "unicode"
        property string lastNonHebrewMode: "unicode"
        property bool busy: false
        property int requestId: 0
        property int activeRequestId: 0
        property string statusText: ""
        property string statusLevel: "info"
        property string lastOutput: ""
        property bool settingsInitialized: false
        property bool settingsReady: false
        property string settingsMessageKey: ""
        property string settingsMessageDetail: ""
        property string settingsStatusLevel: "info"
        property string pendingDocumentAction: ""
    }
}
