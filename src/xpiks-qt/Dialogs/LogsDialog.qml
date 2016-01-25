/*
 * This file is a part of Xpiks - cross platform application for
 * keywording and uploading images for microstocks
 * Copyright (C) 2014-2016 Taras Kushnir <kushnirTV@gmail.com>
 *
 * Xpiks is distributed under the GNU General Public License, version 3.0
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import QtQuick 2.2
import QtQuick.Controls 1.1
import QtQuick.Layouts 1.1
import QtQuick.Dialogs 1.1
import QtQuick.Controls.Styles 1.1
import "../Constants"
import "../Constants/Colors.js" as Colors;
import "../Common.js" as Common;
import "../Components"
import "../StyledControls"

Item {
    id: logsComponent
    property string logText
    anchors.fill: parent

    signal dialogDestruction();
    Component.onDestruction: dialogDestruction();

    function closePopup() {
        logsComponent.destroy()
    }

    Component.onCompleted: focus = true
    Keys.onEscapePressed: closePopup()

    function scrollToBottom() {
        var flickable = scrollView.flickableItem
        if (flickable.contentHeight > flickable.height) {
            flickable.contentY = flickable.contentHeight - flickable.height
        } else {
            flickable.contentY = 0
        }
    }

    PropertyAnimation { target: logsComponent; property: "opacity";
        duration: 400; from: 0; to: 1;
        easing.type: Easing.InOutQuad ; running: true }

    // This rectange is the a overlay to partially show the parent through it
    // and clicking outside of the 'dialog' popup will do 'nothing'
    Rectangle {
        anchors.fill: parent
        id: overlay
        color: "#000000"
        opacity: 0.6
        // add a mouse area so that clicks outside
        // the dialog window will not do anything
        MouseArea {
            anchors.fill: parent
        }
    }

    MessageDialog {
        id: confirmClearLogsDialog
        property int itemIndex
        title: "Confirmation"
        text: qsTr("Are you sure you want to clear logs?")
        standardButtons: StandardButton.Yes | StandardButton.No
        onYes: {
            clearLogsButton.enabled = false
            logsModel.clearLogs()
            logsComponent.logText = logsModel.getAllLogsText()
            clearLogsButton.enabled = true
        }
    }

    FocusScope {
        anchors.fill: parent

        MouseArea {
            anchors.fill: parent
            onWheel: wheel.accepted = true
            onClicked: mouse.accepted = true
            onDoubleClicked: mouse.accepted = true

            property real old_x : 0
            property real old_y : 0

            onPressed:{
                var tmp = mapToItem(logsComponent, mouse.x, mouse.y);
                old_x = tmp.x;
                old_y = tmp.y;

                var dialogPoint = mapToItem(dialogWindow, mouse.x, mouse.y);
                if (!Common.isInComponent(dialogPoint, dialogWindow)) {
                    closePopup()
                }
            }

            onPositionChanged: {
                var old_xy = Common.movePopupInsideComponent(logsComponent, dialogWindow, mouse, old_x, old_y);
                old_x = old_xy[0]; old_y = old_xy[1];
            }
        }

        // This rectangle is the actual popup
        Rectangle {
            id: dialogWindow
            width: logsComponent.width * 0.75
            height: logsComponent.height - 60
            color: Colors.selectedArtworkColor
            anchors.centerIn: parent
            Component.onCompleted: anchors.centerIn = undefined

            RowLayout {
                id: header
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.topMargin: 20
                anchors.leftMargin: 20
                anchors.rightMargin: 20

                StyledText {
                    text: qsTr("Logs")
                }

                Item {
                    Layout.fillWidth: true
                }

                StyledText {
                    property int linesNumber : 100
                    id: oneHunderdLinesWarning
                    text: qsTr("(showing last %1 lines)").arg(linesNumber)
                    color: Colors.defaultInputBackground
                }
            }

            Rectangle {
                anchors.top: header.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.leftMargin: 20
                anchors.rightMargin: 20
                anchors.topMargin: 10
                anchors.bottom: footer.top
                anchors.bottomMargin: 20
                color: Colors.defaultControlColor

                StyledScrollView {
                    id: scrollView
                    anchors.fill: parent
                    anchors.margins: 10

                    StyledTextEdit {
                        id: textEdit
                        text: logsComponent.logText
                        selectionColor: Colors.selectedArtworkColor
                        readOnly: true
                        font.pixelSize: 12*settingsModel.keywordSizeScale

                        Component.onCompleted: {
                            scrollToBottom()
                        }
                    }
                }
            }

            RowLayout {
                id: footer
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 20
                anchors.left: parent.left
                anchors.leftMargin: 20
                anchors.right: parent.right
                anchors.rightMargin: 20
                height: 24
                spacing: 20

                StyledButton {
                    id: loadMoreButton
                    text: qsTr("Load more logs")
                    enabled: logsModel.withLogs
                    width: 120
                    onClicked: {
                        logsComponent.logText = logsModel.getAllLogsText(true)
                        oneHunderdLinesWarning.linesNumber = 1000
                        loadMoreButton.enabled = false
                        scrollToBottom()
                    }
                }

                StyledButton {
                    id: revealFileButton
                    text: qsTr("Reveal logfile")
                    visible: Qt.platform.os !== "linux"
                    width: 120
                    onClicked: {
                        helpersWrapper.revealLogFile()
                    }
                }


                Item {
                    Layout.fillWidth: true
                }

                StyledButton {
                    id: clearLogsButton
                    enabled: logsModel.withLogs
                    text: qsTr("Clear logs")
                    width: 100
                    onClicked: {
                        confirmClearLogsDialog.open()
                    }
                }

                StyledButton {
                    text: qsTr("Close")
                    width: 100
                    onClicked: {
                        closePopup()
                    }
                }
            }
        }
    }
}