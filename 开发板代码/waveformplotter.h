#ifndef WAVEFORMPLOTTER_H
#define WAVEFORMPLOTTER_H

#include <QObject>
#include <QString>
#include <QList>
#include <QImage>
#include <QUrl>

class QEventLoop; // 前向声明

class WaveformPlotter : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QUrl plotImageUrl READ plotImageUrl NOTIFY plotImageUrlChanged)
    Q_PROPERTY(QString imageFilePrefix READ imageFilePrefix WRITE setImageFilePrefix NOTIFY imageFilePrefixChanged)

public:
    explicit WaveformPlotter(QObject *parent = nullptr);

    Q_INVOKABLE void accumulateData(const QString& dataChunk);
    Q_INVOKABLE void accumulateDataCH1(const QString& dataChunk);
    Q_INVOKABLE void accumulateDataCH2(const QString& dataChunk);
    Q_INVOKABLE void finalizePlotting();
    Q_INVOKABLE void finalizeDualChannelPlotting();
    Q_INVOKABLE void clearPlotData();

    QUrl plotImageUrl() const;
    QString imageFilePrefix() const;
    void setImageFilePrefix(const QString &prefix);

signals:
    void plotImageUrlChanged(); // Emitted when the image URL is updated
    void imageFilePrefixChanged();

private:
    QList<double> parseDataString(const QString& rawDataString);
    QImage generatePlotImage(const QList<double>& dataPoints);
    QImage generateDualChannelPlotImage(const QList<double>& ch1Data, const QList<double>& ch2Data);
    void saveImageAndSetUrl(const QImage& image);
    QString getUniqueFileName() const;

    QUrl m_plotImageUrl;
    QString m_imageFilePrefix = "waveform"; // Default prefix
    QString m_accumulatedDataString; // For accumulating multi-part data (single channel)
    QString m_accumulatedDataStringCH1; // For accumulating CH1 data
    QString m_accumulatedDataStringCH2; // For accumulating CH2 data
};

#endif // WAVEFORMPLOTTER_H
