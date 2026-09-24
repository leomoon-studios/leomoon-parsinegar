import QtQuick
import QtTest
import LeoMoon.ParsiNegar
import LeoMoon.ParsiNegar.Test 1.0

TestCase {
    id: testCase
    name: "ExportWorkflow"

    Component {
        id: harnessComponent
        Item {
            id: harness
            property string capturedSvg: ""
            property string previewSvg: ""
            property url capturedDestination
            property alias exportController: curveController
            property alias editorController: editorController

            QtObject {
                id: clipboardMock
                property string lastError: ""
                function copyText(text) { return true }
            }

            EditorController {
                id: editorController
                clipboardBridge: clipboardMock
            }

            QtObject {
                id: bridgeProxy
                signal fontReadCompleted(int requestId, var result)
                signal svgWriteCompleted(int requestId, var result)

                function readBundledFontAsync(id) {
                    return NativeFileBridge.readBundledFontAsync(id)
                }

                function readFontAsync(id, url) {
                    return NativeFileBridge.readFontAsync(id, url)
                }

                function writeSvgAsync(id, destination, svg) {
                    harness.capturedDestination = destination
                    harness.capturedSvg = svg
                    Qt.callLater(function() {
                        bridgeProxy.svgWriteCompleted(id, {
                            ok: true,
                            path: "/tmp/mock-output.svg",
                            byteCount: svg.length
                        })
                    })
                    return true
                }
            }

            Connections {
                target: NativeFileBridge
                function onFontReadCompleted(id, result) {
                    bridgeProxy.fontReadCompleted(id, result)
                }
            }

            SvgCurveExportController {
                id: curveController
                fileBridge: bridgeProxy
            }

            Connections {
                target: curveController
                function onPreviewReady(svg, warnings, font) { harness.previewSvg = svg }
            }

            Image {
                id: previewImage
                objectName: "previewImage"
                width: 400
                height: 200
                source: harness.previewSvg === "" ? ""
                    : "data:image/svg+xml;charset=utf-8," + encodeURIComponent(harness.previewSvg)
                sourceSize.width: 800
                sourceSize.height: 400
                fillMode: Image.PreserveAspectFit
                asynchronous: true
            }
        }
    }

    function test_realWorkerConvertsAndOutlinesWithoutChangingSource() {
        var harness = createTemporaryObject(harnessComponent, testCase)
        verify(harness !== null)
        tryCompare(harness.editorController, "settingsReady", true)
        var source = "سلام.\nsalam."
        harness.editorController.sourceText = source

        verify(harness.exportController.exportWithBundledFont(
            source,
            "file:///tmp/mock-output.svg",
            {
                fontSize: 48,
                lineSpacing: 1.5,
                alignment: "right",
                bounds: { width: 600, height: 300, padding: 20 },
                fill: "#171717",
                precision: 3
            },
            harness.editorController.conversionMode,
            harness.editorController.conversionOptions()))

        tryCompare(harness.exportController, "busy", false, 20000)
        compare(harness.editorController.sourceText, source)
        compare(harness.exportController.convertedText, ".ﻡﻼﺳ\nsalam.")
        verify(/<svg /.test(harness.capturedSvg))
        verify(/<path /.test(harness.capturedSvg))
        verify(!/<(?:text|tspan|image|foreignObject)\b/i.test(harness.capturedSvg))
        verify(!/(?:font-family|@font-face|data:font|\bhref\s*=)/i.test(harness.capturedSvg))
        compare(harness.exportController.outputPath, "/tmp/mock-output.svg")
        compare(harness.exportController.fontIdentity.family, "Vazirmatn")
    }

    function test_realWorkerPreviewRendersWithoutSaving() {
        var harness = createTemporaryObject(harnessComponent, testCase)
        verify(harness !== null)
        tryCompare(harness.editorController, "settingsReady", true)
        var source = "سلام."
        harness.editorController.sourceText = source
        verify(harness.exportController.previewWithBundledFont(
            source, { fontSize: 48, alignment: "right", fill: "#171717" },
            harness.editorController.conversionMode,
            harness.editorController.conversionOptions()))

        tryCompare(harness.exportController, "busy", false, 20000)
        verify(/<svg /.test(harness.previewSvg))
        compare(harness.capturedSvg, "")
        compare(harness.exportController.outputPath, "")
        compare(harness.editorController.sourceText, source)
        var image = findChild(harness, "previewImage")
        verify(image !== null)
        tryCompare(image, "status", Image.Ready, 20000)
    }
}
