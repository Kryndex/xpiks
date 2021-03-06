/*
 * This file is a part of Xpiks - cross platform application for
 * keywording and uploading images for microstocks
 * Copyright (C) 2014-2017 Taras Kushnir <kushnirTV@gmail.com>
 *
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/.
 */

import QtQuick 2.2
import QtQuick.Controls 1.1
import QtQuick.Layouts 1.1
import QtQuick.Dialogs 1.1
import QtQuick.Controls.Styles 1.1
import xpiks 1.0
import "../Constants"
import "../Common.js" as Common;
import "../Components"
import "../StyledControls"
import "../Constants/UIConfig.js" as UIConfig

Rectangle {
    id: artworkEditComponent
    color: uiColors.defaultDarkerColor

    property variant componentParent
    property var autoCompleteBox

    property int artworkIndex: -1
    property var keywordsModel
    property bool wasLeftSideCollapsed
    property bool listViewEnabled: true
    property bool canShowChangesSaved: false

    signal dialogDestruction();
    Component.onDestruction: dialogDestruction();

    Keys.onEscapePressed: closePopup()

    function onAutoCompleteClose() {
        autoCompleteBox = undefined
    }

    function reloadItemEditing(itemIndex) {
        if (itemIndex === artworkIndex) { return }
        if ((itemIndex < 0) || (itemIndex >= rosterListView.count)) { return }

        canShowChangesSaved = false
        changesText.visible = false
        closeAutoComplete()

        var originalIndex = filteredArtItemsModel.getOriginalIndex(itemIndex)
        var metadata = filteredArtItemsModel.getArtworkMetadata(itemIndex)
        var keywordsModel = filteredArtItemsModel.getBasicModel(itemIndex)

        artworkProxy.setSourceArtwork(metadata)
        artworkProxy.registerAsCurrentItem()

        artworkEditComponent.artworkIndex = itemIndex
        artworkEditComponent.keywordsModel = keywordsModel

        if (listViewEnabled) {
            rosterListView.currentIndex = itemIndex
            rosterListView.positionViewAtIndex(itemIndex, ListView.Contain)
        }

        titleTextInput.forceActiveFocus()
        titleTextInput.cursorPosition = titleTextInput.text.length

        artworkProxy.initTitleHighlighting(titleTextInput.textDocument)
        artworkProxy.initDescriptionHighlighting(descriptionTextInput.textDocument)

        savedTimer.start()
    }

    function closePopup() {
        closeAutoComplete()
        artworkProxy.resetModel()
        uiManager.clearCurrentItem()
        mainStackView.pop({immediate: true})
        restoreLeftPane()
    }

    function restoreLeftPane() {
        if (mainStackView.depth === 1) {
            if (!wasLeftSideCollapsed) {
                expandLeftPane()
            }
        }
    }

    function closeAutoComplete() {
        if (typeof artworkEditComponent.autoCompleteBox !== "undefined") {
            artworkEditComponent.autoCompleteBox.closePopup()
        }
    }

    Timer {
        id: savedTimer
        interval: 1000
        running: true
        repeat: false
        onTriggered: {
            canShowChangesSaved = true
        }
    }

    function updateChangesText() {
        if (canShowChangesSaved) {
            changesText.visible = true
        }
    }

    Menu {
        id: wordRightClickMenu
        property string word
        property int keywordIndex
        property bool showAddToDict: true
        property bool showExpandPreset: false

        function popupIfNeeded() {
            if (showAddToDict || showExpandPreset) {
                popup()
            }
        }

        MenuItem {
            visible: wordRightClickMenu.showAddToDict
            text: i18.n + qsTr("Add \"%1\" to dictionary").arg(wordRightClickMenu.word)
            onTriggered: spellCheckService.addWordToUserDictionary(wordRightClickMenu.word);
        }

        Menu {
            id: presetSubMenu
            visible: wordRightClickMenu.showExpandPreset
            title: i18.n + qsTr("Expand as preset")

            Instantiator {
                id : presetsInstantiator
                model: filteredPresetsModel
                onObjectAdded: presetSubMenu.insertItem( index, object )
                onObjectRemoved: presetSubMenu.removeItem( object )
                delegate: MenuItem {
                    text: name
                    onTriggered: {
                        var presetIndex = filteredPresetsModel.getOriginalIndex(index)
                        artworkProxy.expandPreset(wordRightClickMenu.keywordIndex, presetIndex);
                        updateChangesText()
                    }
                }
            }
        }
    }

    Menu {
        id: presetsMenu
        property int artworkIndex

        Menu {
            id: subMenu
            title: i18.n + qsTr("Insert preset")

            Instantiator {
                model: presetsModel
                onObjectAdded:{
                    subMenu.insertItem( index, object )
                }
                onObjectRemoved: subMenu.removeItem( object )
                delegate: MenuItem {
                    text: name
                    onTriggered: {
                        artworkProxy.addPreset(index);
                        updateChangesText()
                    }
                }
            }
        }
    }

    Menu {
        id: itemPreviewMenu
        property int index

        MenuItem {
            text: i18.n + qsTr("Copy to Quick Buffer")
            onTriggered: {
                filteredArtItemsModel.copyToQuickBuffer(itemPreviewMenu.index)
                uiManager.activateQuickBufferTab()
            }
        }
    }

    Component.onCompleted: {
        focus = true

        artworkProxy.registerAsCurrentItem()
        titleTextInput.forceActiveFocus()
        titleTextInput.cursorPosition = titleTextInput.text.length
    }

    Connections {
        target: helpersWrapper
        onGlobalBeforeDestruction: {
            console.debug("UI:EditArtworkHorizontalDialog # globalBeforeDestruction")
            //closePopup()
        }
    }

    Connections {
        target: artworkProxy
        onItemBecomeUnavailable: {
            closePopup()
        }
    }

    MessageDialog {
        id: clearKeywordsDialog

        title: i18.n + qsTr("Confirmation")
        text: i18.n + qsTr("Clear all keywords?")
        standardButtons: StandardButton.Yes | StandardButton.No
        onYes: {
            filteredArtItemsModel.clearKeywords(artworkEditComponent.artworkIndex)
            artworkProxy.updateKeywords()
            updateChangesText()
        }
    }

    // Keys.onEscapePressed: closePopup()

    Connections {
        target: artworkProxy

        onCompletionsAvailable: {
            acSource.initializeCompletions()

            if (typeof artworkEditComponent.autoCompleteBox !== "undefined") {
                // update completion
                return
            }

            var directParent = artworkEditComponent;
            var currWordStartRect = flv.editControl.getCurrentWordStartRect()

            var tmp = flv.editControl.mapToItem(directParent,
                                                currWordStartRect.x - 17,
                                                flv.editControl.height + 1)

            var visibleItemsCount = Math.min(acSource.getCount(), 5);
            var popupHeight = visibleItemsCount * (25 + 1) + 10

            var isBelow = (tmp.y + popupHeight) < directParent.height;

            var options = {
                model: acSource.getCompletionsModel(),
                autoCompleteSource: acSource,
                editableTags: flv,
                isBelowEdit: isBelow,
                "anchors.left": directParent.left,
                "anchors.leftMargin": Math.min(tmp.x, directParent.width - 200)
            }

            if (isBelow) {
                options["anchors.top"] = directParent.top
                options["anchors.topMargin"] = tmp.y
            } else {
                options["anchors.bottom"] = directParent.bottom
                options["anchors.bottomMargin"] = directParent.height - tmp.y + flv.editControl.height
            }

            var component = Qt.createComponent("../Components/CompletionBox.qml");
            if (component.status !== Component.Ready) {
                console.warn("Component Error: " + component.errorString());
            } else {
                var instance = component.createObject(directParent, options);

                instance.boxDestruction.connect(artworkEditComponent.onAutoCompleteClose)
                instance.itemSelected.connect(flv.acceptCompletion)
                artworkEditComponent.autoCompleteBox = instance

                instance.openPopup()
            }
        }
    }

    Rectangle {
        id: leftSpacer
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: 2
        color: applicationWindow.leftSideCollapsed ? bottomPane.color : artworkEditComponent.color
    }

    SplitView {
        orientation: Qt.Horizontal
        anchors.left: leftSpacer.right
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: bottomPane.top

        handleDelegate: Rectangle {
            width: 0
            color: uiColors.selectedArtworkBackground
        }

        onResizingChanged: {
            uiManager.artworkEditRightPaneWidth = rightPane.width
        }

        Item {
            id: boundsRect
            Layout.fillWidth: true
            anchors.top: parent.top
            anchors.bottom: parent.bottom

            Rectangle {
                id: topHeader
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                height: 45
                color: uiColors.defaultDarkColor

                RowLayout {
                    anchors.leftMargin: 10
                    anchors.rightMargin: 20
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    height: childrenRect.height
                    spacing: 0

                    BackGlyphButton {
                        text: i18.n + qsTr("Back")
                        onClicked: {
                            flv.onBeforeClose()
                            closePopup()
                        }
                    }

                    Item {
                        width: 10
                    }

                    StyledText {
                        id: changesText
                        text: i18.n + qsTr("All changes are saved.")
                        isActive: false
                        visible: false
                    }

                    Item {
                        Layout.fillWidth: true
                    }

                    StyledText {
                        text: artworkProxy.basename
                        isActive: false
                    }
                }
            }

            Item {
                id: imageWrapper
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: topHeader.bottom
                anchors.bottom: parent.bottom
                property int imageMargin: 10

                LoaderIcon {
                    width: 100
                    height: 100
                    anchors.centerIn: parent
                    running: previewImage.status == Image.Loading
                }

                StyledScrollView {
                    id: scrollview
                    anchors.fill: parent
                    anchors.leftMargin: imageWrapper.imageMargin
                    anchors.topMargin: imageWrapper.imageMargin

                    Image {
                        id: previewImage
                        source: "image://global/" + artworkProxy.thumbPath
                        cache: false
                        property bool isFullSize: false
                        width: isFullSize ? sourceSize.width : (imageWrapper.width - 2*imageWrapper.imageMargin)
                        height: isFullSize ? sourceSize.height : (imageWrapper.height - 2*imageWrapper.imageMargin)
                        fillMode: Image.PreserveAspectFit
                        anchors.centerIn: parent
                        asynchronous: true
                    }
                }

                Image {
                    id: videoTypeIcon
                    visible: (artworkProxy.isVideo) && (previewImage.status == Image.Ready)
                    enabled: artworkProxy.isVideo
                    source: "qrc:/Graphics/video-icon.svg"
                    fillMode: Image.PreserveAspectCrop
                    sourceSize.width: 225
                    sourceSize.height: 225
                    anchors.centerIn: imageWrapper
                    cache: true
                }

                Rectangle {
                    anchors.bottom: parent.bottom
                    anchors.right: parent.right
                    width: 50
                    height: 50
                    color: uiColors.defaultDarkColor

                    ZoomAmplifier {
                        id: zoomIcon
                        anchors.fill: parent
                        anchors.margins: 10
                        scale: zoomMA.pressed ? 0.9 : 1
                    }

                    MouseArea {
                        id: zoomMA
                        anchors.fill: parent
                        onClicked: {
                            previewImage.isFullSize = !previewImage.isFullSize
                            zoomIcon.isPlus = !zoomIcon.isPlus
                        }
                    }
                }
            }
        }

        Item {
            id: rightPane
            Layout.maximumWidth: 550
            Layout.minimumWidth: 250
            //width: 300
            anchors.top: parent.top
            anchors.bottom: parent.bottom

            Component.onCompleted: {
                rightPane.width = uiManager.artworkEditRightPaneWidth
            }

            Row {
                id: tabsHeader
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                height: 45
                spacing: 0

                Repeater {
                    model: [i18.n + qsTr("Edit"), i18.n + qsTr("Info")]
                    delegate: CustomTab {
                        width: rightPane.width/2
                        property int delegateIndex: index
                        tabIndex: delegateIndex
                        isSelected: tabIndex === editTabView.currentIndex
                        color: isSelected ? uiColors.selectedArtworkBackground : uiColors.inputInactiveBackground
                        hovered: tabMA.containsMouse

                        StyledText {
                            color: parent.isSelected ? uiColors.artworkActiveColor : (parent.hovered ? uiColors.labelActiveForeground : uiColors.labelInactiveForeground)
                            text: modelData
                            anchors.centerIn: parent
                        }

                        MouseArea {
                            id: tabMA
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: editTabView.setCurrentIndex(parent.tabIndex)
                        }
                    }
                }
            }

            Item {
                id: editTabView
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: tabsHeader.bottom
                anchors.bottom: parent.bottom
                property int currentIndex: 0

                function setCurrentIndex(index) {
                    if (index === 0) {
                        infoTab.visible = false
                        editTab.visible = true
                    } else if (index === 1) {
                        infoTab.visible = true
                        editTab.visible = false
                    }

                    editTabView.currentIndex = index
                }

                Rectangle {
                    id: editTab
                    color: uiColors.selectedArtworkBackground
                    anchors.fill: parent
                    enabled: artworkProxy.isValid

                    ColumnLayout {
                        id: fields
                        anchors.fill: parent
                        anchors.leftMargin: 10
                        anchors.rightMargin: 20
                        anchors.topMargin: 5
                        anchors.bottomMargin: 10
                        spacing: 0

                        Item {
                            height: childrenRect.height
                            anchors.left: parent.left
                            anchors.right: parent.right

                            StyledText {
                                anchors.left: parent.left
                                text: i18.n + qsTr("Title:")
                            }

                            StyledText {
                                anchors.right: parent.right
                                text: titleTextInput.length
                            }
                        }

                        Item {
                            height: 5
                        }

                        Rectangle {
                            id: anotherRect
                            anchors.left: parent.left
                            anchors.right: parent.right
                            height: 25
                            color: uiColors.inputBackgroundColor
                            border.color: uiColors.artworkActiveColor
                            border.width: titleTextInput.activeFocus ? 1 : 0
                            clip: true

                            Flickable {
                                id: titleFlick
                                contentWidth: titleTextInput.paintedWidth
                                contentHeight: titleTextInput.paintedHeight
                                anchors.fill: parent
                                anchors.margins: 5
                                clip: true
                                flickableDirection: Flickable.HorizontalFlick
                                interactive: false
                                focus: false

                                function ensureVisible(r) {
                                    if (contentX >= r.x)
                                        contentX = r.x;
                                    else if (contentX+width <= r.x+r.width)
                                        contentX = r.x+r.width-width;
                                }

                                StyledTextEdit {
                                    id: titleTextInput
                                    focus: true
                                    width: paintedWidth > titleFlick.width ? paintedWidth : titleFlick.width
                                    height: titleFlick.height
                                    text: artworkProxy.title
                                    userDictEnabled: true
                                    property string previousText: text
                                    onTextChanged: {
                                        if (text.length > UIConfig.inputsMaxLength) {
                                            var cursor = cursorPosition;
                                            text = previousText;
                                            if (cursor > text.length) {
                                                cursorPosition = text.length;
                                            } else {
                                                cursorPosition = cursor-1;
                                            }
                                            console.info("Pasting cancelled: text length exceeded maximum")
                                        }

                                        previousText = text
                                        artworkProxy.title = text
                                        updateChangesText()
                                    }

                                    onActionRightClicked: {
                                        var showAddToDict = artworkProxy.hasTitleWordSpellError(rightClickedWord)
                                        wordRightClickMenu.showAddToDict = showAddToDict
                                        wordRightClickMenu.word = rightClickedWord
                                        wordRightClickMenu.showExpandPreset = false
                                        wordRightClickMenu.popupIfNeeded()
                                    }

                                    Keys.onBacktabPressed: {
                                        event.accepted = true
                                    }

                                    Keys.onTabPressed: {
                                        descriptionTextInput.forceActiveFocus()
                                        descriptionTextInput.cursorPosition = descriptionTextInput.text.length
                                    }

                                    Component.onCompleted: {
                                        artworkProxy.initTitleHighlighting(titleTextInput.textDocument)
                                    }

                                    onCursorRectangleChanged: titleFlick.ensureVisible(cursorRectangle)

                                    Keys.onPressed: {
                                        if(event.matches(StandardKey.Paste)) {
                                            var clipboardText = clipboard.getText();
                                            if (Common.safeInsert(titleTextInput, clipboardText)) {
                                                event.accepted = true
                                            }
                                        } else if ((event.key === Qt.Key_Return) || (event.key === Qt.Key_Enter)) {
                                            event.accepted = true
                                        }
                                    }
                                }
                            }
                        }

                        Item {
                            height: 20
                        }

                        Item {
                            height: childrenRect.height
                            anchors.left: parent.left
                            anchors.right: parent.right

                            StyledText {
                                anchors.left: parent.left
                                text: i18.n + qsTr("Description:")
                            }

                            StyledText {
                                anchors.right: parent.right
                                text: descriptionTextInput.length
                            }
                        }

                        Item {
                            height: 5
                        }

                        Rectangle {
                            id: rect
                            anchors.left: parent.left
                            anchors.right: parent.right
                            height: 70
                            color: uiColors.inputBackgroundColor
                            border.color: uiColors.artworkActiveColor
                            border.width: descriptionTextInput.activeFocus ? 1 : 0
                            clip: true

                            Flickable {
                                id: descriptionFlick
                                contentWidth: descriptionTextInput.paintedWidth
                                contentHeight: descriptionTextInput.paintedHeight
                                anchors.fill: parent
                                anchors.margins: 5
                                interactive: false
                                flickableDirection: Flickable.HorizontalFlick
                                clip: true

                                function ensureVisible(r) {
                                    if (contentX >= r.x)
                                        contentX = r.x;
                                    else if (contentX+width <= r.x+r.width)
                                        contentX = r.x+r.width-width;
                                    if (contentY >= r.y)
                                        contentY = r.y;
                                    else if (contentY+height <= r.y+r.height)
                                        contentY = r.y+r.height-height;
                                }

                                StyledTextEdit {
                                    id: descriptionTextInput
                                    width: descriptionFlick.width
                                    height: paintedHeight > descriptionFlick.height ? paintedHeight : descriptionFlick.height
                                    text: artworkProxy.description
                                    focus: true
                                    userDictEnabled: true
                                    property string previousText: text
                                    property int maximumLength: 280
                                    onTextChanged: {
                                        if (text.length > UIConfig.inputsMaxLength) {
                                            var cursor = cursorPosition;
                                            text = previousText;
                                            if (cursor > text.length) {
                                                cursorPosition = text.length;
                                            } else {
                                                cursorPosition = cursor-1;
                                            }
                                            console.info("Pasting cancelled: text length exceeded maximum")
                                        }

                                        previousText = text
                                        artworkProxy.description = text
                                        updateChangesText()
                                    }

                                    onActionRightClicked: {
                                        var showAddToDict = artworkProxy.hasDescriptionWordSpellError(rightClickedWord)
                                        wordRightClickMenu.showAddToDict = showAddToDict
                                        wordRightClickMenu.word = rightClickedWord
                                        wordRightClickMenu.showExpandPreset = false
                                        wordRightClickMenu.popupIfNeeded()
                                    }

                                    wrapMode: TextEdit.Wrap
                                    horizontalAlignment: TextEdit.AlignLeft
                                    verticalAlignment: TextEdit.AlignTop
                                    textFormat: TextEdit.PlainText

                                    Component.onCompleted: {
                                        artworkProxy.initDescriptionHighlighting(descriptionTextInput.textDocument)
                                    }

                                    Keys.onBacktabPressed: {
                                        titleTextInput.forceActiveFocus()
                                        titleTextInput.cursorPosition = titleTextInput.text.length
                                    }

                                    Keys.onTabPressed: {
                                        flv.activateEdit()
                                    }

                                    onCursorRectangleChanged: descriptionFlick.ensureVisible(cursorRectangle)

                                    Keys.onPressed: {
                                        if(event.matches(StandardKey.Paste)) {
                                            var clipboardText = clipboard.getText();
                                            if (Common.safeInsert(descriptionTextInput, clipboardText)) {
                                                event.accepted = true
                                            }
                                        } else if ((event.key === Qt.Key_Return) || (event.key === Qt.Key_Enter)) {
                                            event.accepted = true
                                        }
                                    }
                                }
                            }
                        }

                        Item {
                            height: 20
                        }

                        Item {
                            height: childrenRect.height
                            anchors.left: parent.left
                            anchors.right: parent.right

                            StyledText {
                                anchors.left: parent.left
                                id: keywordsLabel
                                text: i18.n + qsTr("Keywords:")
                            }

                            StyledText {
                                anchors.right: parent.right
                                text: artworkProxy.keywordsCount
                            }
                        }

                        Item {
                            height: 4
                        }

                        Rectangle {
                            id: keywordsWrapper
                            border.color: uiColors.artworkActiveColor
                            border.width: flv.isFocused ? 1 : 0
                            Layout.fillHeight: true
                            anchors.left: parent.left
                            anchors.right: parent.right
                            color: uiColors.inputBackgroundColor

                            function removeKeyword(index) {
                                artworkProxy.removeKeywordAt(index)
                                updateChangesText()
                            }

                            function removeLastKeyword() {
                                artworkProxy.removeLastKeyword()
                                updateChangesText()
                            }

                            function appendKeyword(keyword) {
                                artworkProxy.appendKeyword(keyword)
                                updateChangesText()
                            }

                            function pasteKeywords(keywords) {
                                artworkProxy.pasteKeywords(keywords)
                                updateChangesText()
                            }

                            function expandLastKeywordAsPreset() {
                                artworkProxy.expandLastKeywordAsPreset();
                                updateChangesText()
                            }

                            EditableTags {
                                id: flv
                                anchors.fill: parent
                                model: artworkEditComponent.keywordsModel
                                property int keywordHeight: uiManager.keywordHeight
                                scrollStep: keywordHeight
                                populateAnimationEnabled: false

                                function acceptCompletion(completionID) {
                                    var accepted = artworkProxy.acceptCompletionAsPreset(completionID);
                                    if (!accepted) {
                                        var completion = acSource.getCompletion(completionID)
                                        flv.editControl.acceptCompletion(completion)
                                    } else {
                                        flv.editControl.acceptCompletion('')
                                    }
                                }

                                delegate: KeywordWrapper {
                                    id: kw
                                    isHighlighted: true
                                    keywordText: keyword
                                    hasSpellCheckError: !iscorrect
                                    hasDuplicate: hasduplicate
                                    delegateIndex: index
                                    itemHeight: flv.keywordHeight
                                    onRemoveClicked: keywordsWrapper.removeKeyword(delegateIndex)
                                    onActionDoubleClicked: {
                                        var callbackObject = {
                                            onSuccess: function(replacement) {
                                                artworkProxy.editKeyword(kw.delegateIndex, replacement)
                                                updateChangesText()
                                            },
                                            onClose: function() {
                                                flv.activateEdit()
                                            }
                                        }

                                        Common.launchDialog("Dialogs/EditKeywordDialog.qml",
                                                            componentParent,
                                                            {
                                                                callbackObject: callbackObject,
                                                                previousKeyword: keyword,
                                                                keywordIndex: kw.delegateIndex,
                                                                keywordsModel: artworkProxy.getBasicModel()
                                                            })
                                    }

                                    onActionRightClicked: {
                                        wordRightClickMenu.showAddToDict = !iscorrect
                                        var keyword = kw.keywordText
                                        wordRightClickMenu.word = keyword
                                        filteredPresetsModel.searchTerm = keyword
                                        wordRightClickMenu.showExpandPreset = (filteredPresetsModel.getItemsCount() !== 0 )
                                        wordRightClickMenu.keywordIndex = kw.delegateIndex
                                        wordRightClickMenu.popupIfNeeded()
                                    }
                                }

                                onTagAdded: {
                                    keywordsWrapper.appendKeyword(text)
                                }

                                onRemoveLast: {
                                    keywordsWrapper.removeLastKeyword()
                                }

                                onTagsPasted: {
                                    keywordsWrapper.pasteKeywords(tagsList)
                                }

                                onBackTabPressed: {
                                    descriptionTextInput.forceActiveFocus()
                                    descriptionTextInput.cursorPosition = descriptionTextInput.text.length
                                }

                                onCompletionRequested: {
                                    artworkProxy.generateCompletions(prefix)
                                }

                                onExpandLastAsPreset: {
                                    keywordsWrapper.expandLastKeywordAsPreset()
                                }

                                onRightClickedInside: {
                                    filteredPresetsModel.searchTerm = ''
                                    presetsMenu.popup()
                                }
                            }

                            CustomScrollbar {
                                anchors.topMargin: -5
                                anchors.bottomMargin: -5
                                anchors.rightMargin: -15
                                flickable: flv
                            }
                        }

                        Item {
                            height: 10
                        }

                        Flow {
                            anchors.left: parent.left
                            anchors.right: parent.right
                            spacing: 5

                            StyledLink {
                                text: i18.n + qsTr("Fix spelling")
                                enabled: artworkEditComponent.keywordsModel ? artworkEditComponent.keywordsModel.hasSpellErrors : false
                                onClicked: {
                                    artworkProxy.suggestCorrections()
                                    Common.launchDialog("Dialogs/SpellCheckSuggestionsDialog.qml",
                                                        componentParent,
                                                        {})
                                    updateChangesText()
                                }
                            }

                            StyledText {
                                text: "|"
                                verticalAlignment: Text.AlignVCenter
                            }

                            StyledLink {
                                id: removeDuplicatesText
                                text: i18.n + qsTr("Remove Duplicates")
                                enabled: artworkEditComponent.keywordsModel ? artworkEditComponent.keywordsModel.hasDuplicates : false
                                onClicked: {
                                    artworkProxy.setupDuplicatesModel()

                                    var wasCollapsed = applicationWindow.leftSideCollapsed
                                    mainStackView.push({
                                                           item: "qrc:/StackViews/DuplicatesReView.qml",
                                                           properties: {
                                                               componentParent: applicationWindow,
                                                               wasLeftSideCollapsed: wasCollapsed
                                                           },
                                                           destroyOnPop: true
                                                       })
                                }
                            }

                            StyledText {
                                text: "|"
                                verticalAlignment: Text.AlignVCenter
                            }

                            StyledLink {
                                text: i18.n + qsTr("Suggest")
                                onClicked: {
                                    var callbackObject = {
                                        promoteKeywords: function(keywords) {
                                            artworkProxy.pasteKeywords(keywords)
                                            updateChangesText()
                                        }
                                    }

                                    artworkProxy.initSuggestion()

                                    Common.launchDialog("Dialogs/KeywordsSuggestion.qml",
                                                        componentParent,
                                                        {callbackObject: callbackObject});
                                }
                            }

                            StyledText {
                                text: "|"
                                verticalAlignment: Text.AlignVCenter
                            }

                            StyledLink {
                                text: i18.n + qsTr("Copy")
                                enabled: artworkProxy.keywordsCount > 0
                                onClicked: clipboard.setText(artworkProxy.getKeywordsString())
                            }

                            StyledText {
                                text: "|"
                                verticalAlignment: Text.AlignVCenter
                            }

                            StyledLink {
                                text: i18.n + qsTr("Clear")
                                enabled: artworkProxy.keywordsCount > 0
                                onClicked: clearKeywordsDialog.open()
                            }
                        }

                        Item {
                            height: 10
                        }

                        StyledLink {
                            id: plainTextText
                            text: i18.n + qsTr("<u>edit in plain text</u>")
                            normalLinkColor: uiColors.labelActiveForeground
                            onClicked: {
                                var callbackObject = {
                                    onSuccess: function(text, spaceIsSeparator) {
                                        artworkProxy.plainTextEdit(text, spaceIsSeparator)
                                    },
                                    onClose: function() {
                                        flv.activateEdit()
                                    }
                                }

                                Common.launchDialog("Dialogs/PlainTextKeywordsDialog.qml",
                                                    applicationWindow,
                                                    {
                                                        callbackObject: callbackObject,
                                                        keywordsText: artworkProxy.getKeywordsString(),
                                                        keywordsModel: artworkProxy.getBasicModel()
                                                    });
                            }
                        }
                    }
                }

                Rectangle {
                    id: infoTab
                    enabled: artworkProxy.isValid
                    visible: false
                    color: uiColors.selectedArtworkBackground
                    anchors.fill: parent

                    ListView {
                        model: artworkProxy.getPropertiesMap()
                        anchors.fill: parent
                        anchors.margins: 20
                        spacing: 10

                        delegate: Item {
                            id: rowWrapper
                            anchors.left: parent.left
                            anchors.right: parent.right
                            height: childrenRect.height

                            Item {
                                id: keyItem
                                anchors.left: parent.left
                                width: 70
                                height: childrenRect.height

                                StyledText {
                                    text: i18.n + key + ":"
                                    isActive: false
                                    anchors.right: parent.right
                                }
                            }

                            Item {
                                id: valueItem
                                anchors.left: keyItem.right
                                anchors.right: parent.right
                                anchors.leftMargin: 10
                                height: childrenRect.height

                                StyledText {
                                    wrapMode: TextEdit.Wrap
                                    text: value
                                    width: parent.width
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    Rectangle {
        id: bottomPane
        anchors.left: leftSpacer.right
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        height: 110
        color: uiColors.panelColor

        Item {
            id: selectPrevButton
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            width: 40
            enabled: rosterListView.currentIndex > 0

            Rectangle {
                anchors.fill: parent
                color: enabled ? (prevButtonMA.containsMouse ? uiColors.defaultControlColor : uiColors.leftSliderColor) : uiColors.panelColor
            }

            TriangleElement {
                width: 7
                height: 14
                anchors.centerIn: parent
                anchors.horizontalCenterOffset: isFlipped ? -1 : +1
                isVertical: true
                isFlipped: true
                color: {
                    if (enabled) {
                        return prevButtonMA.pressed ? uiColors.inputForegroundColor : uiColors.artworkActiveColor
                    } else {
                        return uiColors.inputBackgroundColor
                    }
                }
            }

            MouseArea {
                id: prevButtonMA
                anchors.fill: parent
                hoverEnabled: true
                onClicked: {
                    reloadItemEditing(rosterListView.currentIndex - 1)
                }
            }
        }

        ListView {
            id: rosterListView
            enabled: listViewEnabled
            boundsBehavior: Flickable.StopAtBounds
            orientation: ListView.Horizontal
            anchors.left: selectPrevButton.right
            anchors.right: selectNextButton.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            model: listViewEnabled ? filteredArtItemsModel : undefined
            highlightFollowsCurrentItem: false
            highlightMoveDuration: 0
            flickableDirection: Flickable.HorizontalFlick
            interactive: false
            focus: true
            clip: true
            spacing: 0

            Component.onCompleted: {
                if (listViewEnabled) {
                    rosterListView.currentIndex = artworkEditComponent.artworkIndex
                    rosterListView.positionViewAtIndex(artworkEditComponent.artworkIndex, ListView.Contain)
                    // TODO: fix bug with ListView.Center
                }
            }

            delegate: Rectangle {
                id: cellItem
                property int delegateIndex: index
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                width: bottomPane.height
                color: ListView.isCurrentItem ? uiColors.panelSelectedColor : "transparent"

                Rectangle {
                    anchors.fill: parent
                    visible: imageMA.containsMouse
                    color: uiColors.panelSelectedColor
                    opacity: 0.6
                }

                Image {
                    id: artworkImage
                    anchors.fill: parent
                    anchors.margins: 15
                    source: "image://cached/" + thumbpath
                    sourceSize.width: 150
                    sourceSize.height: 150
                    fillMode: settingsModel.fitSmallPreview ? Image.PreserveAspectFit : Image.PreserveAspectCrop
                    asynchronous: true
                    // caching is implemented on different level
                    cache: false
                }

                Image {
                    id: videoTypeIconSmall
                    visible: isvideo
                    enabled: isvideo
                    source: "qrc:/Graphics/video-icon-s.png"
                    fillMode: Image.PreserveAspectFit
                    sourceSize.width: 150
                    sourceSize.height: 150
                    anchors.fill: artworkImage
                    cache: true
                }

                Image {
                    id: imageTypeIcon
                    visible: hasvectorattached
                    enabled: hasvectorattached
                    source: "qrc:/Graphics/vector-icon.svg"
                    sourceSize.width: 20
                    sourceSize.height: 20
                    anchors.left: artworkImage.left
                    anchors.bottom: artworkImage.bottom
                    cache: true
                }

                MouseArea {
                    id: imageMA
                    anchors.fill: parent
                    hoverEnabled: true
                    acceptedButtons: Qt.LeftButton | Qt.RightButton
                    onClicked: {
                        if (mouse.button == Qt.RightButton) {
                            itemPreviewMenu.index = cellItem.delegateIndex
                            itemPreviewMenu.popup()
                        } else {
                            reloadItemEditing(cellItem.delegateIndex)
                        }
                    }
                }
            }

            // hack until QML will allow scrolling horizontally with mouse wheel
            MouseArea {
                id: horizontalScrollMA
                anchors.fill: parent
                enabled: rosterListView.contentWidth > rosterListView.width
                propagateComposedEvents: true
                preventStealing: true
                property double epsilon: 0.000001

                onWheel: {
                    var shiftX = wheel.angleDelta.y
                    var flickable = rosterListView

                    if (shiftX > epsilon) { // up/right
                        var maxScrollPos = flickable.contentWidth - flickable.width
                        flickable.contentX = Math.min(maxScrollPos, flickable.contentX + shiftX)
                        wheel.accepted = true
                    } else if (shiftX < -epsilon) { // bottom/left
                        flickable.contentX = Math.max(0, flickable.contentX + shiftX)
                        wheel.accepted = true
                    }
                }
            }
        }

        Item {
            id: selectNextButton
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            width: 40
            enabled: rosterListView.currentIndex < (rosterListView.count - 1)

            Rectangle {
                anchors.fill: parent
                color: enabled ? (nextButtonMA.containsMouse ? uiColors.defaultControlColor : uiColors.leftSliderColor) : uiColors.panelColor
            }

            TriangleElement {
                width: 7
                height: 14
                anchors.centerIn: parent
                anchors.horizontalCenterOffset: isFlipped ? -1 : +1
                isVertical: true
                color: {
                    if (enabled) {
                        return nextButtonMA.pressed ? uiColors.inputForegroundColor : uiColors.artworkActiveColor
                    } else {
                        return uiColors.inputBackgroundColor
                    }
                }
            }

            MouseArea {
                id: nextButtonMA
                anchors.fill: parent
                hoverEnabled: true
                onClicked: {
                    reloadItemEditing(rosterListView.currentIndex + 1)
                }
            }
        }
    }

    ClipboardHelper {
        id: clipboard
    }
}
