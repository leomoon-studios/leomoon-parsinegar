// Font parsing and SVG outline generation run outside the QML scene thread.
Qt.include("vendor/typr.js");
Qt.include("vendor/js-bidi.js");
Qt.include("vendor/js-parsi-reshaper.js");
Qt.include("qml/core/ParsiNegar.js");
Qt.include("qml/core/ResourceLimits.js");
Qt.include("qml/core/SvgCurveExporter.js");

var currentJob = null;

function processJob(message) {
    try {
        var text = currentJob.conversionMode
            ? ParsiNegar.convert(
                currentJob.text,
                currentJob.conversionMode,
                currentJob.conversionOptions || {},
                JsBidi,
                JsParsiReshaper)
            : currentJob.text;
        var bytes = new Uint8Array(currentJob.fontBytes);
        ResourceLimits.assertFontBytes(bytes);
        var inspection = SvgCurveExporter.inspect(
            text, bytes, currentJob.options, Typr, ResourceLimits
        );
        var svg = SvgCurveExporter.exportSvg(
            text, bytes, currentJob.options, Typr, ResourceLimits
        );
        currentJob = null;
        WorkerScript.sendMessage({
            id: message.id,
            ok: true,
            svg: svg,
            font: inspection.font,
            missingGlyphs: inspection.missingGlyphs,
            convertedText: text
        });
    } catch (error) {
        currentJob = null;
        WorkerScript.sendMessage({
            id: message.id,
            ok: false,
            code: String(error && error.code || "EXPORT_FAILED"),
            message: String(error && error.message || error),
            details: error && error.details || []
        });
    }
}

WorkerScript.onMessage = function (message) {
    if (message.action === "cancel") {
        if (currentJob && currentJob.id === message.id)
            currentJob = null;
        return;
    }
    if (message.action === "begin") {
        currentJob = {
            id: message.id,
            text: message.text,
            options: message.options,
            conversionMode: message.conversionMode,
            conversionOptions: message.conversionOptions,
            fontBytes: []
        };
        return;
    }
    if (message.action !== "chunk" || !currentJob || currentJob.id !== message.id)
        return;
    try {
        for (var index = 0; index < message.fontBytes.length; index++)
            currentJob.fontBytes.push(message.fontBytes[index]);
        if (message.final)
            processJob(message);
    } catch (error) {
        currentJob = null;
        WorkerScript.sendMessage({
            id: message.id,
            ok: false,
            code: String(error && error.code || "EXPORT_FAILED"),
            message: String(error && error.message || error),
            details: error && error.details || []
        });
    }
};
