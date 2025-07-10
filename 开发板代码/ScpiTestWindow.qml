// ScpiTestWindow.qml
import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import ScpiCom 1.0 // 导入您的 C++ 模块
import WavePlotting 1.0 // URI used in qmlRegisterType for WaveformPlotter
import QtQuick.Window 2.2 // For Screen

SystemWindow { // 已从 Rectangle 更改为 SystemWindow
    id: scpiTestWindow
    width: adaptive_width
    height: adaptive_height
    visible: true // SystemWindow 需要明确设置可见或通过 show() 调用
    title: qsTr("SCPI Test Tool") // 设置窗口标题

    property bool expectingWaveformData: false // Flag to know when to process data for plotting

    // 使用 contentItem 设置背景
    contentItem: Rectangle {
        anchors.fill: parent
        color: "#2c3e50" // 设置背景色

        // 所有原窗口内容现在都应置于此 contentItem Rectangle 内部
        // 顶部栏 (模仿 WashWindow 的 tBar)
        Rectangle {
            id: tBar
            width: parent.width
            height: scpiTestWindow.adaptive_height / 15 // 注意这里的 parent 现在是 contentItem
            color: "#34495e" // 标题栏颜色示例

            Text {
                id: titleText
                text: scpiTestWindow.title // 可以直接引用 SystemWindow 的 title
                anchors.centerIn: parent
                color: "white"
                font.pixelSize: Math.min(scpiTestWindow.adaptive_width / 40, scpiTestWindow.adaptive_height / 25)
                font.bold: true
                font.family: "Microsoft YaHei"
            }

            Rectangle {
                id: backButtonRect
                width: Math.max(tBar.height * 2.5, scpiTestWindow.adaptive_width / 8)
                height: tBar.height * 0.7
                anchors.left: parent.left
                anchors.leftMargin: 20
                anchors.verticalCenter: parent.verticalCenter
                color: "#c0392b"
                radius: 5
                visible: true

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 10
                    anchors.rightMargin: 10
                    spacing: 5

                    Text {
                        text: "‹"
                        color: "white"
                        font.pixelSize: backButtonRect.height * 0.5
                        Layout.alignment: Qt.AlignVCenter
                    }

                    Text {
                        text: qsTr("返回")
                        color: "white"
                        font.pixelSize: backButtonRect.height * 0.4
                        font.family: "Microsoft YaHei"
                        Layout.alignment: Qt.AlignVCenter
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        console.log("ScpiTestWindow: Closing SystemWindow.");
                        scpiTestWindow.close();
                    }
                }
            }
        }

        // 主要内容区域 - 现在使用 GridLayout
        GridLayout {
            id: mainContentGrid
            anchors.top: tBar.bottom
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: 20
            columns: 2
            rows: 2
            columnSpacing: 15
            rowSpacing: 15

            // 左上角单元格
            ColumnLayout {
                id: topLeftCell
                Layout.fillWidth: true // This will fill the allocated column width
                Layout.preferredWidth: mainContentGrid.width / 2 - mainContentGrid.columnSpacing / 2
                Layout.fillHeight: true // 根据内容调整，或允许其扩展
                spacing: 10

                RowLayout { // IP 输入行
                    Layout.fillWidth: true
                    Label { 
                        text: qsTr("Host IP:"); 
                        color: "white"; 
                        font.pixelSize: scpiTestWindow.adaptive_height / 35; 
                        font.family: "Microsoft YaHei";
                        Layout.preferredWidth: scpiTestWindow.adaptive_width / 10 // Adjust this as needed
                        horizontalAlignment: Text.AlignHCenter
                    }
                    TextField {
                        id: hostInput
                        Layout.fillWidth: true
                        text: scpiHandler.hostAddress
                        placeholderText: qsTr("Enter instrument IP address")
                        color: "white"
                        font.pixelSize: scpiTestWindow.adaptive_height / 38
                        font.family: "Microsoft YaHei"
                        background: Rectangle { color: "#34495e"; border.color: "#7f8c8d"; radius: 3; border.width: 1 }
                        onEditingFinished: scpiHandler.hostAddress = text
                    }
                }

                RowLayout { // Port 输入行
                    Layout.fillWidth: true
                    Label { 
                        text: qsTr("Port:"); 
                        color: "white"; 
                        font.pixelSize: scpiTestWindow.adaptive_height / 35; 
                        font.family: "Microsoft YaHei";
                        Layout.preferredWidth: scpiTestWindow.adaptive_width / 10; // Same as Host IP Label
                        horizontalAlignment: Text.AlignHCenter // Center the text within the preferredWidth
                    }
                    TextField {
                        id: portInput
                        Layout.fillWidth: true
                        text: scpiHandler.port.toString()
                        placeholderText: qsTr("Enter port (e.g., 5025)")
                        validator: IntValidator { bottom: 1; top: 65535 }
                        color: "white"
                        font.pixelSize: scpiTestWindow.adaptive_height / 38
                        font.family: "Microsoft YaHei"
                        background: Rectangle { color: "#34495e"; border.color: "#7f8c8d"; radius: 3; border.width: 1 }
                        onEditingFinished: scpiHandler.port = parseInt(text)
                    }
                }

                // Connect 按钮单独一行并居中
                Button {
                    id: connectButton
                    text: scpiHandler.connected ? qsTr("Disconnect") : qsTr("Connect")
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignHCenter // 在 ColumnLayout 中居中
                    Layout.preferredWidth: scpiTestWindow.adaptive_width / 4.5 // 或根据需要调整
                    Layout.preferredHeight: scpiTestWindow.adaptive_height / 18
                    font.pixelSize: scpiTestWindow.adaptive_height / 35
                    font.family: "Microsoft YaHei"
                    background: Rectangle {
                        color: parent.pressed ? (scpiHandler.connected ? "#c0392b" : "#16a085") : (scpiHandler.connected ? "#e74c3c" : "#1abc9c")
                        radius: 5
                        border.color: parent.pressed ? (scpiHandler.connected ? "#a52a1a" : "#117e64") : (scpiHandler.connected ? "#c0392b" : "#16a085")
                        border.width: 1
                    }
                    contentItem: Text {
                        text: connectButton.text
                        color: "white"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        font: connectButton.font
                    }
                    onClicked: {
                        if (scpiHandler.connected) {
                            scpiHandler.disconnectFromDevice();
                        } else {
                            scpiHandler.connectToDevice();
                        }
                    }
                }

                // 状态标签在下一行并居中
                Label {
                    id: statusLabel
                    text: qsTr("Disconnected")
                    color: "red"
                    Layout.alignment: Qt.AlignHCenter // 在 ColumnLayout 中居中
                    // Layout.fillWidth: true // 不再需要 fillWidth
                    // horizontalAlignment: Text.AlignRight // 不再需要，因为父级 Layout.alignment 控制位置
                    font.pixelSize: scpiTestWindow.adaptive_height / 38
                    font.bold: true
                    font.family: "Microsoft YaHei"
                }
            }

            // 右上角单元格
            ColumnLayout {
                id: topRightCell
                Layout.fillWidth: true // This will fill the allocated column width
                Layout.preferredWidth: mainContentGrid.width / 2 - mainContentGrid.columnSpacing / 2
                Layout.fillHeight: true // 根据内容调整
                spacing: 10

                TextField {
                    id: commandInput
                    Layout.fillWidth: true
                    placeholderText: qsTr("Enter SCPI command (e.g., *IDN?)")
                    color: "white"
                    font.pixelSize: scpiTestWindow.adaptive_height / 38
                    font.family: "Microsoft YaHei"
                    background: Rectangle { color: "#34495e"; border.color: "#7f8c8d"; radius: 3; border.width: 1 }
                    Layout.preferredHeight: scpiTestWindow.adaptive_height / 16
                }

                Button {
                    id: sendButton
                    text: qsTr("Send Command")
                    Layout.fillWidth: true // SendButton 占满一行
                    enabled: scpiHandler.connected
                    // Layout.preferredWidth: scpiTestWindow.adaptive_width / 4.5 // 不再需要，使用 fillWidth
                    Layout.preferredHeight: scpiTestWindow.adaptive_height / 18
                    font.pixelSize: scpiTestWindow.adaptive_height / 35
                    font.family: "Microsoft YaHei"
                    background: Rectangle {
                        color: parent.enabled ? (parent.pressed ? "#2980b9" : "#3498db") : "#7f8c8d"
                        radius: 5
                        border.color: parent.enabled ? (parent.pressed ? "#1f618d" : "#2980b9") : "#566573"
                        border.width: 1
                    }
                    contentItem: Text {
                        text: sendButton.text
                        color: "white"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        font: sendButton.font
                    }
                    onClicked: {
                        if (commandInput.text.trim() !== "") {
                            responseText.append(qsTr("Sent: ") + commandInput.text + "\n");
                            scpiHandler.sendCommand(commandInput.text);
                            commandInput.text = "";
                        }
                    }
                }

                // Run 和 Stop 按钮共用一行
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10 // 按钮之间的间距

                    Button {
                        id: runButton
                        text: qsTr("Run")
                        Layout.fillWidth: true // 平分宽度
                        enabled: scpiHandler.connected
                        // Layout.preferredWidth: scpiTestWindow.adaptive_width / 4.5 // 由 fillWidth 控制
                        Layout.preferredHeight: scpiTestWindow.adaptive_height / 18
                        font.pixelSize: scpiTestWindow.adaptive_height / 35
                        font.family: "Microsoft YaHei"
                        background: Rectangle {
                            color: parent.enabled ? (parent.pressed ? "#2980b9" : "#3498db") : "#7f8c8d"
                            radius: 5
                            border.color: parent.enabled ? (parent.pressed ? "#1f618d" : "#2980b9") : "#566573"
                            border.width: 1
                        }
                        contentItem: Text {
                            text: runButton.text
                            color: "white"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            font: runButton.font
                        }
                        onClicked: {
                            responseText.append(qsTr("Sent: :RUN") + "\n");
                            scpiHandler.sendCommand(":RUN");
                        }
                    }

                    Button {
                        id: stopButton
                        text: qsTr("Stop")
                        Layout.fillWidth: true // 平分宽度
                        enabled: scpiHandler.connected
                        // Layout.preferredWidth: scpiTestWindow.adaptive_width / 4.5 // 由 fillWidth 控制
                        Layout.preferredHeight: scpiTestWindow.adaptive_height / 18
                        font.pixelSize: scpiTestWindow.adaptive_height / 35
                        font.family: "Microsoft YaHei"
                        background: Rectangle {
                            color: parent.enabled ? (parent.pressed ? "#c0392b" : "#e74c3c") : "#7f8c8d"
                            radius: 5
                            border.color: parent.enabled ? (parent.pressed ? "#a52a1a" : "#c0392b") : "#566573"
                            border.width: 1
                        }
                        contentItem: Text {
                            text: stopButton.text
                            color: "white"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            font: stopButton.font
                        }
                        onClicked: {
                            responseText.append(qsTr("Sent: :STOP") + "\n");
                            scpiHandler.sendCommand(":STOP");
                        }
                    }
                }

                // 新增"读取CH1波形"按钮
                Button {
                    id: readCh1WaveformButton
                    text: qsTr("读取CH1波形")
                    Layout.fillWidth: true // 占满一行
                    enabled: scpiHandler.connected
                    Layout.preferredHeight: scpiTestWindow.adaptive_height / 18
                    font.pixelSize: scpiTestWindow.adaptive_height / 35
                    font.family: "Microsoft YaHei"

                    property int currentCommandIndex: 0
                    property var commandList: [
                        ":STOP",
                        ":WAV:SOUR CHAN1",
                        ":WAV:MODE NORM",
                        ":WAV:FORM ASCii",
                        ":WAV:POIN NORM",
                        ":WAV:DATA?" // :RUN 命令已从此序列中移除
                    ]

                    function sendNextCommandInSequence() {
                        if (currentCommandIndex < commandList.length) {
                            var cmd = commandList[currentCommandIndex];

                            // 移除旧的在发送 :RUN 前 finalize 的逻辑

                            responseText.append(qsTr("Sent: ") + cmd + "\n");
                            scpiHandler.sendCommand(cmd);

                            if (cmd === ":WAV:DATA?") {
                                scpiTestWindow.expectingWaveformData = true;
                                dataFinalizationTimer.stop(); // 确保在开始接收前是停止的
                                console.log("Expecting waveform data after :WAV:DATA?. Data finalization timer will be armed by received data or sequence end.");
                            }

                            currentCommandIndex++;
                            if (currentCommandIndex < commandList.length) {
                                commandSequenceTimer.start();
                            } else { // 所有命令已发送完毕
                                console.log("Command sequence finished sending.");
                                // 如果最后一个发送的命令是 :WAV:DATA?，启动最终化计时器
                                // 如果没有数据收到，它将触发一次进行处理（可能处理空数据）
                                if (commandList[currentCommandIndex-1] === ":WAV:DATA?") {
                                     dataFinalizationTimer.start();
                                     console.log("Last command was :WAV:DATA?, dataFinalizationTimer started.");
                                }
                            }
                        }
                    }

                    background: Rectangle { // 蓝色样式，同 Send/Run 按钮
                        color: parent.enabled ? (parent.pressed ? "#2980b9" : "#3498db") : "#7f8c8d"
                        radius: 5
                        border.color: parent.enabled ? (parent.pressed ? "#1f618d" : "#2980b9") : "#566573"
                        border.width: 1
                    }
                    contentItem: Text {
                        text: readCh1WaveformButton.text
                        color: "white"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        font: readCh1WaveformButton.font
                    }
                    onClicked: {
                        waveformPlotter.clearPlotData(); // 清除旧数据和图像
                        scpiTestWindow.expectingWaveformData = false;
                        currentCommandIndex = 0;
                        // waveformPlotter.processAndPlotData(""); // 旧的调用，已被 clearPlotData 替代
                        sendNextCommandInSequence();
                    }
                }
            }

            // 左下角单元格
            ColumnLayout {
                id: bottomLeftCell
                Layout.fillWidth: true // This will fill the allocated column width
                Layout.preferredWidth: mainContentGrid.width / 2 - mainContentGrid.columnSpacing / 2
                Layout.fillHeight: true
                spacing: 5 // 调整间距

                // Response 标签和清空按钮在同一行
                RowLayout {
                    Layout.fillWidth: true
                    // Layout.alignment: Qt.AlignVCenter // Vertically center items if they have different heights
                    spacing: 10 // Spacing between label, spacer, and button

                    Text {
                        text: qsTr("Response:")
                        color: "white"
                        font.pixelSize: scpiTestWindow.adaptive_height / 38
                        font.family: "Microsoft YaHei"
                        // No Layout.alignment needed here, it's positioned by RowLayout order
                    }

                    // Flexible spacer to push the button to the right
                    Item { Layout.fillWidth: true }

                    Button {
                        id: clearResponseButton
                        text: qsTr("清空响应")
                        // Layout.alignment: Qt.AlignHCenter // No longer needed, positioned by spacer
                        Layout.preferredWidth: topRightCell.width / 2.5 // Adjusted for potentially less space, or fixed value
                        Layout.preferredHeight: scpiTestWindow.adaptive_height / 20
                        font.pixelSize: scpiTestWindow.adaptive_height / 38
                        font.family: "Microsoft YaHei"

                        background: Rectangle { // 中性灰色样式
                            color: parent.pressed ? "#566573" : "#7f8c8d"
                            radius: 5
                            border.color: parent.pressed ? "#34495e" : "#566573"
                            border.width: 1
                        }
                        contentItem: Text {
                            text: clearResponseButton.text
                            color: "white"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            font: clearResponseButton.font
                        }
                        onClicked: {
                            responseText.text = ""; // 清空 TextArea 内容
                        }
                    }
                }

                ScrollView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    TextArea {
                        id: responseText
                        Layout.fillWidth: true // TextArea 填充 ScrollView 的宽度
                        // Layout.fillHeight: true is implicit as ScrollView manages it
                        readOnly: true
                        wrapMode: Text.Wrap
                        font.family: "Microsoft YaHei"
                        font.pixelSize: scpiTestWindow.adaptive_height / 40
                        color: "#ecf0f1"
                        background: Rectangle {
                            color: "#34495e"
                            border.color: "#7f8c8d"
                            radius: 3
                            border.width: 1
                        }
                    }
                }
            }

            // 右下角单元格 (用于显示波形图)
            Rectangle { // 作为 Image 的容器，匹配其他单元格的 preferredWidth/Height
                id: bottomRightCellPlot
                Layout.fillWidth: true
                Layout.preferredWidth: mainContentGrid.width / 2 - mainContentGrid.columnSpacing / 2
                Layout.fillHeight: true
                color: "transparent" // 与父背景色一致，或者设为透明

                Image {
                    id: waveformImage
                    anchors.fill: parent
                    anchors.margins: 5 // 可选边距
                    // 使用时间戳来防止缓存问题
                    source: waveformPlotter.plotImageUrl.toString() ? waveformPlotter.plotImageUrl.toString() + "?timestamp=" + new Date().getTime() : ""
                    fillMode: Image.PreserveAspectFit // 保持图片比例
                    smooth: true // 平滑缩放

                    onSourceChanged: {
                        // Optional: Log when source changes for debugging
                        // console.log("Waveform Image source changed to: " + source);
                    }
                    Component.onCompleted: {
                        // Optional: Log when component completes for debugging
                        // console.log("Waveform Image QML component completed. Initial source: " + source);
                    }
                }
            }

            // 用于命令序列的定时器 (放在 GridLayout 的子元素层级，确保ID可被按钮访问)
            Timer {
                id: commandSequenceTimer
                interval: 10 // 10ms 延迟
                repeat: false // 单次触发，由 sendNextCommandInSequence 按需重启
                onTriggered: {
                    readCh1WaveformButton.sendNextCommandInSequence();
                }
            }
        } // End of mainContentGrid
    } // End of contentItem Rectangle

    // SCPI 客户端逻辑 -- 移到 SystemWindow 的直接子元素中
    ScpiClient {
        id: scpiHandler
        hostAddress: "192.168.10.3" // 初始默认 IP
        port: 5555                   // 初始默认端口

        onConnectionStatusChanged: {
            statusLabel.text = connected ? qsTr("Connected") : qsTr("Disconnected");
            statusLabel.color = connected ? "green" : "red";
            connectButton.text = connected ? qsTr("Disconnect") : qsTr("Connect");
        }

        onDataReceived: {
            responseText.append(qsTr("Received: ") + data + "\n");
            if (scpiTestWindow.expectingWaveformData) {
                waveformPlotter.accumulateData(data); // 累积数据块
                dataFinalizationTimer.restart(); // 每次收到数据块时，重设计时器
                // console.log("Accumulated waveform data chunk. Restarted finalization timer.");
            }
        }

        onErrorOccurred: {
            responseText.append(qsTr("Error: ") + errorString + "\n");
        }
    }

    WaveformPlotter {
        id: waveformPlotter
        // onPlotImageUrlChanged is implicitly handled by the binding in waveformImage.source
    }

    // 新增：用于检测波形数据接收结束的定时器
    Timer {
        id: dataFinalizationTimer
        interval: 500 // 等待更多数据块的超时时间 (毫秒)，可根据实际情况调整
        repeat: false // 单次触发
        onTriggered: {
            if (scpiTestWindow.expectingWaveformData) { // 再次检查标志，确保仍然期望数据
                console.log("Data finalization timer triggered. Finalizing plot.");
                waveformPlotter.finalizePlotting();
                scpiTestWindow.expectingWaveformData = false; // 处理完毕，重置标志

                // 根据用户要求，在绘图数据处理完成后发送 :RUN 命令
                responseText.append(qsTr("Sent: :RUN (post-plot)") + "\n");
                scpiHandler.sendCommand(":RUN");
                console.log("Sent :RUN command after plotting and data finalization.");
            }
        }
    }

    property int adaptive_width: Screen.desktopAvailableWidth
    property int adaptive_height: Screen.desktopAvailableHeight
}
