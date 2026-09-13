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
    property string sourceText: ""
    property bool editorRtl: true
    property bool reverseWords: true
    property bool videoStudioPro: false
    property string uiLanguage: "en"
    property var reshaperSettings: Settings.ReshaperSettings.defaults(Settings.ReshaperSettings.metadata)

    readonly property string shapingProfile: state.shapingProfile
    readonly property string conversionMode: state.conversionMode
    readonly property bool hebrewProfile: shapingProfile === "hebrew"
    readonly property bool busy: state.busy
    readonly property int conversionRequestId: state.requestId
    readonly property string statusText: state.statusText
    readonly property string statusLevel: state.statusLevel
    readonly property string lastOutput: state.lastOutput
    readonly property int maximumTextLength: Limits.ResourceLimits.values.maxConversionTextLength

    signal conversionFinished(bool ok, string output)

    function uiText(key) {
        return Strings.InterfaceStrings.text(uiLanguage, key)
    }

    function setEditorDirection(rtl) {
        editorRtl = rtl === true
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
        return true
    }

    function setShapingProfile(profile) {
        var nextProfile = Settings.ReshaperSettings.sanitizeShapingProfile(Settings.ReshaperSettings.metadata, profile)
        if (nextProfile === state.shapingProfile)
            return

        if (nextProfile === "hebrew") {
            state.lastNonHebrewMode = state.conversionMode
            state.conversionMode = "unicode"
            videoStudioPro = false
        }

        var nextSettings = Settings.ReshaperSettings.copy(reshaperSettings)
        var language = Settings.ReshaperSettings.profileLanguage(Settings.ReshaperSettings.metadata, nextProfile)
        if (language !== null)
            nextSettings.language = language
        reshaperSettings = Settings.ReshaperSettings.sanitize(Settings.ReshaperSettings.metadata, nextSettings)
        state.shapingProfile = nextProfile

        if (nextProfile !== "hebrew")
            state.conversionMode = state.lastNonHebrewMode
        clearStatus()
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
    }
}
