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
    property string pendingConversionMode: ""
    property var pendingConversionOptions: ({})
    property bool pendingPreview: false
    property string convertedText: ""
    property var fontByteView: null
    property int fontByteOffset: 0

    signal exported(string path, var warnings, var font)
    signal previewReady(string svg, var warnings, var font)
    signal failed(string code, string message, var details)
    signal cancelled()

    function cancel() {
        if (!busy)
            return false
        curveWorker.sendMessage({ action: "cancel", id: activeRequestId })
        requestId++
        activeRequestId = 0
        resetPending()
        busy = false
        cancelled()
        return true
    }

    function exportTo(text, fontUrl, destinationUrl, options, conversionMode, conversionOptions) {
        return startRequest(text, fontUrl, destinationUrl, options,
            conversionMode, conversionOptions, false, false)
    }

    function exportWithBundledFont(text, destinationUrl, options, conversionMode, conversionOptions) {
        return startRequest(text, "", destinationUrl, options,
            conversionMode, conversionOptions, true, false)
    }

    function previewTo(text, fontUrl, options, conversionMode, conversionOptions) {
        return startRequest(text, fontUrl, "", options,
            conversionMode, conversionOptions, false, true)
    }

    function previewWithBundledFont(text, options, conversionMode, conversionOptions) {
        return startRequest(text, "", "", options,
            conversionMode, conversionOptions, true, true)
    }

    function startRequest(text, fontUrl, destinationUrl, options,
                          conversionMode, conversionOptions, bundled, preview) {
        if (busy || !fileBridge
                || typeof fileBridge[bundled ? "readBundledFontAsync" : "readFontAsync"] !== "function")
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
        pendingConversionMode = conversionMode || ""
        pendingConversionOptions = conversionOptions || ({})
        pendingPreview = preview
        requestId++
        activeRequestId = requestId
        var started = bundled
            ? fileBridge.readBundledFontAsync(activeRequestId)
            : fileBridge.readFontAsync(activeRequestId, fontUrl)
        if (!started) {
            failExport("FONT_READ_FAILED", bundled
                ? "The bundled font read could not be started."
                : "The font read could not be started.", [])
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
        try {
            fontByteView = new Uint8Array(result.data)
            Limits.ResourceLimits.assertFontBytes(fontByteView)
            fontByteOffset = 0
            curveWorker.sendMessage({
                action: "begin",
                id: id,
                text: pendingText,
                options: pendingOptions,
                conversionMode: pendingConversionMode,
                conversionOptions: pendingConversionOptions
            })
            copyFontChunk()
        } catch (error) {
            failExport(error.code, error.message || error, error.details || [])
        }
        return true
    }

    function copyFontChunk() {
        if (!busy || !fontByteView)
            return
        var end = Math.min(fontByteOffset + 262144, fontByteView.length)
        var chunk = []
        for (var index = fontByteOffset; index < end; index++)
            chunk.push(fontByteView[index])
        fontByteOffset = end
        curveWorker.sendMessage({
            action: "chunk",
            id: activeRequestId,
            fontBytes: chunk,
            final: fontByteOffset >= fontByteView.length
        })
        if (fontByteOffset < fontByteView.length) {
            Qt.callLater(copyFontChunk)
            return
        }
        fontByteView = null
        fontByteOffset = 0
    }

    function finishWorker(message) {
        if (!busy || !message || message.id !== activeRequestId)
            return false
        if (!message.ok) {
            failExport(message.code, message.message, message.details)
            return true
        }
        fontIdentity = message.font || ({})
        convertedText = String(message.convertedText || "")
        missingGlyphs = message.missingGlyphs || []
        if (pendingPreview) {
            var svg = String(message.svg || "")
            var warnings = missingGlyphs
            var font = fontIdentity
            resetPending()
            activeRequestId = 0
            busy = false
            previewReady(svg, warnings, font)
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
        if (activeRequestId !== 0)
            curveWorker.sendMessage({ action: "cancel", id: activeRequestId })
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
        pendingConversionMode = ""
        pendingConversionOptions = ({})
        pendingPreview = false
        fontByteView = null
        fontByteOffset = 0
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
