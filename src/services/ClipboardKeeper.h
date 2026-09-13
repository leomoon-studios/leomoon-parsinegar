#pragma once

#include <QString>
#include <QStringList>

namespace ClipboardKeeper {

inline constexpr qsizetype maximumPayloadBytes = 4 * 1024 * 1024;

[[nodiscard]] bool invocationTransferPath(const QStringList &arguments, QString *transferPath);
[[nodiscard]] bool startDetached(
    const QString &text,
    QString *errorMessage,
    int lifetimeMilliseconds = 0,
    const QString &executablePath = {});
[[nodiscard]] int run(const QString &serverName);

} // namespace ClipboardKeeper
