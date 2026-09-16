pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Dialogs as Dialogs
import QtQuick.Layouts

FocusScope {
    id: root

    required property var controller
    required property var exportController
    required property Typography typography
    property var fileBridge: null
    property bool advancedVisible: controller.exportSettings.advancedVisible
    property string alignment: controller.exportSettings.alignment
    property bool automaticWidth: controller.exportSettings.automaticWidth
    property bool automaticHeight: controller.exportSettings.automaticHeight
    property url chosenDestination
    property string statusText: ""
    property string statusLevel: "info"
    readonly property bool rightToLeft: controller.uiLanguage === "fa" || controller.uiLanguage === "ar"

    LayoutMirroring.enabled: rightToLeft
    LayoutMirroring.childrenInherit: true

    function uiText(key) {
        return controller.uiText(key)
    }

    function currentFontPath() {
        return controller.conversionMode === "unicode"
            ? controller.unicodeFontPath
            : controller.compatibilityFontPath
    }

    function fontDisplayName() {
        var path = currentFontPath()
        if (path === "" && controller.conversionMode === "unicode")
            return uiText("export.bundledFont")
        if (path === "")
            return uiText("export.fontRequired")
        return path.replace(/\\/g, "/").split("/").pop()
    }

    function numberValue(field) {
        return Number(field.text.trim())
    }

    function persistExportSettings() {
        controller.setExportSettings({
            advancedVisible: advancedVisible,
            automaticWidth: automaticWidth,
            automaticHeight: automaticHeight,
            alignment: alignment,
            fontSize: fontSizeField.text,
            lineSpacing: lineSpacingField.text,
            width: widthField.text,
            height: heightField.text,
            padding: paddingField.text,
            precision: precisionField.text,
            fontIndex: fontIndexField.text,
            fill: fillField.text,
            axes: axesField.text
        })
    }

    function exportOptions() {
        var fontSize = numberValue(fontSizeField)
        var lineSpacing = numberValue(lineSpacingField)
        var padding = numberValue(paddingField)
        var precision = numberValue(precisionField)
        if (!fontSizeField.acceptableNumber || !lineSpacingField.acceptableNumber
                || !paddingField.acceptableNumber || !precisionField.acceptableNumber
                || Math.floor(precision) !== precision) {
            throw new Error("INVALID_OPTION")
        }
        var fill = fillField.text.trim()
        if (!/^#[0-9a-fA-F]{6}([0-9a-fA-F]{2})?$/.test(fill))
            throw new Error("INVALID_OPTION")

        var bounds = { padding: padding }
        if (!automaticWidth) {
            if (!widthField.acceptableNumber)
                throw new Error("INVALID_OPTION")
            bounds.width = numberValue(widthField)
        }
        if (!automaticHeight) {
            if (!heightField.acceptableNumber)
                throw new Error("INVALID_OPTION")
            bounds.height = numberValue(heightField)
        }

        var result = {
            fontSize: fontSize,
            lineSpacing: lineSpacing,
            alignment: alignment,
            bounds: bounds,
            fill: fill,
            precision: precision
        }
        if (fontIndexField.text.trim() !== "") {
            var fontIndex = numberValue(fontIndexField)
            if (!fontIndexField.acceptableNumber || Math.floor(fontIndex) !== fontIndex)
                throw new Error("INVALID_OPTION")
            result.fontIndex = fontIndex
        }
        if (axesField.text.trim() !== "") {
            var parts = axesField.text.split(",")
            var axes = []
            for (var index = 0; index < parts.length; index++) {
                var axis = Number(parts[index].trim())
                if (!isFinite(axis))
                    throw new Error("INVALID_OPTION")
                axes.push(axis)
            }
            result.axes = axes
        }
        return result
    }

    function errorText(code, message, details) {
        var keys = {
            "INVALID_OPTION": "export.error.invalidOption",
            "INVALID_FONT": "export.error.invalidFont",
            "INVALID_FONT_INDEX": "export.error.invalidFont",
            "BOUNDS_TOO_SMALL": "export.error.bounds",
            "UNSUPPORTED_GLYPH": "export.error.unsupportedGlyph",
            "INVALID_OUTLINE": "export.error.unsupportedGlyph",
            "EXPORT_TEXT_TOO_LARGE": "export.error.textTooLarge",
            "FONT_TOO_LARGE": "export.error.fontTooLarge",
            "SVG_TOO_LARGE": "export.error.svgTooLarge",
            "INVALID_DIMENSIONS": "export.error.dimensions",
            "INVALID_LOCAL_URL": "export.error.invalidPath",
            "FONT_NOT_FOUND": "export.error.invalidFont",
            "FONT_READ_FAILED": "export.error.invalidFont",
            "UNSUPPORTED_FONT_TYPE": "export.error.invalidFont",
            "SVG_WRITE_FAILED": "export.error.save",
            "SVG_DIRECTORY_NOT_FOUND": "export.error.save"
        }
        var text = uiText(keys[code] || "export.error.generic")
        if (details && details.length)
            text += " " + glyphLabels(details)
        else if (!keys[code] && message)
            text += " " + message
        return text
    }

    function glyphLabels(glyphs) {
        var labels = []
        for (var index = 0; index < glyphs.length; index++)
            labels.push(glyphs[index].label)
        return labels.join(", ")
    }

    function validateBeforeSave() {
        statusText = ""
        if (controller.sourceText === "") {
            statusText = uiText("export.error.noText")
            statusLevel = "error"
            return false
        }
        if (controller.conversionMode === "compatibility" && controller.compatibilityFontPath === "") {
            statusText = uiText("export.error.fontRequired")
            statusLevel = "error"
            return false
        }
        try { exportOptions() }
        catch (error) {
            statusText = uiText("export.error.invalidOption")
            statusLevel = "error"
            return false
        }
        return true
    }

    function chooseDestination() {
        if (!validateBeforeSave())
            return false
        saveDialog.open()
        return true
    }

    function beginExport() {
        if (!validateBeforeSave() || String(chosenDestination) === "")
            return false
        statusText = uiText("export.processing")
        statusLevel = "info"
        var options = exportOptions()
        var conversionOptions = controller.conversionOptions()
        if (controller.conversionMode === "unicode" && controller.unicodeFontPath === "") {
            return exportController.exportWithBundledFont(
                controller.sourceText, chosenDestination, options,
                controller.conversionMode, conversionOptions)
        }
        var fontUrl = fileBridge.localFileUrl(currentFontPath())
        return exportController.exportTo(
            controller.sourceText, fontUrl, chosenDestination, options,
            controller.conversionMode, conversionOptions)
    }

    function acceptFont(url) {
        if (!fileBridge)
            return false
        var path = fileBridge.localFilePath(url)
        if (path === "" || !controller.setFontPath(controller.conversionMode, path)) {
            statusText = uiText("export.error.invalidPath")
            statusLevel = "error"
            return false
        }
        statusText = ""
        return true
    }

    Keys.onEscapePressed: function(event) {
        if (!exportController.busy)
            controller.closeExport()
        event.accepted = true
    }

    Connections {
        target: root.exportController
        function onExported(path, warnings, font) {
            root.statusText = warnings && warnings.length
                ? root.uiText("export.warning.missingGlyphs") + " " + root.glyphLabels(warnings)
                : root.uiText("export.success")
            root.statusLevel = warnings && warnings.length ? "warning" : "success"
        }
        function onFailed(code, message, details) {
            root.statusText = root.errorText(code, message, details)
            root.statusLevel = "error"
        }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: AppTheme.spacingMedium

        PageHeader {
            Layout.fillWidth: true
            title: root.uiText("export.title")
            subtitle: root.uiText("export.subtitle")
        }

        ScrollView {
            id: exportScroll
            objectName: "exportScroll"
            Layout.fillWidth: true
            Layout.fillHeight: true
            enabled: !root.exportController.busy
            contentWidth: availableWidth
            clip: true
            leftPadding: AppTheme.spacingLarge
            rightPadding: AppTheme.spacingLarge
            ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
            ScrollBar.vertical.policy: ScrollBar.AsNeeded

            Column {
                width: exportScroll.availableWidth
                spacing: AppTheme.spacingMedium

                Rectangle {
                    width: parent.width
                    height: modeContent.implicitHeight + AppTheme.spacingLarge * 2
                    radius: AppTheme.cornerRadiusLarge
                    color: AppTheme.surface
                    border.color: AppTheme.border
                    border.width: AppTheme.borderWidth

                    ColumnLayout {
                        id: modeContent
                        anchors.fill: parent
                        anchors.margins: AppTheme.spacingLarge
                        spacing: AppTheme.spacingMedium

                        SectionHeading {
                            label: root.uiText("export.mode")
                        }

                        GridLayout {
                            Layout.fillWidth: true
                            columns: 2
                            columnSpacing: AppTheme.spacingSmall

                            AppButton {
                                objectName: "exportUnicodeButton"
                                Layout.fillWidth: true
                                Layout.preferredWidth: 0
                                text: root.uiText("mode.unicode")
                                selected: root.controller.conversionMode === "unicode"
                                onClicked: root.controller.setConversionMode("unicode")
                            }

                            AppButton {
                                objectName: "exportCompatibilityButton"
                                Layout.fillWidth: true
                                Layout.preferredWidth: 0
                                text: root.uiText("mode.compatibility")
                                selected: root.controller.conversionMode === "compatibility"
                                enabled: !root.controller.hebrewProfile
                                onClicked: root.controller.setConversionMode("compatibility")
                            }
                        }

                        SectionHeading {
                            label: root.uiText("export.font")
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: AppTheme.spacingSmall

                            Label {
                                objectName: "exportFontName"
                                Layout.fillWidth: true
                                text: root.fontDisplayName()
                                font.family: AppTheme.fontFamily
                                font.pixelSize: AppTheme.fontBody
                                color: root.currentFontPath() === "" && root.controller.conversionMode === "compatibility"
                                    ? AppTheme.warning : AppTheme.foreground
                                elide: Text.ElideMiddle
                            }

                            AppButton {
                                objectName: "chooseExportFontButton"
                                text: root.uiText("export.chooseFont")
                                enabled: !root.exportController.busy
                                onClicked: fontDialog.open()
                            }

                            AppButton {
                                objectName: "useBundledFontButton"
                                visible: root.controller.conversionMode === "unicode" && root.controller.unicodeFontPath !== ""
                                text: root.uiText("export.useBundledFont")
                                enabled: !root.exportController.busy
                                onClicked: root.controller.setFontPath("unicode", "")
                            }
                        }
                    }
                }

                Rectangle {
                    width: parent.width
                    height: optionsContent.implicitHeight + AppTheme.spacingLarge * 2
                    radius: AppTheme.cornerRadiusLarge
                    color: AppTheme.surface
                    border.color: AppTheme.border
                    border.width: AppTheme.borderWidth

                    ColumnLayout {
                        id: optionsContent
                        anchors.fill: parent
                        anchors.margins: AppTheme.spacingLarge
                        spacing: AppTheme.spacingMedium

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: AppTheme.spacingMedium

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: AppTheme.spacingTiny
                                Label { text: root.uiText("export.fontSize"); font.family: AppTheme.fontFamily; color: AppTheme.muted }
                                NumericField { id: fontSizeField; objectName: "exportFontSize"; Layout.fillWidth: true; minimumValue: 0.01; maximumValue: 4096; text: root.controller.exportSettings.fontSize; onEditingFinished: root.persistExportSettings() }
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: AppTheme.spacingTiny
                                Label { text: root.uiText("export.lineSpacing"); font.family: AppTheme.fontFamily; color: AppTheme.muted }
                                NumericField { id: lineSpacingField; objectName: "exportLineSpacing"; Layout.fillWidth: true; minimumValue: 0.01; maximumValue: 10; text: root.controller.exportSettings.lineSpacing; onEditingFinished: root.persistExportSettings() }
                            }
                        }

                        Label { text: root.uiText("export.alignment"); font.family: AppTheme.fontFamily; color: AppTheme.muted }

                        GridLayout {
                            Layout.fillWidth: true
                            columns: 3
                            columnSpacing: AppTheme.spacingSmall
                            AppButton { objectName: "exportAlignLeft"; Layout.fillWidth: true; Layout.preferredWidth: 0; text: root.uiText("export.alignLeft"); selected: root.alignment === "left"; onClicked: { root.alignment = "left"; root.persistExportSettings() } }
                            AppButton { objectName: "exportAlignCenter"; Layout.fillWidth: true; Layout.preferredWidth: 0; text: root.uiText("export.alignCenter"); selected: root.alignment === "center"; onClicked: { root.alignment = "center"; root.persistExportSettings() } }
                            AppButton { objectName: "exportAlignRight"; Layout.fillWidth: true; Layout.preferredWidth: 0; text: root.uiText("export.alignRight"); selected: root.alignment === "right"; onClicked: { root.alignment = "right"; root.persistExportSettings() } }
                        }

                        AppButton {
                            objectName: "exportMoreOptionsButton"
                            Layout.fillWidth: true
                            text: root.advancedVisible ? root.uiText("export.fewerOptions") : root.uiText("export.moreOptions")
                            selected: root.advancedVisible
                            onClicked: {
                                root.advancedVisible = !root.advancedVisible
                                root.persistExportSettings()
                            }
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            visible: root.advancedVisible
                            spacing: AppTheme.spacingMedium

                            GridLayout {
                                Layout.fillWidth: true
                                columns: 3
                                columnSpacing: AppTheme.spacingMedium
                                rowSpacing: AppTheme.spacingSmall

                                Label { text: root.uiText("export.width"); font.family: AppTheme.fontFamily; color: AppTheme.muted }
                                NumericField { id: widthField; objectName: "exportWidth"; Layout.fillWidth: true; minimumValue: 0.01; maximumValue: 1000000; text: root.controller.exportSettings.width; enabled: !root.automaticWidth; opacity: enabled ? 1.0 : 0.5; onEditingFinished: root.persistExportSettings() }
                                AppToggle {
                                    objectName: "exportAutoWidth"
                                    text: root.uiText("export.auto")
                                    checked: root.automaticWidth
                                    onToggled: {
                                        root.automaticWidth = checked
                                        root.persistExportSettings()
                                    }
                                    Accessible.name: root.uiText("export.auto") + " " + root.uiText("export.width")
                                }

                                Label { text: root.uiText("export.height"); font.family: AppTheme.fontFamily; color: AppTheme.muted }
                                NumericField { id: heightField; objectName: "exportHeight"; Layout.fillWidth: true; minimumValue: 0.01; maximumValue: 1000000; text: root.controller.exportSettings.height; enabled: !root.automaticHeight; opacity: enabled ? 1.0 : 0.5; onEditingFinished: root.persistExportSettings() }
                                AppToggle {
                                    objectName: "exportAutoHeight"
                                    text: root.uiText("export.auto")
                                    checked: root.automaticHeight
                                    onToggled: {
                                        root.automaticHeight = checked
                                        root.persistExportSettings()
                                    }
                                    Accessible.name: root.uiText("export.auto") + " " + root.uiText("export.height")
                                }
                            }

                            GridLayout {
                                Layout.fillWidth: true
                                columns: 2
                                columnSpacing: AppTheme.spacingMedium
                                rowSpacing: AppTheme.spacingSmall

                                ColumnLayout {
                                    Layout.fillWidth: true
                                    Label { text: root.uiText("export.padding"); font.family: AppTheme.fontFamily; color: AppTheme.muted }
                                    NumericField { id: paddingField; objectName: "exportPadding"; Layout.fillWidth: true; minimumValue: 0; maximumValue: 100000; text: root.controller.exportSettings.padding; onEditingFinished: root.persistExportSettings() }
                                }
                                ColumnLayout {
                                    Layout.fillWidth: true
                                    Label { text: root.uiText("export.precision"); font.family: AppTheme.fontFamily; color: AppTheme.muted }
                                    NumericField { id: precisionField; objectName: "exportPrecision"; Layout.fillWidth: true; minimumValue: 0; maximumValue: 8; text: root.controller.exportSettings.precision; onEditingFinished: root.persistExportSettings() }
                                }
                                ColumnLayout {
                                    Layout.fillWidth: true
                                    Label { text: root.uiText("export.fontIndex"); font.family: AppTheme.fontFamily; color: AppTheme.muted }
                                    NumericField { id: fontIndexField; objectName: "exportFontIndex"; Layout.fillWidth: true; minimumValue: 0; maximumValue: 1000000; text: root.controller.exportSettings.fontIndex; placeholderText: root.uiText("export.default"); onEditingFinished: root.persistExportSettings() }
                                }
                                ColumnLayout {
                                    Layout.fillWidth: true
                                    Label { text: root.uiText("export.fill"); font.family: AppTheme.fontFamily; color: AppTheme.muted }
                                    TextField { id: fillField; objectName: "exportFill"; Layout.fillWidth: true; text: root.controller.exportSettings.fill; font.family: AppTheme.fontFamily; onEditingFinished: root.persistExportSettings() }
                                }
                            }

                            Label { text: root.uiText("export.axes"); font.family: AppTheme.fontFamily; color: AppTheme.muted }
                            TextField { id: axesField; objectName: "exportAxes"; Layout.fillWidth: true; text: root.controller.exportSettings.axes; placeholderText: root.uiText("export.axesHint"); font.family: AppTheme.fontFamily; LayoutMirroring.enabled: false; onEditingFinished: root.persistExportSettings() }
                        }
                    }
                }

                Label {
                    objectName: "exportFontIdentity"
                    width: parent.width
                    visible: Boolean(root.exportController.fontIdentity.family)
                    text: root.uiText("export.inspectedFont").arg(root.exportController.fontIdentity.family || "").arg(root.exportController.fontIdentity.style || "")
                    font.family: AppTheme.fontFamily
                    font.pixelSize: AppTheme.fontCaption
                    color: AppTheme.muted
                    elide: Text.ElideRight
                }

                AppButton {
                    objectName: "saveSvgButton"
                    width: parent.width
                    text: root.exportController.busy ? root.uiText("button.cancel") : root.uiText("export.save")
                    accent: true
                    enabled: root.typography.ready
                    onClicked: {
                        if (root.exportController.busy) {
                            root.exportController.cancel()
                            root.statusText = root.uiText("export.cancelled")
                            root.statusLevel = "info"
                        } else {
                            root.chooseDestination()
                        }
                    }
                }
            }
        }

        Item {
            Layout.fillWidth: true
            Layout.minimumHeight: 44
            Layout.preferredHeight: 44
            Layout.maximumHeight: 44
            StatusMessage { anchors.fill: parent; message: root.statusText; level: root.statusLevel; busy: root.exportController.busy }
        }
    }

    Dialogs.FileDialog {
        id: fontDialog
        title: root.uiText("export.chooseFont")
        fileMode: Dialogs.FileDialog.OpenFile
        nameFilters: ["OpenType fonts (*.ttf *.otf *.ttc)"]
        onAccepted: root.acceptFont(selectedFile)
    }

    Dialogs.FileDialog {
        id: saveDialog
        title: root.uiText("export.save")
        fileMode: Dialogs.FileDialog.SaveFile
        defaultSuffix: "svg"
        nameFilters: ["SVG images (*.svg)"]
        onAccepted: {
            root.chosenDestination = selectedFile
            root.beginExport()
        }
    }
}
