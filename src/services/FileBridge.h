#pragma once

#include <QObject>
#include <QString>
#include <QUrl>
#include <QVariantList>
#include <QVariantMap>

class FileBridge final : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString lastError READ lastError NOTIFY lastErrorChanged)
    Q_PROPERTY(QVariantList fontCatalog READ fontCatalog NOTIFY fontCatalogChanged)
    Q_PROPERTY(bool fontCatalogReady READ fontCatalogReady NOTIFY fontCatalogReadyChanged)
    Q_PROPERTY(bool fontCatalogScanning READ fontCatalogScanning NOTIFY fontCatalogScanningChanged)

public:
    static constexpr qint64 maximumFontBytes = 50LL * 1024 * 1024;
    static constexpr qint64 maximumSvgBytes = 16LL * 1024 * 1024;
    static constexpr qint64 maximumDocumentBytes = 1LL * 1024 * 1024;
    static constexpr qsizetype maximumDocumentCharacters = 250000;

    explicit FileBridge(QObject *parent = nullptr);

    [[nodiscard]] QString lastError() const;
    [[nodiscard]] QVariantList fontCatalog() const;
    [[nodiscard]] bool fontCatalogReady() const;
    [[nodiscard]] bool fontCatalogScanning() const;

    Q_INVOKABLE QVariantMap readFont(const QUrl &url);
    Q_INVOKABLE bool readFontAsync(int requestId, const QUrl &url);
    Q_INVOKABLE bool readBundledFontAsync(int requestId);
    Q_INVOKABLE QString localFilePath(const QUrl &url);
    Q_INVOKABLE QUrl localFileUrl(const QString &path) const;
    Q_INVOKABLE bool fontPathExists(const QString &path) const;
    Q_INVOKABLE bool scanInstalledFontsAsync();
    Q_INVOKABLE QVariantMap readTextDocument(const QUrl &url);
    Q_INVOKABLE QVariantMap writeTextDocument(const QUrl &url, const QString &text);
    Q_INVOKABLE QVariantMap writeSvg(const QUrl &url, const QString &svg);
    Q_INVOKABLE bool writeSvgAsync(int requestId, const QUrl &url, const QString &svg);

signals:
    void fontRead(const QString &path, qint64 byteCount);
    void textDocumentRead(const QString &path, qsizetype characterCount, qint64 byteCount);
    void textDocumentWritten(const QString &path, qsizetype characterCount, qint64 byteCount);
    void svgWritten(const QString &path, qint64 byteCount);
    void fontReadCompleted(int requestId, const QVariantMap &result);
    void svgWriteCompleted(int requestId, const QVariantMap &result);
    void operationFailed(const QString &code, const QString &message);
    void lastErrorChanged();
    void fontCatalogChanged();
    void fontCatalogReadyChanged();
    void fontCatalogScanningChanged();

private:
    [[nodiscard]] bool localPath(const QUrl &url, QString *path, QVariantMap *error);
    [[nodiscard]] QVariantMap success(const QVariantMap &values = {});
    [[nodiscard]] QVariantMap failure(const QString &code, const QString &message);

    QString m_lastError;
    QVariantList m_installedFonts;
    bool m_fontCatalogReady = false;
    bool m_fontCatalogScanning = false;
};
