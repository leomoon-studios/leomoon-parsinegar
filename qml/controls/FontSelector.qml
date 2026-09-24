import QtQuick
import QtQuick.Controls

Control {
    id: control

    LayoutMirroring.enabled: false
    LayoutMirroring.childrenInherit: true

    property var fonts: []
    property string selectedKey: ""
    property string placeholderText: ""
    property string emptyText: ""
    property string previewText: ""
    property var filteredFonts: []
    property bool updatingText: false
    readonly property alias searchField: searchField
    signal fontSelected(var fontEntry)

    implicitHeight: 44
    focusPolicy: Qt.StrongFocus

    function fuzzyScore(value, query) {
        var candidate = String(value).toLocaleLowerCase()
        var needle = String(query).trim().toLocaleLowerCase()
        if (needle === "")
            return 0
        if (candidate === needle)
            return -1000
        if (candidate.indexOf(needle) === 0)
            return -500 + candidate.length - needle.length
        var substring = candidate.indexOf(needle)
        if (substring >= 0)
            return -250 + substring * 2 + candidate.length - needle.length

        var position = -1
        var score = 0
        for (var index = 0; index < needle.length; index++) {
            var next = candidate.indexOf(needle[index], position + 1)
            if (next < 0)
                return null
            score += next - position - 1
            position = next
        }
        return score + candidate.length
    }

    function filter(query) {
        var matches = []
        for (var index = 0; index < fonts.length; index++) {
            var entry = fonts[index]
            var score = fuzzyScore(entry.display, query)
            if (score !== null)
                matches.push({ entry: entry, score: score, order: index })
        }
        matches.sort(function(left, right) {
            return left.score === right.score ? left.order - right.order : left.score - right.score
        })
        var result = []
        for (var match = 0; match < matches.length; match++)
            result.push(matches[match].entry)
        filteredFonts = result
        resultList.currentIndex = result.length > 0 ? 0 : -1
        return result
    }

    function selectedEntry() {
        for (var index = 0; index < fonts.length; index++) {
            if (fonts[index].key === selectedKey)
                return fonts[index]
        }
        return null
    }

    function syncText() {
        if (searchField.activeFocus || popup.visible)
            return
        var entry = selectedEntry()
        updatingText = true
        searchField.text = entry ? entry.display : ""
        updatingText = false
    }

    function openList() {
        if (!enabled)
            return
        filter("")
        popup.open()
        searchField.forceActiveFocus()
        searchField.selectAll()
    }

    function choose(index) {
        if (index < 0 || index >= filteredFonts.length)
            return false
        var entry = filteredFonts[index]
        updatingText = true
        searchField.text = entry.display
        updatingText = false
        popup.close()
        fontSelected(entry)
        return true
    }

    onFontsChanged: {
        filter("")
        syncText()
    }
    onSelectedKeyChanged: syncText()

    contentItem: TextField {
        id: searchField
        objectName: control.objectName + "SearchField"
        leftPadding: AppTheme.spacingMedium
        rightPadding: AppTheme.spacingLarge * 2
        placeholderText: control.fonts.length > 0 ? control.placeholderText : control.emptyText
        font.family: AppTheme.fontFamily
        font.styleName: ""
        font.pixelSize: AppTheme.fontControl
        color: AppTheme.foreground
        selectionColor: AppTheme.accent
        selectedTextColor: AppTheme.accentText
        enabled: control.enabled
        background: Item {}

        onPressed: {
            if (!popup.visible)
                control.openList()
        }
        onTextEdited: {
            if (control.updatingText)
                return
            control.filter(text)
            if (!popup.visible)
                popup.open()
        }
        onAccepted: control.choose(resultList.currentIndex)

        Keys.onDownPressed: function(event) {
            if (!popup.visible)
                control.openList()
            else if (resultList.count > 0)
                resultList.currentIndex = Math.min(resultList.count - 1, resultList.currentIndex + 1)
            event.accepted = true
        }
        Keys.onUpPressed: function(event) {
            if (!popup.visible)
                control.openList()
            else if (resultList.count > 0)
                resultList.currentIndex = Math.max(0, resultList.currentIndex - 1)
            event.accepted = true
        }
        Keys.onEscapePressed: function(event) {
            popup.close()
            control.syncText()
            event.accepted = true
        }
        Keys.onReturnPressed: function(event) {
            control.choose(resultList.currentIndex)
            event.accepted = true
        }
        Keys.onEnterPressed: function(event) {
            control.choose(resultList.currentIndex)
            event.accepted = true
        }
    }

    background: Rectangle {
        color: AppTheme.surface
        border.color: control.visualFocus || searchField.activeFocus ? AppTheme.focus : AppTheme.border
        border.width: control.visualFocus || searchField.activeFocus
            ? AppTheme.focusBorderWidth : AppTheme.borderWidth
        radius: AppTheme.cornerRadius

        Text {
            anchors.right: parent.right
            anchors.rightMargin: AppTheme.spacingMedium
            anchors.verticalCenter: parent.verticalCenter
            text: "▼"
            color: AppTheme.muted
            font.family: AppTheme.fontFamily
            font.pixelSize: AppTheme.fontCaption
        }
    }

    Popup {
        id: popup
        parent: control
        x: 0
        y: control.height + AppTheme.spacingTiny
        width: control.width
        height: Math.min(280, resultList.contentHeight + AppTheme.spacingSmall * 2)
        padding: AppTheme.spacingSmall
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

        onClosed: control.syncText()

        background: Rectangle {
            color: AppTheme.surfaceRaised
            border.color: AppTheme.border
            border.width: AppTheme.borderWidth
            radius: AppTheme.cornerRadius
        }

        contentItem: ListView {
            id: resultList
            objectName: control.objectName + "ResultList"
            clip: true
            model: control.filteredFonts
            currentIndex: count > 0 ? 0 : -1
            boundsBehavior: Flickable.StopAtBounds
            ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }

            delegate: ItemDelegate {
                id: fontDelegate
                required property var modelData
                required property int index
                width: resultList.width
                height: 46
                highlighted: ListView.isCurrentItem
                hoverEnabled: true
                onHoveredChanged: {
                    if (hovered)
                        resultList.currentIndex = index
                }
                onClicked: control.choose(index)

                background: Rectangle {
                    color: fontDelegate.highlighted || fontDelegate.hovered
                        ? AppTheme.withAlpha(AppTheme.accent, 0.14) : "transparent"
                    radius: AppTheme.cornerRadius
                }

                contentItem: Row {
                    spacing: AppTheme.spacingMedium

                    Text {
                        width: Math.max(0, fontDelegate.width * 0.3 - AppTheme.spacingMedium)
                        anchors.verticalCenter: parent.verticalCenter
                        text: fontDelegate.modelData.display
                        font.family: AppTheme.fontFamily
                        font.styleName: ""
                        font.pixelSize: AppTheme.fontControl
                        color: AppTheme.foreground
                        elide: Text.ElideRight
                    }

                    Text {
                        id: previewText
                        width: Math.max(0, fontDelegate.width * 0.7
                            - parent.spacing - AppTheme.spacingMedium)
                        anchors.verticalCenter: parent.verticalCenter
                        text: fontDelegate.modelData.previewText === undefined
                            ? control.previewText : fontDelegate.modelData.previewText
                        textFormat: Text.PlainText
                        font.family: fontDelegate.modelData.family
                        font.styleName: fontDelegate.modelData.style
                        font.pixelSize: AppTheme.fontBody
                        color: AppTheme.muted
                        horizontalAlignment: Text.AlignRight
                        elide: Text.ElideRight
                    }
                }
            }

            Label {
                anchors.centerIn: parent
                visible: resultList.count === 0
                text: control.emptyText
                font.family: AppTheme.fontFamily
                color: AppTheme.muted
            }
        }
    }
}
