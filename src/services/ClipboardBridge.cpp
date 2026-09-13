#include "ClipboardBridge.h"

#include <QClipboard>
#include <QGuiApplication>

ClipboardBridge::ClipboardBridge(QObject *parent)
    : QObject(parent)
{
}

QString ClipboardBridge::lastError() const
{
    return m_lastError;
}

bool ClipboardBridge::copyText(const QString &text)
{
    QClipboard *clipboard = QGuiApplication::clipboard();
    if (clipboard == nullptr) {
        setError(QStringLiteral("CLIPBOARD_UNAVAILABLE"), QStringLiteral("The system clipboard is unavailable."));
        return false;
    }

    clipboard->setText(text, QClipboard::Clipboard);
    if (clipboard->text(QClipboard::Clipboard) != text) {
        setError(QStringLiteral("CLIPBOARD_WRITE_FAILED"), QStringLiteral("The system clipboard did not retain the copied text."));
        return false;
    }

    clearError();
    emit copied(text);
    return true;
}

QString ClipboardBridge::readText()
{
    QClipboard *clipboard = QGuiApplication::clipboard();
    if (clipboard == nullptr) {
        setError(QStringLiteral("CLIPBOARD_UNAVAILABLE"), QStringLiteral("The system clipboard is unavailable."));
        return {};
    }

    clearError();
    return clipboard->text(QClipboard::Clipboard);
}

void ClipboardBridge::clearError()
{
    if (m_lastError.isEmpty()) {
        return;
    }
    m_lastError.clear();
    emit lastErrorChanged();
}

void ClipboardBridge::setError(const QString &code, const QString &message)
{
    if (m_lastError != message) {
        m_lastError = message;
        emit lastErrorChanged();
    }
    emit operationFailed(code, message);
}
