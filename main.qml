import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Controls 2.5
import Qt.labs.platform 1.0
import QtQuick.Layouts 1.3
import Qt.labs.folderlistmodel 2.2
import QtMultimedia 5.9


Window {
    id: mainWindow
    objectName: "hello"
    visible : true
    width   : 640
    height  : 580
    color   : "white"
    title   : qsTr("Loop")


    Audio{
        id:playFile
        volume: 1
        muted: false
        onPlaying: {
            console.log("playing")
            timerPlay.start()
        }
        onError: {
            console.log("error")
        }
        function startLoop(){
            if(btnStart.x < btnFinish.x)
            {
                var startPercent = (btnStart.x - barSeek.leftPadding + btnStart.width/2)/(barSeek.width-barSeek.rightPadding-barSeek.leftPadding)
                playFile.seek(startPercent*playFile.duration)
            }
            else if(btnStart.x > btnFinish.x)
            {
                var anotherStartPercent = (btnFinish.x - barSeek.leftPadding + btnFinish.width/2)/(barSeek.width-barSeek.rightPadding-barSeek.leftPadding)
                playFile.seek(anotherStartPercent*playFile.duration)
            }
        }
        function checkLoop(){
            if(btnStart.x < btnFinish.x)
            {
                var finishPercent= (btnFinish.x - barSeek.leftPadding + btnFinish.width/2)/(barSeek.width-barSeek.rightPadding-barSeek.leftPadding)
                return finishPercent
            }
            else if(btnStart.x > btnFinish.x)
            {
                var anotherFinishPercent = (btnStart.x - barSeek.leftPadding + btnStart.width/2)/(barSeek.width-barSeek.rightPadding-barSeek.leftPadding)
                return anotherFinishPercent
            }
            return 1
        }

    }

    Timer{
        id: timerPlay
        interval: 20
        repeat: true
        onTriggered: {
            if(btnLoop.checked)
            {
                var finishPercent = playFile.checkLoop()
                var currentPercent = playFile.position/playFile.duration
                if( currentPercent >= finishPercent)
                {
                    playFile.startLoop()
                }
            }
            barSeek.value = (playFile.position/playFile.duration)*100
        }
    }

   FolderDialog {
        id: folderDialog
        title: "Choose a folder"
        onAccepted: {
            console.log(currentFolder + folderDialog.folder)
            folderModel.folder = folderDialog.folder

        }
        onRejected: {
            console.log("Cancelled")
            folderDialog.close()
        }
    }

    ColumnLayout{
        id:columnWindow
        anchors.fill: parent
        spacing:0

        RowLayout{
            id: rowMenu
            spacing: 2
            Button{
                id: btnBack
                text: "Back"
                background: Rectangle {
                    implicitWidth: 100
                    implicitHeight: 30
                    color:btnBack.down ? "#ffffff":"#ffcccc"
                }
                onClicked:{
                    folderModel.folder = folderModel.parentFolder
                }

            }
            Button{
                id: btnOpenFolder
                text: "Open"
                background: Rectangle {
                    implicitWidth: 100
                    implicitHeight: 30
                    color:btnOpenFolder.down ? "#ffffff":"#ffcccc"
                }
                onPressed: folderDialog.open()

            }
        }
        Rectangle{
            color:"white"
            width: mainWindow.width
            height:mainWindow.height-rectSeek.height-btnBack.height-rectControls.height

            ListView{
                id:lstFolders
                width: parent.width
                height: parent.height
                anchors.fill: parent
                focus: true
                spacing: 1
                clip: true
                model: folderModel
                delegate: fileDelegate

                FolderListModel{
                    id: folderModel
                    folder: folderDialog.folder
                    nameFilters: ["*.mp3","*.wav"]
                    showDirsFirst: true
                }

                Component{
                    id: fileDelegate

                    Rectangle {
                        width: parent.width
                        height: 35
                        color: ListView.isCurrentItem ? "#ff6666" : "white"

                        Row {
                            width: parent.width
                            height: parent.height
                            anchors.fill: parent
                            spacing: -1

                            Rectangle{
                                width:50
                                height: parent.height
                                color:"transparent"
                                Image {
                                    id: icon
                                    width: 25
                                    height:25
                                    source: "image://iconProvider/"+filePath
                                    anchors.verticalCenter: parent.verticalCenter
                                    anchors.horizontalCenter: parent.horizontalCenter
                                }
                            }

                            Text {
                                text: fileName
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: lstFolders.currentIndex = index
                            onDoubleClicked: {
                                if(folderModel.get(index,"fileIsDir"))
                                    folderModel.folder = folderModel.get(index,"fileURL")
                                else{
                                    playFile.source = folderModel.get(index,"fileURL")
                                   // console.log(playFile.source)
                                    playFile.play()
                                }
                              }
                            }
                        }
                    }
                }

            }




        Rectangle {
            id: rectSeek
            width: mainWindow.width
            height: 30
            color: "white"




            Slider {
                            id: barSeek
                            from:0
                            to:100
                            value: 100
                            leftPadding:20
                            rightPadding:20
                            height:parent.height
                            clip:true

                            background: Rectangle {
                                x: barSeek.leftPadding
                                y: barSeek.topPadding + barSeek.availableHeight / 2+(height/2)-implicitHeight
                                implicitWidth: mainWindow.width
                                implicitHeight: 5
                                width: barSeek.availableWidth
                                height: implicitHeight
                                radius: 0
                                color: "#ffcccc"

                                Rectangle {

                                    width: barSeek.visualPosition * (parent.width+circle.width/2)
                                    height: 5
                                    color: "#ff6666"//"#21be2b"
                                }
                            }

                            handle: Rectangle {
                                id: circle
                                x: barSeek.leftPadding-width/2 + (barSeek.visualPosition *barSeek.availableWidth)
                                y: barSeek.topPadding + barSeek.availableHeight / 2 - height / 2
                                implicitWidth: 7
                                implicitHeight: 18
                                radius: 13
                                color: barSeek.pressed ? "#f0f0f0" : "#f6f6f6"
                                border.color: "#bdbebf"
                            }

                            MouseArea{
                                anchors.fill : parent
                                id: mouseArea
                                drag {
                                    threshold: 0
                                    target: circle
                                    axis: Drag.XAxis
                                    minimumX: barSeek.leftPadding-circle.width/2
                                    maximumX: barSeek.width -barSeek.rightPadding-circle.width/2
                                }
                                onPositionChanged:  {
                                    if (drag.active){
                                        updatePosition()
                                        playFile.seek((playFile.duration*barSeek.value)/barSeek.to)
                                    }
                                }
                                function updatePosition() {
                                    barSeek.value =( barSeek.to *(circle.x-drag.minimumX) )/(drag.maximumX-drag.minimumX)
                                }
                            }
            }

            RoundButton {
                id: btnStart
                x: barSeek.leftPadding-(width/2)
                y: 0
                width: 5
                height: parent.height
                text: ""
                MouseArea{
                    anchors.fill : parent
                    drag.target: btnStart
                    drag.axis: Drag.XAxis
                    drag.minimumX: barSeek.leftPadding-(width/2)
                    drag.maximumX: barSeek.width -barSeek.rightPadding-(width/2)
                    drag.threshold: 0
                }
            }
            RoundButton {
                id:btnFinish
                x: 40
                y: 0
                width: 5
                height: parent.height
                text: ""
                MouseArea{
                    anchors.fill : parent
                    drag.target: btnFinish
                    drag.axis: Drag.XAxis
                    drag.minimumX: barSeek.leftPadding-(width/2)
                    drag.maximumX: barSeek.width -barSeek.rightPadding-(width/2)
                    drag.threshold: 0
                }
            }
        }


        Rectangle{
            id: rectControls
            width:mainWindow.width
            height:100
            color:"white"

            Button {
                id: btnPlay
                background: Rectangle{
                    implicitHeight: 40
                    implicitWidth: 40
                    color:  btnPlay.checked ?"gray":"#d6d6d6"
                    radius: 20
                }
                text:"|>"
                checkable: true
                anchors.horizontalCenter: parent.horizontalCenter
                onClicked: {
                    if(checked)
                        playFile.pause()
                    else{
                        playFile.play()
                        if(btnLoop.checked == true){
                            var startPercent = (btnStart.x - barSeek.leftPadding + btnStart.width/2)/(barSeek.width-barSeek.rightPadding-barSeek.leftPadding)
                            playFile.seek(startPercent*playFile.duration)
                        }
                    }
                }
            }
            Button {
                id: btnLoop
                background: Rectangle{
                    implicitHeight: 30
                    implicitWidth: 30
                    color:  btnLoop.checked ?"gray":"#d6d6d6"
                    radius: 20
                }
                text:"L"
                checkable: true
                anchors.leftMargin: 10
                anchors.left: btnPlay.right
            }
        }



        }









}

