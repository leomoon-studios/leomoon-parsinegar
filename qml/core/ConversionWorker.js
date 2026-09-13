// Heavy text conversion runs outside the QML scene/UI thread.
Qt.include("vendor/js-bidi.js");
Qt.include("vendor/js-parsi-reshaper.js");
Qt.include("qml/core/ParsiNegar.js");

WorkerScript.onMessage = function (message) {
    try {
        var output = ParsiNegar.convert(
            message.text,
            message.mode,
            message.options,
            JsBidi,
            JsParsiReshaper
        );
        if (typeof message.maxOutputLength === "number" && output.length > message.maxOutputLength) {
            var sizeError = new Error("Converted text exceeds the supported length");
            sizeError.code = message.sizeErrorCode || "CONVERSION_TEXT_TOO_LARGE";
            throw sizeError;
        }
        WorkerScript.sendMessage({ id: message.id, ok: true, output: output });
    } catch (error) {
        WorkerScript.sendMessage({
            id: message.id,
            ok: false,
            code: String(error && error.code || "CONVERSION_FAILED"),
            message: String(error && error.message || error)
        });
    }
};
