#ifndef HTTPUPLOADER_H
#define HTTPUPLOADER_H

#include <QObject>
#include <QString>
#include <QUrl>
#include <QNetworkAccessManager>
#include <QNetworkReply> // Required for QNetworkReply::NetworkError

class QHttpMultiPart; // Forward declaration
class QJsonDocument; // Forward declaration
class QJsonObject; // Forward declaration

class HttpUploader : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QUrl serverUrl READ serverUrl WRITE setServerUrl NOTIFY serverUrlChanged)

public:
    explicit HttpUploader(QObject *parent = nullptr);

    QUrl serverUrl() const;
    void setServerUrl(const QUrl &url);

    Q_INVOKABLE void uploadData(const QString &imagePath, const QString &textData, const QString &imageFileName = "waveform.png");
    Q_INVOKABLE void uploadExperimentData(const QString &experimentId, const QString &studentId, const QString &formattedData);
    Q_INVOKABLE void uploadTextOnly(const QString &textData);
    Q_INVOKABLE void checkAppointment(const QString &query);
    Q_INVOKABLE void checkStudentAppointment(const QString &studentCode);

signals:
    void serverUrlChanged();
    void uploadProgress(qint64 bytesSent, qint64 bytesTotal);
    void uploadFinished(const QString &replyData);
    void uploadError(const QString &errorString);
    void textUploadFinished(const QString &replyData);
    void textUploadError(const QString &errorString);
    void appointmentCheckFinished(const QString &replyData);
    void appointmentCheckError(const QString &errorString);
    void studentAppointmentCheckFinished(const QString &replyData);
    void studentAppointmentCheckError(const QString &errorString);


private slots:
    void onUploadProgress(qint64 bytesSent, qint64 bytesTotal);
    void onUploadFinished();
    // Slot to handle QNetworkReply::errorOccurred
    void handleUploadError(QNetworkReply::NetworkError errorCode);
    void onTextUploadFinished();
    void handleTextUploadError(QNetworkReply::NetworkError errorCode);
    void onAppointmentCheckFinished();
    void handleAppointmentCheckError(QNetworkReply::NetworkError errorCode);
    void onStudentAppointmentCheckFinished();
    void handleStudentAppointmentCheckError(QNetworkReply::NetworkError errorCode);


private:
    QNetworkAccessManager *m_networkManager;
    QUrl m_serverUrl;
};

#endif // HTTPUPLOADER_H 