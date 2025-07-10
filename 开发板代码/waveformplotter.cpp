#include "waveformplotter.h"
#include "qpainterpath.h"
#include <QPainter>
#include <QPen>
#include <QDebug>
#include <QFile>
#include <QStandardPaths>
#include <QDir>
#include <cmath> // For std::fabs
#include <QFont>
#include <QTextOption>
#include <QCoreApplication>
#include <QEventLoop>

WaveformPlotter::WaveformPlotter(QObject *parent) : QObject(parent) {}

QUrl WaveformPlotter::plotImageUrl() const {
    return m_plotImageUrl;
}

QString WaveformPlotter::imageFilePrefix() const {
    return m_imageFilePrefix;
}

void WaveformPlotter::setImageFilePrefix(const QString &prefix) {
    if (m_imageFilePrefix != prefix) {
        m_imageFilePrefix = prefix;
        emit imageFilePrefixChanged();
    }
}

QString WaveformPlotter::getUniqueFileName() const {
    return QString("%1_plot.png").arg(m_imageFilePrefix);
}

QList<double> WaveformPlotter::parseDataString(const QString& rawDataString) {
    QList<double> dataPoints;
    // Trim the whole string first, then split. This matches your Python example.
    QStringList stringValues = rawDataString.trimmed().split(',');
    
    int processedCount = 0;
    for (const QString& valStrLoop : stringValues) {
        QString valStr = valStrLoop.trimmed(); // Trim each individual part
        if (!valStr.isEmpty()) {
            bool ok;
            double val = valStr.toDouble(&ok);
            if (ok) {
                dataPoints.append(val);
            } else {
                // This part might be an SCPI header, e.g., #800001400
                // If a part of the header doesn't convert to double, it's skipped.
                // This is a simple way to ignore non-numeric prefixes if they are comma-separated.
                // However, if the header is like #800001400-3.000000e+01, this won't split correctly.
                // Assuming data is purely comma-separated floats or header is easily skipped by toDouble failing.
                qWarning() << "WaveformPlotter: Could not convert '" << valStr << "' to double. Skipping.";
            }
        }
        
        // 每处理50个数据点就让UI线程处理一次事件（更频繁）
        processedCount++;
        if (processedCount % 50 == 0) {
            QCoreApplication::processEvents(QEventLoop::AllEvents, 1); // 最多1ms
        }
    }
    qDebug() << "WaveformPlotter: Parsed" << dataPoints.size() << "data points.";
    return dataPoints;
}

QImage WaveformPlotter::generatePlotImage(const QList<double>& dataPoints) {
    if (dataPoints.isEmpty()) {
        qWarning() << "WaveformPlotter: No data points to plot.";
        return QImage(); // Return empty image
    }

    const int imgWidth = 600;
    const int imgHeight = 400;
    const int marginTop = 40, marginBottom = 50, marginLeft = 60, marginRight = 20;
    const int plotWidth = imgWidth - marginLeft - marginRight;
    const int plotHeight = imgHeight - marginTop - marginBottom;

    QImage image(imgWidth, imgHeight, QImage::Format_ARGB32_Premultiplied);
    image.fill(Qt::white);

    QPainter painter(&image);
    painter.setRenderHint(QPainter::Antialiasing);

    // Define a base font
    QFont baseFont("Microsoft YaHei", 10); // Or "Arial", or other common font
    QFont titleFont("Microsoft YaHei", 14, QFont::Bold);
    QFont axisLabelFont("Microsoft YaHei", 10);
    QFont tickLabelFont("Microsoft YaHei", 8);

    double yMin = dataPoints.first();
    double yMax = dataPoints.first();
    for (double val : dataPoints) {
        if (val < yMin) yMin = val;
        if (val > yMax) yMax = val;
    }
    if (std::fabs(yMin - yMax) < 1e-9) { // Handle case where all points are (nearly) the same
        yMin -= 1.0;
        yMax += 1.0;
    }
    double yRange = yMax - yMin;
    if (std::fabs(yRange) < 1e-9) yRange = 1.0; // Avoid division by zero if yMin and yMax were identical after adjustment

    // Transform painter to plot coordinates
    painter.translate(marginLeft, marginTop + plotHeight); // Origin at bottom-left of plot area
    painter.scale(1, -1); // Flip Y-axis

    // --- Draw Axes ---
    QPen axisPen(Qt::black, 1);
    painter.setPen(axisPen);
    painter.drawLine(0, 0, plotWidth, 0); // X-axis
    painter.drawLine(0, 0, 0, plotHeight);  // Y-axis

    // --- Draw Grid ---
    QPen gridPen(Qt::lightGray, 1, Qt::DotLine);
    painter.setPen(gridPen);
    int numGridLinesX = 10;
    int numGridLinesY = 5;
    for (int i = 1; i < numGridLinesX; ++i) { // Skip drawing on axes themselves
        int x = (i * plotWidth / numGridLinesX);
        painter.drawLine(x, 0, x, plotHeight);
    }
    for (int i = 1; i < numGridLinesY; ++i) { // Skip drawing on axes themselves
        int y = (i * plotHeight / numGridLinesY);
        painter.drawLine(0, y, plotWidth, y);
    }

    // --- Draw Waveform ---
    QPen dataPen(Qt::blue, 1);
    painter.setPen(dataPen);
    QPainterPath path;
    double xStep = static_cast<double>(plotWidth) / (dataPoints.size() > 1 ? (dataPoints.size() - 1) : 1);
    for (int i = 0; i < dataPoints.size(); ++i) {
        double x_coord = i * xStep;
        double y_coord = ((dataPoints[i] - yMin) / yRange * plotHeight);
        if (i == 0) {
            path.moveTo(x_coord, y_coord);
        } else {
            path.lineTo(x_coord, y_coord);
        }
        
        // 每处理100个点就让UI线程处理事件（更频繁）
        if (i % 100 == 0) {
            QCoreApplication::processEvents(QEventLoop::AllEvents, 1);
        }
    }
    painter.drawPath(path);

    // --- Draw Labels and Title (Need to reset transform for text) ---
    painter.resetTransform(); // Back to default QImage coordinates
    painter.setPen(Qt::black);

    // Title
    painter.setFont(titleFont);
    painter.drawText(QRect(marginLeft, 5, plotWidth, marginTop - 10), Qt::AlignCenter, QStringLiteral("CH1波形"));

    // X-axis Label
    painter.setFont(axisLabelFont);
    painter.drawText(QRect(marginLeft, marginTop + plotHeight + 15, plotWidth, marginBottom - 15), Qt::AlignCenter, QStringLiteral("采样点数")); // Increased Y offset for label

    // Y-axis Label (simple horizontal text)
    // For vertical text, you'd need to save painter state, rotate, draw, restore.
    painter.setFont(axisLabelFont);
    // Centering Y-axis label requires a bit more care with QRect for horizontal text
    QRect yLabelRect(5, marginTop + (plotHeight / 2) - 50, marginLeft - 10, 100); // Adjusted for vertical centering
    QTextOption yLabelOption(Qt::AlignCenter);
    // painter.drawText(yLabelRect, QStringLiteral("采样值"), yLabelOption); // This might still be tricky for perfectly centered vertical text
    // Simpler: Draw rotated text if needed, or accept slightly off-center horizontal text for simplicity
    // For simple horizontal text near the axis:
    painter.drawText(QRect(5, marginTop, marginLeft - 10, plotHeight), Qt::AlignCenter | Qt::TextWordWrap, QStringLiteral("采样值"));


    // Y-axis tick labels
    painter.setFont(tickLabelFont);
    for (int i = 0; i <= numGridLinesY; ++i) {
        double val = yMin + (i * yRange / numGridLinesY);
        int y_img_coord = marginTop + plotHeight - (i * plotHeight / numGridLinesY);
        // Ensure a small margin from the axis line for the text
        painter.drawText(QRect(0, y_img_coord - 10, marginLeft - 8, 20), Qt::AlignRight | Qt::AlignVCenter, QString::number(val, 'f', 2));
        if (i > 0 && i < numGridLinesY) painter.drawLine(marginLeft - 5, y_img_coord, marginLeft, y_img_coord); // Tick mark
    }
    // X-axis tick labels
    painter.setFont(tickLabelFont);
    painter.drawText(QRect(marginLeft - 5, marginTop + plotHeight + 5, 30, 20), Qt::AlignHCenter | Qt::AlignTop, "0"); // Increased Y offset for tick label
    if (dataPoints.size() > 1) {
        painter.drawText(QRect(marginLeft + plotWidth - 25, marginTop + plotHeight + 5, 50, 20), Qt::AlignHCenter | Qt::AlignTop, QString::number(dataPoints.size() - 1)); // Increased Y offset
    }
    for (int i = 1; i < numGridLinesX; ++i) {
        int x_img_coord = marginLeft + (i * plotWidth / numGridLinesX);
        painter.drawLine(x_img_coord, marginTop + plotHeight, x_img_coord, marginTop + plotHeight + 5); // Tick mark
    }


    return image;
}

void WaveformPlotter::saveImageAndSetUrl(const QImage& image) {
    if (image.isNull()) {
        if (m_plotImageUrl.isValid()) { // Clear only if it was previously valid
            m_plotImageUrl = QUrl();
            emit plotImageUrlChanged();
        }
        return;
    }

    QString tempPath = QStandardPaths::writableLocation(QStandardPaths::AppLocalDataLocation); // More persistent temp location
    if (tempPath.isEmpty()) {
        tempPath = QDir::currentPath(); // Fallback
        qWarning() << "WaveformPlotter: Could not get app local data location, using current path:" << tempPath;
    }

    QDir dir(tempPath);
    if (!dir.exists()) {
        if (!dir.mkpath(".")) {
            qWarning() << "WaveformPlotter: Could not create directory:" << tempPath;
            // Fallback to simpler temp if mkpath fails
            tempPath = QStandardPaths::writableLocation(QStandardPaths::TempLocation);
            if (tempPath.isEmpty()) tempPath = ".";
            dir.setPath(tempPath);
            if(!dir.exists()) dir.mkpath("."); // Try again with simpler temp
        }
    }

    QString fileName = getUniqueFileName();
    QString filePath = dir.filePath(fileName);

    // Ensure any existing file with the same name is removed to avoid caching issues with QML Image
    if (QFile::exists(filePath)) {
        QFile::remove(filePath);
    }

    if (image.save(filePath, "PNG")) {
        QUrl newUrl = QUrl::fromLocalFile(filePath);
        if (m_plotImageUrl != newUrl) {
            m_plotImageUrl = newUrl;
            emit plotImageUrlChanged();
        }
        qDebug() << "WaveformPlotter: Plot saved to" << filePath << "URL:" << m_plotImageUrl;
    } else {
        qWarning() << "WaveformPlotter: Failed to save plot image to" << filePath;
        if (m_plotImageUrl.isValid()) {
            m_plotImageUrl = QUrl();
            emit plotImageUrlChanged();
        }
    }
}

// New methods for accumulating data
void WaveformPlotter::clearPlotData() {
    qDebug() << "WaveformPlotter: Clearing accumulated data and plot.";
    m_accumulatedDataString.clear();
    m_accumulatedDataStringCH1.clear();
    m_accumulatedDataStringCH2.clear();
    saveImageAndSetUrl(QImage()); // Clears the image by saving a null/empty image
}

void WaveformPlotter::accumulateData(const QString& dataChunk) {
    // qDebug() << "WaveformPlotter: Accumulating data chunk, length:" << dataChunk.length();
    m_accumulatedDataString.append(dataChunk);
}

void WaveformPlotter::accumulateDataCH1(const QString& dataChunk) {
    qDebug() << "WaveformPlotter: Accumulating CH1 data chunk, length:" << dataChunk.length();
    m_accumulatedDataStringCH1.append(dataChunk);
}

void WaveformPlotter::accumulateDataCH2(const QString& dataChunk) {
    qDebug() << "WaveformPlotter: Accumulating CH2 data chunk, length:" << dataChunk.length();
    m_accumulatedDataStringCH2.append(dataChunk);
}

void WaveformPlotter::finalizePlotting() {
    qDebug() << "WaveformPlotter: Finalizing plot with accumulated data, total length:" << m_accumulatedDataString.length();
    if (m_accumulatedDataString.trimmed().isEmpty()) {
        qWarning() << "WaveformPlotter: Accumulated data is empty or whitespace-only.";
        saveImageAndSetUrl(QImage());
        return;
    }
    QList<double> dataPoints = parseDataString(m_accumulatedDataString);
    QImage plotImage = generatePlotImage(dataPoints);
    saveImageAndSetUrl(plotImage);
}

void WaveformPlotter::finalizeDualChannelPlotting() {
    qDebug() << "WaveformPlotter: Finalizing dual channel plot. CH1 length:" << m_accumulatedDataStringCH1.length() 
             << ", CH2 length:" << m_accumulatedDataStringCH2.length();
    
    if (m_accumulatedDataStringCH1.trimmed().isEmpty() && m_accumulatedDataStringCH2.trimmed().isEmpty()) {
        qWarning() << "WaveformPlotter: Both CH1 and CH2 data are empty.";
        saveImageAndSetUrl(QImage());
        return;
    }
    
    QList<double> ch1Data = parseDataString(m_accumulatedDataStringCH1);
    QList<double> ch2Data = parseDataString(m_accumulatedDataStringCH2);
    QImage plotImage = generateDualChannelPlotImage(ch1Data, ch2Data);
    saveImageAndSetUrl(plotImage);
}

QImage WaveformPlotter::generateDualChannelPlotImage(const QList<double>& ch1Data, const QList<double>& ch2Data) {
    // 如果两个通道都没有数据，返回空图像
    if (ch1Data.isEmpty() && ch2Data.isEmpty()) {
        qWarning() << "WaveformPlotter: No data points to plot for either channel.";
        return QImage();
    }

    const int imgWidth = 600;
    const int imgHeight = 400;
    const int marginTop = 40, marginBottom = 50, marginLeft = 60, marginRight = 20;
    const int plotWidth = imgWidth - marginLeft - marginRight;
    const int plotHeight = imgHeight - marginTop - marginBottom;

    QImage image(imgWidth, imgHeight, QImage::Format_ARGB32_Premultiplied);
    image.fill(Qt::white);

    QPainter painter(&image);
    painter.setRenderHint(QPainter::Antialiasing);

    // Define fonts
    QFont titleFont("Microsoft YaHei", 14, QFont::Bold);
    QFont axisLabelFont("Microsoft YaHei", 10);
    QFont tickLabelFont("Microsoft YaHei", 8);

    // 确定Y轴范围（包括两个通道的数据）
    double yMin = 0, yMax = 0;
    bool hasData = false;
    
    if (!ch1Data.isEmpty()) {
        yMin = yMax = ch1Data.first();
        hasData = true;
        for (double val : ch1Data) {
            if (val < yMin) yMin = val;
            if (val > yMax) yMax = val;
        }
    }
    
    if (!ch2Data.isEmpty()) {
        if (!hasData) {
            yMin = yMax = ch2Data.first();
            hasData = true;
        }
        for (double val : ch2Data) {
            if (val < yMin) yMin = val;
            if (val > yMax) yMax = val;
        }
    }
    
    if (!hasData) return QImage();
    
    if (std::fabs(yMin - yMax) < 1e-9) {
        yMin -= 1.0;
        yMax += 1.0;
    }
    double yRange = yMax - yMin;
    if (std::fabs(yRange) < 1e-9) yRange = 1.0;

    // Transform painter to plot coordinates
    painter.translate(marginLeft, marginTop + plotHeight);
    painter.scale(1, -1);

    // Draw Axes
    QPen axisPen(Qt::black, 1);
    painter.setPen(axisPen);
    painter.drawLine(0, 0, plotWidth, 0); // X-axis
    painter.drawLine(0, 0, 0, plotHeight);  // Y-axis

    // Draw Grid
    QPen gridPen(Qt::lightGray, 1, Qt::DotLine);
    painter.setPen(gridPen);
    int numGridLinesX = 10;
    int numGridLinesY = 5;
    for (int i = 1; i < numGridLinesX; ++i) {
        int x = (i * plotWidth / numGridLinesX);
        painter.drawLine(x, 0, x, plotHeight);
    }
    for (int i = 1; i < numGridLinesY; ++i) {
        int y = (i * plotHeight / numGridLinesY);
        painter.drawLine(0, y, plotWidth, y);
    }

    // 确定X轴范围（使用数据点数更多的通道）
    int maxDataPoints = qMax(ch1Data.size(), ch2Data.size());
    double xStep = maxDataPoints > 1 ? static_cast<double>(plotWidth) / (maxDataPoints - 1) : 0;

    // Draw CH1 Waveform (蓝色)
    if (!ch1Data.isEmpty()) {
        QPen ch1Pen(Qt::blue, 2);
        painter.setPen(ch1Pen);
        QPainterPath ch1Path;
        double ch1XStep = ch1Data.size() > 1 ? static_cast<double>(plotWidth) / (ch1Data.size() - 1) : 0;
        
        for (int i = 0; i < ch1Data.size(); ++i) {
            double x_coord = i * ch1XStep;
            double y_coord = ((ch1Data[i] - yMin) / yRange * plotHeight);
            if (i == 0) {
                ch1Path.moveTo(x_coord, y_coord);
            } else {
                ch1Path.lineTo(x_coord, y_coord);
            }
            
            // 每处理100个点就让UI线程处理事件（更频繁）
            if (i % 100 == 0) {
                QCoreApplication::processEvents(QEventLoop::AllEvents, 1);
            }
        }
        painter.drawPath(ch1Path);
    }

    // Draw CH2 Waveform (红色)
    if (!ch2Data.isEmpty()) {
        QPen ch2Pen(Qt::red, 2);
        painter.setPen(ch2Pen);
        QPainterPath ch2Path;
        double ch2XStep = ch2Data.size() > 1 ? static_cast<double>(plotWidth) / (ch2Data.size() - 1) : 0;
        
        for (int i = 0; i < ch2Data.size(); ++i) {
            double x_coord = i * ch2XStep;
            double y_coord = ((ch2Data[i] - yMin) / yRange * plotHeight);
            if (i == 0) {
                ch2Path.moveTo(x_coord, y_coord);
            } else {
                ch2Path.lineTo(x_coord, y_coord);
            }
            
            // 每处理100个点就让UI线程处理事件（更频繁）
            if (i % 100 == 0) {
                QCoreApplication::processEvents(QEventLoop::AllEvents, 1);
            }
        }
        painter.drawPath(ch2Path);
    }

    // Reset transform for text
    painter.resetTransform();
    painter.setPen(Qt::black);

    // Title
    painter.setFont(titleFont);
    painter.drawText(QRect(marginLeft, 5, plotWidth, marginTop - 10), Qt::AlignCenter, QStringLiteral("双通道波形"));

    // X-axis Label
    painter.setFont(axisLabelFont);
    painter.drawText(QRect(marginLeft, marginTop + plotHeight + 15, plotWidth, marginBottom - 15), Qt::AlignCenter, QStringLiteral("采样点数"));

    // Y-axis Label
    painter.setFont(axisLabelFont);
    painter.drawText(QRect(5, marginTop, marginLeft - 10, plotHeight), Qt::AlignCenter | Qt::TextWordWrap, QStringLiteral("采样值"));

    // Y-axis tick labels
    painter.setFont(tickLabelFont);
    for (int i = 0; i <= numGridLinesY; ++i) {
        double val = yMin + (i * yRange / numGridLinesY);
        int y_img_coord = marginTop + plotHeight - (i * plotHeight / numGridLinesY);
        painter.drawText(QRect(0, y_img_coord - 10, marginLeft - 8, 20), Qt::AlignRight | Qt::AlignVCenter, QString::number(val, 'f', 2));
        if (i > 0 && i < numGridLinesY) painter.drawLine(marginLeft - 5, y_img_coord, marginLeft, y_img_coord);
    }
    
    // X-axis tick labels
    painter.setFont(tickLabelFont);
    painter.drawText(QRect(marginLeft - 5, marginTop + plotHeight + 5, 30, 20), Qt::AlignHCenter | Qt::AlignTop, "0");
    if (maxDataPoints > 1) {
        painter.drawText(QRect(marginLeft + plotWidth - 25, marginTop + plotHeight + 5, 50, 20), Qt::AlignHCenter | Qt::AlignTop, QString::number(maxDataPoints - 1));
    }
    for (int i = 1; i < numGridLinesX; ++i) {
        int x_img_coord = marginLeft + (i * plotWidth / numGridLinesX);
        painter.drawLine(x_img_coord, marginTop + plotHeight, x_img_coord, marginTop + plotHeight + 5);
    }

    // Draw Legend
    painter.setFont(axisLabelFont);
    int legendY = marginTop + 20;
    if (!ch1Data.isEmpty()) {
        painter.setPen(Qt::blue);
        painter.drawLine(plotWidth + marginLeft - 100, legendY, plotWidth + marginLeft - 80, legendY);
        painter.setPen(Qt::black);
        painter.drawText(plotWidth + marginLeft - 75, legendY - 5, 60, 20, Qt::AlignLeft | Qt::AlignVCenter, "CH1");
        legendY += 20;
    }
    if (!ch2Data.isEmpty()) {
        painter.setPen(Qt::red);
        painter.drawLine(plotWidth + marginLeft - 100, legendY, plotWidth + marginLeft - 80, legendY);
        painter.setPen(Qt::black);
        painter.drawText(plotWidth + marginLeft - 75, legendY - 5, 60, 20, Qt::AlignLeft | Qt::AlignVCenter, "CH2");
    }

    return image;
}
