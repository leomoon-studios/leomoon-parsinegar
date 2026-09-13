#include "TextDirectionBridge.h"

#include <QQuickTextDocument>
#include <QTextBlock>
#include <QTextBlockFormat>
#include <QTextCursor>
#include <QTextDocument>

#include <optional>

namespace {

std::optional<Qt::LayoutDirection> firstStrongDirection(const QString &text)
{
    for (char32_t character : text.toUcs4()) {
        switch (QChar::direction(character)) {
        case QChar::DirL:
            return Qt::LeftToRight;
        case QChar::DirR:
        case QChar::DirAL:
            return Qt::RightToLeft;
        default:
            break;
        }
    }
    return std::nullopt;
}

QQuickTextDocument *textDocumentWrapper(QObject *object)
{
    auto *wrapper = qobject_cast<QQuickTextDocument *>(object);
    return wrapper && wrapper->textDocument() ? wrapper : nullptr;
}

void applyParagraphFormats(QTextDocument *document)
{
    Qt::LayoutDirection inheritedDirection = Qt::RightToLeft;
    QTextCursor cursor(document);
    bool editBlockStarted = false;
    for (QTextBlock block = document->begin(); block.isValid(); block = block.next()) {
        const auto detectedDirection = firstStrongDirection(block.text());
        if (detectedDirection.has_value()) {
            inheritedDirection = detectedDirection.value();
        }

        const Qt::LayoutDirection direction = detectedDirection.value_or(inheritedDirection);
        const Qt::Alignment alignment = (direction == Qt::RightToLeft ? Qt::AlignRight : Qt::AlignLeft)
            | Qt::AlignAbsolute;
        QTextBlockFormat format = block.blockFormat();
        if (format.layoutDirection() == direction && format.alignment() == alignment) {
            continue;
        }

        if (!editBlockStarted) {
            if (document->isUndoAvailable()) {
                cursor.joinPreviousEditBlock();
            } else {
                cursor.beginEditBlock();
            }
            editBlockStarted = true;
        }
        format.setLayoutDirection(direction);
        format.setAlignment(alignment);
        cursor.setPosition(block.position());
        cursor.setBlockFormat(format);
    }
    if (editBlockStarted) {
        cursor.endEditBlock();
    }
}

} // namespace

TextDirectionBridge::TextDirectionBridge(QObject *parent)
    : QObject(parent)
{
}

bool TextDirectionBridge::applyAutomaticDirection(QObject *quickTextDocument) const
{
    QQuickTextDocument *wrapper = textDocumentWrapper(quickTextDocument);
    if (!wrapper) {
        return false;
    }

    applyParagraphFormats(wrapper->textDocument());
    return true;
}

QString TextDirectionBridge::plainText(QObject *quickTextDocument) const
{
    QQuickTextDocument *wrapper = textDocumentWrapper(quickTextDocument);
    return wrapper ? wrapper->textDocument()->toPlainText() : QString();
}

bool TextDirectionBridge::setPlainText(QObject *quickTextDocument, const QString &text) const
{
    QQuickTextDocument *wrapper = textDocumentWrapper(quickTextDocument);
    if (!wrapper) {
        return false;
    }

    QTextDocument *document = wrapper->textDocument();
    if (document->toPlainText() != text) {
        document->setPlainText(text);
    }
    applyParagraphFormats(document);
    return true;
}
