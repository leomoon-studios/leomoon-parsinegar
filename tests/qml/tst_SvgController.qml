import QtQuick
import QtTest
import LeoMoon.ParsiNegar

TestCase {
    id: testCase
    name: "SvgController"

    Component {
        id: controllerComponent
        SvgCurveExportController {
            property QtObject bridgeMock: QtObject {
                property int readCount: 0
                property int bundledReadCount: 0
                property int writeCount: 0
                property int lastRequestId: 0
                property url lastDestination
                property string lastSvg: ""
                signal fontReadCompleted(int requestId, var result)
                signal svgWriteCompleted(int requestId, var result)
                function readFontAsync(id, url) { readCount++; lastRequestId = id; return true }
                function readBundledFontAsync(id) { bundledReadCount++; lastRequestId = id; return true }
                function writeSvgAsync(id, destination, svg) {
                    writeCount++
                    lastRequestId = id
                    lastDestination = destination
                    lastSvg = svg
                    return true
                }
            }
            fileBridge: bridgeMock
        }
    }

    function createController() {
        var controller = createTemporaryObject(controllerComponent, testCase)
        verify(controller !== null)
        return controller
    }

    function test_boundedRequestAndStaleResponses() {
        var controller = createController()
        verify(controller.exportTo("پارسی", "file:///tmp/font.ttf", "file:///tmp/result.svg", {
            fontSize: 48,
            lineSpacing: 1.2,
            alignment: "right",
            bounds: { width: 600, height: 300, padding: 20 },
            fill: "#000000",
            precision: 3,
            fontIndex: 0,
            axes: [400]
        }))
        verify(controller.busy)
        compare(controller.bridgeMock.readCount, 1)
        verify(!controller.exportTo("second", "file:///tmp/font.ttf", "file:///tmp/result.svg", {}))
        verify(!controller.finishWorker({ id: controller.activeRequestId + 1, ok: true, svg: "<svg/>", missingGlyphs: [] }))
        compare(controller.bridgeMock.writeCount, 0)

        verify(controller.finishWorker({
            id: controller.activeRequestId,
            ok: true,
            svg: "<svg><path d=\"M0 0Z\"/></svg>",
            missingGlyphs: [],
            font: { family: "Vazirmatn", style: "Regular" }
        }))
        compare(controller.bridgeMock.writeCount, 1)
        verify(controller.finishWrite(controller.activeRequestId, {
            ok: true,
            path: "/tmp/result.svg",
            byteCount: controller.bridgeMock.lastSvg.length
        }))
        verify(!controller.busy)
        compare(controller.outputPath, "/tmp/result.svg")
        compare(controller.fontIdentity.family, "Vazirmatn")
    }

    function test_missingGlyphsAreWrittenAsWarning() {
        var controller = createController()
        verify(controller.exportWithBundledFont("🧬", "file:///tmp/result.svg", {}))
        compare(controller.bridgeMock.bundledReadCount, 1)
        var id = controller.activeRequestId
        verify(controller.finishWorker({
            id: id,
            ok: true,
            svg: "<svg><path d=\"M0 0Z\"/></svg>",
            missingGlyphs: [{ character: "🧬", codePoint: 129516, label: "U+1F9EC" }],
            font: { family: "Vazirmatn" }
        }))
        verify(controller.busy)
        compare(controller.errorCode, "")
        compare(controller.missingGlyphs.length, 1)
        compare(controller.bridgeMock.writeCount, 1)
        verify(controller.finishWrite(id, {
            ok: true,
            path: "/tmp/result.svg",
            byteCount: controller.bridgeMock.lastSvg.length
        }))
        verify(!controller.busy)
        compare(controller.outputPath, "/tmp/result.svg")
    }

    function test_previewProducesSvgWithoutWriting() {
        var controller = createController()
        var previewSvg = ""
        var previewWarnings = []
        controller.previewReady.connect(function(svg, warnings) {
            previewSvg = svg
            previewWarnings = warnings
        })
        verify(controller.previewTo("پارسی", "file:///tmp/font.ttf", {}, "unicode", {}))
        compare(controller.bridgeMock.readCount, 1)
        compare(controller.pendingPreview, true)
        verify(!controller.previewWithBundledFont("second", {}, "unicode", {}))

        var id = controller.activeRequestId
        verify(controller.finishWorker({
            id: id,
            ok: true,
            svg: "<svg><path d=\"M0 0Z\"/></svg>",
            missingGlyphs: [{ label: "U+1F9EC" }],
            font: { family: "LMN Test" }
        }))
        compare(previewSvg, "<svg><path d=\"M0 0Z\"/></svg>")
        compare(previewWarnings.length, 1)
        compare(controller.bridgeMock.writeCount, 0)
        compare(controller.outputPath, "")
        compare(controller.fontIdentity.family, "LMN Test")
        compare(controller.pendingPreview, false)
        compare(controller.busy, false)
        verify(!controller.finishWorker({ id: id, ok: true, svg: "<svg/>" }))
    }

    function test_oversizedTextRejectedBeforeRead() {
        var controller = createController()
        var oversized = new Array(50002).join("پ")
        verify(!controller.exportWithBundledFont(oversized, "file:///tmp/result.svg", {}))
        compare(controller.errorCode, "EXPORT_TEXT_TOO_LARGE")
        compare(controller.bridgeMock.bundledReadCount, 0)
    }

    function test_cancelDiscardsLateResults() {
        var controller = createController()
        verify(controller.exportWithBundledFont("پارسی", "file:///tmp/result.svg", {}))
        var cancelledId = controller.activeRequestId
        verify(controller.cancel())
        verify(!controller.busy)
        compare(controller.activeRequestId, 0)
        verify(!controller.finishWorker({ id: cancelledId, ok: true, svg: "<svg/>", missingGlyphs: [] }))
        compare(controller.bridgeMock.writeCount, 0)
        verify(!controller.cancel())
    }
}
