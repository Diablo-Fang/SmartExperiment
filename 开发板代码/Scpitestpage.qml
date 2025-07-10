import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import ScpiCom 1.0 // 导入你注册的C++模块

Page {
    id: scpiPage
    title: qsTr("SCPI Test Tool")

    ScpiClient {
        id: scpiHandler
        hostAddress: "192.168.1.100" // 默认或通过输入设置
        port: 5025                   // 默认或通过输入设置

        onConnectionStatusChanged: {
            statusLabel.text = connected ? qsTr("Connected") : qsTr("Disconnected");
            statusLabel.color = connected ? "green" : "red";
            connectButton.text = connected ? qsTr("Disconnect") : qsTr("Connect");
        }

        onDataReceived: {
            responseText.append(qsTr("Received: ") + data + "\n");
        }

        onErrorOccurred: {
            responseText.append(qsTr("Error: ") + errorString + "\n");
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 10
        spacing: 10

        RowLayout {
            Layout.fillWidth: true
            Label { text: qsTr("Host IP:") }
            TextField {
                id: hostInput
                Layout.fillWidth: true
                text: scpiHandler.hostAddress
                placeholderText: qsTr("Enter instrument IP address")
                onEditingFinished: scpiHandler.hostAddress = text
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Label { text: qsTr("Port:") }
            TextField {
                id: portInput
                Layout.fillWidth: true
                text: scpiHandler.port.toString()
                placeholderText: qsTr("Enter port (e.g., 5025)")
                validator: IntValidator { bottom: 1; top: 65535 }
                onEditingFinished: scpiHandler.port = parseInt(text)
            }
        }

        Button {
            id: connectButton
            text: scpiHandler.connected ? qsTr("Disconnect") : qsTr("Connect")
            Layout.alignment: Qt.AlignHCenter
            onClicked: {
                if (scpiHandler.connected) {
                    scpiHandler.disconnectFromDevice();
                } else {
                    scpiHandler.connectToDevice();
                }
            }
        }

        Label {
            id: statusLabel
            text: qsTr("Disconnected")
            color: "red"
            Layout.alignment: Qt.AlignHCenter
        }

        TextField {
            id: commandInput
            Layout.fillWidth: true
            placeholderText: qsTr("Enter SCPI command (e.g., *IDN?)")
        }

        Button {
            text: qsTr("Send Command")
            Layout.alignment: Qt.AlignHCenter
            enabled: scpiHandler.connected
            onClicked: {
                if (commandInput.text.trim() !== "") {
                    responseText.append(qsTr("Sent: ") + commandInput.text + "\n");
                    scpiHandler.sendCommand(commandInput.text);
                    commandInput.text = ""; // 清空输入框
                }
            }
        }

        Label {
            text: qsTr("Response:")
        }

        TextArea {
            id: responseText
            Layout.fillWidth: true
            Layout.fillHeight: true
            readOnly: true
            wrapMode: Text.Wrap
            font.family: "Courier New" // 等宽字体更适合显示原始数据
        }
    }
}
