#pragma once

#include <QByteArray>
#include <QNetworkAccessManager>
#include <QObject>
#include <QString>

class ReleaseChecker final : public QObject
{
    Q_OBJECT

public:
    explicit ReleaseChecker(QObject *parent = nullptr);

    Q_INVOKABLE void checkForUpdates();
    [[nodiscard]] static QString newerVersion(const QByteArray &releaseJson,
                                               const QString &currentVersion);

signals:
    void updateAvailable(const QString &version);

private:
    QNetworkAccessManager m_network;
    bool m_checked = false;
};
