import QtQuick 2.0
import QtQuick.Controls 2.0
import QtQuick.Window 2.2
Rectangle {
    id:root
//    width: 800
//    height: 480-tBar.height
//    color: "green"
    color: "#00000000"
    property int adaptive_width: Screen.desktopAvailableWidth
    property int adaptive_height: Screen.desktopAvailableHeight
    SwipeView{
        id:menuSwpView
        width: adaptive_width
        height: adaptive_height/1.2

//        Loader{
//            id:page1
//            anchors.fill: parent
//            source: "qrc:/page1.qml"
//        }

//        Loader{
//            id:page2
//            anchors.fill: parent
//            source: "qrc:/page2.qml"
//        }

        Page{
            width: adaptive_width
            height: adaptive_height/1.2
            background: Rectangle {
                anchors.fill: parent
                      opacity: 0
                      color: "#00000000"
                  }
            Rectangle{
                id: recttop
                width: adaptive_width
                height: adaptive_height/24
                color: "transparent"

//                MenuListItem {
//                                            imageSource:"images/wvga/home/cam.png"
//                                            text1: "_text";
//                                            num: "1"
//                                        }
            }


                ListModel{
                    id: menuListModel1
                    ListElement {
                        _imageSource: "images/wvga/home/player.png"
                        _text1: qsTr("视频播放器")
                        _text2: qsTr("播放器")
                        _num: "1"
                        _qurl: "PlayerWindow.qml"
                    }
                    ListElement {
                        _imageSource: "images/wvga/home/music.png"
                        _text1: qsTr("音乐播放器")
                        _text2: qsTr("音乐")
                        _num: "1"
                        _qurl: "MusicWindow.qml"
                    }
                    ListElement {
                        _imageSource: "images/wvga/home/camera.png"
                        _text1: qsTr("拍照和预览")
                        _text2: qsTr("摄像头")
                        _num: "1"
                        _qurl: "CameraWindow.qml"
                    }
                    ListElement {
                        _imageSource: "images/wvga/home/picture.png"
                        _text1: qsTr("图片浏览")
                        _text2: qsTr("图片")
                        _num: "1"
                        _qurl: "PictureWindow.qml"
                    }
                    ListElement {
                        _imageSource: "images/wvga/home/scope.png"
                        _text1: qsTr("心电仪演示")
                        _text2: qsTr("心电仪")
                        _num: "1"
                        _qurl: "ScopeWindow.qml"
                    }

                }

                Grid{
                    id: menuListGrid1
                    anchors.top: recttop.bottom
                    anchors.topMargin: adaptive_height/24/*20*/
                    columns: 3
                    rows:2
//                    topPadding: 30
                    columnSpacing: adaptive_width/8.33/*96;*/
                    rowSpacing: adaptive_height/19.2 /*25*/
                    anchors.horizontalCenter: parent.horizontalCenter

                    Repeater{
                        model: menuListModel1
                        delegate: MenuListItem {
                            imageSource: _imageSource;
                            text1: _text1;
                            text2: _text2;
                            num: _num;
                            qurl: _qurl;
                        }
                    }
                }
        }

        Page{
            width: adaptive_width
            height: adaptive_height/1.2
            background: Rectangle {
                anchors.fill: parent
                      opacity: 0
                      color: "#00000000"
                  }
            Rectangle{
                id: recttop2
                width: adaptive_width
                height: adaptive_height/24
                color: "transparent"

//                MenuListItem {
//                                            imageSource:"images/wvga/home/cam.png"
//                                            text1: "_text";
//                                            num: "1"
//                                        }
            }


                ListModel{
                    id: menuListModel2
                    ListElement {
                        _imageSource: "images/wvga/home/information.png"
                        _text1: qsTr("系统信息")
                        _text2: qsTr("系统信息")
                        _num: "1"
                        _qurl: "InfoWindow.qml"
                    }
                    ListElement {
                        _imageSource: "images/wvga/home/settings.png"
                        _text1: qsTr("")
                        _text2: qsTr("系统设置")
                        _num: "1"
                        _qurl: "SettingsWindow.qml"
                    }
                    ListElement {
                        _imageSource: "images/wvga/home/filemanager.png"
                        _text1: qsTr("")
                        _text2: qsTr("文件管理")
                        _num: "1"
                        _qurl: "FileWindow.qml"
                    }
                    ListElement {
                        _imageSource: "images/wvga/home/browser.png"
                        _text1: qsTr("浏览器演示")
                        _text2: qsTr("浏览器")
                        _num: "1"
                        _qurl: "BrowserWindow.qml"
                    }
                    ListElement {
                        _imageSource: "images/wvga/home/contact.png"
                        _text1: qsTr("联系我们")
                        _text2: qsTr("联系我们")
                        _num: "1"
                        _qurl: "SupportWindow.qml"
                    }
//                    ListElement {
//                        _imageSource: "images/wvga/home/cam.png"
//                        _text: "2.45"
//                        _num:"1"

//                    }
//                    ListElement {
//                        _imageSource: "images/wvga/home/cam.png"
//                        _text: "2.45"
//                        _num:"1"

//                    }
                }

                Grid{
                    id: menuListGrid2
                    anchors.top: recttop2.bottom
                    anchors.topMargin: adaptive_height/24/*20*/
                    columns: 3
                    rows:2
//                    topPadding: 30
                    columnSpacing: adaptive_width/8.33/*96;*/
                    rowSpacing: adaptive_height/19.2 /*25*/
                    anchors.horizontalCenter: parent.horizontalCenter

                    Repeater{
                        model: menuListModel2
                        delegate: MenuListItem {
                            imageSource: _imageSource;
                            text1: _text1;
                            text2: _text2;
                            num: _num;
                            qurl: _qurl;
                        }
                    }
                }
        }

        Page { // 这是第三页
                    id: menuPage3 // 给第三页一个ID
                    width: adaptive_width
                    height: adaptive_height/1.2
                    background: Rectangle {
                        anchors.fill: parent
                        opacity: 0
                        color: "#00000000"
                    }

                    Rectangle{ // 类似前两页的顶部空白矩形
                        id: recttop3
                        width: adaptive_width
                        height: adaptive_height/24
                        color: "transparent"
                    }

                    ListModel{
                        id: menuListModel3
                        ListElement {
                            _imageSource: "images/wvga/home/settings.png" // 请替换为SCPI工具的合适图标
                            _text1: qsTr("SCPI 测试工具")
                            _text2: qsTr("SCPI 工具")
                            _num: "1" // 或者其他您用作标识的数字
                            _qurl: "ScpiTestWindow.qml" // <--- 指向新的SCPI窗口文件
                        }
                        ListElement {
                            _imageSource: "images/wvga/home/work.png"  // 你workpage的图标路径，换成合适图标
                            _text1: qsTr("作答界面")
                            _text2: qsTr("workpage")
                            _num: "2"
                            _qurl: "workpage.qml"  // 指向你的 workpage.qml 文件
                        }
                        // 如果第三页还需要其他按钮，可以在这里继续添加 ListElement
                    }

                    Grid{
                        id: menuListGrid3
                        anchors.top: recttop3.bottom
                        anchors.topMargin: adaptive_height/24
                        columns: 3 // 与其他页面保持一致，或按需调整
                        rows: 2    // 根据您的按钮数量调整
                        columnSpacing: adaptive_width/8.33
                        rowSpacing: adaptive_height/19.2
                        anchors.horizontalCenter: parent.horizontalCenter

                        Repeater{
                            model: menuListModel3
                            delegate: MenuListItem { // 假设 MenuListItem 是您自定义的组件
                                imageSource: _imageSource
                                text1: _text1
                                text2: _text2
                                num: _num
                                qurl: _qurl
                                // 确保 MenuListItem 的 onClicked 处理器能够使用 qurl 打开新窗口
                                // 例如，它内部可能有类似 mainWnd.chooseWnd(qurl) 的调用
                            }
                        }
                    }
                }



    }
    PageIndicator{
        id: control
        count:menuSwpView.count
        currentIndex: menuSwpView.currentIndex
        anchors{
            bottom: menuSwpView.bottom
            horizontalCenter: parent.horizontalCenter
        }
        delegate: Rectangle {
                  implicitWidth: 8
                  implicitHeight: 8

                  radius: width / 2
                  color: "#eeeeee"

                  opacity: index === control.currentIndex ? 0.95 : pressed ? 0.7 : 0.45

                  Behavior on opacity {
                      NumberAnimation {
                          duration: 200
                      }
                  }
              }
    }


//    HomeButton{
//        anchors.margins: 20
//        width: 128
//        height: 128
//        text: qsTr("系统信息")
//    }


    HomeButton {
        text: qsTr("toMENU")
        label.visible: false
        source:"images/wvga/home/menu.png"
//        width: 30
//        height: 30
        glowRadius: 20
//        z: 2

            anchors {
                horizontalCenter: parent.horizontalCenter
                bottom: parent.bottom
                bottomMargin: height * 0.5
            }

        onClicked: {
               mainWnd.chooseWnd("HOME")
        }
    }

}
