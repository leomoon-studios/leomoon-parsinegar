import QtQuick
import "qml/core/ResourceLimits.js" as Limits

// Coordinates bounded native I/O with the scene-independent curve worker.
Item {
    id: root

    visible: false
    width: 0
    height: 0

    property var fileBridge: null
    property bool busy: false
    property string errorCode: ""
    property string errorMessage: ""
    property string outputPath: ""
    property var missingGlyphs: []
    property var fontIdentity: ({})
    property int requestId: 0
    property int activeRequestId: 0
    property string pendingText: ""
    property url pendingDestination
    property var pendingOptions: ({})
    property bool pendingAllowMissingGlyphs: false

    signal exported(string path, var warnings, var font)
    signal failed(string code, string message, var details)

    function exportTo(text, fontUrl, destinationUrl, options, allowMissing) {
        if (busy || !fileBridge || typeof fileBridge.readFontAsync !== "function")
            return false
        try {
            Limits.ResourceLimits.assertTextLength(
                text, Limits.ResourceLimits.values.maxSvgTextLength, "EXPORT_TEXT_TOO_LARGE")
        } catch (error) {
            failExport(error.code, error.message || error, error.details || [])
            return false
        }

        busy = true
        errorCode = ""
        errorMessage = ""
        outputPath = ""
        missingGlyphs = []
        fontIdentity = ({})
        pendingText = text
        pendingDestination = destinationUrl
        pendingOptions = options || ({})
        pendingAllowMissingGlyphs = allowMissing === true
        requestId++
        activeRequestId = requestId
        if (!fileBridge.readFontAsync(activeRequestId, fontUrl)) {
            failExport("FONT_READ_FAILED", "The font read could not be started.", [])
            return false
        }
        return true
    }

    function exportWithBundledFont(text, destinationUrl, options, allowMissing) {
        if (busy || !fileBridge || typeof fileBridge.readBundledFontAsync !== "function")
            return false
        try {
            Limits.ResourceLimits.assertTextLength(
                text, Limits.ResourceLimits.values.maxSvgTextLength, "EXPORT_TEXT_TOO_LARGE")
        } catch (error) {
            failExport(error.code, error.message || error, error.details || [])
            return false
        }
        busy = true
        errorCode = ""
        errorMessage = ""
        outputPath = ""
        missingGlyphs = []
        fontIdentity = ({})
        pendingText = text
        pendingDestination = destinationUrl
        pendingOptions = options || ({})
        pendingAllowMissingGlyphs = allowMissing === true
        requestId++
        activeRequestId = requestId
        if (!fileBridge.readBundledFontAsync(activeRequestId)) {
            failExport("FONT_READ_FAILED", "The bundled font read could not be started.", [])
            return false
        }
        return true
    }

    function finishFontRead(id, result) {
        if (!busy || id !== activeRequestId)
            return false
        if (!result || result.ok !== true) {
            failExport(result && result.code, result && result.message, [])
            return true
        }
        curveWorker.sendMessage({
            id: id,
            text: pendingText,
            options: pendingOptions,
            fontBytes: result.data
        })
        return true
    }

    function finishWorker(message) {
        if (!busy || !message || message.id !== activeRequestId)
            return false
        if (!message.ok) {
            failExport(message.code, message.message, message.details)
            return true
        }
        fontIdentity = message.font || ({})
        missingGlyphs = message.missingGlyphs || []
        if (missingGlyphs.length > 0 && !pendingAllowMissingGlyphs) {
            failExport("MISSING_GLYPHS", "The selected font is missing required glyphs.", missingGlyphs)
            return true
        }
        if (!fileBridge || typeof fileBridge.writeSvgAsync !== "function"
                || !fileBridge.writeSvgAsync(activeRequestId, pendingDestination, message.svg)) {
            failExport("SVG_WRITE_FAILED", "The SVG write could not be started.", [])
        }
        return true
    }

    function finishWrite(id, result) {
        if (!busy || id !== activeRequestId)
            return false
        if (!result || result.ok !== true) {
            failExport(result && result.code, result && result.message, [])
            return true
        }
        var warnings = missingGlyphs
        var font = fontIdentity
        outputPath = String(result.path || "")
        resetPending()
        busy = false
        exported(outputPath, warnings, font)
        return true
    }

    function failExport(code, message, details) {
        requestId++
        activeRequestId = 0
        resetPending()
        busy = false
        errorCode = String(code || "EXPORT_FAILED")
        errorMessage = String(message || "Export failed")
        failed(errorCode, errorMessage, details || [])
    }

    function resetPending() {
        pendingText = ""
        pendingDestination = ""
        pendingOptions = ({})
        pendingAllowMissingGlyphs = false
    }

    WorkerScript {
        id: curveWorker
        source: Qt.resolvedUrl("SvgCurveWorker.js")
        onMessage: function(message) { root.finishWorker(message) }
    }

    Connections {
        target: root.fileBridge
        ignoreUnknownSignals: true
        function onFontReadCompleted(id, result) { root.finishFontRead(id, result) }
        function onSvgWriteCompleted(id, result) { root.finishWrite(id, result) }
    }
}
