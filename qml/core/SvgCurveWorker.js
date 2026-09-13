// Font parsing and SVG outline generation run outside the QML scene thread.
Qt.include("vendor/typr.js");
Qt.include("qml/core/ResourceLimits.js");
Qt.include("qml/core/SvgCurveExporter.js");

WorkerScript.onMessage = function (message) {
    try {
        var bytes = new Uint8Array(message.fontBytes);
        ResourceLimits.assertFontBytes(bytes);
        var inspection = SvgCurveExporter.inspect(
            message.text, bytes, message.options, Typr, ResourceLimits
        );
        var svg = SvgCurveExporter.exportSvg(
            message.text, bytes, message.options, Typr, ResourceLimits
        );
        WorkerScript.sendMessage({
            id: message.id,
            ok: true,
            svg: svg,
            font: inspection.font,
            missingGlyphs: inspection.missingGlyphs
        });
    } catch (error) {
        WorkerScript.sendMessage({
            id: message.id,
            ok: false,
            code: String(error && error.code || "EXPORT_FAILED"),
            message: String(error && error.message || error),
            details: error && error.details || []
        });
    }
};
