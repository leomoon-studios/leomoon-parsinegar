#pragma once

#include <QObject>

class TextDirectionBridge final : public QObject
{
    Q_OBJECT

public:
    explicit TextDirectionBridge(QObject *parent = nullptr);

    Q_INVOKABLE bool applyAutomaticDirection(QObject *quickTextDocument) const;
    Q_INVOKABLE QString paragraphDirection(QObject *quickTextDocument, int position) const;
    Q_INVOKABLE QString plainText(QObject *quickTextDocument) const;
    Q_INVOKABLE bool setPlainText(QObject *quickTextDocument, const QString &text) const;
};
