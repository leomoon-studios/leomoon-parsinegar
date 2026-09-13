#pragma once

#include <QObject>
#include <QString>

class ClipboardBridge final : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString lastError READ lastError NOTIFY lastErrorChanged)

public:
    explicit ClipboardBridge(QObject *parent = nullptr);

    [[nodiscard]] QString lastError() const;

    Q_INVOKABLE bool copyText(const QString &text);
    Q_INVOKABLE QString readText();

signals:
    void copied(const QString &text);
    void operationFailed(const QString &code, const QString &message);
    void lastErrorChanged();

private:
    void clearError();
    void setError(const QString &code, const QString &message);

    QString m_lastError;
};
