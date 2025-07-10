#ifndef SCPICLIENT_H
#define SCPICLIENT_H

#include <QObject>
#include <QTcpSocket>
#include <QString>
#include <QTimer>
#include <QByteArray>

class ScpiClient : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString hostAddress READ hostAddress WRITE setHostAddress NOTIFY hostAddressChanged)
    Q_PROPERTY(int port READ port WRITE setPort NOTIFY portChanged)
    Q_PROPERTY(bool connected READ isConnected NOTIFY connectionStatusChanged)

public:
    explicit ScpiClient(QObject *parent = nullptr);
    ~ScpiClient();

    QString hostAddress() const;
    void setHostAddress(const QString &address);

    int port() const;
    void setPort(int port);

    bool isConnected() const;

public slots:
    void connectToDevice();
    void disconnectFromDevice();
    void sendCommand(const QString &command);

signals:
    void hostAddressChanged();
    void portChanged();
    void connectionStatusChanged(bool connected);
    void dataReceived(const QString &data);
    void errorOccurred(const QString &errorString); // 用于报告错误

private slots:
    void onConnected();
    void onDisconnected();
    void onReadyRead();
    void onError(QAbstractSocket::SocketError socketError);
    void processPendingData(); // 分批处理挂起的数据

private:
    QTcpSocket *m_tcpSocket;
    QString m_hostAddress;
    int m_port;
    bool m_connected;
    
    // 用于分批处理大数据的成员变量
    QByteArray m_pendingData; // 待处理的数据缓冲区
    QTimer *m_dataProcessTimer; // 用于分批处理数据的定时器
    static const int MAX_CHUNK_SIZE = 2048; // 减小到2KB，更频繁让出控制权
    static const int TIMER_INTERVAL = 5; // 增加到5ms，给UI更多时间
};

#endif // SCPICLIENT_H
