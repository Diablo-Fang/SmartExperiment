import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import QtQuick.Window 2.2 // For Screen
import ScpiCom 1.0 // 导入SCPI通信模块
import WavePlotting 1.0 // 导入波形绘制模块
import HttpUpload 1.0 // 导入HTTP上传模块

SystemWindow {
    id: workPageWindow
    width: adaptive_width
    height: adaptive_height
    visible: true
    title: qsTr("实验报告")

    property bool expectingWaveformData: false // 用于标记是否正在等待波形数据
    property string currentWaveformTarget: "" // 标识当前波形数据的目标：ch1、vi1vo1、vi1vo2、vo1vo2
    property var pendingUploads: [] // 待上传的文件列表
    property int currentUploadIndex: 0 // 当前上传的文件索引
    property bool isGettingDualChannelData: false // 用于标记是否正在获取双通道数据
    property string currentDualChannelStep: "" // 当前双通道获取步骤：ch1、ch2

    // 侧拉栏相关属性
    property bool sidebarVisible: true // 侧拉栏是否可见
    property int sidebarWidth: 450 // 侧拉栏宽度

    // 进度跟踪属性
    property bool part1Completed: false
    property bool part2Completed: false 
    property bool part3Completed: false
    property bool part5Completed: false
    property bool part6Completed: false

    // 连接状态检测
    property int heartbeatFailureCount: 0
    property int maxHeartbeatFailures: 3 // 连续失败3次后认为断开
    property bool isHeartbeatActive: false

    // 信号发生器连接状态检测
    property int sigGenHeartbeatFailureCount: 0
    property int sigGenMaxHeartbeatFailures: 3 // 连续失败3次后认为断开
    property bool isSigGenHeartbeatActive: false

    // 鉴权相关属性
    property bool isAuthenticated: false
    property bool isAuthenticating: true
    property string studentName: ""
    property string studentNumber: ""
    property string experimentId: "" // 存储从鉴权响应中获取的实验id

    // 在组件完成后先进行鉴权，鉴权成功后再连接示波器
    Component.onCompleted: {
        console.log("WorkPage: Starting authentication process...");
        // 显示学号输入弹窗
        showStudentCodeDialog();
        
        // 连接所有TextField的文本变化事件
        connectTextFieldEvents();
    }

    // 组件销毁时清理资源
    Component.onDestruction: {
        console.log("WorkPage: Component being destroyed, cleaning up resources...");
        cleanupResources();
    }

    // 资源清理函数
    function cleanupResources() {
        console.log("WorkPage: Starting resource cleanup...");
        
        // 停止所有定时器
        heartbeatTimer.stop();
        heartbeatTimeoutTimer.stop();
        sigGenHeartbeatTimer.stop();
        sigGenHeartbeatTimeoutTimer.stop();
        reconnectTimer.stop();
        sigGenReconnectTimer.stop();
        dataFinalizationTimer.stop();
        uploadDelayTimer.stop();
        vi1vo1CommandTimer.stop();
        vi1vo2CommandTimer.stop();
        vo1vo2CommandTimer.stop();
        console.log("WorkPage: All timers stopped");
        
        // 断开SCPI连接
        if (scpiHandler.connected) {
            scpiHandler.disconnectFromDevice();
            console.log("WorkPage: SCPI connection disconnected");
        }
        
        // 断开信号发生器连接
        if (sigGenHandler.connected) {
            sigGenHandler.disconnectFromDevice();
            console.log("WorkPage: Signal generator connection disconnected");
        }
        
        // 清理波形绘制器资源
        waveformPlotter.clearPlotData();
        vi1vo1Plotter.clearPlotData();
        vi1vo2Plotter.clearPlotData();
        vo1vo2Plotter.clearPlotData();
        console.log("WorkPage: Waveform plotter data cleared");
        
        // 重置所有状态变量
        workPageWindow.expectingWaveformData = false;
        workPageWindow.currentWaveformTarget = "";
        workPageWindow.pendingUploads = [];
        workPageWindow.currentUploadIndex = 0;
        workPageWindow.isGettingDualChannelData = false;
        workPageWindow.currentDualChannelStep = "";
        workPageWindow.heartbeatFailureCount = 0;
        workPageWindow.isHeartbeatActive = false;
        
        // 重置信号发生器状态
        workPageWindow.sigGenHeartbeatFailureCount = 0;
        workPageWindow.isSigGenHeartbeatActive = false;
        
        // 重置进度状态
        workPageWindow.part1Completed = false;
        workPageWindow.part2Completed = false;
        workPageWindow.part3Completed = false;
        workPageWindow.part5Completed = false;
        workPageWindow.part6Completed = false;
        
        console.log("WorkPage: All state variables reset");
        console.log("WorkPage: Resource cleanup completed");
    }

    // 连接TextField事件的函数
    function connectTextFieldEvents() {
        // 表1字段
        table1vc1Field.textChanged.connect(checkAllPartsCompletion);
        table1vb1Field.textChanged.connect(checkAllPartsCompletion);
        table1ve1Field.textChanged.connect(checkAllPartsCompletion);
        table1vc2Field.textChanged.connect(checkAllPartsCompletion);
        table1vb2Field.textChanged.connect(checkAllPartsCompletion);
        table1ve2Field.textChanged.connect(checkAllPartsCompletion);
        
        // 表2字段
        table2vs1Field.textChanged.connect(checkAllPartsCompletion);
        table2vol1Field.textChanged.connect(checkAllPartsCompletion);
        table2avl1Field.textChanged.connect(checkAllPartsCompletion);
        table2vo1Field.textChanged.connect(checkAllPartsCompletion);
        table2av1Field.textChanged.connect(checkAllPartsCompletion);
        table2ri1Field.textChanged.connect(checkAllPartsCompletion);
        table2ro1Field.textChanged.connect(checkAllPartsCompletion);
        table2vo3Field.textChanged.connect(checkAllPartsCompletion);
        table2av3Field.textChanged.connect(checkAllPartsCompletion);
        table2w1Field.textChanged.connect(checkAllPartsCompletion);
        table2vs2Field.textChanged.connect(checkAllPartsCompletion);
        table2vol2Field.textChanged.connect(checkAllPartsCompletion);
        table2avl2Field.textChanged.connect(checkAllPartsCompletion);
        table2vo2Field.textChanged.connect(checkAllPartsCompletion);
        table2av2Field.textChanged.connect(checkAllPartsCompletion);
        table2ri2Field.textChanged.connect(checkAllPartsCompletion);
        table2ro2Field.textChanged.connect(checkAllPartsCompletion);
        table2vo4Field.textChanged.connect(checkAllPartsCompletion);
        table2av4Field.textChanged.connect(checkAllPartsCompletion);
        table2w2Field.textChanged.connect(checkAllPartsCompletion);
        
        // 表3字段
        table3vc11Field.textChanged.connect(checkAllPartsCompletion);
        table3vc21Field.textChanged.connect(checkAllPartsCompletion);
        table3vb11Field.textChanged.connect(checkAllPartsCompletion);
        table3vb21Field.textChanged.connect(checkAllPartsCompletion);
        table3ve11Field.textChanged.connect(checkAllPartsCompletion);
        table3ve21Field.textChanged.connect(checkAllPartsCompletion);
        table3vc12Field.textChanged.connect(checkAllPartsCompletion);
        table3vc22Field.textChanged.connect(checkAllPartsCompletion);
        table3vb12Field.textChanged.connect(checkAllPartsCompletion);
        table3vb22Field.textChanged.connect(checkAllPartsCompletion);
        table3ve12Field.textChanged.connect(checkAllPartsCompletion);
        table3ve22Field.textChanged.connect(checkAllPartsCompletion);
        
        // 表4字段
        table4vo11Field.textChanged.connect(checkAllPartsCompletion);
        table4vo21Field.textChanged.connect(checkAllPartsCompletion);
        table4vo1Field.textChanged.connect(checkAllPartsCompletion);
        table4a1Field.textChanged.connect(checkAllPartsCompletion);
        table4k1Field.textChanged.connect(checkAllPartsCompletion);
        table4vo12Field.textChanged.connect(checkAllPartsCompletion);
        table4vo22Field.textChanged.connect(checkAllPartsCompletion);
        table4vo2Field.textChanged.connect(checkAllPartsCompletion);
        table4a2Field.textChanged.connect(checkAllPartsCompletion);
        table4vo13Field.textChanged.connect(checkAllPartsCompletion);
        table4vo23Field.textChanged.connect(checkAllPartsCompletion);
        table4vo3Field.textChanged.connect(checkAllPartsCompletion);
        table4a3Field.textChanged.connect(checkAllPartsCompletion);
        table4k2Field.textChanged.connect(checkAllPartsCompletion);
        table4vo14Field.textChanged.connect(checkAllPartsCompletion);
        table4vo24Field.textChanged.connect(checkAllPartsCompletion);
        table4vo4Field.textChanged.connect(checkAllPartsCompletion);
        table4a4Field.textChanged.connect(checkAllPartsCompletion);
        
        // 表5字段
        table5vi1Field.textChanged.connect(checkAllPartsCompletion);
        table5vo1Field.textChanged.connect(checkAllPartsCompletion);
        table5vi2Field.textChanged.connect(checkAllPartsCompletion);
        table5vo2Field.textChanged.connect(checkAllPartsCompletion);
        
        console.log("WorkPage: Connected all TextField events for progress tracking");
    }

    // +++ JAVASCRIPT FUNCTIONS FOR CLEARING DATA +++
    function clearTextFieldsInItem(item) {
        if (!item || item === meterRangeCombo) {
            return;
        }

        // Check if the current item is a TextField and clear it
        if (item.hasOwnProperty("text") && item.hasOwnProperty("placeholderText")) {
            var typeString = item.toString();
            // Be a bit more specific, also good for TextArea if used
            if (typeString.includes("TextField") || typeString.includes("TextArea")) {
                 item.text = "";
            }
        }

        // Recursively process children
        if (item.children) {
            for (var i = 0; i < item.children.length; i++) {
                clearTextFieldsInItem(item.children[i]);
            }
        }

        // Also process contentItem if it exists (e.g., for GroupBox, Control)
        if (item.contentItem) {
            clearTextFieldsInItem(item.contentItem);
        }
    }

    // +++ NEW FUNCTION FOR COLLECTING TEXT FIELDS DATA +++
    function collectTextFieldsData(item, dataList) {
        if (!item || item === meterRangeCombo) {
            return;
        }

        // Check if the current item is a TextField and collect its data
        if (item.hasOwnProperty("text") && item.hasOwnProperty("placeholderText")) {
            var typeString = item.toString();
            if (typeString.includes("TextField") || typeString.includes("TextArea")) {
                var fieldData = {
                    "id": item.objectName || "unnamed_field_" + dataList.length,
                    "text": item.text || "",
                    "placeholder": item.placeholderText || ""
                };
                dataList.push(fieldData);
            }
        }

        // Recursively process children
        if (item.children) {
            for (var i = 0; i < item.children.length; i++) {
                collectTextFieldsData(item.children[i], dataList);
            }
        }

        // Also process contentItem if it exists
        if (item.contentItem) {
            collectTextFieldsData(item.contentItem, dataList);
        }
    }

    function clearAllData() {
        console.log("WorkPage: Clearing all data...");

        // 定义所有需要清空的TextField ID
        var fieldIds = [
            // 表1: 静态工作点
            "table1vc1Field", "table1vb1Field", "table1ve1Field",
            "table1vc2Field", "table1vb2Field", "table1ve2Field",
            
            // 表2: 动态参数
            "table2vs1Field", "table2vol1Field", "table2avl1Field", "table2vo1Field", "table2av1Field",
            "table2ri1Field", "table2ro1Field", "table2vo3Field", "table2av3Field", "table2w1Field",
            "table2vs2Field", "table2vol2Field", "table2avl2Field", "table2vo2Field", "table2av2Field",
            "table2ri2Field", "table2ro2Field", "table2vo4Field", "table2av4Field", "table2w2Field",
            
            // 表3: 差分放大器静态工作点
            "table3vc11Field", "table3vc21Field", "table3vb11Field", "table3vb21Field", "table3ve11Field", "table3ve21Field",
            "table3vc12Field", "table3vc22Field", "table3vb12Field", "table3vb22Field", "table3ve12Field", "table3ve22Field",
            
            // 表4: 差分放大器动态参数
            "table4vo11Field", "table4vo21Field", "table4vo1Field", "table4a1Field", "table4k1Field",
            "table4vo12Field", "table4vo22Field", "table4vo2Field", "table4a2Field",
            "table4vo13Field", "table4vo23Field", "table4vo3Field", "table4a3Field", "table4k2Field",
            "table4vo14Field", "table4vo24Field", "table4vo4Field", "table4a4Field",
            
            // 表5: 运算放大器反向比例电路
            "table5vi1Field", "table5vo1Field", "table5vi2Field", "table5vo2Field"
        ];

        // 清空所有定义的TextField
        for (var i = 0; i < fieldIds.length; i++) {
            try {
                var fieldItem = eval(fieldIds[i]);
                if (fieldItem) {
                    fieldItem.text = "";
                }
            } catch (e) {
                console.log("WorkPage: Error clearing field:", fieldIds[i], e.toString());
            }
        }

        // 重置ComboBox
        if (typeof meterRangeCombo !== 'undefined') {
            meterRangeCombo.currentIndex = 0; // Assuming 0 is the default/initial index
        }

        // 清空图片
        if (typeof vi1vo1Plotter !== 'undefined') vi1vo1Plotter.clearPlotData();
        if (typeof vi1vo2Plotter !== 'undefined') vi1vo2Plotter.clearPlotData();
        if (typeof vo1vo2Plotter !== 'undefined') vo1vo2Plotter.clearPlotData();
        if (typeof waveformPlotter !== 'undefined') waveformPlotter.clearPlotData();

        console.log("WorkPage: Data clearing complete.");
    }

    function collectAllData() {
        console.log("WorkPage: Collecting all data for submission...");
        
        // 创建符合服务端格式的数据对象
        var experimentData = {
            "experimentScore": 95, // 默认实验分数
            "currentText": meterRangeCombo.model[meterRangeCombo.currentIndex], // ComboBox选择的文本
        };

        // 添加所有表格字段，使用实际的字段名称
        var fieldMappings = [
            // 表1: 静态工作点
            { fieldId: "table1vc1Field", dataKey: "table1vc1Field" },
            { fieldId: "table1vb1Field", dataKey: "table1vb1Field" },
            { fieldId: "table1ve1Field", dataKey: "table1ve1Field" },
            { fieldId: "table1vc2Field", dataKey: "table1vc2Field" },
            { fieldId: "table1vb2Field", dataKey: "table1vb2Field" },
            { fieldId: "table1ve2Field", dataKey: "table1ve2Field" },
            
            // 表2: 动态参数
            { fieldId: "table2vs1Field", dataKey: "table2vs1Field" },
            { fieldId: "table2vol1Field", dataKey: "table2vol1Field" },
            { fieldId: "table2avl1Field", dataKey: "table2avl1Field" },
            { fieldId: "table2vo1Field", dataKey: "table2vo1Field" },
            { fieldId: "table2av1Field", dataKey: "table2av1Field" },
            { fieldId: "table2ri1Field", dataKey: "table2ri1Field" },
            { fieldId: "table2ro1Field", dataKey: "table2ro1Field" },
            { fieldId: "table2vo3Field", dataKey: "table2vo3Field" },
            { fieldId: "table2av3Field", dataKey: "table2av3Field" },
            { fieldId: "table2w1Field", dataKey: "table2w1Field" },
            { fieldId: "table2vs2Field", dataKey: "table2vs2Field" },
            { fieldId: "table2vol2Field", dataKey: "table2vol2Field" },
            { fieldId: "table2avl2Field", dataKey: "table2avl2Field" },
            { fieldId: "table2vo2Field", dataKey: "table2vo2Field" },
            { fieldId: "table2av2Field", dataKey: "table2av2Field" },
            { fieldId: "table2ri2Field", dataKey: "table2ri2Field" },
            { fieldId: "table2ro2Field", dataKey: "table2ro2Field" },
            { fieldId: "table2vo4Field", dataKey: "table2vo4Field" },
            { fieldId: "table2av4Field", dataKey: "table2av4Field" },
            { fieldId: "table2w2Field", dataKey: "table2w2Field" },
            
            // 表3: 差分放大器静态工作点
            { fieldId: "table3vc11Field", dataKey: "table3vc11Field" },
            { fieldId: "table3vc21Field", dataKey: "table3vc21Field" },
            { fieldId: "table3vb11Field", dataKey: "table3vb11Field" },
            { fieldId: "table3vb21Field", dataKey: "table3vb21Field" },
            { fieldId: "table3ve11Field", dataKey: "table3ve11Field" },
            { fieldId: "table3ve21Field", dataKey: "table3ve21Field" },
            { fieldId: "table3vc12Field", dataKey: "table3vc12Field" },
            { fieldId: "table3vc22Field", dataKey: "table3vc22Field" },
            { fieldId: "table3vb12Field", dataKey: "table3vb12Field" },
            { fieldId: "table3vb22Field", dataKey: "table3vb22Field" },
            { fieldId: "table3ve12Field", dataKey: "table3ve12Field" },
            { fieldId: "table3ve22Field", dataKey: "table3ve22Field" },
            
            // 表4: 差分放大器动态参数
            { fieldId: "table4vo11Field", dataKey: "table4vo11Field" },
            { fieldId: "table4vo21Field", dataKey: "table4vo21Field" },
            { fieldId: "table4vo1Field", dataKey: "table4vo1Field" },
            { fieldId: "table4a1Field", dataKey: "table4a1Field" },
            { fieldId: "table4k1Field", dataKey: "table4k1Field" },
            { fieldId: "table4vo12Field", dataKey: "table4vo12Field" },
            { fieldId: "table4vo22Field", dataKey: "table4vo22Field" },
            { fieldId: "table4vo2Field", dataKey: "table4vo2Field" },
            { fieldId: "table4a2Field", dataKey: "table4a2Field" },
            { fieldId: "table4vo13Field", dataKey: "table4vo13Field" },
            { fieldId: "table4vo23Field", dataKey: "table4vo23Field" },
            { fieldId: "table4vo3Field", dataKey: "table4vo3Field" },
            { fieldId: "table4a3Field", dataKey: "table4a3Field" },
            { fieldId: "table4k2Field", dataKey: "table4k2Field" },
            { fieldId: "table4vo14Field", dataKey: "table4vo14Field" },
            { fieldId: "table4vo24Field", dataKey: "table4vo24Field" },
            { fieldId: "table4vo4Field", dataKey: "table4vo4Field" },
            { fieldId: "table4a4Field", dataKey: "table4a4Field" },
            
            // 表5: 运算放大器反向比例电路
            { fieldId: "table5vi1Field", dataKey: "table5vi1Field" },
            { fieldId: "table5vo1Field", dataKey: "table5vo1Field" },
            { fieldId: "table5vi2Field", dataKey: "table5vi2Field" },
            { fieldId: "table5vo2Field", dataKey: "table5vo2Field" }
        ];

        // 收集所有表格字段数据
        for (var i = 0; i < fieldMappings.length; i++) {
            var mapping = fieldMappings[i];
            try {
                var fieldItem = eval(mapping.fieldId);
                if (fieldItem) {
                    // 对于数字字段，尝试转换为数字
                    var value = fieldItem.text || "";
                    var numValue = parseFloat(value);
                    experimentData[mapping.dataKey] = isNaN(numValue) ? value : numValue;
                } else {
                    console.log("WorkPage: Field not found:", mapping.fieldId);
                    experimentData[mapping.dataKey] = "";
                }
            } catch (e) {
                console.log("WorkPage: Error accessing field:", mapping.fieldId, e.toString());
                experimentData[mapping.dataKey] = "";
            }
        }

        // 添加图片字段（设置为null，因为我们只上传现有数据）
        experimentData["vi1vo1Image"] = vi1vo1Plotter.plotImageUrl.toString() || null;
        experimentData["vi1vo2Image"] = vi1vo2Plotter.plotImageUrl.toString() || null;
        experimentData["vo1vo2Image"] = vo1vo2Plotter.plotImageUrl.toString() || null;

        console.log("WorkPage: Collected experiment data");
        return experimentData;
    }

    function submitData() {
        var data = collectAllData();
        var jsonData = JSON.stringify(data, null, 2);
        console.log("WorkPage: Submitting data:", jsonData);
        
        // 检查是否有实验ID和学生号
        if (!workPageWindow.experimentId || !workPageWindow.studentNumber) {
            console.log("WorkPage: Missing experiment ID or student number");
            confirmDialog.dialogState = "auth_failed";
            confirmDialog.open();
            return;
        }
        
        // 记录需要上传的图片文件（恢复二进制上传）
        workPageWindow.pendingUploads = [];
        
        if (data.vi1vo1Image) {
            workPageWindow.pendingUploads.push({
                imagePath: data.vi1vo1Image,
                fileName: "vi1vo1_waveform.png",
                jsonData: jsonData
            });
        }
        
        if (data.vi1vo2Image) {
            workPageWindow.pendingUploads.push({
                imagePath: data.vi1vo2Image,
                fileName: "vi1vo2_waveform.png",
                jsonData: jsonData
            });
        }
        
        if (data.vo1vo2Image) {
            workPageWindow.pendingUploads.push({
                imagePath: data.vo1vo2Image,
                fileName: "vo1vo2_waveform.png",
                jsonData: jsonData
            });
        }
        
        // 如果没有任何图片，显示警告
        if (workPageWindow.pendingUploads.length === 0) {
            console.log("WorkPage: No images available, showing warning");
            confirmDialog.dialogState = "no_images";
            confirmDialog.open();
        } else {
            // 开始上传，显示提交中状态
            confirmDialog.dialogState = "uploading";
            workPageWindow.currentUploadIndex = 0;
            uploadNextFile();
        }
    }

    function uploadNextFile() {
        if (workPageWindow.currentUploadIndex < workPageWindow.pendingUploads.length) {
            var upload = workPageWindow.pendingUploads[workPageWindow.currentUploadIndex];
            console.log("WorkPage: Uploading", upload.fileName, "...");
            
            // 解析JSON数据并添加id和studentId
            var dataObj = JSON.parse(upload.jsonData);
            dataObj.id = workPageWindow.experimentId;
            dataObj.studentId = workPageWindow.studentNumber;
            var enhancedJsonData = JSON.stringify(dataObj);
            
            httpUploader.uploadData(upload.imagePath, enhancedJsonData, upload.fileName);
        }
    }
    // +++ END OF JAVASCRIPT FUNCTIONS +++

    // 使用 contentItem 设置背景
    contentItem: Rectangle {
        id: mainRectangle
        anchors.fill: parent
        color: "white" // 白色背景

        // 标题栏
        Rectangle {
            id: titleBar
            width: parent.width
            height: workPageWindow.adaptive_height / 15
            color: "#f0f0f0" // 浅灰色背景
            anchors.top: parent.top

            Text {
                id: titleText
                text: qsTr("实验报告")
                anchors.centerIn: parent
                color: "#333333"
                font.pixelSize: Math.min(workPageWindow.adaptive_width / 40, workPageWindow.adaptive_height / 25)
                font.bold: true
                font.family: "Microsoft YaHei"
            }

            // 返回按钮
            Rectangle {
                id: backButtonRect
                width: Math.max(titleBar.height * 2.5, workPageWindow.adaptive_width / 8)
                height: titleBar.height * 0.7
                anchors.left: parent.left
                anchors.leftMargin: 20
                anchors.verticalCenter: parent.verticalCenter
                color: "#c0392b"
                radius: 5

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
                        console.log("WorkPage: Back button clicked, cleaning up resources before closing");
                        cleanupResources();
                        console.log("WorkPage: Destroying and returning to main menu.");
                        // 清空mainloader.source来销毁workpage并返回主菜单
                        if (typeof mainloader !== 'undefined') {
                            mainloader.source = "";
                        } else {
                            // 如果无法访问mainloader，则直接销毁窗口
                            workPageWindow.destroy();
                        }
                    }
                }
            }
        }

        // 状态栏
        Rectangle {
            id: statusBar
            width: parent.width
            height: workPageWindow.adaptive_height / 20
            color: "#e8e8e8"
            anchors.top: titleBar.bottom

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 20
                anchors.rightMargin: 20
                spacing: 20

                Text {
                    id: statusText
                    text: {
                        if (workPageWindow.isAuthenticating) {
                            return qsTr("正在验证身份...");
                        } else if (workPageWindow.isAuthenticated) {
                            return qsTr("姓名：") + workPageWindow.studentName + qsTr("        学号：") + workPageWindow.studentNumber;
                        } else {
                            return qsTr("身份验证失败");
                        }
                    }
                    color: "#555555"
                    font.pixelSize: workPageWindow.adaptive_height / 45
                    font.family: "Microsoft YaHei"
                    Layout.alignment: Qt.AlignVCenter
                }

                Item { Layout.fillWidth: true } // 弹性空间

                // 仪器状态下拉栏
                Rectangle {
                    id: instrumentStatusContainer
                    width: 300
                    height: statusBar.height * 0.8
                    color: "#f5f5f5"
                    border.color: "#cccccc"
                    border.width: 1
                    radius: 4
                    Layout.alignment: Qt.AlignVCenter

                    property bool dropdownVisible: false

                    // 主显示区域
                    Rectangle {
                        id: mainStatusArea
                        anchors.fill: parent
                        color: instrumentStatusContainer.dropdownVisible ? "#e0e0e0" : "transparent"
                        radius: parent.radius

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 8
                            anchors.rightMargin: 8
                            spacing: 5

                            Text {
                                text: qsTr("仪器状态")
                                color: "#555555"
                                font.pixelSize: workPageWindow.adaptive_height / 50
                                font.family: "Microsoft YaHei"
                                font.bold: true
                                Layout.alignment: Qt.AlignVCenter
                            }

                            Item { Layout.fillWidth: true }

                            // 下拉箭头
                            Text {
                                text: instrumentStatusContainer.dropdownVisible ? "▲" : "▼"
                                color: "#777777"
                                font.pixelSize: workPageWindow.adaptive_height / 60
                                Layout.alignment: Qt.AlignVCenter
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                instrumentStatusContainer.dropdownVisible = !instrumentStatusContainer.dropdownVisible;
                            }
                        }
                    }

                    // 下拉菜单
                    Rectangle {
                        id: dropdownMenu
                        width: parent.width
                        height: instrumentStatusContainer.dropdownVisible ? (oscilloscopeStatusItem.height + signalGeneratorStatusItem.height + 15) : 0
                        anchors.top: parent.bottom
                        anchors.topMargin: 2
                        color: "#ffffff"
                        border.color: "#cccccc"
                        border.width: 1
                        radius: 4
                        visible: height > 0
                        z: 10

                        Behavior on height {
                            NumberAnimation {
                                duration: 200
                                easing.type: Easing.OutCubic
                            }
                        }

                        Column {
                            anchors.fill: parent
                            anchors.margins: 5
                            spacing: 5

                            // 示波器状态项
                            Rectangle {
                                id: oscilloscopeStatusItem
                                width: parent.width
                                height: 35
                                color: "transparent"

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.leftMargin: 8
                                    anchors.rightMargin: 8
                                    spacing: 8

                                    // 状态指示圆点
                                    Rectangle {
                                        width: 8
                                        height: 8
                                        radius: 4
                                        color: {
                                            if (scpiHandler.connected) {
                                                if (heartbeatTimer.running) {
                                                    return "green";
                                                } else {
                                                    return "orange";
                                                }
                                            } else {
                                                if (workPageWindow.heartbeatFailureCount > 0) {
                                                    return "orange";
                                                } else {
                                                    return "red";
                                                }
                                            }
                                        }
                                        Layout.alignment: Qt.AlignVCenter
                                    }

                                    Text {
                                        text: qsTr("示波器")
                                        color: "#333333"
                                        font.pixelSize: workPageWindow.adaptive_height / 55
                                        font.family: "Microsoft YaHei"
                                        Layout.alignment: Qt.AlignVCenter
                                    }

                                    Item { Layout.fillWidth: true }

                                    Text {
                                        text: {
                                            if (scpiHandler.connected) {
                                                if (heartbeatTimer.running) {
                                                    return qsTr("已连接 (监控中)");
                                                } else {
                                                    return qsTr("已连接");
                                                }
                                            } else {
                                                if (workPageWindow.heartbeatFailureCount > 0) {
                                                    return qsTr("连接异常");
                                                } else {
                                                    return qsTr("未连接");
                                                }
                                            }
                                        }
                                        color: "#666666"
                                        font.pixelSize: workPageWindow.adaptive_height / 60
                                        font.family: "Microsoft YaHei"
                                        Layout.alignment: Qt.AlignVCenter
                                    }
                                }
                            }

                            // 信号发生器状态项
                            Rectangle {
                                id: signalGeneratorStatusItem
                                width: parent.width
                                height: 35
                                color: "transparent"

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.leftMargin: 8
                                    anchors.rightMargin: 8
                                    spacing: 8

                                    // 状态指示圆点
                                    Rectangle {
                                        width: 8
                                        height: 8
                                        radius: 4
                                        color: {
                                            if (sigGenHandler.connected) {
                                                if (sigGenHeartbeatTimer.running) {
                                                    return "green";
                                                } else {
                                                    return "orange";
                                                }
                                            } else {
                                                if (workPageWindow.sigGenHeartbeatFailureCount > 0) {
                                                    return "orange";
                                                } else {
                                                    return "red";
                                                }
                                            }
                                        }
                                        Layout.alignment: Qt.AlignVCenter
                                    }

                                    Text {
                                        text: qsTr("信号发生器")
                                        color: "#333333"
                                        font.pixelSize: workPageWindow.adaptive_height / 55
                                        font.family: "Microsoft YaHei"
                                        Layout.alignment: Qt.AlignVCenter
                                    }

                                    Item { Layout.fillWidth: true }

                                    Text {
                                        text: {
                                            if (sigGenHandler.connected) {
                                                if (sigGenHeartbeatTimer.running) {
                                                    return qsTr("已连接 (监控中)");
                                                } else {
                                                    return qsTr("已连接");
                                                }
                                            } else {
                                                if (workPageWindow.sigGenHeartbeatFailureCount > 0) {
                                                    return qsTr("连接异常");
                                                } else {
                                                    return qsTr("未连接");
                                                }
                                            }
                                        }
                                        color: "#666666"
                                        font.pixelSize: workPageWindow.adaptive_height / 60
                                        font.family: "Microsoft YaHei"
                                        Layout.alignment: Qt.AlignVCenter
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        // 主要内容区域 - 滚动区域
        ScrollView {
            id: scrollArea
            anchors.top: statusBar.bottom
            anchors.bottom: clearDataBar.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: 20
            clip: true

            // 禁用水平滚动条，只保留垂直滚动条
            ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
            ScrollBar.vertical.policy: ScrollBar.AsNeeded

            ColumnLayout {
                id: mainContentLayout
                width: scrollArea.availableWidth
                spacing: 20

                // 文本内容
                Text {
                    Layout.fillWidth: true
                    wrapMode: Text.Wrap
                    text: "实验过程记录（60 分）"
                    font.bold: true
                    font.pointSize: 16
                    bottomPadding: 10
                    font.family: "Microsoft YaHei"
                    color: "#333333"
                }

                GroupBox {
                    title: "1、负反馈放大器数据记录"
                    Layout.fillWidth: true
                    font.family: "Microsoft YaHei"
                    
                    Column {
                        spacing: 10
                        width: parent.width
                        
                        GroupBox {
                            title: "表1（图1 静态工作点）（5 分）"
                            width: parent.width
                            font.family: "Microsoft YaHei"
                            
                            Grid {
                                columns: 5
                                spacing: 5
                                verticalItemAlignment: Grid.AlignVCenter

                                // 表头
                                Text { text: "                    "; font.bold: true; font.family: "Microsoft YaHei" }
                                Text { text: "VC (V)"; font.bold: true; font.family: "Microsoft YaHei"; color: "#333333" }
                                Text { text: "VB (V)"; font.bold: true; font.family: "Microsoft YaHei"; color: "#333333" }
                                Text { text: "VE (V)"; font.bold: true; font.family: "Microsoft YaHei"; color: "#333333" }
                                Text { text: "VCE (V)"; font.bold: true; font.family: "Microsoft YaHei"; color: "#333333" }

                                // 第一级数据
                                Text { text: "第一级"; font.family: "Microsoft YaHei"; color: "#333333"; horizontalAlignment: Text.AlignLeft }
                                TextField { id: table1vc1Field; placeholderText: "输入值"; font.family: "Microsoft YaHei"; color: "#333333" }
                                TextField { id: table1vb1Field; placeholderText: "输入值"; font.family: "Microsoft YaHei"; color: "#333333" }
                                TextField { id: table1ve1Field; placeholderText: "输入值"; font.family: "Microsoft YaHei"; color: "#333333" }
                                Text { text: "5.5"; font.family: "Microsoft YaHei"; color: "#333333"; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }

                                // 第二级数据
                                Text { text: "第二级"; font.family: "Microsoft YaHei"; color: "#333333"; horizontalAlignment: Text.AlignLeft }
                                TextField { id: table1vc2Field; placeholderText: "输入值"; font.family: "Microsoft YaHei"; color: "#333333" }
                                TextField { id: table1vb2Field; placeholderText: "输入值"; font.family: "Microsoft YaHei"; color: "#333333" }
                                TextField { id: table1ve2Field; placeholderText: "输入值"; font.family: "Microsoft YaHei"; color: "#333333" }
                                Text { text: "5.5"; font.family: "Microsoft YaHei"; color: "#333333"; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                            }
                        }


                        GroupBox {
                            title: "表2（图1 动态参数，计算公式见表下）（20 分）"
                            width: parent.width
                            font.family: "Microsoft YaHei"
                            
                            Grid {
                                columns: 14
                                spacing: 5
                                verticalItemAlignment: Grid.AlignVCenter

                                // 表头
                                Text { text: "参数"; font.bold: true; font.family: "Microsoft YaHei"; color: "#333333" }
                                Text { text: "Vs"; font.bold: true; font.family: "Microsoft YaHei"; color: "#333333" }
                                Text { text: "Rs"; font.bold: true; font.family: "Microsoft YaHei"; color: "#333333" }
                                Text { text: "Vi"; font.bold: true; font.family: "Microsoft YaHei"; color: "#333333" }
                                Text { text: "f"; font.bold: true; font.family: "Microsoft YaHei"; color: "#333333" }
                                Text { text: "VCC=12V"; font.bold: true; font.family: "Microsoft YaHei"; color: "#333333" }
                                Text { text: "RL=4.7K"; font.bold: true; font.family: "Microsoft YaHei"; color: "#333333" }
                                Text { text: "VCC=12V"; font.bold: true; font.family: "Microsoft YaHei"; color: "#333333" }
                                Text { text: "RL=∞"; font.bold: true; font.family: "Microsoft YaHei"; color: "#333333" }
                                Text { text: "Ri"; font.bold: true; font.family: "Microsoft YaHei"; color: "#333333" }
                                Text { text: "Ro"; font.bold: true; font.family: "Microsoft YaHei"; color: "#333333" }
                                Text { text: "VCC=10V"; font.bold: true; font.family: "Microsoft YaHei"; color: "#333333" }
                                Text { text: "RL=∞"; font.bold: true; font.family: "Microsoft YaHei"; color: "#333333" }
                                Text { text: "W"; font.bold: true; font.family: "Microsoft YaHei"; color: "#333333" }

                                Text { text: "状态"; font.bold: true; font.family: "Microsoft YaHei"; color: "#333333" }
                                Text { text: "(mV)"; font.bold: true; font.family: "Microsoft YaHei"; color: "#333333" }
                                Text { text: "(kΩ)    "; font.bold: true; font.family: "Microsoft YaHei"; color: "#333333" }
                                Text { text: "(mV)    "; font.bold: true; font.family: "Microsoft YaHei"; color: "#333333" }
                                Text { text: "(Hz)    "; font.bold: true; font.family: "Microsoft YaHei"; color: "#333333" }
                                Text { text: "Vol"; font.bold: true; font.family: "Microsoft YaHei"; color: "#333333" }
                                Text { text: "Avl"; font.bold: true; font.family: "Microsoft YaHei"; color: "#333333" }
                                Text { text: "Vo"; font.bold: true; font.family: "Microsoft YaHei"; color: "#333333" }
                                Text { text: "Av"; font.bold: true; font.family: "Microsoft YaHei"; color: "#333333" }
                                Text { text: "(kΩ)"; font.bold: true; font.family: "Microsoft YaHei"; color: "#333333" }
                                Text { text: "(kΩ)"; font.bold: true; font.family: "Microsoft YaHei"; color: "#333333" }
                                Text { text: "Vo"; font.bold: true; font.family: "Microsoft YaHei"; color: "#333333" }
                                Text { text: "Av"; font.bold: true; font.family: "Microsoft YaHei"; color: "#333333" }
                                Text { text: "%"; font.bold: true; font.family: "Microsoft YaHei"; color: "#333333" }

                                // 第一级数据
                                Text { text: "基本放大"; font.family: "Microsoft YaHei"; color: "#333333"; horizontalAlignment: Text.AlignLeft }
                                TextField { id: table2vs1Field; placeholderText: "①"; font.family: "Microsoft YaHei"; color: "#333333"; implicitWidth: 100 }
                                Text { text: "10"; font.bold: true; font.family: "Microsoft YaHei"; color: "#333333" }
                                Text { text: "5"; font.bold: true; font.family: "Microsoft YaHei"; color: "#333333" }
                                Text { text: "1K"; font.bold: true; font.family: "Microsoft YaHei"; color: "#333333" }
                                TextField { id: table2vol1Field; placeholderText: "③"; font.family: "Microsoft YaHei"; color: "#333333"; implicitWidth: 100 }
                                TextField { id: table2avl1Field; placeholderText: "输入值"; font.family: "Microsoft YaHei"; color: "#333333"; implicitWidth: 100 }
                                TextField { id: table2vo1Field; placeholderText: "⑤"; font.family: "Microsoft YaHei"; color: "#333333"; implicitWidth: 100 }
                                TextField { id: table2av1Field; placeholderText: "输入值"; font.family: "Microsoft YaHei"; color: "#333333"; implicitWidth: 100 }
                                TextField { id: table2ri1Field; placeholderText: "输入值"; font.family: "Microsoft YaHei"; color: "#333333"; implicitWidth: 100 }
                                TextField { id: table2ro1Field; placeholderText: "输入值"; font.family: "Microsoft YaHei"; color: "#333333"; implicitWidth: 100 }
                                TextField { id: table2vo3Field; placeholderText: "⑦"; font.family: "Microsoft YaHei"; color: "#333333"; implicitWidth: 100 }
                                TextField { id: table2av3Field; placeholderText: "输入值"; font.family: "Microsoft YaHei"; color: "#333333"; implicitWidth: 100 }
                                TextField { id: table2w1Field; placeholderText: "输入值"; font.family: "Microsoft YaHei"; color: "#333333"; implicitWidth: 100 }

                                Text { text: "负反馈放大"; font.family: "Microsoft YaHei"; color: "#333333"; horizontalAlignment: Text.AlignLeft }
                                TextField { id: table2vs2Field; placeholderText: "②"; font.family: "Microsoft YaHei"; color: "#333333"; implicitWidth: 100 }
                                Text { text: "10"; font.bold: true; font.family: "Microsoft YaHei"; color: "#333333" }
                                Text { text: "5"; font.bold: true; font.family: "Microsoft YaHei"; color: "#333333" }
                                Text { text: "1K"; font.bold: true; font.family: "Microsoft YaHei"; color: "#333333" }
                                TextField { id: table2vol2Field; placeholderText: "④"; font.family: "Microsoft YaHei"; color: "#333333"; implicitWidth: 100 }
                                TextField { id: table2avl2Field; placeholderText: "输入值"; font.family: "Microsoft YaHei"; color: "#333333"; implicitWidth: 100 }
                                TextField { id: table2vo2Field; placeholderText: "⑥"; font.family: "Microsoft YaHei"; color: "#333333"; implicitWidth: 100 }
                                TextField { id: table2av2Field; placeholderText: "输入值"; font.family: "Microsoft YaHei"; color: "#333333"; implicitWidth: 100 }
                                TextField { id: table2ri2Field; placeholderText: "输入值"; font.family: "Microsoft YaHei"; color: "#333333"; implicitWidth: 100 }
                                TextField { id: table2ro2Field; placeholderText: "输入值"; font.family: "Microsoft YaHei"; color: "#333333"; implicitWidth: 100 }
                                TextField { id: table2vo4Field; placeholderText: "⑧"; font.family: "Microsoft YaHei"; color: "#333333"; implicitWidth: 100 }
                                TextField { id: table2av4Field; placeholderText: "输入值"; font.family: "Microsoft YaHei"; color: "#333333"; implicitWidth: 100 }
                                TextField { id: table2w2Field; placeholderText: "输入值"; font.family: "Microsoft YaHei"; color: "#333333"; implicitWidth: 100 }
                            }
                        }

                        // The "计算公式" Text element should be here, as a sibling to the GroupBox "表2"
                                Text {
                                    text: "计算公式：\nRi = Vi / (Vs - Vi) * Rs\nRo = (Vo / VoL - 1) * RL (RL = 4.7kΩ)\nW(稳定度) = (AV12v - AV10v) / AV12v * 100%\nAv = Vo / Vi"
                            font.pixelSize: 11
                                    topPadding: 10
                                    font.family: "Microsoft YaHei"
                            color: "#333333"
                            Layout.fillWidth: true
                            wrapMode: Text.Wrap
                            Layout.leftMargin: 20
                        }
                    }
                }

                // 2. 差分放大器数据记录
                GroupBox {
                    title: "2、差分放大器数据记录"
                    Layout.fillWidth: true
                    font.family: "Microsoft YaHei"
                    
                    Column {
                        spacing: 10
                        width: parent.width

                        // 表3：静态工作点
                        GroupBox {
                            title: "表3（图2 静态工作点）（5 分）"
                            width: parent.width
                            font.family: "Microsoft YaHei"
                            
                            Grid {
                                columns: 7
                                spacing: 5
                                verticalItemAlignment: Grid.AlignVCenter

                                // 表头
                                Text { text: "                    "; font.bold: true; font.family: "Microsoft YaHei" }
                                Text { text: "VC1(V)"; font.bold: true; font.family: "Microsoft YaHei" }
                                Text { text: "VC2(V)"; font.bold: true; font.family: "Microsoft YaHei" }
                                Text { text: "VB1(V)"; font.bold: true; font.family: "Microsoft YaHei" }
                                Text { text: "VB2(V)"; font.bold: true; font.family: "Microsoft YaHei" }
                                Text { text: "VE1(V)"; font.bold: true; font.family: "Microsoft YaHei" }
                                Text { text: "VE2(V)"; font.bold: true; font.family: "Microsoft YaHei" }

                                // 典型差放数据
                                Text { text: "典型差放(1)"; font.family: "Microsoft YaHei" }
                                TextField { id: table3vc11Field; placeholderText: "输入值"; font.family: "Microsoft YaHei" }
                                TextField { id: table3vc21Field; placeholderText: "输入值"; font.family: "Microsoft YaHei" }
                                TextField { id: table3vb11Field; placeholderText: "输入值"; font.family: "Microsoft YaHei" }
                                TextField { id: table3vb21Field; placeholderText: "输入值"; font.family: "Microsoft YaHei" }
                                TextField { id: table3ve11Field; placeholderText: "输入值"; font.family: "Microsoft YaHei" }
                                TextField { id: table3ve21Field; placeholderText: "输入值"; font.family: "Microsoft YaHei" }

                                // 恒流源差放数据
                                Text { text: "恒流源差放(2)"; font.family: "Microsoft YaHei" }
                                TextField { id: table3vc12Field; placeholderText: "输入值"; font.family: "Microsoft YaHei" }
                                TextField { id: table3vc22Field; placeholderText: "输入值"; font.family: "Microsoft YaHei" }
                                TextField { id: table3vb12Field; placeholderText: "输入值"; font.family: "Microsoft YaHei" }
                                TextField { id: table3vb22Field; placeholderText: "输入值"; font.family: "Microsoft YaHei" }
                                TextField { id: table3ve12Field; placeholderText: "输入值"; font.family: "Microsoft YaHei" }
                                TextField { id: table3ve22Field; placeholderText: "输入值"; font.family: "Microsoft YaHei" }
                            }
                        }

                        // 表4：动态参数
                        GroupBox {
                            title: "表4（图2 动态参数，计算公式见表下）（15 分）"
                            width: parent.width
                            font.family: "Microsoft YaHei"
                            
                            Column {
                                spacing: 5

                                // 表格内容
                                Grid {
                                    columns: 8
                                    spacing: 5
                                    verticalItemAlignment: Grid.AlignVCenter

                                    // 表头
                                    Text { text: "电路形式"; font.bold: true; font.family: "Microsoft YaHei" }
                                    Text { text: "输入信号类型"; font.bold: true; font.family: "Microsoft YaHei" }
                                    Text { text: "VS(V)（有效值）"; font.bold: true; font.family: "Microsoft YaHei" }
                                    Text { text: "VO1(V)（有效值）"; font.bold: true; font.family: "Microsoft YaHei" }
                                    Text { text: "VO2(V)（有效值）"; font.bold: true; font.family: "Microsoft YaHei" }
                                    Text { text: "VO(V)（有效值）"; font.bold: true; font.family: "Microsoft YaHei" }
                                    Text { text: "双端输出电压增益"; font.bold: true; font.family: "Microsoft YaHei" }
                                    Text { text: "KCMR"; font.bold: true; font.family: "Microsoft YaHei" }

                                    // 典型差放数据
                                    Text { text: "典型差放(3)"; font.family: "Microsoft YaHei" }
                                    Text { text: "差模"; font.family: "Microsoft YaHei" }
                                    Text { text: "50mV"; font.bold: true; font.family: "Microsoft YaHei" }
                                    TextField { id: table4vo11Field; placeholderText: "输入值"; font.family: "Microsoft YaHei" }
                                    TextField { id: table4vo21Field; placeholderText: "输入值"; font.family: "Microsoft YaHei" }
                                    TextField { id: table4vo1Field; placeholderText: "输入值"; font.family: "Microsoft YaHei" }
                                    TextField { id: table4a1Field; placeholderText: "输入值"; font.family: "Microsoft YaHei" }
                                    TextField { id: table4k1Field; placeholderText: "输入值"; font.family: "Microsoft YaHei" }

                                    Text { text: "                    " }
                                    Text { text: "共模"; font.family: "Microsoft YaHei" }
                                    Text { text: "1"; font.bold: true; font.family: "Microsoft YaHei" }
                                    TextField { id: table4vo12Field; placeholderText: "输入值"; font.family: "Microsoft YaHei" }
                                    TextField { id: table4vo22Field; placeholderText: "输入值"; font.family: "Microsoft YaHei" }
                                    TextField { id: table4vo2Field; placeholderText: "输入值"; font.family: "Microsoft YaHei" }
                                    TextField { id: table4a2Field; placeholderText: "输入值"; font.family: "Microsoft YaHei" }
                                    Text { text: "                    " }

                                    // 恒流源差放数据
                                    Text { text: "恒流源差放(4)"; font.family: "Microsoft YaHei" }
                                    Text { text: "差模"; font.family: "Microsoft YaHei" }
                                    Text { text: "50mV"; font.bold: true; font.family: "Microsoft YaHei" }
                                    TextField { id: table4vo13Field; placeholderText: "输入值"; font.family: "Microsoft YaHei" }
                                    TextField { id: table4vo23Field; placeholderText: "输入值"; font.family: "Microsoft YaHei" }
                                    TextField { id: table4vo3Field; placeholderText: "输入值"; font.family: "Microsoft YaHei" }
                                    TextField { id: table4a3Field; placeholderText: "输入值"; font.family: "Microsoft YaHei" }
                                    TextField { id: table4k2Field; placeholderText: "输入值"; font.family: "Microsoft YaHei" }

                                    Text { text: "                    " }
                                    Text { text: "共模"; font.family: "Microsoft YaHei" }
                                    Text { text: "1"; font.bold: true; font.family: "Microsoft YaHei" }
                                    TextField { id: table4vo14Field; placeholderText: "输入值"; font.family: "Microsoft YaHei" }
                                    TextField { id: table4vo24Field; placeholderText: "输入值"; font.family: "Microsoft YaHei" }
                                    TextField { id: table4vo4Field; placeholderText: "输入值"; font.family: "Microsoft YaHei" }
                                    TextField { id: table4a4Field; placeholderText: "输入值"; font.family: "Microsoft YaHei" }
                                    Text { text: "                    " }
                                }
                            }
                        }

                                Text {
                                    text: "计算公式：\n差模Vo = ||Vo1| + |Vo2||\n共模Vo = ||Vo1| - |Vo2||\n增益Av = Vo/Vs\nKCMR = |AVD/AVC|"
                            font.pixelSize: 11
                                    topPadding: 10
                                    font.family: "Microsoft YaHei"
                            color: "#333333"
                            Layout.fillWidth: true
                            wrapMode: Text.Wrap
                            Layout.leftMargin: 20
                        }
                    }
                }

                // 3、差分放大器中观察Vi1与VO1和VO2的相位关系并记录波形
                GroupBox {
                    title: "3、差分放大器中观察Vi1与VO1和VO2的相位关系并记录波形（5分）"
                    Layout.fillWidth: true
                    font.family: "Microsoft YaHei"
                    
                    Column {
                        spacing: 10
                        width: parent.width
                        
                        Text {
                            text: "将VS=50mv f=1000Hz的正弦信号从Vi1单端输入（即将信号源红夹子接Vi1，黑夹子接GND，将Vi2接地，即Vi2=0），用示波器（两个黑夹子接地）分别观察Vi1与VO1，Vi1与VO2之间的相位关系，并记录波形。"
                            width: parent.width
                            wrapMode: Text.WordWrap
                            font.family: "Microsoft YaHei"
                        }

                        // 获取Vi1与Vo1波形按钮
                        Button {
                            id: getVi1Vo1Button
                            text: workPageWindow.isGettingDualChannelData && workPageWindow.currentWaveformTarget === "vi1vo1" ? 
                                  "获取中..." : "获取Vi1与Vo1波形"
                            width: parent.width * 0.6
                            height: workPageWindow.adaptive_height / 20
                            anchors.horizontalCenter: parent.horizontalCenter
                            enabled: scpiHandler.connected && !workPageWindow.isGettingDualChannelData
                            font.family: "Microsoft YaHei"
                            font.pixelSize: workPageWindow.adaptive_height / 40

                            property int currentCommandIndex: 0
                            property var ch1CommandList: [
                                ":STOP",
                                ":WAV:SOUR CHAN1",
                                ":WAV:MODE NORM",
                                ":WAV:FORM ASCii",
                                ":WAV:POIN NORM",
                                ":WAV:DATA?"
                            ]
                            property var ch2CommandList: [
                                ":WAV:SOUR CHAN2",
                                ":WAV:MODE NORM",
                                ":WAV:FORM ASCii",
                                ":WAV:POIN NORM",
                                ":WAV:DATA?"
                            ]

                            function sendNextCommandInSequence() {
                                if (workPageWindow.currentDualChannelStep === "ch1") {
                                    if (currentCommandIndex < ch1CommandList.length) {
                                        var cmd = ch1CommandList[currentCommandIndex];
                                        console.log("WorkPage: Vi1Vo1 CH1 - Sending command:", cmd);
                                        scpiHandler.sendCommand(cmd);

                                        if (cmd === ":WAV:DATA?") {
                                            workPageWindow.expectingWaveformData = true;
                                            dataFinalizationTimer.stop();
                                        }

                                        currentCommandIndex++;
                                        if (currentCommandIndex < ch1CommandList.length) {
                                            vi1vo1CommandTimer.start();
                                        } else {
                                            if (ch1CommandList[currentCommandIndex-1] === ":WAV:DATA?") {
                                                dataFinalizationTimer.start();
                                            }
                                        }
                                    }
                                } else if (workPageWindow.currentDualChannelStep === "ch2") {
                                    if (currentCommandIndex < ch2CommandList.length) {
                                        var cmd = ch2CommandList[currentCommandIndex];
                                        console.log("WorkPage: Vi1Vo1 CH2 - Sending command:", cmd);
                                        scpiHandler.sendCommand(cmd);

                                        if (cmd === ":WAV:DATA?") {
                                            workPageWindow.expectingWaveformData = true;
                                            dataFinalizationTimer.stop();
                                        }

                                        currentCommandIndex++;
                                        if (currentCommandIndex < ch2CommandList.length) {
                                            vi1vo1CommandTimer.start();
                                        } else {
                                            if (ch2CommandList[currentCommandIndex-1] === ":WAV:DATA?") {
                                                dataFinalizationTimer.start();
                                            }
                                        }
                                    }
                                }
                            }

                            background: Rectangle {
                                color: parent.pressed ? "#a0a0a0" : "#d0d0d0"
                                radius: 5
                                border.color: "#808080"
                                border.width: 1
                            }
                            contentItem: Text {
                                text: getVi1Vo1Button.text
                                color: "black"
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                                font: getVi1Vo1Button.font
                            }
                            onClicked: {
                                vi1vo1Plotter.clearPlotData();
                                workPageWindow.expectingWaveformData = false;
                                workPageWindow.isGettingDualChannelData = true;
                                workPageWindow.currentWaveformTarget = "vi1vo1";
                                workPageWindow.currentDualChannelStep = "ch1";
                                currentCommandIndex = 0;
                                sendNextCommandInSequence();
                            }
                        }

                        // Vi1与Vo1波形图片显示区域
                        Rectangle {
                            id: vi1vo1DisplayArea
                            width: parent.width * 0.8
                            height: 450
                            anchors.horizontalCenter: parent.horizontalCenter
                            color: "#f8f8f8"
                            border.color: "#cccccc"
                            border.width: 1
                            radius: 8

                            ColumnLayout {
                                anchors.fill: parent
                                anchors.margins: 15
                                spacing: 10

                                Text {
                                    text: "Vi1与Vo1波形显示"
                                    font.family: "Microsoft YaHei"
                                    font.pixelSize: workPageWindow.adaptive_height / 45
                                    font.bold: true
                                    color: "#555555"
                                    Layout.alignment: Qt.AlignHCenter
                                }

                                Image {
                                    id: vi1vo1WaveformImage
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    source: vi1vo1Plotter.plotImageUrl.toString() ? vi1vo1Plotter.plotImageUrl.toString() + "?timestamp=" + new Date().getTime() : ""
                                    fillMode: Image.PreserveAspectFit
                                    smooth: true

                                    Rectangle {
                                        anchors.centerIn: parent
                                        width: parent.width * 0.8
                                        height: parent.height * 0.6
                                        color: "#ecf0f1"
                                        border.color: "#bdc3c7"
                                        border.width: 1
                                        radius: 5
                                        visible: !parent.source.toString()

                                        Text {
                                            anchors.centerIn: parent
                                            text: "点击上方按钮获取Vi1与Vo1波形"
                                            font.family: "Microsoft YaHei"
                                            font.pixelSize: workPageWindow.adaptive_height / 55
                                            color: "#7f8c8d"
                                            horizontalAlignment: Text.AlignHCenter
                                        }
                                    }
                                }

                                Text {
                                    text: "图3: Vi1与Vo1波形对比"
                                    font.family: "Microsoft YaHei"
                                    font.pixelSize: workPageWindow.adaptive_height / 55
                                    color: "#666666"
                                    Layout.alignment: Qt.AlignHCenter
                                }
                            }
                        }

                        // 获取Vi1与Vo2波形按钮
                        Button {
                            id: getVi1Vo2Button
                            text: workPageWindow.isGettingDualChannelData && workPageWindow.currentWaveformTarget === "vi1vo2" ? 
                                  "获取中..." : "获取Vi1与Vo2波形"
                            width: parent.width * 0.6
                            height: workPageWindow.adaptive_height / 20
                            anchors.horizontalCenter: parent.horizontalCenter
                            enabled: scpiHandler.connected && !workPageWindow.isGettingDualChannelData
                            font.family: "Microsoft YaHei"
                            font.pixelSize: workPageWindow.adaptive_height / 40

                            property int currentCommandIndex: 0
                            property var ch1CommandList: [
                                ":STOP",
                                ":WAV:SOUR CHAN1",
                                ":WAV:MODE NORM",
                                ":WAV:FORM ASCii",
                                ":WAV:POIN NORM",
                                ":WAV:DATA?"
                            ]
                            property var ch2CommandList: [
                                ":WAV:SOUR CHAN2",
                                ":WAV:MODE NORM",
                                ":WAV:FORM ASCii",
                                ":WAV:POIN NORM",
                                ":WAV:DATA?"
                            ]

                            function sendNextCommandInSequence() {
                                if (workPageWindow.currentDualChannelStep === "ch1") {
                                    if (currentCommandIndex < ch1CommandList.length) {
                                        var cmd = ch1CommandList[currentCommandIndex];
                                        console.log("WorkPage: Vi1Vo2 CH1 - Sending command:", cmd);
                                        scpiHandler.sendCommand(cmd);

                                        if (cmd === ":WAV:DATA?") {
                                            workPageWindow.expectingWaveformData = true;
                                            dataFinalizationTimer.stop();
                                        }

                                        currentCommandIndex++;
                                        if (currentCommandIndex < ch1CommandList.length) {
                                            vi1vo2CommandTimer.start();
                                        } else {
                                            if (ch1CommandList[currentCommandIndex-1] === ":WAV:DATA?") {
                                                dataFinalizationTimer.start();
                                            }
                                        }
                                    }
                                } else if (workPageWindow.currentDualChannelStep === "ch2") {
                                    if (currentCommandIndex < ch2CommandList.length) {
                                        var cmd = ch2CommandList[currentCommandIndex];
                                        console.log("WorkPage: Vi1Vo2 CH2 - Sending command:", cmd);
                                        scpiHandler.sendCommand(cmd);

                                        if (cmd === ":WAV:DATA?") {
                                            workPageWindow.expectingWaveformData = true;
                                            dataFinalizationTimer.stop();
                                        }

                                        currentCommandIndex++;
                                        if (currentCommandIndex < ch2CommandList.length) {
                                            vi1vo2CommandTimer.start();
                                        } else {
                                            if (ch2CommandList[currentCommandIndex-1] === ":WAV:DATA?") {
                                                dataFinalizationTimer.start();
                                            }
                                        }
                                    }
                                }
                            }

                            background: Rectangle {
                                color: parent.pressed ? "#a0a0a0" : "#d0d0d0"
                                radius: 5
                                border.color: "#808080"
                                border.width: 1
                            }
                            contentItem: Text {
                                text: getVi1Vo2Button.text
                                color: "black"
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                                font: getVi1Vo2Button.font
                            }
                            onClicked: {
                                vi1vo2Plotter.clearPlotData();
                                workPageWindow.expectingWaveformData = false;
                                workPageWindow.isGettingDualChannelData = true;
                                workPageWindow.currentWaveformTarget = "vi1vo2";
                                workPageWindow.currentDualChannelStep = "ch1";
                                currentCommandIndex = 0;
                                sendNextCommandInSequence();
                            }
                        }

                        // Vi1与Vo2波形图片显示区域
                        Rectangle {
                            id: vi1vo2DisplayArea
                            width: parent.width * 0.8
                            height: 450
                            anchors.horizontalCenter: parent.horizontalCenter
                            color: "#f8f8f8"
                            border.color: "#cccccc"
                            border.width: 1
                            radius: 8

                            ColumnLayout {
                                anchors.fill: parent
                                anchors.margins: 15
                                spacing: 10

                                Text {
                                    text: "Vi1与Vo2波形显示"
                                    font.family: "Microsoft YaHei"
                                    font.pixelSize: workPageWindow.adaptive_height / 45
                                    font.bold: true
                                    color: "#555555"
                                    Layout.alignment: Qt.AlignHCenter
                                }

                                Image {
                                    id: vi1vo2WaveformImage
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    source: vi1vo2Plotter.plotImageUrl.toString() ? vi1vo2Plotter.plotImageUrl.toString() + "?timestamp=" + new Date().getTime() : ""
                                    fillMode: Image.PreserveAspectFit
                                    smooth: true

                                    Rectangle {
                                        anchors.centerIn: parent
                                        width: parent.width * 0.8
                                        height: parent.height * 0.6
                                        color: "#ecf0f1"
                                        border.color: "#bdc3c7"
                                        border.width: 1
                                        radius: 5
                                        visible: !parent.source.toString()

                                        Text {
                                            anchors.centerIn: parent
                                            text: "点击上方按钮获取Vi1与Vo2波形"
                                            font.family: "Microsoft YaHei"
                                            font.pixelSize: workPageWindow.adaptive_height / 55
                                            color: "#7f8c8d"
                                            horizontalAlignment: Text.AlignHCenter
                                        }
                                    }
                                }

                                Text {
                                    text: "图4: Vi1与Vo2波形对比"
                                    font.family: "Microsoft YaHei"
                                    font.pixelSize: workPageWindow.adaptive_height / 55
                                    color: "#666666"
                                    Layout.alignment: Qt.AlignHCenter
                                }
                            }
                        }

                        // 命令序列定时器
                        Timer {
                            id: vi1vo1CommandTimer
                            interval: 10
                            repeat: false
                            onTriggered: {
                                getVi1Vo1Button.sendNextCommandInSequence();
                            }
                        }

                        Timer {
                            id: vi1vo2CommandTimer
                            interval: 10
                            repeat: false
                            onTriggered: {
                                getVi1Vo2Button.sendNextCommandInSequence();
                            }
                        }
                    }
                }

                // 4、运算放大电路供电
                GroupBox {
                    title: "4、运算放大电路供电"
                    Layout.fillWidth: true
                    font.family: "Microsoft YaHei"
                    
                    Column {
                        spacing: 10
                        width: parent.width
                        
                        Text {
                            text: "图3芯片是双电源(±5v)供电，千万不可接错！芯片的4号管脚接实验箱'正直流稳压电源'（2号框，其中开关要打开）单元中+5v洞，11号管脚接实验箱'负直流稳压电源'（11号框，其中开关要打开）单元中-5v洞。芯片全程均需电源供电，因此在实验结束前4和11管脚应全程均应按前述方法连接，切不可中途将这两根线拔出，导致芯片无电源支持，而不能正常工作。"
                            width: parent.width
                            wrapMode: Text.WordWrap
                            font.family: "Microsoft YaHei"
                            color: "#333333"
                        }
                    }
                }

                // 5. 运算放大器反向比例电路
                GroupBox {
                    title: "5、运算放大器反向比例电路（5分）"
                    Layout.fillWidth: true
                    font.family: "Microsoft YaHei"
                    Column {
                        spacing: 10
                        width: parent.width

                        Text {
                            text: "5.1 按照图4先安装反向比例运算电路（确保导线是好的）"
                            width: parent.width
                            wrapMode: Text.WordWrap
                            font.family: "Microsoft YaHei"
                            color: "#333333"
                        }

                        Text {
                            text: "5.2 完成VA=1.2v，VB=0.6v信号输入"
                            width: parent.width
                            wrapMode: Text.WordWrap
                            font.family: "Microsoft YaHei"
                            color: "#333333"
                        }

                        // 档位选择
                        GroupBox {
                            title: "5.3 用万用表的档位选择"
                            width: parent.width
                            font.family: "Microsoft YaHei"
                            Column {
                                spacing: 5
                                width: parent.width

                                Text {
                                    text: "请选择测量VA、VB信号时使用的万用表档位："
                                    width: parent.width
                                    wrapMode: Text.WordWrap
                                    font.family: "Microsoft YaHei"
                                    color: "#333333"
                                }

                                ComboBox {
                                    id: meterRangeCombo
                                    model: ["A、电压档", "B、电流档", "C、电阻档", "D、蜂鸣档"]
                                    width: parent.width
                                    font.family: "Microsoft YaHei" // For the displayed current item text
                                    // color: "#333333" // Optional: for the ComboBox main text when closed

                                    // Delegate for customizing items in the dropdown popup
                                    delegate: ItemDelegate {
                                        width: ListView.view.width // Makes the delegate fill the width of the ListView
                                        text: modelData // The text for the item, from the model
                                        font.family: "Microsoft YaHei" // Apply YaHei font to each dropdown item
                                        highlighted: ListView.isCurrentItem // Standard highlighting for current item
                                        hoverEnabled: true // Optional: visual feedback on hover
                                        
                                        // Optional: Custom background colors for different states
                                        // background: Rectangle {
                                        //     color: highlighted ? "#e0e0e0" : (hovered ? "#f0f0f0" : "transparent")
                                        // }

                                        onClicked: {
                                            // When an item in the dropdown is clicked:
                                            // 1. Set the ComboBox's currentIndex to the clicked item's index.
                                            // 2. The ComboBox will automatically close its popup.
                                            meterRangeCombo.currentIndex = index;
                                            // ComboBox handles closing its own popup, no need for meterRangeCombo.popup.close()
                                        }
                                    }
                                    // Remove the custom popup: Popup { ... } block if it exists from previous attempts
                                }
                            }
                        }

                        // 表5：反向比例运算电路
                        GroupBox {
                            title: "表5 反向比例运算电路"
                            width: parent.width
                            font.family: "Microsoft YaHei"
                            Grid {
                                columns: 3
                                spacing: 5
                                verticalItemAlignment: Grid.AlignVCenter

                                // 表头
                                Text { text: "Vi"; font.bold: true; font.family: "Microsoft YaHei"; color: "#333333" }
                                Text { text: "Vo(v)"; font.bold: true; font.family: "Microsoft YaHei"; color: "#333333" }
                                Text { text: "运放序号"; font.bold: true; font.family: "Microsoft YaHei"; color: "#333333" }

                                // 数据行
                                Text { text: "VA=1.2v VB=0.6v"; font.family: "Microsoft YaHei"; color: "#333333" }
                                TextField { id: table5vi1Field; placeholderText: "输入Vo值"; font.family: "Microsoft YaHei"; color: "#333333" /*Text color for input*/ }
                                TextField { id: table5vo1Field; placeholderText: "输入运放序号"; font.family: "Microsoft YaHei"; color: "#333333" }

                                Text { text: "VA=1.2v VB=0.6v"; font.family: "Microsoft YaHei"; color: "#333333" }
                                TextField { id: table5vi2Field; placeholderText: "输入Vo值"; font.family: "Microsoft YaHei"; color: "#333333" }
                                TextField { id: table5vo2Field; placeholderText: "输入运放序号"; font.family: "Microsoft YaHei"; color: "#333333" }
                            }
                        }
                    }
                }

                // 6. 运算放大器三角波发生器
                GroupBox {
                    title: "6、运算放大器三角波发生器（5分）"
                    Layout.fillWidth: true
                    font.family: "Microsoft YaHei"
                    
                    Column {
                        spacing: 10
                        width: parent.width

                        Text {
                            text: "6.1 按照图5安装三角波发生器（确保实验中用到的两个运算单元能够正常工作，见5.4）\n6.2用示波器分别观察Vo1与Vo2的波形。"
                            width: parent.width
                            wrapMode: Text.WordWrap
                            font.family: "Microsoft YaHei"
                            color: "#333333"
                        }

                        // 获取Vo1与Vo2波形按钮
                        Button {
                            id: getVo1Vo2Button
                            text: workPageWindow.isGettingDualChannelData && workPageWindow.currentWaveformTarget === "vo1vo2" ? 
                                  "获取中..." : "获取Vo1与Vo2波形"
                            width: parent.width * 0.6
                            height: workPageWindow.adaptive_height / 20
                            anchors.horizontalCenter: parent.horizontalCenter
                            enabled: scpiHandler.connected && !workPageWindow.isGettingDualChannelData
                            font.family: "Microsoft YaHei"
                            font.pixelSize: workPageWindow.adaptive_height / 40

                            property int currentCommandIndex: 0
                            property var ch1CommandList: [
                                ":STOP",
                                ":WAV:SOUR CHAN1",
                                ":WAV:MODE NORM",
                                ":WAV:FORM ASCii",
                                ":WAV:POIN NORM",
                                ":WAV:DATA?"
                            ]
                            property var ch2CommandList: [
                                ":WAV:SOUR CHAN2",
                                ":WAV:MODE NORM",
                                ":WAV:FORM ASCii",
                                ":WAV:POIN NORM",
                                ":WAV:DATA?"
                            ]

                            function sendNextCommandInSequence() {
                                if (workPageWindow.currentDualChannelStep === "ch1") {
                                    if (currentCommandIndex < ch1CommandList.length) {
                                        var cmd = ch1CommandList[currentCommandIndex];
                                        console.log("WorkPage: Vo1Vo2 CH1 - Sending command:", cmd);
                                        scpiHandler.sendCommand(cmd);

                                        if (cmd === ":WAV:DATA?") {
                                            workPageWindow.expectingWaveformData = true;
                                            dataFinalizationTimer.stop();
                                        }

                                        currentCommandIndex++;
                                        if (currentCommandIndex < ch1CommandList.length) {
                                            vo1vo2CommandTimer.start();
                                        } else {
                                            if (ch1CommandList[currentCommandIndex-1] === ":WAV:DATA?") {
                                                dataFinalizationTimer.start();
                                            }
                                        }
                                    }
                                } else if (workPageWindow.currentDualChannelStep === "ch2") {
                                    if (currentCommandIndex < ch2CommandList.length) {
                                        var cmd = ch2CommandList[currentCommandIndex];
                                        console.log("WorkPage: Vo1Vo2 CH2 - Sending command:", cmd);
                                        scpiHandler.sendCommand(cmd);

                                        if (cmd === ":WAV:DATA?") {
                                            workPageWindow.expectingWaveformData = true;
                                            dataFinalizationTimer.stop();
                                        }

                                        currentCommandIndex++;
                                        if (currentCommandIndex < ch2CommandList.length) {
                                            vo1vo2CommandTimer.start();
                                        } else {
                                            if (ch2CommandList[currentCommandIndex-1] === ":WAV:DATA?") {
                                                dataFinalizationTimer.start();
                                            }
                                        }
                                    }
                                }
                            }

                            background: Rectangle {
                                color: parent.pressed ? "#a0a0a0" : "#d0d0d0"
                                radius: 5
                                border.color: "#808080"
                                border.width: 1
                            }
                            contentItem: Text {
                                text: getVo1Vo2Button.text
                                color: "black"
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                                font: getVo1Vo2Button.font
                            }
                            onClicked: {
                                vo1vo2Plotter.clearPlotData();
                                workPageWindow.expectingWaveformData = false;
                                workPageWindow.isGettingDualChannelData = true;
                                workPageWindow.currentWaveformTarget = "vo1vo2";
                                workPageWindow.currentDualChannelStep = "ch1";
                                currentCommandIndex = 0;
                                sendNextCommandInSequence();
                            }
                        }

                        // Vo1与Vo2波形图片显示区域
                        Rectangle {
                            id: vo1vo2DisplayArea
                            width: parent.width * 0.8
                            height: 450
                            anchors.horizontalCenter: parent.horizontalCenter
                            color: "#f8f8f8"
                            border.color: "#cccccc"
                            border.width: 1
                            radius: 8

                            ColumnLayout {
                                anchors.fill: parent
                                anchors.margins: 15
                                spacing: 10

                                Text {
                                    text: "Vo1与Vo2波形显示"
                                    font.family: "Microsoft YaHei"
                                    font.pixelSize: workPageWindow.adaptive_height / 45
                                    font.bold: true
                                    color: "#555555"
                                    Layout.alignment: Qt.AlignHCenter
                                }

                                Image {
                                    id: vo1vo2WaveformImage
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    source: vo1vo2Plotter.plotImageUrl.toString() ? vo1vo2Plotter.plotImageUrl.toString() + "?timestamp=" + new Date().getTime() : ""
                                    fillMode: Image.PreserveAspectFit
                                    smooth: true

                                    Rectangle {
                                        anchors.centerIn: parent
                                        width: parent.width * 0.8
                                        height: parent.height * 0.6
                                        color: "#ecf0f1"
                                        border.color: "#bdc3c7"
                                        border.width: 1
                                        radius: 5
                                        visible: !parent.source.toString()

                                        Text {
                                            anchors.centerIn: parent
                                            text: "点击上方按钮获取Vo1与Vo2波形"
                                            font.family: "Microsoft YaHei"
                                            font.pixelSize: workPageWindow.adaptive_height / 55
                                            color: "#7f8c8d"
                                            horizontalAlignment: Text.AlignHCenter
                                        }
                                    }
                                }

                                Text {
                                    text: "图5: Vo1与Vo2三角波形对比"
                                    font.family: "Microsoft YaHei"
                                    font.pixelSize: workPageWindow.adaptive_height / 55
                                    color: "#666666"
                                    Layout.alignment: Qt.AlignHCenter
                                }
                            }
                        }

                        // Vo1Vo2命令序列定时器
                        Timer {
                            id: vo1vo2CommandTimer
                            interval: 10
                            repeat: false
                            onTriggered: {
                                getVo1Vo2Button.sendNextCommandInSequence();
                            }
                        }
                    }
                }
            }
        }

        // +++ NEW BUTTON BAR +++
        Rectangle {
            id: clearDataBar
            width: mainRectangle.width - (scrollArea.anchors.leftMargin + scrollArea.anchors.rightMargin) // Match scrollArea width
            height: Math.max(adaptive_height / 20, 55) // Sensible height for the bar
            color: "#f0f0f0" // Light gray, similar to titleBar
            anchors.bottom: mainRectangle.bottom
            anchors.bottomMargin: scrollArea.anchors.leftMargin // Use same margin as scrollArea
            anchors.left: mainRectangle.left
            anchors.leftMargin: scrollArea.anchors.leftMargin

            // 提交按钮
            Button {
                id: submitButton
                text: qsTr("提交")
                anchors.left: parent.left
                anchors.leftMargin: 10
                anchors.verticalCenter: parent.verticalCenter
                height: parent.height * 0.70
                enabled: !workPageWindow.expectingWaveformData && !workPageWindow.isGettingDualChannelData

                font.family: "Microsoft YaHei"
                font.pixelSize: Math.min(height * 0.45, workPageWindow.adaptive_width / 65)

                background: Rectangle {
                    color: submitButton.enabled ? (submitButton.pressed ? "#27ae60" : "#2ecc71") : "#95a5a6"
                    radius: 5
                    border.color: submitButton.enabled ? (submitButton.pressed ? "#229954" : "#27ae60") : "#7f8c8d"
                    border.width: 1
                    anchors.fill: parent
                }
                contentItem: Text {
                    text: submitButton.text
                    color: submitButton.enabled ? "white" : "#333333"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    font: submitButton.font
                }

                onClicked: {
                    confirmDialog.open();
                }
            }

            Button {
                id: clearAllButton
                text: qsTr("清空数据")
                anchors.right: parent.right
                anchors.rightMargin: 10 // Margin within the bar
                anchors.verticalCenter: parent.verticalCenter
                height: parent.height * 0.70 // Adjust button height within the bar

                font.family: "Microsoft YaHei"
                font.pixelSize: Math.min(height * 0.45, workPageWindow.adaptive_width / 65)

                background: Rectangle {
                    color: clearAllButton.pressed ? "#c0392b" : "#e74c3c" // Reddish theme for action
                    radius: 5
                    border.color: clearAllButton.pressed ? "#a93226" : "#c0392b"
                    border.width: 1
                    anchors.fill: parent
                }
                contentItem: Text {
                    id: clearAllButtonText
                    text: clearAllButton.text
                    color: "white"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    font: clearAllButton.font
                }

                onClicked: {
                    workPageWindow.clearAllData();
                }
            }
        }
        // +++ END OF NEW BUTTON BAR +++
        
        // +++ 侧拉栏 +++
        Rectangle {
            id: sidebar
            width: workPageWindow.sidebarWidth
            height: parent.height - titleBar.height - statusBar.height
            anchors.top: statusBar.bottom
            anchors.right: parent.right
            anchors.rightMargin: workPageWindow.sidebarVisible ? 0 : -workPageWindow.sidebarWidth
            color: "#f8f8f8"
            border.color: "#dddddd"
            border.width: 1
            z: 15

            Behavior on anchors.rightMargin {
                NumberAnimation {
                    duration: 300
                    easing.type: Easing.OutCubic
                }
            }

            Column {
                anchors.fill: parent
                anchors.margins: 15
                spacing: 15

                // 侧拉栏标题
                Text {
                    text: qsTr("实验电路图")
                    font.family: "Microsoft YaHei"
                    font.pixelSize: 18
                    font.bold: true
                    color: "#333333"
                    width: parent.width
                    horizontalAlignment: Text.AlignHCenter
                }

                // 分割线
                Rectangle {
                    width: parent.width
                    height: 1
                    color: "#dddddd"
                }

                // 滚动区域放置图片
                ScrollView {
                    id: sidebarScrollArea
                    width: parent.width
                    height: parent.height - 60
                    clip: true
                    ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
                    ScrollBar.vertical.policy: ScrollBar.AsNeeded

                    Column {
                        width: sidebarScrollArea.availableWidth
                        spacing: 20

                        // 图1 负反馈电路
                        Rectangle {
                            width: parent.width
                            height: 320
                            color: "#ffffff"
                            border.color: "#cccccc"
                            border.width: 1
                            radius: 5

                            Column {
                                anchors.fill: parent
                                anchors.margins: 10
                                spacing: 8

                                Text {
                                    text: "图1 负反馈电路"
                                    font.family: "Microsoft YaHei"
                                    font.pixelSize: 14
                                    font.bold: true
                                    color: "#333333"
                                    width: parent.width
                                    horizontalAlignment: Text.AlignHCenter
                                }

                                Image {
                                    width: parent.width - 10
                                    height: parent.height - 30
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    source: "images/exp1/p1.png"
                                    fillMode: Image.PreserveAspectFit
                                    smooth: true

                                    Rectangle {
                                        anchors.fill: parent
                                        color: "#f0f0f0"
                                        visible: parent.status === Image.Error
                                        
                                        Text {
                                            anchors.centerIn: parent
                                            text: "图片加载失败"
                                            font.family: "Microsoft YaHei"
                                            font.pixelSize: 12
                                            color: "#999999"
                                        }
                                    }
                                }
                            }
                        }

                        // 图2 差分放大电路
                        Rectangle {
                            width: parent.width
                            height: 320
                            color: "#ffffff"
                            border.color: "#cccccc"
                            border.width: 1
                            radius: 5

                            Column {
                                anchors.fill: parent
                                anchors.margins: 10
                                spacing: 8

                                Text {
                                    text: "图2 差分放大电路"
                                    font.family: "Microsoft YaHei"
                                    font.pixelSize: 14
                                    font.bold: true
                                    color: "#333333"
                                    width: parent.width
                                    horizontalAlignment: Text.AlignHCenter
                                }

                                Image {
                                    width: parent.width - 10
                                    height: parent.height - 30
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    source: "images/exp1/p2.png"
                                    fillMode: Image.PreserveAspectFit
                                    smooth: true

                                    Rectangle {
                                        anchors.fill: parent
                                        color: "#f0f0f0"
                                        visible: parent.status === Image.Error
                                        
                                        Text {
                                            anchors.centerIn: parent
                                            text: "图片加载失败"
                                            font.family: "Microsoft YaHei"
                                            font.pixelSize: 12
                                            color: "#999999"
                                        }
                                    }
                                }
                            }
                        }

                        // 图3 LM324管脚图
                        Rectangle {
                            width: parent.width
                            height: 200
                            color: "#ffffff"
                            border.color: "#cccccc"
                            border.width: 1
                            radius: 5

                            Column {
                                anchors.fill: parent
                                anchors.margins: 10
                                spacing: 8

                                Text {
                                    text: "图3 LM324管脚图"
                                    font.family: "Microsoft YaHei"
                                    font.pixelSize: 14
                                    font.bold: true
                                    color: "#333333"
                                    width: parent.width
                                    horizontalAlignment: Text.AlignHCenter
                                }

                                Image {
                                    width: parent.width - 20
                                    height: parent.height - 40
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    source: "images/exp1/p3.png"
                                    fillMode: Image.PreserveAspectFit
                                    smooth: true

                                    Rectangle {
                                        anchors.fill: parent
                                        color: "#f0f0f0"
                                        visible: parent.status === Image.Error
                                        
                                        Text {
                                            anchors.centerIn: parent
                                            text: "图片加载失败"
                                            font.family: "Microsoft YaHei"
                                            font.pixelSize: 12
                                            color: "#999999"
                                        }
                                    }
                                }
                            }
                        }

                        // 图4 反向比例运算电路
                        Rectangle {
                            width: parent.width
                            height: 200
                            color: "#ffffff"
                            border.color: "#cccccc"
                            border.width: 1
                            radius: 5

                            Column {
                                anchors.fill: parent
                                anchors.margins: 10
                                spacing: 8

                                Text {
                                    text: "图4 反向比例运算电路"
                                    font.family: "Microsoft YaHei"
                                    font.pixelSize: 14
                                    font.bold: true
                                    color: "#333333"
                                    width: parent.width
                                    horizontalAlignment: Text.AlignHCenter
                                }

                                Image {
                                    width: parent.width - 20
                                    height: parent.height - 40
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    source: "images/exp1/p4.png"
                                    fillMode: Image.PreserveAspectFit
                                    smooth: true

                                    Rectangle {
                                        anchors.fill: parent
                                        color: "#f0f0f0"
                                        visible: parent.status === Image.Error
                                        
                                        Text {
                                            anchors.centerIn: parent
                                            text: "图片加载失败"
                                            font.family: "Microsoft YaHei"
                                            font.pixelSize: 12
                                            color: "#999999"
                                        }
                                    }
                                }
                            }
                        }

                        // 图5 三角波发生器
                        Rectangle {
                            width: parent.width
                            height: 200
                            color: "#ffffff"
                            border.color: "#cccccc"
                            border.width: 1
                            radius: 5

                            Column {
                                anchors.fill: parent
                                anchors.margins: 10
                                spacing: 8

                                Text {
                                    text: "图5 三角波发生器"
                                    font.family: "Microsoft YaHei"
                                    font.pixelSize: 14
                                    font.bold: true
                                    color: "#333333"
                                    width: parent.width
                                    horizontalAlignment: Text.AlignHCenter
                                }

                                Image {
                                    width: parent.width - 20
                                    height: parent.height - 40
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    source: "images/exp1/p5.png"
                                    fillMode: Image.PreserveAspectFit
                                    smooth: true

                                    Rectangle {
                                        anchors.fill: parent
                                        color: "#f0f0f0"
                                        visible: parent.status === Image.Error
                                        
                                        Text {
                                            anchors.centerIn: parent
                                            text: "图片加载失败"
                                            font.family: "Microsoft YaHei"
                                            font.pixelSize: 12
                                            color: "#999999"
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        // 侧拉栏控制按钮
        Rectangle {
            id: sidebarToggleButton
            width: 40
            height: 60
            anchors.right: parent.right
            anchors.rightMargin: workPageWindow.sidebarVisible ? workPageWindow.sidebarWidth : 10
            anchors.verticalCenter: parent.verticalCenter
            color: "#3498db"
            radius: 5
            z: 16

            Behavior on anchors.rightMargin {
                NumberAnimation {
                    duration: 300
                    easing.type: Easing.OutCubic
                }
            }

            Text {
                anchors.centerIn: parent
                text: workPageWindow.sidebarVisible ? "‹" : "›"
                font.pixelSize: 24
                color: "white"
                font.bold: true
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    workPageWindow.sidebarVisible = !workPageWindow.sidebarVisible;
                }
            }

            // 添加阴影效果
            Rectangle {
                anchors.fill: parent
                color: "transparent"
                border.color: "#2980b9"
                border.width: 1
                radius: parent.radius
            }
        }
        // +++ END OF 侧拉栏 +++
    }

    // +++ STUDENT CODE INPUT DIALOG +++
    Dialog {
        id: studentCodeDialog
        title: qsTr("学号验证")
        anchors.centerIn: parent
        width: Math.min(parent.width * 0.6, 300)
        height: Math.min(parent.height * 0.3, 180)
        modal: true
        closePolicy: Popup.NoAutoClose // 禁止自动关闭
        
        background: Rectangle {
            color: "white"
            radius: 8
            border.color: "#cccccc"
            border.width: 1
        }

        contentItem: Rectangle {
            color: "transparent"
            
            Column {
                anchors.centerIn: parent
                spacing: 20
                width: parent.width * 0.9

                Text {
                    text: qsTr("请输入学号")
                    font.family: "Microsoft YaHei"
                    font.pixelSize: 16
                    color: "#333333"
                    horizontalAlignment: Text.AlignHCenter
                    width: parent.width
                }

                TextField {
                    id: studentCodeInput
                    placeholderText: qsTr("请输入学号")
                    font.family: "Microsoft YaHei"
                    font.pixelSize: 14
                    width: parent.width
                    selectByMouse: true
                    
                    background: Rectangle {
                        color: "white"
                        border.color: studentCodeInput.focus ? "#3498db" : "#bdc3c7"
                        border.width: 2
                        radius: 4
                    }
                    
                    onAccepted: {
                        // 回车键触发验证
                        verifyStudentCode();
                    }
                }

                Row {
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: 15

                    Button {
                        text: qsTr("确认")
                        width: 80
                        height: 35
                        font.family: "Microsoft YaHei"
                        enabled: studentCodeInput.text.trim() !== ""

                        background: Rectangle {
                            color: parent.pressed ? "#27ae60" : "#2ecc71"
                            radius: 5
                            border.color: parent.pressed ? "#229954" : "#27ae60"
                            border.width: 1
                        }
                        contentItem: Text {
                            text: parent.text
                            color: "white"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            font: parent.font
                        }

                        onClicked: {
                            verifyStudentCode();
                        }
                    }

                    Button {
                        text: qsTr("取消")
                        width: 80
                        height: 35
                        font.family: "Microsoft YaHei"

                        background: Rectangle {
                            color: parent.pressed ? "#95a5a6" : "#bdc3c7"
                            radius: 5
                            border.color: parent.pressed ? "#7f8c8d" : "#95a5a6"
                            border.width: 1
                        }
                        contentItem: Text {
                            text: parent.text
                            color: "#333333"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            font: parent.font
                        }

                        onClicked: {
                            // 取消认证，返回上一级页面
                            studentCodeDialog.close();
                            console.log("WorkPage: Authentication cancelled by user");
                            cleanupResources();
                            if (typeof mainloader !== 'undefined') {
                                mainloader.source = "";
                            } else {
                                workPageWindow.destroy();
                            }
                        }
                    }
                }
            }
        }
    }
    // +++ END OF STUDENT CODE INPUT DIALOG +++

    // +++ CONFIRMATION DIALOG +++
    Dialog {
        id: confirmDialog
        title: qsTr("提示")
        anchors.centerIn: parent
        width: Math.min(parent.width * 0.8, 400)
        height: Math.min(parent.height * 0.4, 250)
        modal: true
        
        property string dialogState: "confirm" // 状态：confirm, no_images, uploading, success, device_cleanup, cleanup_complete, auth_failed
        
        background: Rectangle {
            color: "white"
            radius: 8
            border.color: "#cccccc"
            border.width: 1
        }

        contentItem: Rectangle {
            color: "transparent"
            
            Column {
                anchors.centerIn: parent
                spacing: 20
                width: parent.width * 0.9

                // 状态显示文本
                Text {
                    id: dialogStatusText
                    text: {
                        switch(confirmDialog.dialogState) {
                            case "confirm":
                                return qsTr("请仔细检查报告后提交，提交后将无法更改。确认提交吗？");
                            case "no_images":
                                return qsTr("未检测到波形图，请确认正确捕获波形后再进行提交！");
                            case "uploading":
                                return qsTr("提交中……");
                            case "success":
                                return qsTr("提交成功！");
                            case "device_cleanup":
                                return qsTr("请整理实验设备并关闭仪器电源！");
                            case "cleanup_complete":
                                return qsTr("实验完成！请安静离开实验室");
                            case "auth_failed":
                                return qsTr("当前时间不在预约实验时间段内");
                            default:
                                return "";
                        }
                    }
                    font.family: "Microsoft YaHei"
                    font.pixelSize: 14
                    color: (confirmDialog.dialogState === "no_images" || confirmDialog.dialogState === "auth_failed") ? "#e74c3c" : "#333333"
                    wrapMode: Text.WordWrap
                    width: parent.width
                    horizontalAlignment: Text.AlignHCenter
                }

                // 按钮区域
                Row {
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: 20
                    visible: confirmDialog.dialogState !== "uploading" && confirmDialog.dialogState !== "device_cleanup"

                    // 确认按钮（在不同状态下有不同功能）
                    Button {
                        id: confirmSubmitButton
                        text: {
                            switch(confirmDialog.dialogState) {
                                case "confirm":
                                    return qsTr("确认");
                                case "no_images":
                                    return qsTr("知道了");
                                case "success":
                                    return qsTr("确认");
                                case "device_cleanup":
                                    return qsTr("知道了");
                                case "cleanup_complete":
                                    return qsTr("完成");
                                case "auth_failed":
                                    return qsTr("返回");
                                default:
                                    return qsTr("确认");
                            }
                        }
                        width: 80
                        height: 35
                        font.family: "Microsoft YaHei"

                        background: Rectangle {
                            color: {
                                switch(confirmDialog.dialogState) {
                                    case "confirm":
                                    case "success":
                                        return confirmSubmitButton.pressed ? "#27ae60" : "#2ecc71";
                                    case "no_images":
                                    case "auth_failed":
                                        return confirmSubmitButton.pressed ? "#d35400" : "#e67e22";
                                    case "device_cleanup":
                                        return confirmSubmitButton.pressed ? "#d35400" : "#e67e22";
                                    case "cleanup_complete":
                                        return confirmSubmitButton.pressed ? "#27ae60" : "#2ecc71";
                                    default:
                                        return confirmSubmitButton.pressed ? "#27ae60" : "#2ecc71";
                                }
                            }
                            radius: 5
                            border.color: {
                                switch(confirmDialog.dialogState) {
                                    case "confirm":
                                    case "success":
                                        return confirmSubmitButton.pressed ? "#229954" : "#27ae60";
                                    case "no_images":
                                    case "auth_failed":
                                        return confirmSubmitButton.pressed ? "#ba4a00" : "#d35400";
                                    case "device_cleanup":
                                        return confirmSubmitButton.pressed ? "#ba4a00" : "#d35400";
                                    case "cleanup_complete":
                                        return confirmSubmitButton.pressed ? "#229954" : "#27ae60";
                                    default:
                                        return confirmSubmitButton.pressed ? "#229954" : "#27ae60";
                                }
                            }
                            border.width: 1
                        }
                        contentItem: Text {
                            text: confirmSubmitButton.text
                            color: "white"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            font: confirmSubmitButton.font
                        }

                        onClicked: {
                            switch(confirmDialog.dialogState) {
                                case "confirm":
                                    workPageWindow.submitData();
                                    break;
                                case "no_images":
                                    confirmDialog.dialogState = "confirm";
                                    break;
                                case "success":
                                    confirmDialog.close();
                                    confirmDialog.dialogState = "confirm";
                                    workPageWindow.clearAllData();
                                    break;
                                case "device_cleanup":
                                    confirmDialog.dialogState = "cleanup_complete";
                                    break;
                                case "auth_failed":
                                    // 鉴权失败，清理资源并返回上一级
                                    confirmDialog.close();
                                    confirmDialog.dialogState = "confirm";
                                    console.log("WorkPage: Authentication failed, cleaning up resources before exit");
                                    cleanupResources();
                                    console.log("WorkPage: Exiting to previous page due to authentication failure");
                                    // 清空mainloader.source来销毁workpage并返回主菜单
                                    if (typeof mainloader !== 'undefined') {
                                        mainloader.source = "";
                                    } else {
                                        workPageWindow.destroy();
                                    }
                                    break;
                                case "cleanup_complete":
                                    // 清空数据并退出页面
                                    confirmDialog.close();
                                    confirmDialog.dialogState = "confirm";
                                    workPageWindow.clearAllData();
                                    console.log("WorkPage: Experiment completed, cleaning up resources before exit");
                                    cleanupResources();
                                    console.log("WorkPage: Exiting to previous page after experiment completion");
                                    // 清空mainloader.source来销毁workpage并返回主菜单
                                    if (typeof mainloader !== 'undefined') {
                                        mainloader.source = "";
                                    } else {
                                        workPageWindow.destroy();
                                    }
                                    break;
                            }
                        }
                    }

                    // 取消按钮（只在确认和无图片状态显示，鉴权失败时不显示）
                    Button {
                        id: cancelSubmitButton
                        text: qsTr("取消")
                        width: 80
                        height: 35
                        font.family: "Microsoft YaHei"
                        visible: confirmDialog.dialogState === "confirm" || confirmDialog.dialogState === "no_images"

                        background: Rectangle {
                            color: cancelSubmitButton.pressed ? "#95a5a6" : "#bdc3c7"
                            radius: 5
                            border.color: cancelSubmitButton.pressed ? "#7f8c8d" : "#95a5a6"
                            border.width: 1
                        }
                        contentItem: Text {
                            text: cancelSubmitButton.text
                            color: "#333333"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            font: cancelSubmitButton.font
                        }

                        onClicked: {
                            confirmDialog.close();
                            confirmDialog.dialogState = "confirm";
                        }
                    }
                }

                // 加载动画（仅在上传时显示）
                BusyIndicator {
                    anchors.horizontalCenter: parent.horizontalCenter
                    visible: confirmDialog.dialogState === "uploading"
                    running: confirmDialog.dialogState === "uploading"
                }
            }
        }
    }
    // +++ END OF CONFIRMATION DIALOG +++

    // +++ HTTP UPLOADER +++
    HttpUploader {
        id: httpUploader

        onUploadProgress: {
            console.log("WorkPage: Upload progress:", bytesSent, "/", bytesTotal);
        }

        onUploadFinished: {
            console.log("WorkPage: Upload finished successfully:", replyData);
            
            // 继续上传下一个文件
            workPageWindow.currentUploadIndex++;
            if (workPageWindow.currentUploadIndex < workPageWindow.pendingUploads.length) {
                // 添加小延迟避免服务器压力
                uploadDelayTimer.start();
            } else {
                console.log("WorkPage: All uploads completed successfully!");
                // 所有文件上传完成，检查示波器状态
                if (scpiHandler.connected) {
                    // 示波器仍在线，进入设备整理模式
                    confirmDialog.dialogState = "device_cleanup";
                } else {
                    // 示波器已断开，直接显示成功状态
                    confirmDialog.dialogState = "cleanup_complete";
                }
            }
        }

        onUploadError: {
            console.log("WorkPage: Upload error:", errorString);
            
            // 即使出错也继续上传下一个文件
            workPageWindow.currentUploadIndex++;
            if (workPageWindow.currentUploadIndex < workPageWindow.pendingUploads.length) {
                uploadDelayTimer.start();
            } else {
                console.log("WorkPage: Upload sequence completed with some errors.");
                // 即使有错误也检查示波器状态
                if (scpiHandler.connected) {
                    confirmDialog.dialogState = "device_cleanup";
                } else {
                    confirmDialog.dialogState = "cleanup_complete";
                }
            }
        }

        onTextUploadFinished: {
            console.log("WorkPage: Text upload finished successfully:", replyData);
        }

        onTextUploadError: {
            console.log("WorkPage: Text upload error:", errorString);
        }

        // 鉴权相关信号处理
        onAppointmentCheckFinished: {
            console.log("WorkPage: Appointment check finished successfully:", replyData);
            handleAuthResponse(replyData);
        }

        onAppointmentCheckError: {
            console.log("WorkPage: Appointment check error:", errorString);
            workPageWindow.isAuthenticating = false;
            workPageWindow.isAuthenticated = false;
            confirmDialog.dialogState = "auth_failed";
            confirmDialog.open();
        }

        // 学生预约验证信号处理
        onStudentAppointmentCheckFinished: {
            console.log("WorkPage: Student appointment check finished successfully:", replyData);
            handleStudentAuthResponse(replyData);
        }

        onStudentAppointmentCheckError: {
            console.log("WorkPage: Student appointment check error:", errorString);
            workPageWindow.isAuthenticating = false;
            workPageWindow.isAuthenticated = false;
            confirmDialog.dialogState = "auth_failed";
            confirmDialog.open();
        }
    }
    // +++ END OF HTTP UPLOADER +++

    // 上传延迟定时器
    Timer {
        id: uploadDelayTimer
        interval: 500 // 500ms延迟
        repeat: false
        onTriggered: {
            uploadNextFile();
        }
    }

    // SCPI 客户端逻辑
    ScpiClient {
        id: scpiHandler

        onConnectionStatusChanged: {
            console.log("WorkPage: Connection status changed to:", connected);
            
            if (connected) {
                // 连接成功，启动心跳检测，停止重连定时器
                workPageWindow.heartbeatFailureCount = 0;
                heartbeatTimer.start();
                reconnectTimer.stop(); // 停止重连定时器
                console.log("WorkPage: Started heartbeat monitoring, stopped reconnect timer");
            } else {
                // 连接断开，停止心跳检测，启动重连定时器
                heartbeatTimer.stop();
                heartbeatTimeoutTimer.stop();
                workPageWindow.isHeartbeatActive = false;
                workPageWindow.heartbeatFailureCount = 0;
                
                // 启动重连定时器
                if (!reconnectTimer.running) {
                    reconnectTimer.start();
                    console.log("WorkPage: Started reconnect timer");
                }
                console.log("WorkPage: Stopped heartbeat monitoring");
            }
        }

        onDataReceived: {
            console.log("WorkPage: Received data from oscilloscope:", data);
            
            // 检查是否是心跳响应
            if (workPageWindow.isHeartbeatActive) {
                // 收到任何数据都认为心跳成功
                heartbeatTimeoutTimer.stop();
                workPageWindow.isHeartbeatActive = false;
                workPageWindow.heartbeatFailureCount = 0;
                console.log("WorkPage: Heartbeat successful, connection is alive");
                
                // 如果收到的是设备识别信息，不进行波形数据处理
                if (data.includes("RIGOL") || data.includes("Tektronix") || data.includes("Keysight") || data.includes("SIGLENT")) {
                    console.log("WorkPage: Received device identification:", data.trim());
                    return; // 直接返回，不处理为波形数据
                }
            }
            
            if (workPageWindow.expectingWaveformData) {
                // 根据当前目标将数据发送到对应的WaveformPlotter
                if (workPageWindow.currentWaveformTarget === "ch1") {
                    waveformPlotter.accumulateData(data);
                } else if (workPageWindow.currentWaveformTarget === "vi1vo1") {
                    if (workPageWindow.isGettingDualChannelData) {
                        if (workPageWindow.currentDualChannelStep === "ch1") {
                            vi1vo1Plotter.accumulateDataCH1(data);
                        } else if (workPageWindow.currentDualChannelStep === "ch2") {
                            vi1vo1Plotter.accumulateDataCH2(data);
                        }
                    } else {
                        vi1vo1Plotter.accumulateData(data);
                    }
                } else if (workPageWindow.currentWaveformTarget === "vi1vo2") {
                    if (workPageWindow.isGettingDualChannelData) {
                        if (workPageWindow.currentDualChannelStep === "ch1") {
                            vi1vo2Plotter.accumulateDataCH1(data);
                        } else if (workPageWindow.currentDualChannelStep === "ch2") {
                            vi1vo2Plotter.accumulateDataCH2(data);
                        }
                    } else {
                        vi1vo2Plotter.accumulateData(data);
                    }
                } else if (workPageWindow.currentWaveformTarget === "vo1vo2") {
                    if (workPageWindow.isGettingDualChannelData) {
                        if (workPageWindow.currentDualChannelStep === "ch1") {
                            vo1vo2Plotter.accumulateDataCH1(data);
                        } else if (workPageWindow.currentDualChannelStep === "ch2") {
                            vo1vo2Plotter.accumulateDataCH2(data);
                        }
                    } else {
                        vo1vo2Plotter.accumulateData(data);
                    }
                }
                dataFinalizationTimer.restart();
                console.log("WorkPage: Accumulated waveform data chunk for target:", workPageWindow.currentWaveformTarget, "step:", workPageWindow.currentDualChannelStep);
            }
        }

        onErrorOccurred: {
            console.log("WorkPage: SCPI Error occurred:", errorString);
            
            // 错误发生时，停止心跳检测
            if (workPageWindow.isHeartbeatActive) {
                heartbeatTimeoutTimer.stop();
                workPageWindow.isHeartbeatActive = false;
                workPageWindow.heartbeatFailureCount++;
                
                if (workPageWindow.heartbeatFailureCount >= workPageWindow.maxHeartbeatFailures) {
                    console.log("WorkPage: Multiple errors detected, handling connection loss");
                    handleConnectionLost();
                }
            }
        }
    }

    // 信号发生器 SCPI 客户端
    ScpiClient {
        id: sigGenHandler

        onConnectionStatusChanged: {
            console.log("WorkPage: Signal generator connection status changed to:", connected);
            
            if (connected) {
                // 连接成功，启动心跳检测，停止重连定时器
                workPageWindow.sigGenHeartbeatFailureCount = 0;
                sigGenHeartbeatTimer.start();
                sigGenReconnectTimer.stop(); // 停止重连定时器
                console.log("WorkPage: Started signal generator heartbeat monitoring, stopped reconnect timer");
            } else {
                // 连接断开，停止心跳检测，启动重连定时器
                sigGenHeartbeatTimer.stop();
                sigGenHeartbeatTimeoutTimer.stop();
                workPageWindow.isSigGenHeartbeatActive = false;
                workPageWindow.sigGenHeartbeatFailureCount = 0;
                
                // 启动重连定时器
                if (!sigGenReconnectTimer.running) {
                    sigGenReconnectTimer.start();
                    console.log("WorkPage: Started signal generator reconnect timer");
                }
                console.log("WorkPage: Stopped signal generator heartbeat monitoring");
            }
        }

        onDataReceived: {
            console.log("WorkPage: Received data from signal generator:", data);
            
            // 检查是否是心跳响应
            if (workPageWindow.isSigGenHeartbeatActive) {
                // 收到任何数据都认为心跳成功
                sigGenHeartbeatTimeoutTimer.stop();
                workPageWindow.isSigGenHeartbeatActive = false;
                workPageWindow.sigGenHeartbeatFailureCount = 0;
                console.log("WorkPage: Signal generator heartbeat successful, connection is alive");
                
                // 如果收到的是设备识别信息，记录日志
                if (data.includes("RIGOL") || data.includes("Tektronix") || data.includes("Keysight") || data.includes("SIGLENT")) {
                    console.log("WorkPage: Received signal generator device identification:", data.trim());
                    return;
                }
            }
        }

        onErrorOccurred: {
            console.log("WorkPage: Signal generator SCPI Error occurred:", errorString);
            
            // 错误发生时，停止心跳检测
            if (workPageWindow.isSigGenHeartbeatActive) {
                sigGenHeartbeatTimeoutTimer.stop();
                workPageWindow.isSigGenHeartbeatActive = false;
                workPageWindow.sigGenHeartbeatFailureCount++;
                
                if (workPageWindow.sigGenHeartbeatFailureCount >= workPageWindow.sigGenMaxHeartbeatFailures) {
                    console.log("WorkPage: Multiple signal generator errors detected, handling connection loss");
                    handleSigGenConnectionLost();
                }
            }
        }
    }

    // 波形绘制器
    WaveformPlotter {
        id: waveformPlotter
        imageFilePrefix: "general"
    }

    // Vi1与Vo1波形绘制器
    WaveformPlotter {
        id: vi1vo1Plotter
        imageFilePrefix: "vi1vo1"
    }

    // Vi1与Vo2波形绘制器
    WaveformPlotter {
        id: vi1vo2Plotter
        imageFilePrefix: "vi1vo2"
    }

    // Vo1与Vo2波形绘制器
    WaveformPlotter {
        id: vo1vo2Plotter
        imageFilePrefix: "vo1vo2"
    }

    // 用于检测波形数据接收结束的定时器
    Timer {
        id: dataFinalizationTimer
        interval: 500 // 等待更多数据块的超时时间 (毫秒)
        repeat: false
        onTriggered: {
            if (workPageWindow.expectingWaveformData) {
                console.log("WorkPage: Data finalization timer triggered. Target:", workPageWindow.currentWaveformTarget, "Step:", workPageWindow.currentDualChannelStep);
                
                if (workPageWindow.isGettingDualChannelData) {
                    // 双通道模式处理
                    if (workPageWindow.currentDualChannelStep === "ch1") {
                        // CH1数据接收完成，开始获取CH2数据
                        console.log("WorkPage: CH1 data completed, starting CH2...");
                        workPageWindow.expectingWaveformData = false;
                        workPageWindow.currentDualChannelStep = "ch2";
                        
                        // 重置命令索引并开始CH2获取
                        if (workPageWindow.currentWaveformTarget === "vi1vo1") {
                            getVi1Vo1Button.currentCommandIndex = 0;
                            getVi1Vo1Button.sendNextCommandInSequence();
                        } else if (workPageWindow.currentWaveformTarget === "vi1vo2") {
                            getVi1Vo2Button.currentCommandIndex = 0;
                            getVi1Vo2Button.sendNextCommandInSequence();
                        } else if (workPageWindow.currentWaveformTarget === "vo1vo2") {
                            getVo1Vo2Button.currentCommandIndex = 0;
                            getVo1Vo2Button.sendNextCommandInSequence();
                        }
                    } else if (workPageWindow.currentDualChannelStep === "ch2") {
                        // CH2数据接收完成，进行双通道绘制
                        console.log("WorkPage: CH2 data completed, finalizing dual channel plot...");
                        
                        if (workPageWindow.currentWaveformTarget === "vi1vo1") {
                            vi1vo1Plotter.finalizeDualChannelPlotting();
                        } else if (workPageWindow.currentWaveformTarget === "vi1vo2") {
                            vi1vo2Plotter.finalizeDualChannelPlotting();
                        } else if (workPageWindow.currentWaveformTarget === "vo1vo2") {
                            vo1vo2Plotter.finalizeDualChannelPlotting();
                        }
                        
                        workPageWindow.expectingWaveformData = false;
                        workPageWindow.isGettingDualChannelData = false;
                        workPageWindow.currentDualChannelStep = "";
                        workPageWindow.currentWaveformTarget = "";

                        // 发送 :RUN 命令
                        console.log("WorkPage: Sent :RUN command after dual channel plotting.");
                        scpiHandler.sendCommand(":RUN");
                        
                        // 检查进度完成状态
                        checkAllPartsCompletion();
                    }
                } else {
                    // 单通道模式处理（原有逻辑）
                    if (workPageWindow.currentWaveformTarget === "ch1") {
                        waveformPlotter.finalizePlotting();
                    } else if (workPageWindow.currentWaveformTarget === "vi1vo1") {
                        vi1vo1Plotter.finalizePlotting();
                    } else if (workPageWindow.currentWaveformTarget === "vi1vo2") {
                        vi1vo2Plotter.finalizePlotting();
                    } else if (workPageWindow.currentWaveformTarget === "vo1vo2") {
                        vo1vo2Plotter.finalizePlotting();
                    }
                    
                    workPageWindow.expectingWaveformData = false;
                    workPageWindow.currentWaveformTarget = "";

                    // 在绘图数据处理完成后发送 :RUN 命令
                    console.log("WorkPage: Sent :RUN command after plotting and data finalization.");
                    scpiHandler.sendCommand(":RUN");
                    
                    // 检查进度完成状态
                    checkAllPartsCompletion();
                }
            }
        }
    }

    property int adaptive_width: Screen.desktopAvailableWidth
    property int adaptive_height: Screen.desktopAvailableHeight

    // 检测各部分完成状态的函数
    function checkPart1Completion() {
        // 表1字段
        var table1Fields = [
            table1vc1Field, table1vb1Field, table1ve1Field,
            table1vc2Field, table1vb2Field, table1ve2Field
        ];
        
        // 表2字段  
        var table2Fields = [
            table2vs1Field, table2vol1Field, table2avl1Field, table2vo1Field, table2av1Field,
            table2ri1Field, table2ro1Field, table2vo3Field, table2av3Field, table2w1Field,
            table2vs2Field, table2vol2Field, table2avl2Field, table2vo2Field, table2av2Field,
            table2ri2Field, table2ro2Field, table2vo4Field, table2av4Field, table2w2Field
        ];
        
        var allFilled = true;
        for (var i = 0; i < table1Fields.length; i++) {
            if (!table1Fields[i].text || table1Fields[i].text.trim() === "") {
                allFilled = false;
                break;
            }
        }
        
        if (allFilled) {
            for (var j = 0; j < table2Fields.length; j++) {
                if (!table2Fields[j].text || table2Fields[j].text.trim() === "") {
                    allFilled = false;
                    break;
                }
            }
        }
        
        if (allFilled && !workPageWindow.part1Completed) {
            workPageWindow.part1Completed = true;
            httpUploader.uploadTextOnly("part1 finished");
            console.log("WorkPage: Part 1 completed!");
        }
    }

    function checkPart2Completion() {
        // 表3字段
        var table3Fields = [
            table3vc11Field, table3vc21Field, table3vb11Field, table3vb21Field, table3ve11Field, table3ve21Field,
            table3vc12Field, table3vc22Field, table3vb12Field, table3vb22Field, table3ve12Field, table3ve22Field
        ];
        
        // 表4字段
        var table4Fields = [
            table4vo11Field, table4vo21Field, table4vo1Field, table4a1Field, table4k1Field,
            table4vo12Field, table4vo22Field, table4vo2Field, table4a2Field,
            table4vo13Field, table4vo23Field, table4vo3Field, table4a3Field, table4k2Field,
            table4vo14Field, table4vo24Field, table4vo4Field, table4a4Field
        ];
        
        var allFilled = true;
        for (var i = 0; i < table3Fields.length; i++) {
            if (!table3Fields[i].text || table3Fields[i].text.trim() === "") {
                allFilled = false;
                break;
            }
        }
        
        if (allFilled) {
            for (var j = 0; j < table4Fields.length; j++) {
                if (!table4Fields[j].text || table4Fields[j].text.trim() === "") {
                    allFilled = false;
                    break;
                }
            }
        }
        
        if (allFilled && !workPageWindow.part2Completed) {
            workPageWindow.part2Completed = true;
            httpUploader.uploadTextOnly("part2 finished");
            console.log("WorkPage: Part 2 completed!");
        }
    }

    function checkPart3Completion() {
        // 检查是否两个波形都已获取
        var vi1vo1HasImage = vi1vo1Plotter.plotImageUrl.toString() !== "";
        var vi1vo2HasImage = vi1vo2Plotter.plotImageUrl.toString() !== "";
        
        if (vi1vo1HasImage && vi1vo2HasImage && !workPageWindow.part3Completed) {
            workPageWindow.part3Completed = true;
            httpUploader.uploadTextOnly("part3 finished");
            console.log("WorkPage: Part 3 completed!");
        }
    }

    function checkPart5Completion() {
        // 表5字段
        var table5Fields = [
            table5vi1Field, table5vo1Field, table5vi2Field, table5vo2Field
        ];
        
        var allFilled = true;
        for (var i = 0; i < table5Fields.length; i++) {
            if (!table5Fields[i].text || table5Fields[i].text.trim() === "") {
                allFilled = false;
                break;
            }
        }
        
        if (allFilled && !workPageWindow.part5Completed) {
            workPageWindow.part5Completed = true;
            httpUploader.uploadTextOnly("part5 finished");
            console.log("WorkPage: Part 5 completed!");
        }
    }

    function checkPart6Completion() {
        // 检查Vo1与Vo2波形是否已获取
        var vo1vo2HasImage = vo1vo2Plotter.plotImageUrl.toString() !== "";
        
        if (vo1vo2HasImage && !workPageWindow.part6Completed) {
            workPageWindow.part6Completed = true;
            httpUploader.uploadTextOnly("part6 finished");
            console.log("WorkPage: Part 6 completed!");
        }
    }

    // 综合检查函数，在数据变化时调用
    function checkAllPartsCompletion() {
        checkPart1Completion();
        checkPart2Completion(); 
        checkPart3Completion();
        checkPart5Completion();
        checkPart6Completion();
    }

    // 心跳检测定时器
    Timer {
        id: heartbeatTimer
        interval: 2000 // 每2秒检测一次（从5秒改为2秒）
        repeat: true
        running: false

        onTriggered: {
            if (scpiHandler.connected && !workPageWindow.expectingWaveformData && !workPageWindow.isGettingDualChannelData) {
                workPageWindow.isHeartbeatActive = true;
                console.log("WorkPage: Sending heartbeat command...");
                scpiHandler.sendCommand("*IDN?"); // 发送设备识别命令作为心跳
                heartbeatTimeoutTimer.restart(); // 启动超时检测
            }
        }
    }

    // 心跳超时定时器
    Timer {
        id: heartbeatTimeoutTimer
        interval: 1000 // 2秒超时（从3秒改为2秒）
        repeat: false
        running: false

        onTriggered: {
            if (workPageWindow.isHeartbeatActive) {
                console.log("WorkPage: Heartbeat timeout, connection may be lost");
                workPageWindow.heartbeatFailureCount++;
                workPageWindow.isHeartbeatActive = false;
                
                if (workPageWindow.heartbeatFailureCount >= workPageWindow.maxHeartbeatFailures) {
                    console.log("WorkPage: Too many heartbeat failures, marking as disconnected");
                    handleConnectionLost();
                }
            }
        }
    }

    // 处理连接丢失
    function handleConnectionLost() {
        heartbeatTimer.stop();
        heartbeatTimeoutTimer.stop();
        workPageWindow.heartbeatFailureCount = 0;
        workPageWindow.isHeartbeatActive = false;
        
        // 强制断开连接
        scpiHandler.disconnectFromDevice();
        
        console.log("WorkPage: Connection lost, connection status will handle reconnection");
        // 不再手动启动重连定时器，由onConnectionStatusChanged自动处理
    }

    // 重连定时器
    Timer {
        id: reconnectTimer
        interval: 5000 // 每5秒尝试重连一次
        repeat: true // 设置为重复模式
        running: false

        onTriggered: {
            // 只有在未连接状态下才尝试重连
            if (!scpiHandler.connected) {
                console.log("WorkPage: Attempting to reconnect to oscilloscope...");
                scpiHandler.hostAddress = "192.168.10.3";
                scpiHandler.port = 5555;
                scpiHandler.connectToDevice();
            } else {
                // 如果已经连接，停止重连定时器
                console.log("WorkPage: Already connected, stopping reconnect timer");
                stop();
            }
        }
    }

    // 信号发生器心跳检测定时器
    Timer {
        id: sigGenHeartbeatTimer
        interval: 2000 // 每2秒检测一次
        repeat: true
        running: false

        onTriggered: {
            if (sigGenHandler.connected && !workPageWindow.expectingWaveformData && !workPageWindow.isGettingDualChannelData) {
                workPageWindow.isSigGenHeartbeatActive = true;
                console.log("WorkPage: Sending signal generator heartbeat command...");
                sigGenHandler.sendCommand("*IDN?"); // 发送设备识别命令作为心跳
                sigGenHeartbeatTimeoutTimer.restart(); // 启动超时检测
            }
        }
    }

    // 信号发生器心跳超时定时器
    Timer {
        id: sigGenHeartbeatTimeoutTimer
        interval: 1000 // 1秒超时
        repeat: false
        running: false

        onTriggered: {
            if (workPageWindow.isSigGenHeartbeatActive) {
                console.log("WorkPage: Signal generator heartbeat timeout, connection may be lost");
                workPageWindow.sigGenHeartbeatFailureCount++;
                workPageWindow.isSigGenHeartbeatActive = false;
                
                if (workPageWindow.sigGenHeartbeatFailureCount >= workPageWindow.sigGenMaxHeartbeatFailures) {
                    console.log("WorkPage: Too many signal generator heartbeat failures, marking as disconnected");
                    handleSigGenConnectionLost();
                }
            }
        }
    }

    // 信号发生器重连定时器
    Timer {
        id: sigGenReconnectTimer
        interval: 5000 // 每5秒尝试重连一次
        repeat: true // 设置为重复模式
        running: false

        onTriggered: {
            // 只有在未连接状态下才尝试重连
            if (!sigGenHandler.connected) {
                console.log("WorkPage: Attempting to reconnect to signal generator...");
                sigGenHandler.hostAddress = "192.168.10.4";
                sigGenHandler.port = 5555;
                sigGenHandler.connectToDevice();
            } else {
                // 如果已经连接，停止重连定时器
                console.log("WorkPage: Signal generator already connected, stopping reconnect timer");
                stop();
            }
        }
    }

    // 监听示波器连接状态变化
    Connections {
        target: scpiHandler
        function onConnectionStatusChanged(connected) {
            if (confirmDialog.dialogState === "device_cleanup" && !connected) {
                console.log("WorkPage: Oscilloscope disconnected, enabling completion");
                confirmDialog.dialogState = "cleanup_complete";
            }
        }
    }

    // 显示学号输入弹窗
    function showStudentCodeDialog() {
        workPageWindow.isAuthenticating = true;
        workPageWindow.isAuthenticated = false;
        studentCodeDialog.open();
        studentCodeInput.focus = true;
    }

    // 验证学号
    function verifyStudentCode() {
        var studentCode = studentCodeInput.text.trim();
        if (studentCode === "") {
            return;
        }
        
        console.log("WorkPage: Verifying student code:", studentCode);
        studentCodeDialog.close();
        
        // 发送HTTP GET请求验证学号
        httpUploader.checkStudentAppointment(studentCode);
    }

    // 用户鉴权函数 - 已废弃，保留为兼容性
    function authenticateUser() {
        console.log("WorkPage: Old authentication method called, redirecting to new process");
        showStudentCodeDialog();
    }

    // 处理学生预约验证响应
    function handleStudentAuthResponse(response) {
        console.log("WorkPage: Received student auth response:", response);
        
        try {
            var jsonData = JSON.parse(response);
            
            // 检查响应是否成功
            if (jsonData.code !== 200 || !jsonData.data) {
                console.log("WorkPage: No valid appointment found");
                workPageWindow.isAuthenticating = false;
                workPageWindow.isAuthenticated = false;
                confirmDialog.dialogState = "auth_failed";
                confirmDialog.open();
                return;
            }
            
            // 直接从data对象获取学生信息
            var appointmentData = jsonData.data;
            var studentCode = appointmentData.studentCode;
            var studentName = appointmentData.studentName;
            var appointmentTime = appointmentData.experimentAppointmentTime;
            var experimentId = appointmentData.id; // 获取实验id，字段名是id而不是experimentId
            
            console.log("WorkPage: Found appointment - Student:", studentName, "Code:", studentCode, "Time:", appointmentTime, "Experiment ID:", experimentId);
            
            // 验证时间是否在允许范围内
            if (isTimeInValidRange(appointmentTime)) {
                // 时间验证通过，设置用户信息
                workPageWindow.studentName = studentName;
                workPageWindow.studentNumber = studentCode;
                workPageWindow.experimentId = experimentId; // 存储实验id
                workPageWindow.isAuthenticating = false;
                workPageWindow.isAuthenticated = true;
                
                console.log("WorkPage: Authentication successful. Name:", studentName, "Number:", studentCode, "Experiment ID:", experimentId);
                
                // 鉴权成功后自动连接示波器和信号发生器
                console.log("WorkPage: Auto-connecting to oscilloscope after authentication...");
                scpiHandler.hostAddress = "192.168.10.3";
                scpiHandler.port = 5555;
                scpiHandler.connectToDevice();
                
                console.log("WorkPage: Auto-connecting to signal generator after authentication...");
                sigGenHandler.hostAddress = "192.168.10.4";
                sigGenHandler.port = 5555;
                sigGenHandler.connectToDevice();
                
                // 启动重连定时器
                reconnectTimer.start();
                sigGenReconnectTimer.start();
            } else {
                // 时间不在允许范围内
                console.log("WorkPage: Current time is not within valid appointment range");
                workPageWindow.isAuthenticating = false;
                workPageWindow.isAuthenticated = false;
                confirmDialog.dialogState = "auth_failed";
                confirmDialog.open();
            }
            
        } catch (error) {
            console.log("WorkPage: Error parsing JSON response:", error);
            workPageWindow.isAuthenticating = false;
            workPageWindow.isAuthenticated = false;
            confirmDialog.dialogState = "auth_failed";
            confirmDialog.open();
        }
    }

    // 检查当前时间是否在预约时间的3小时有效期内
    function isTimeInValidRange(appointmentTimeStr) {
        try {
            // 解析预约时间字符串 (格式: "2025-06-25 10:00:00")
            var appointmentDate = new Date(appointmentTimeStr.replace(/-/g, '/'));
            if (isNaN(appointmentDate.getTime())) {
                console.log("WorkPage: Invalid appointment time format:", appointmentTimeStr);
                return false;
            }
            
            // 计算3小时后的时间
            var endTime = new Date(appointmentDate.getTime() + 3 * 60 * 60 * 1000); // 3小时 = 3 * 60 * 60 * 1000 毫秒
            
            // 获取当前时间
            var currentTime = new Date();
            
            console.log("WorkPage: Time validation - Appointment:", appointmentDate.toLocaleString());
            console.log("WorkPage: Time validation - End time:", endTime.toLocaleString());
            console.log("WorkPage: Time validation - Current time:", currentTime.toLocaleString());
            
            // 检查当前时间是否在预约时间和结束时间之间
            var isValid = currentTime >= appointmentDate && currentTime <= endTime;
            console.log("WorkPage: Time validation result:", isValid);
            
            return isValid;
        } catch (error) {
            console.log("WorkPage: Error in time validation:", error);
            return false;
        }
    }

    // 处理鉴权响应 - 保留为兼容性
    function handleAuthResponse(response) {
        console.log("WorkPage: Old auth response handler called, response:", response);
        // 此方法已被handleStudentAuthResponse替代
    }

    // 处理信号发生器连接丢失
    function handleSigGenConnectionLost() {
        sigGenHeartbeatTimer.stop();
        sigGenHeartbeatTimeoutTimer.stop();
        workPageWindow.sigGenHeartbeatFailureCount = 0;
        workPageWindow.isSigGenHeartbeatActive = false;
        
        // 强制断开连接
        sigGenHandler.disconnectFromDevice();
        
        console.log("WorkPage: Signal generator connection lost, connection status will handle reconnection");
        // 不再手动启动重连定时器，由onConnectionStatusChanged自动处理
    }
}
