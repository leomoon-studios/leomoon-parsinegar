#include "ClipboardKeeper.h"

#include <QClipboard>
#include <QCoreApplication>
#include <QDataStream>
#include <QDir>
#include <QElapsedTimer>
#include <QFile>
#include <QFileInfo>
#include <QGuiApplication>
#include <QProcess>
#include <QTemporaryFile>
#include <QThread>
#include <QTimer>

namespace {

constexpr auto keeperArgument = "--clipboard-keeper";
constexpr auto transferFilePrefix = "parsinegar-clipboard-";
constexpr int handoffTimeoutMilliseconds = 5000;

void setError(QString *errorMessage, const QString &message)
{
    if (errorMessage != nullptr) {
        *errorMessage = message;
    }
}

bool isPrivateTransferFile(const QFileInfo &info)
{
    const QString temporaryDirectory = QFileInfo(QDir::tempPath()).canonicalFilePath();
    const QString parentDirectory = info.dir().canonicalPath();
#ifdef Q_OS_WIN
    return info.isFile()
        && info.fileName().startsWith(QString::fromLatin1(transferFilePrefix))
        && parentDirectory.compare(temporaryDirectory, Qt::CaseInsensitive) == 0;
#else
    const QFileDevice::Permissions publicPermissions = QFileDevice::ReadGroup
        | QFileDevice::WriteGroup
        | QFileDevice::ExeGroup
        | QFileDevice::ReadOther
        | QFileDevice::WriteOther
        | QFileDevice::ExeOther;
    return info.isFile()
        && info.fileName().startsWith(QString::fromLatin1(transferFilePrefix))
        && parentDirectory == temporaryDirectory
        && (info.permissions() & publicPermissions) == QFileDevice::Permissions {};
#endif
}

} // namespace

namespace ClipboardKeeper {

bool invocationTransferPath(const QStringList &arguments, QString *transferPath)
{
    const qsizetype index = arguments.indexOf(QString::fromLatin1(keeperArgument));
    if (index < 0) {
        return false;
    }
    if (index + 1 >= arguments.size() || arguments.at(index + 1).isEmpty()) {
        if (transferPath != nullptr) {
            transferPath->clear();
        }
        return true;
    }
    if (transferPath != nullptr) {
        *transferPath = arguments.at(index + 1);
    }
    return true;
}

bool startDetached(
    const QString &text,
    QString *errorMessage,
    int lifetimeMilliseconds,
    const QString &executablePath)
{
    const QByteArray payload = text.toUtf8();
    if (payload.size() > maximumPayloadBytes) {
        setError(errorMessage, QStringLiteral("Clipboard text exceeds the handoff limit."));
        return false;
    }
    if (lifetimeMilliseconds < 0) {
        setError(errorMessage, QStringLiteral("Clipboard keeper lifetime is invalid."));
        return false;
    }

    QTemporaryFile transferFile(
        QDir::temp().filePath(QString::fromLatin1(transferFilePrefix) + QStringLiteral("XXXXXX")));
    if (!transferFile.open()
        || !transferFile.setPermissions(QFileDevice::ReadOwner | QFileDevice::WriteOwner)) {
        setError(errorMessage, QStringLiteral("Could not create a private clipboard handoff file."));
        return false;
    }

    QDataStream stream(&transferFile);
    stream.setVersion(QDataStream::Qt_6_5);
    stream << payload << lifetimeMilliseconds;
    if (stream.status() != QDataStream::Ok || !transferFile.flush()) {
        setError(errorMessage, QStringLiteral("Could not write the clipboard handoff file."));
        return false;
    }

    const QString transferPath = transferFile.fileName();
    transferFile.close();
    transferFile.setAutoRemove(false);
    const QString program = executablePath.isEmpty()
        ? QCoreApplication::applicationFilePath()
        : executablePath;
    if (program.isEmpty()
        || !QProcess::startDetached(program, {QString::fromLatin1(keeperArgument), transferPath})) {
        QFile::remove(transferPath);
        setError(errorMessage, QStringLiteral("Could not start the clipboard keeper process."));
        return false;
    }

    QElapsedTimer timer;
    timer.start();
    while (QFileInfo::exists(transferPath) && timer.elapsed() < handoffTimeoutMilliseconds) {
        QThread::msleep(10);
    }
    if (QFileInfo::exists(transferPath)) {
        QFile::remove(transferPath);
        setError(errorMessage, QStringLiteral("The clipboard keeper did not accept the text."));
        return false;
    }

    if (errorMessage != nullptr) {
        errorMessage->clear();
    }
    return true;
}

int run(const QString &transferPath)
{
    const QFileInfo transferInfo(transferPath);
    if (transferPath.isEmpty() || !isPrivateTransferFile(transferInfo)
        || transferInfo.size() > maximumPayloadBytes + 64) {
        return EXIT_FAILURE;
    }

    QFile transferFile(transferPath);
    if (!transferFile.open(QIODevice::ReadOnly)) {
        return EXIT_FAILURE;
    }
    QDataStream stream(&transferFile);
    stream.setVersion(QDataStream::Qt_6_5);
    QByteArray payload;
    int lifetimeMilliseconds = 0;
    stream >> payload >> lifetimeMilliseconds;
    const bool validFrame = stream.status() == QDataStream::Ok
        && transferFile.atEnd()
        && payload.size() <= maximumPayloadBytes
        && lifetimeMilliseconds >= 0;
    transferFile.close();
    if (!validFrame) {
        return EXIT_FAILURE;
    }

    const QString text = QString::fromUtf8(payload);
    if (text.toUtf8() != payload) {
        return EXIT_FAILURE;
    }

    QClipboard *clipboard = QGuiApplication::clipboard();
    if (clipboard == nullptr) {
        return EXIT_FAILURE;
    }
    clipboard->setText(text, QClipboard::Clipboard);
    if (clipboard->text(QClipboard::Clipboard) != text || !QFile::remove(transferPath)) {
        return EXIT_FAILURE;
    }

    QObject::connect(clipboard, &QClipboard::dataChanged, QCoreApplication::instance(), [clipboard, text]() {
        if (!clipboard->ownsClipboard() || clipboard->text(QClipboard::Clipboard) != text) {
            QCoreApplication::quit();
        }
    });
    if (lifetimeMilliseconds > 0) {
        QTimer::singleShot(lifetimeMilliseconds, QCoreApplication::instance(), &QCoreApplication::quit);
    }
    return QCoreApplication::exec();
}

} // namespace ClipboardKeeper
