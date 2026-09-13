import QtQuick
import "qml/core/InterfaceStrings.js" as Strings
import "qml/core/ReshaperSettings.js" as Settings
import "qml/core/ResourceLimits.js" as Limits

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
    property string uiLanguage: "en"
    property string unicodeFontPath: ""
    property string compatibilityFontPath: ""
    property var reshaperSettings: Settings.ReshaperSettings.defaults(Settings.ReshaperSettings.metadata)
    property string page: "editor"
    property int settingsRevision: 0

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
    readonly property string settingsStatusText: state.settingsMessageKey === ""
        ? ""
        : uiText(state.settingsMessageKey) + state.settingsMessageDetail
    readonly property string settingsStatusLevel: state.settingsStatusLevel

    signal conversionFinished(bool ok, string output)
    signal settingsWritten(string json)

    function uiText(key) {
        return Strings.InterfaceStrings.text(uiLanguage, key)
    }

    function openSettings() {
        page = "settings"
    }

    function closeSettings() {
        page = "editor"
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

    function desktopSettings() {
        return {
            conversionMode: conversionMode,
            reverseWords: reverseWords,
            videoStudioPro: videoStudioPro,
            fontPaths: {
                unicode: unicodeFontPath,
                compatibility: compatibilityFontPath
            }
        }
    }

    function saveSettings() {
        if (!state.settingsReady || !settingsStore || typeof settingsStore.save !== "function")
            return false
        var json = Settings.ReshaperSettings.serialize(
            reshaperMetadata, reshaperSettings, uiLanguage, shapingProfile, desktopSettings())
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
        settingsRevision++

        var desktop = Settings.ReshaperSettings.sanitizeDesktop(parsed.desktop)
        reverseWords = desktop.reverseWords
        state.lastNonHebrewMode = desktop.conversionMode
        state.conversionMode = hebrewProfile ? "unicode" : desktop.conversionMode
        videoStudioPro = !hebrewProfile && state.conversionMode === "compatibility"
            ? desktop.videoStudioPro
            : false
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

        try {
            Limits.ResourceLimits.assertTextLength(sourceText, maximumTextLength, "CONVERSION_TEXT_TOO_LARGE")
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
            text: sourceText,
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
        state.statusText = uiText("status.converted")
        state.statusLevel = "success"
        conversionFinished(true, message.output)
        return true
    }

    onSourceTextChanged: clearStatus()
    Component.onCompleted: initializeSettings()

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
    }
}
