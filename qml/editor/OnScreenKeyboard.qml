pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: root

    required property var controller
    property var modifierService: null
    property string visualDirection: "rtl"
    property bool shiftLatched: false
    readonly property bool rightToLeft: controller.uiLanguage === "fa" || controller.uiLanguage === "ar"
    readonly property bool physicalShift: modifierService !== null && modifierService.shiftPressed
    readonly property bool shiftActive: physicalShift || shiftLatched
    readonly property var numberRow: [
        "=", "-", "۰", "۹", "۸", "۷", "۶", "۵", "۴", "۳", "۲", "۱",
        { id: "ZWJ", label: "ZWJ", text: "‍", tooltipKey: "keyboard.zwjTooltip" }
    ]
    readonly property var primaryRows: [
        ["\\", "چ", "ج", "ح", "خ", "ه", "ع", "غ", "ف", "ق", "ث", "ص", "ض", "ژ"],
        ["گ", "ک", "م", "ن", "ت", "ا", "ل", "ب", "ی", "س", "ش"],
        ["/", ".", "و", "پ", "د", "ذ", "ر", "ز", "ط", "ظ", "﴿", "﴾"],
        ["ئ", "ؤ", "ي", "ك", "ة", "آ", "إ", "أ", "ء"]
    ]
    readonly property var shiftedRows: [
        ["+", "ـ", "(", ")", "*", "،", "×", "٪", "﷼", "٫", "٬", "!", "÷"],
        ["|", "{", "}", "[", "]",
            { label: "◌ّ", text: "ّ", diacritic: true },
            { label: "◌َ", text: "َ", diacritic: true },
            { label: "◌ِ", text: "ِ", diacritic: true },
            { label: "◌ُ", text: "ُ", diacritic: true },
            { label: "◌ً", text: "ً", diacritic: true },
            { label: "◌ٍ", text: "ٍ", diacritic: true },
            { label: "◌ٌ", text: "ٌ", diacritic: true },
            { label: "◌ْ", text: "ْ", diacritic: true }, "؛"],
        ["؛", ":", "«", "»", "ة", "آ", "أ", "إ", "ي", "ئ", "ؤ"],
        ["؟", "<", ">", "ء",
            { label: "◌ٔ", text: "ٔ", diacritic: true },
            "",
            { label: "◌ٰ", text: "ٰ", diacritic: true },
            "ژ", "…", "·",
            { label: "RLM", text: "‏", tooltipKey: "keyboard.rlmTooltip" },
            { label: "LRM", text: "‎", tooltipKey: "keyboard.lrmTooltip" }],
        [
            { label: "RLE", text: "‫", tooltipKey: "keyboard.rleTooltip" },
            { label: "LRE", text: "‪", tooltipKey: "keyboard.lreTooltip" },
            "﴿", "﴾", "\\", "/", "-", "=", "ك"
        ]
    ]
    readonly property var activeRows: [numberRow].concat(primaryRows)
    readonly property var pairedSymbols: ({
        "«": "»", "»": "«",
        "(": ")", ")": "(",
        "[": "]", "]": "[",
        "{": "}", "}": "{",
        "<": ">", ">": "<"
    })

    onPhysicalShiftChanged: {
        if (physicalShift)
            shiftLatched = false
    }

    function keyText(key) {
        return typeof key === "string" ? key : key.text
    }

    function keyLabel(key) {
        return typeof key === "string" ? key : key.label
    }

    function keyAt(row, rowIndex, position) {
        var base = row[position]
        var shifted = shiftedRows[rowIndex][position]
        if (visualDirection === "ltr" && typeof shifted === "string") {
            var partner = pairedSymbols[shifted]
            var shiftedRow = shiftedRows[rowIndex]
            if (partner !== undefined
                    && ((position > 0 && shiftedRow[position - 1] === partner)
                        || (position + 1 < shiftedRow.length && shiftedRow[position + 1] === partner)))
                shifted = partner
        }
        var current = shiftActive ? shifted : base
        var alternate = shiftActive ? base : shifted
        return {
            id: typeof base === "string" ? base : base.id,
            text: keyText(current),
            label: keyLabel(current),
            alternateLabel: shifted === "" ? "" : keyLabel(alternate),
            diacritic: typeof current === "object" && current.diacritic === true,
            tooltipKey: typeof current === "object" ? current.tooltipKey : ""
        }
    }

    function displayLabel(value) {
        var mirroredLabels = {
            "(": ")",
            ")": "(",
            "[": "]",
            "]": "[",
            "{": "}",
            "}": "{",
            "<": ">",
            ">": "<",
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
        readonly property string insertionText: keyData.text
        readonly property string keyLabel: root.displayLabel(keyData.label)
        readonly property string alternateLabel: root.displayLabel(keyData.alternateLabel)
        readonly property string keyId: keyData.id
        readonly property bool diacritic: keyData.diacritic === true
        readonly property string toolTipText: keyData.tooltipKey
            ? root.controller.uiText(keyData.tooltipKey) : ""

        implicitWidth: 40
        implicitHeight: 34
        objectName: "keyboardKey_" + keyId
        padding: AppTheme.spacingTiny
        hoverEnabled: true
        focusPolicy: Qt.TabFocus
        enabled: insertionText !== ""
        text: keyLabel
        Accessible.name: keyLabel

        contentItem: Item {
            Text {
                anchors.centerIn: parent
                text: keyButton.insertionText === "﴿" || keyButton.insertionText === "﴾"
                    ? "\u200E" + keyButton.text + "\u200E" : keyButton.text
                font.family: AppTheme.fontFamily
                font.pixelSize: keyButton.diacritic ? AppTheme.fontBody + 10
                    : keyButton.keyLabel.length > 3 ? AppTheme.fontCaption : AppTheme.fontBody
                font.weight: keyButton.diacritic ? Font.DemiBold : Font.Medium
                color: AppTheme.foreground
            }

            Text {
                anchors.top: parent.top
                anchors.right: parent.right
                text: keyButton.alternateLabel
                font.family: AppTheme.fontFamily
                font.pixelSize: AppTheme.fontCaption - 2
                color: AppTheme.muted
            }
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

            Repeater {
                model: root.activeRows

                delegate: RowLayout {
                    id: keyRow

                    required property int index
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
                            keyData: root.keyAt(keyRow.modelData, keyRow.index, index)
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
                    id: shiftButton
                    objectName: "keyboardShiftButton"
                    focusPolicy: Qt.TabFocus
                    Layout.preferredWidth: 0
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    text: root.controller.uiText("keyboard.shift")
                    selected: root.shiftActive
                    onClicked: {
                        if (!root.physicalShift)
                            root.shiftLatched = !root.shiftLatched
                    }
                }

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
                    text: root.controller.uiText(root.shiftActive ? "keyboard.zwnj" : "keyboard.space")
                    onClicked: root.textRequested(root.shiftActive ? "‌" : " ")
                    ToolTip.visible: hovered && root.shiftActive
                    ToolTip.delay: 500
                    ToolTip.text: root.controller.uiText("keyboard.zwnjTooltip")
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
