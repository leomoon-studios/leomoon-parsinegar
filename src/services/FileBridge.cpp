#include "FileBridge.h"

#include <QDir>
#include <QFile>
#include <QFileInfo>
#include <QSaveFile>

FileBridge::FileBridge(QObject *parent)
    : QObject(parent)
{
}

QString FileBridge::lastError() const
{
    return m_lastError;
}

QVariantMap FileBridge::readFont(const QUrl &url)
{
    QString path;
    QVariantMap pathError;
    if (!localPath(url, &path, &pathError)) {
        return pathError;
    }

    const QFileInfo info(path);
    const QString suffix = info.suffix().toLower();
    if (suffix != QStringLiteral("ttf") && suffix != QStringLiteral("otf") && suffix != QStringLiteral("ttc")) {
        return failure(QStringLiteral("UNSUPPORTED_FONT_TYPE"), QStringLiteral("The selected file must be TTF, OTF, or TTC."));
    }
    if (!info.exists() || !info.isFile()) {
        return failure(QStringLiteral("FONT_NOT_FOUND"), QStringLiteral("The selected font file does not exist."));
    }
    if (info.size() > maximumFontBytes) {
        return failure(QStringLiteral("FONT_TOO_LARGE"), QStringLiteral("The selected font exceeds the supported size."));
    }

    QFile file(path);
    if (!file.open(QIODevice::ReadOnly)) {
        return failure(QStringLiteral("FONT_READ_FAILED"), file.errorString());
    }
    const QByteArray bytes = file.read(maximumFontBytes + 1);
    if (bytes.size() > maximumFontBytes) {
        return failure(QStringLiteral("FONT_TOO_LARGE"), QStringLiteral("The selected font exceeds the supported size."));
    }

    emit fontRead(path, bytes.size());
    return success({
        { QStringLiteral("path"), path },
        { QStringLiteral("data"), bytes },
        { QStringLiteral("byteCount"), bytes.size() },
    });
}

bool FileBridge::fontPathExists(const QString &path) const
{
    if (path.isEmpty()) {
        return false;
    }
    const QFileInfo info(path);
    const QString suffix = info.suffix().toLower();
    return info.isAbsolute() && info.isFile() && info.isReadable()
        && (suffix == QStringLiteral("ttf") || suffix == QStringLiteral("otf")
            || suffix == QStringLiteral("ttc"));
}

QVariantMap FileBridge::writeSvg(const QUrl &url, const QString &svg)
{
    QString path;
    QVariantMap pathError;
    if (!localPath(url, &path, &pathError)) {
        return pathError;
    }
    if (QFileInfo(path).suffix().compare(QStringLiteral("svg"), Qt::CaseInsensitive) != 0) {
        path += QStringLiteral(".svg");
    }

    const QByteArray bytes = svg.toUtf8();
    if (bytes.size() > maximumSvgBytes) {
        return failure(QStringLiteral("SVG_TOO_LARGE"), QStringLiteral("The SVG data exceeds the supported size."));
    }

    const QFileInfo destination(path);
    if (!destination.dir().exists()) {
        return failure(QStringLiteral("SVG_DIRECTORY_NOT_FOUND"), QStringLiteral("The destination directory does not exist."));
    }

    QSaveFile file(path);
    if (!file.open(QIODevice::WriteOnly)) {
        return failure(QStringLiteral("SVG_WRITE_FAILED"), file.errorString());
    }
    if (file.write(bytes) != bytes.size()) {
        file.cancelWriting();
        return failure(QStringLiteral("SVG_WRITE_FAILED"), file.errorString());
    }
    if (!file.commit()) {
        return failure(QStringLiteral("SVG_WRITE_FAILED"), file.errorString());
    }

    emit svgWritten(path, bytes.size());
    return success({
        { QStringLiteral("path"), path },
        { QStringLiteral("byteCount"), bytes.size() },
    });
}

bool FileBridge::localPath(const QUrl &url, QString *path, QVariantMap *error)
{
    if (!url.isValid() || !url.isLocalFile() || !url.query().isEmpty() || !url.fragment().isEmpty()) {
        *error = failure(QStringLiteral("INVALID_LOCAL_URL"), QStringLiteral("Only local file URLs are supported."));
        return false;
    }

    const QString candidate = QDir::cleanPath(url.toLocalFile());
    if (candidate.isEmpty() || !QFileInfo(candidate).isAbsolute()) {
        *error = failure(QStringLiteral("INVALID_LOCAL_URL"), QStringLiteral("The local file URL must contain an absolute path."));
        return false;
    }

    *path = candidate;
    return true;
}

QVariantMap FileBridge::success(const QVariantMap &values)
{
    if (!m_lastError.isEmpty()) {
        m_lastError.clear();
        emit lastErrorChanged();
    }
    QVariantMap result = values;
    result.insert(QStringLiteral("ok"), true);
    return result;
}

QVariantMap FileBridge::failure(const QString &code, const QString &message)
{
    if (m_lastError != message) {
        m_lastError = message;
        emit lastErrorChanged();
    }
    emit operationFailed(code, message);
    return {
        { QStringLiteral("ok"), false },
        { QStringLiteral("code"), code },
        { QStringLiteral("message"), message },
    };
}
