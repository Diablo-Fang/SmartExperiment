#include "HttpUploader.h"
#include <QHttpMultiPart>
#include <QFile>
#include <QFileInfo>
#include <QNetworkRequest>
#include <QNetworkReply>
#include <QMimeDatabase>
#include <QDebug>
#include <QJsonDocument>
#include <QJsonObject>

HttpUploader::HttpUploader(QObject *parent) : QObject(parent),
    m_networkManager(new QNetworkAccessManager(this)),
    m_serverUrl("http://192.168.10.1/dev-api/manage/experiment1")
{
}

QUrl HttpUploader::serverUrl() const
{
    return m_serverUrl;
}

void HttpUploader::setServerUrl(const QUrl &url)
{
    if (m_serverUrl != url) {
        m_serverUrl = url;
        emit serverUrlChanged();
    }
}

void HttpUploader::uploadData(const QString &imagePath, const QString &textData, const QString &imageFileName)
{
    if (m_serverUrl.isEmpty() || !m_serverUrl.isValid()) {
        qWarning() << "Server URL is not set or invalid.";
        emit uploadError(tr("Server URL is not set or invalid."));
        return;
    }

    QHttpMultiPart *multiPart = new QHttpMultiPart(QHttpMultiPart::FormDataType);

    // 处理文本数据部分
    QHttpPart textPart;
    textPart.setHeader(QNetworkRequest::ContentDispositionHeader, QVariant("form-data; name=\"textData\""));
    textPart.setBody(textData.toUtf8());
    multiPart->append(textPart);

    // 处理图片文件部分
    QString localFilePath = imagePath;
    if (localFilePath.startsWith("file:///")) {
        localFilePath = QUrl(imagePath).toLocalFile();
    }

    QFile *file = new QFile(localFilePath);
    if (!file->open(QIODevice::ReadOnly)) {
        qWarning() << "Could not open image file:" << localFilePath << file->errorString();
        emit uploadError(tr("Could not open image file: %1").arg(file->errorString()));
        delete multiPart; // 清理 multipart
        delete file; // 清理文件对象
        return;
    }

    QHttpPart imagePart;
    QMimeDatabase db;
    QMimeType mimeType = db.mimeTypeForFile(localFilePath, QMimeDatabase::MatchContent);
    imagePart.setHeader(QNetworkRequest::ContentTypeHeader, QVariant(mimeType.name())); // e.g., "image/png"
    QString dispositionHeader = QString("form-data; name=\"imageFile\"; filename=\"%1\"").arg(imageFileName);
    imagePart.setHeader(QNetworkRequest::ContentDispositionHeader, QVariant(dispositionHeader));
    imagePart.setBodyDevice(file);
    file->setParent(multiPart); // file will be deleted when multiPart is deleted

    multiPart->append(imagePart);

    QNetworkRequest request(m_serverUrl);
    // 可以根据需要添加其他请求头，例如认证token等
    // request.setRawHeader("Authorization", "Bearer your_token");

    QNetworkReply *reply = m_networkManager->put(request, multiPart);
    multiPart->setParent(reply); // multiPart will be deleted when reply is deleted

    connect(reply, &QNetworkReply::uploadProgress, this, &HttpUploader::onUploadProgress);
    connect(reply, &QNetworkReply::finished, this, &HttpUploader::onUploadFinished);
    // 连接错误信号
    connect(reply, SIGNAL(errorOccurred(QNetworkReply::NetworkError)), this, SLOT(handleUploadError(QNetworkReply::NetworkError)));

    qInfo() << "Starting upload to" << m_serverUrl.toString() << "with image:" << localFilePath << "and text data using PUT method.";
}

void HttpUploader::uploadExperimentData(const QString &experimentId, const QString &studentId, const QString &formattedData)
{
    if (m_serverUrl.isEmpty() || !m_serverUrl.isValid()) {
        qWarning() << "Server URL is not set or invalid.";
        emit uploadError(tr("Server URL is not set or invalid."));
        return;
    }

    QNetworkRequest request(m_serverUrl);
    request.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");

    // 解析传入的格式化数据
    QJsonDocument doc = QJsonDocument::fromJson(formattedData.toUtf8());
    QJsonObject jsonObj = doc.object();
    
    // 添加id和studentId到JSON对象
    jsonObj["id"] = experimentId;
    jsonObj["studentId"] = studentId;

    // 转换回JSON字符串
    QJsonDocument finalDoc(jsonObj);
    QByteArray jsonData = finalDoc.toJson(QJsonDocument::Compact);

    QNetworkReply *reply = m_networkManager->put(request, jsonData);

    connect(reply, &QNetworkReply::finished, this, &HttpUploader::onUploadFinished);
    connect(reply, SIGNAL(errorOccurred(QNetworkReply::NetworkError)), this, SLOT(handleUploadError(QNetworkReply::NetworkError)));

    qInfo() << "Starting experiment data upload to" << m_serverUrl.toString() << "with experiment ID:" << experimentId << "and student ID:" << studentId << "using PUT method.";
}

void HttpUploader::onUploadProgress(qint64 bytesSent, qint64 bytesTotal)
{
    emit uploadProgress(bytesSent, bytesTotal);
}

void HttpUploader::onUploadFinished()
{
    QNetworkReply *reply = qobject_cast<QNetworkReply*>(sender());
    if (!reply) return;

    if (reply->error() == QNetworkReply::NoError) {
        QString responseData = reply->readAll();
        qInfo() << "Upload successful. Server reply:" << responseData;
        emit uploadFinished(responseData);
    } else {
        // 这个分支实际上可能不会被频繁触发，因为我们单独连接了 errorOccurred
        // 但保留它作为一种备用
        QString errorString = tr("Upload failed: %1").arg(reply->errorString());
        qWarning() << errorString;
        emit uploadError(errorString);
    }
    reply->deleteLater();
}

void HttpUploader::handleUploadError(QNetworkReply::NetworkError errorCode)
{
    QNetworkReply *reply = qobject_cast<QNetworkReply*>(sender());
    if (!reply) return;

    QString errorString = tr("Upload error: %1 (code: %2)").arg(reply->errorString()).arg(errorCode);
    qWarning() << errorString;
    emit uploadError(errorString);
    reply->deleteLater(); 
}

void HttpUploader::uploadTextOnly(const QString &textData)
{
    if (m_serverUrl.isEmpty() || !m_serverUrl.isValid()) {
        qWarning() << "Server URL is not set or invalid.";
        emit uploadError(tr("Server URL is not set or invalid."));
        return;
    }

    // 构建upload-text端点URL - 使用更安全的路径替换方式
    QUrl textUploadUrl = m_serverUrl;
    QString path = textUploadUrl.path();
    if (!path.endsWith("/")) path += "/";
    path += "upload-text";
    textUploadUrl.setPath(path);

    QNetworkRequest request(textUploadUrl);
    request.setHeader(QNetworkRequest::ContentTypeHeader, "text/plain");

    QNetworkReply *reply = m_networkManager->put(request, textData.toUtf8());

    connect(reply, &QNetworkReply::finished, this, &HttpUploader::onTextUploadFinished);
    connect(reply, SIGNAL(errorOccurred(QNetworkReply::NetworkError)), this, SLOT(handleTextUploadError(QNetworkReply::NetworkError)));

    qInfo() << "Starting text upload to" << textUploadUrl.toString() << "with data:" << textData << "using PUT method.";
}

void HttpUploader::onTextUploadFinished()
{
    QNetworkReply *reply = qobject_cast<QNetworkReply*>(sender());
    if (!reply) return;

    if (reply->error() == QNetworkReply::NoError) {
        QString responseData = reply->readAll();
        qInfo() << "Text upload successful. Server reply:" << responseData;
        emit textUploadFinished(responseData);
    } else {
        QString errorString = tr("Text upload failed: %1").arg(reply->errorString());
        qWarning() << errorString;
        emit textUploadError(errorString);
    }
    reply->deleteLater();
}

void HttpUploader::handleTextUploadError(QNetworkReply::NetworkError errorCode)
{
    QNetworkReply *reply = qobject_cast<QNetworkReply*>(sender());
    if (!reply) return;

    QString errorString = tr("Text upload error: %1 (code: %2)").arg(reply->errorString()).arg(errorCode);
    qWarning() << errorString;
    emit textUploadError(errorString);
    reply->deleteLater();
}

void HttpUploader::checkStudentAppointment(const QString &studentCode)
{
    if (m_serverUrl.isEmpty() || !m_serverUrl.isValid()) {
        qWarning() << "Server URL is not set or invalid.";
        emit studentAppointmentCheckError(tr("Server URL is not set or invalid."));
        return;
    }

    // 构建学生预约检查URL - 使用正确的鉴权端点
    QUrl studentCheckUrl = m_serverUrl;
    // 重置为正确的鉴权端点路径
    studentCheckUrl.setPath("/dev-api/manage/student/" + studentCode);

    QNetworkRequest request(studentCheckUrl);
    request.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");

    // 发送GET请求
    QNetworkReply *reply = m_networkManager->get(request);

    connect(reply, &QNetworkReply::finished, this, &HttpUploader::onStudentAppointmentCheckFinished);
    connect(reply, SIGNAL(errorOccurred(QNetworkReply::NetworkError)), this, SLOT(handleStudentAppointmentCheckError(QNetworkReply::NetworkError)));

    qInfo() << "Starting student appointment check to" << studentCheckUrl.toString() << "for student code:" << studentCode;
}

void HttpUploader::onStudentAppointmentCheckFinished()
{
    QNetworkReply *reply = qobject_cast<QNetworkReply*>(sender());
    if (!reply) return;

    if (reply->error() == QNetworkReply::NoError) {
        QString responseData = reply->readAll();
        qInfo() << "Student appointment check successful. Server reply:" << responseData;
        emit studentAppointmentCheckFinished(responseData);
    } else {
        QString errorString = tr("Student appointment check failed: %1").arg(reply->errorString());
        qWarning() << errorString;
        emit studentAppointmentCheckError(errorString);
    }
    reply->deleteLater();
}

void HttpUploader::handleStudentAppointmentCheckError(QNetworkReply::NetworkError errorCode)
{
    QNetworkReply *reply = qobject_cast<QNetworkReply*>(sender());
    if (!reply) return;

    QString errorString = tr("Student appointment check error: %1 (code: %2)").arg(reply->errorString()).arg(errorCode);
    qWarning() << errorString;
    emit studentAppointmentCheckError(errorString);
    reply->deleteLater();
}

void HttpUploader::checkAppointment(const QString &query)
{
    if (m_serverUrl.isEmpty() || !m_serverUrl.isValid()) {
        qWarning() << "Server URL is not set or invalid.";
        emit appointmentCheckError(tr("Server URL is not set or invalid."));
        return;
    }

    // 构建check-appointment端点URL - 使用更安全的路径替换方式
    QUrl appointmentCheckUrl = m_serverUrl;
    QString path = appointmentCheckUrl.path();
    if (!path.endsWith("/")) path += "/";
    path += "check-appointment";
    appointmentCheckUrl.setPath(path);

    QNetworkRequest request(appointmentCheckUrl);
    request.setHeader(QNetworkRequest::ContentTypeHeader, "text/plain");

    QNetworkReply *reply = m_networkManager->put(request, query.toUtf8());

    connect(reply, &QNetworkReply::finished, this, &HttpUploader::onAppointmentCheckFinished);
    connect(reply, SIGNAL(errorOccurred(QNetworkReply::NetworkError)), this, SLOT(handleAppointmentCheckError(QNetworkReply::NetworkError)));

    qInfo() << "Starting appointment check to" << appointmentCheckUrl.toString() << "with query:" << query << "using PUT method.";
}

void HttpUploader::onAppointmentCheckFinished()
{
    QNetworkReply *reply = qobject_cast<QNetworkReply*>(sender());
    if (!reply) return;

    if (reply->error() == QNetworkReply::NoError) {
        QString responseData = reply->readAll();
        qInfo() << "Appointment check successful. Server reply:" << responseData;
        emit appointmentCheckFinished(responseData);
    } else {
        QString errorString = tr("Appointment check failed: %1").arg(reply->errorString());
        qWarning() << errorString;
        emit appointmentCheckError(errorString);
    }
    reply->deleteLater();
}

void HttpUploader::handleAppointmentCheckError(QNetworkReply::NetworkError errorCode)
{
    QNetworkReply *reply = qobject_cast<QNetworkReply*>(sender());
    if (!reply) return;

    QString errorString = tr("Appointment check error: %1 (code: %2)").arg(reply->errorString()).arg(errorCode);
    qWarning() << errorString;
    emit appointmentCheckError(errorString);
    reply->deleteLater();
} 