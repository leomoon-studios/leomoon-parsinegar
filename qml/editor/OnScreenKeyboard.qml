pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: root

    required property var controller
    property string activeLayer: "primary"
    property string visualDirection: "rtl"
    readonly property bool rightToLeft: controller.uiLanguage === "fa" || controller.uiLanguage === "ar"
    readonly property var primaryRows: [
        ["\\", "چ", "ج", "ح", "خ", "ه", "ع", "غ", "ف", "ق", "ث", "ص", "ض", "ژ"],
        ["گ", "ک", "م", "ن", "ت", "ا", "ل", "ب", "ی", "س", "ش"],
        ["/", ".", "و", "پ", "د", "ذ", "ر", "ز", "ط", "ظ", "﴿", "﴾"],
        ["ئ", "ؤ", "ي", "ك", "ة", "آ", "إ", "أ", "ء"]
    ]
    readonly property var symbolsRows: [
        ["=", "-", "۰", "۹", "۸", "۷", "۶", "۵", "۴", "۳", "۲", "۱", "ـ"],
        ["«", "»", "﴿", "﴾", "﷼", "٪", "٫", "،", "؛", "؟", "!", "-", "/", "\\"],
        ["(", ")", "[", "]", "{", "}", ":", "=", "+", "*", "×", "÷", "·", "…"],
        [
            { id: "fatha", label: "◌َ", text: "َ", diacritic: true },
            { id: "kasra", label: "◌ِ", text: "ِ", diacritic: true },
            { id: "damma", label: "◌ُ", text: "ُ", diacritic: true },
            { id: "fathatan", label: "◌ً", text: "ً", diacritic: true },
            { id: "kasratan", label: "◌ٍ", text: "ٍ", diacritic: true },
            { id: "dammatan", label: "◌ٌ", text: "ٌ", diacritic: true },
            { id: "shadda", label: "◌ّ", text: "ّ", diacritic: true },
            { id: "sukun", label: "◌ْ", text: "ْ", diacritic: true },
            { id: "hamzaAbove", label: "◌ٔ", text: "ٔ", diacritic: true },
            { id: "superscriptAlef", label: "◌ٰ", text: "ٰ", diacritic: true },
            "ـ",
            { label: "ZWNJ", text: "‌", tooltipKey: "keyboard.zwnjTooltip" }, { label: "ZWJ", text: "‍", tooltipKey: "keyboard.zwjTooltip" },
            { label: "RLM", text: "‏", tooltipKey: "keyboard.rlmTooltip" }, { label: "LRM", text: "‎", tooltipKey: "keyboard.lrmTooltip" },
            { label: "RLE", text: "‫", tooltipKey: "keyboard.rleTooltip" }, { label: "LRE", text: "‪", tooltipKey: "keyboard.lreTooltip" }
        ]
    ]
    readonly property var activeRows: activeLayer === "primary" ? primaryRows : symbolsRows
    readonly property var pairedSymbols: ({
        "«": "»", "»": "«",
        "﴿": "﴾", "﴾": "﴿",
        "(": ")", ")": "(",
        "[": "]", "]": "[",
        "{": "}", "}": "{"
    })

    function keyAt(row, position) {
        var key = row[position]
        if (visualDirection !== "ltr" || typeof key !== "string")
            return key

        var partner = pairedSymbols[key]
        if (partner !== undefined
                && ((position > 0 && row[position - 1] === partner)
                    || (position + 1 < row.length && row[position + 1] === partner)))
            return partner
        return key
    }

    function displayLabel(value) {
        var mirroredLabels = {
            "(": ")",
            ")": "(",
            "[": "]",
            "]": "[",
            "{": "}",
            "}": "{",
            "«": "»",
            "»": "«"
        }
        return visualDirection === "rtl" ? (mirroredLabels[value] || value) : value
    }

    signal textRequested(string text)
    signal backspaceRequested()
    signal newlineRequested()

    implicitHeight: keyboardSurface.implicitHeight
    LayoutMirroring.enabled: false
    LayoutMirroring.childrenInherit: false

    component KeyboardKey: Button {
        id: keyButton

        required property var keyData
        readonly property string insertionText: typeof keyData === "string" ? keyData : keyData.text
        readonly property string keyLabel: root.displayLabel(
            typeof keyData === "string" ? keyData : keyData.label)
        readonly property string keyId: typeof keyData === "string" ? keyData : keyData.id || keyData.label
        readonly property bool diacritic: typeof keyData === "object" && keyData.diacritic === true
        readonly property string toolTipText: typeof keyData === "object" && keyData.tooltipKey
            ? root.controller.uiText(keyData.tooltipKey) : ""

        implicitWidth: 40
        implicitHeight: 34
        objectName: "keyboardKey_" + keyId
        padding: AppTheme.spacingTiny
        hoverEnabled: true
        focusPolicy: Qt.TabFocus
        text: keyLabel
        Accessible.name: keyLabel

        contentItem: Text {
            text: keyButton.insertionText === "﴿" || keyButton.insertionText === "﴾"
                ? "\u200E" + keyButton.text + "\u200E" : keyButton.text
            font.family: AppTheme.fontFamily
            font.pixelSize: keyButton.diacritic ? AppTheme.fontBody + 10
                : keyButton.keyLabel.length > 3 ? AppTheme.fontCaption : AppTheme.fontBody
            font.weight: keyButton.diacritic ? Font.DemiBold : Font.Medium
            color: AppTheme.foreground
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideRight
        }

        background: Rectangle {
            color: keyButton.down || keyButton.hovered ? AppTheme.surfaceRaised : AppTheme.surface
            border.color: keyButton.visualFocus ? AppTheme.focus : AppTheme.border
            border.width: keyButton.visualFocus ? AppTheme.focusBorderWidth : AppTheme.borderWidth
            radius: AppTheme.cornerRadiusSmall
        }

        onClicked: root.textRequested(insertionText)

        ToolTip.visible: keyButton.hovered && keyButton.toolTipText !== ""
        ToolTip.delay: 500
        ToolTip.text: keyButton.toolTipText
    }

    Rectangle {
        id: keyboardSurface
        anchors.fill: parent
        implicitHeight: keyboardLayout.implicitHeight + AppTheme.spacingMedium * 2
        color: AppTheme.surface
        border.color: AppTheme.border
        border.width: AppTheme.borderWidth
        radius: AppTheme.cornerRadiusLarge

        ColumnLayout {
            id: keyboardLayout
            anchors.fill: parent
            anchors.margins: AppTheme.spacingMedium
            spacing: AppTheme.spacingSmall

            RowLayout {
                Layout.fillWidth: true
                spacing: AppTheme.spacingSmall
                LayoutMirroring.enabled: root.rightToLeft
                LayoutMirroring.childrenInherit: true

                Label {
                    Layout.fillWidth: true
                    text: root.controller.uiText("keyboard.title")
                    font.family: AppTheme.fontFamily
                    font.pixelSize: AppTheme.fontControl
                    font.weight: Font.DemiBold
                    color: AppTheme.foreground
                    elide: Text.ElideRight
                }

                AppButton {
                    objectName: "keyboardPrimaryLayer"
                    focusPolicy: Qt.TabFocus
                    text: root.controller.uiText("keyboard.primary")
                    selected: root.activeLayer === "primary"
                    onClicked: root.activeLayer = "primary"
                }

                AppButton {
                    objectName: "keyboardSymbolsAdvancedLayer"
                    focusPolicy: Qt.TabFocus
                    text: root.controller.uiText("keyboard.symbols")
                    selected: root.activeLayer === "symbols"
                    onClicked: root.activeLayer = "symbols"
                }
            }

            Repeater {
                model: root.activeRows

                delegate: RowLayout {
                    id: keyRow

                    required property var modelData

                    Layout.fillWidth: true
                    Layout.preferredHeight: 34
                    spacing: AppTheme.spacingTiny
                    layoutDirection: Qt.RightToLeft
                    LayoutMirroring.enabled: false
                    LayoutMirroring.childrenInherit: false

                    Repeater {
                        model: keyRow.modelData

                        delegate: KeyboardKey {
                            required property int index

                            Layout.fillWidth: true
                            Layout.preferredWidth: 0
                            Layout.fillHeight: true
                            keyData: root.keyAt(keyRow.modelData, index)
                        }
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true
                Layout.preferredHeight: 34
                spacing: AppTheme.spacingTiny
                layoutDirection: Qt.RightToLeft
                LayoutMirroring.enabled: false
                LayoutMirroring.childrenInherit: false

                AppButton {
                    objectName: "keyboardBackspaceButton"
                    focusPolicy: Qt.TabFocus
                    Layout.preferredWidth: 0
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    text: root.controller.uiText("keyboard.backspace")
                    onClicked: root.backspaceRequested()
                }

                AppButton {
                    objectName: "keyboardSpaceButton"
                    focusPolicy: Qt.TabFocus
                    Layout.preferredWidth: 0
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    text: root.controller.uiText("keyboard.space")
                    onClicked: root.textRequested(" ")
                }

                AppButton {
                    objectName: "keyboardEnterButton"
                    focusPolicy: Qt.TabFocus
                    Layout.preferredWidth: 0
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    text: root.controller.uiText("keyboard.enter")
                    onClicked: root.newlineRequested()
                }
            }
        }
    }
}
