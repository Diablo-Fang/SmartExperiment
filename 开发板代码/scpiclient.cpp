#include "scpiclient.h"
#include <QDebug>
#include <QCoreApplication>

// 定义静态常量成员
const int ScpiClient::MAX_CHUNK_SIZE;
const int ScpiClient::TIMER_INTERVAL;

ScpiClient::ScpiClient(QObject *parent)
    : QObject(parent), m_tcpSocket(new QTcpSocket(this)), m_port(5025), m_connected(false) // 5025是SCPI常用的端口
{
    connect(m_tcpSocket, &QTcpSocket::connected, this, &ScpiClient::onConnected);
    connect(m_tcpSocket, &QTcpSocket::disconnected, this, &ScpiClient::onDisconnected);
    connect(m_tcpSocket, &QTcpSocket::readyRead, this, &ScpiClient::onReadyRead);
    connect(m_tcpSocket, QOverload<QAbstractSocket::SocketError>::of(&QTcpSocket::errorOccurred), this, &ScpiClient::onError);
    
    // 初始化数据处理定时器
    m_dataProcessTimer = new QTimer(this);
    m_dataProcessTimer->setSingleShot(true);
    m_dataProcessTimer->setInterval(TIMER_INTERVAL); // 使用常量
    connect(m_dataProcessTimer, &QTimer::timeout, this, &ScpiClient::processPendingData);
}

ScpiClient::~ScpiClient()
{
    if (m_tcpSocket->isOpen()) {
        m_tcpSocket->disconnectFromHost();
    }
}

QString ScpiClient::hostAddress() const
{
    return m_hostAddress;
}

void ScpiClient::setHostAddress(const QString &address)
{
    if (m_hostAddress != address) {
        m_hostAddress = address;
        emit hostAddressChanged();
    }
}

int ScpiClient::port() const
{
    return m_port;
}

void ScpiClient::setPort(int port)
{
    if (m_port != port) {
        m_port = port;
        emit portChanged();
    }
}

bool ScpiClient::isConnected() const
{
    return m_connected;
}

void ScpiClient::connectToDevice()
{
    if (m_tcpSocket->state() == QAbstractSocket::UnconnectedState) {
        qDebug() << "Attempting to connect to" << m_hostAddress << ":" << m_port;
        m_tcpSocket->connectToHost(m_hostAddress, m_port);
    } else {
        qDebug() << "Already connected or connecting.";
    }
}

void ScpiClient::disconnectFromDevice()
{
    if (m_tcpSocket->isOpen()) {
        m_tcpSocket->disconnectFromHost();
    }
}

void ScpiClient::sendCommand(const QString &command)
{
    if (m_tcpSocket->isOpen() && m_tcpSocket->state() == QAbstractSocket::ConnectedState) {
        // SCPI命令通常以换行符结尾
        QByteArray scpiCommand = command.toUtf8();
        if (!scpiCommand.endsWith('\n')) {
            scpiCommand.append('\n');
        }
        qDebug() << "Sending SCPI command:" << scpiCommand.constData();
        m_tcpSocket->write(scpiCommand);
        m_tcpSocket->flush(); // 确保立即发送
    } else {
        qDebug() << "Cannot send command: Socket not open or not connected.";
        emit errorOccurred(tr("Not connected to device."));
    }
}

void ScpiClient::onConnected()
{
    m_connected = true;
    qDebug() << "Connected to device.";
    emit connectionStatusChanged(true);
}

void ScpiClient::onDisconnected()
{
    m_connected = false;
    qDebug() << "Disconnected from device.";
    emit connectionStatusChanged(false);
}

void ScpiClient::onReadyRead()
{
    // 读取新数据并添加到待处理缓冲区
    QByteArray newData = m_tcpSocket->readAll();
    m_pendingData.append(newData);
    
    qDebug() << "ScpiClient: Received" << newData.size() << "bytes, total pending:" << m_pendingData.size() << "bytes";
    
    // 如果定时器没有运行，启动它来处理数据
    if (!m_dataProcessTimer->isActive()) {
        m_dataProcessTimer->start();
    }
}

void ScpiClient::processPendingData()
{
    if (m_pendingData.isEmpty()) {
        return; // 没有数据需要处理
    }
    
    // 处理一个较小的数据块
    int chunkSize = qMin(m_pendingData.size(), MAX_CHUNK_SIZE);
    QByteArray chunk = m_pendingData.left(chunkSize);
    m_pendingData.remove(0, chunkSize);
    
    // 将数据块转换为字符串并发送信号
    QString response = QString::fromUtf8(chunk);
    qDebug() << "ScpiClient: Processing chunk of" << chunkSize << "bytes, remaining:" << m_pendingData.size() << "bytes";
    emit dataReceived(response);
    
    // 强制处理UI事件，确保界面响应
    QCoreApplication::processEvents(QEventLoop::AllEvents, 2); // 最多处理2ms的事件
    
    // 如果还有更多数据需要处理，重新启动定时器
    if (!m_pendingData.isEmpty()) {
        m_dataProcessTimer->start();
    } else {
        qDebug() << "ScpiClient: All data processed";
    }
}

void ScpiClient::onError(QAbstractSocket::SocketError socketError)
{
    Q_UNUSED(socketError);
    QString errorStr = m_tcpSocket->errorString();
    qDebug() << "Socket Error:" << errorStr;
    emit errorOccurred(errorStr);
    // 如果是连接错误，确保状态更新
    if (m_connected && (socketError == QAbstractSocket::RemoteHostClosedError ||
                        socketError == QAbstractSocket::NetworkError ||
                        socketError == QAbstractSocket::ConnectionRefusedError)) {
        m_connected = false;
        emit connectionStatusChanged(false);
    }
}
