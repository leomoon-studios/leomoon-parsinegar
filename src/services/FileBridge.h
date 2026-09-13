#pragma once

#include <QObject>
#include <QString>
#include <QUrl>
#include <QVariantMap>

class FileBridge final : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString lastError READ lastError NOTIFY lastErrorChanged)

public:
    static constexpr qint64 maximumFontBytes = 50LL * 1024 * 1024;
    static constexpr qint64 maximumSvgBytes = 16LL * 1024 * 1024;

    explicit FileBridge(QObject *parent = nullptr);

    [[nodiscard]] QString lastError() const;

    Q_INVOKABLE QVariantMap readFont(const QUrl &url);
    Q_INVOKABLE bool fontPathExists(const QString &path) const;
    Q_INVOKABLE QVariantMap writeSvg(const QUrl &url, const QString &svg);

signals:
    void fontRead(const QString &path, qint64 byteCount);
    void svgWritten(const QString &path, qint64 byteCount);
    void operationFailed(const QString &code, const QString &message);
    void lastErrorChanged();

private:
    [[nodiscard]] bool localPath(const QUrl &url, QString *path, QVariantMap *error);
    [[nodiscard]] QVariantMap success(const QVariantMap &values = {});
    [[nodiscard]] QVariantMap failure(const QString &code, const QString &message);

    QString m_lastError;
};
