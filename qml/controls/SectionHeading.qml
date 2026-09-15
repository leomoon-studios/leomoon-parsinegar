import QtQuick

Text {
    id: control

    property string label: ""

    text: label
    textFormat: Text.PlainText
    color: AppTheme.foreground
    font.family: AppTheme.fontFamily
    font.pixelSize: AppTheme.fontBody
    font.weight: Font.DemiBold
    wrapMode: Text.WordWrap

    // Parent pages mirror their layout for Persian, including text alignment.
    // AlignLeft therefore renders physically right in Persian and left in English.
    horizontalAlignment: Text.AlignLeft
}
