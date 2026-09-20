#include "FileBridge.h"

#include <QDir>
#include <QDirIterator>
#include <QFile>
#include <QFileInfo>
#include <QFutureWatcher>
#include <QRawFont>
#include <QSaveFile>
#include <QSet>
#include <QStandardPaths>
#include <QStringConverter>
#include <QtConcurrentRun>

#include <algorithm>

namespace {

constexpr auto bundledFontPath = ":/qt/qml/LeoMoon/ParsiNegar/assets/fonts/Vazirmatn[wght].ttf";

QVariantMap readBundledFont()
{
    QFile file(QString::fromUtf8(bundledFontPath));
    if (!file.open(QIODevice::ReadOnly)) {
        return {
            { QStringLiteral("ok"), false },
            { QStringLiteral("code"), QStringLiteral("FONT_READ_FAILED") },
            { QStringLiteral("message"), file.errorString() },
        };
    }
    const QByteArray bytes = file.read(FileBridge::maximumFontBytes + 1);
    if (bytes.size() > FileBridge::maximumFontBytes) {
        return {
            { QStringLiteral("ok"), false },
            { QStringLiteral("code"), QStringLiteral("FONT_TOO_LARGE") },
            { QStringLiteral("message"), QStringLiteral("The bundled font exceeds the supported size.") },
        };
    }
    return {
        { QStringLiteral("ok"), true },
        { QStringLiteral("path"), QStringLiteral("bundled:Vazirmatn") },
        { QStringLiteral("data"), bytes },
        { QStringLiteral("byteCount"), bytes.size() },
    };
}

void appendUniqueDirectory(QStringList *directories, const QString &path)
{
    if (path.isEmpty()) {
        return;
    }
    const QString cleanPath = QDir::cleanPath(path);
    if (!directories->contains(cleanPath)) {
        directories->append(cleanPath);
    }
}

QStringList fontDirectories()
{
    QStringList directories;
    for (const QString &path : QStandardPaths::standardLocations(QStandardPaths::FontsLocation)) {
        appendUniqueDirectory(&directories, path);
    }
    for (const QString &path : QStandardPaths::standardLocations(QStandardPaths::GenericDataLocation)) {
        appendUniqueDirectory(&directories, QDir(path).filePath(QStringLiteral("fonts")));
    }

#if defined(Q_OS_WIN)
    appendUniqueDirectory(&directories, QDir(qEnvironmentVariable("WINDIR")).filePath(QStringLiteral("Fonts")));
    appendUniqueDirectory(&directories,
        QDir(QStandardPaths::writableLocation(QStandardPaths::GenericDataLocation))
            .filePath(QStringLiteral("Microsoft/Windows/Fonts")));
#elif defined(Q_OS_MACOS)
    appendUniqueDirectory(&directories, QStringLiteral("/System/Library/Fonts"));
    appendUniqueDirectory(&directories, QStringLiteral("/Library/Fonts"));
    appendUniqueDirectory(&directories,
        QDir(QStandardPaths::writableLocation(QStandardPaths::HomeLocation))
            .filePath(QStringLiteral("Library/Fonts")));
#else
    appendUniqueDirectory(&directories, QStringLiteral("/usr/local/share/fonts"));
    appendUniqueDirectory(&directories, QStringLiteral("/usr/share/fonts"));
    appendUniqueDirectory(&directories,
        QDir(QStandardPaths::writableLocation(QStandardPaths::HomeLocation))
            .filePath(QStringLiteral(".fonts")));
#endif
    return directories;
}

bool supportedFontFile(const QFileInfo &info)
{
    const QString suffix = info.suffix().toLower();
    return info.isFile() && info.isReadable()
        && (suffix == QStringLiteral("ttf") || suffix == QStringLiteral("otf")
            || suffix == QStringLiteral("ttc"));
}

QVariantList buildFontCatalog()
{
    QVariantList fonts;
    QSet<QString> paths;
    QSet<QString> faces;
    for (const QString &directory : fontDirectories()) {
        if (!QFileInfo::exists(directory)) {
            continue;
        }
        QDirIterator iterator(directory, QDir::Files | QDir::Readable | QDir::NoDotAndDotDot,
                              QDirIterator::Subdirectories);
        while (iterator.hasNext()) {
            const QString path = QDir::cleanPath(iterator.next());
            const QFileInfo info = iterator.fileInfo();
            if (!supportedFontFile(info) || paths.contains(path)) {
                continue;
            }
            paths.insert(path);
            const QRawFont font(path, 16.0, QFont::PreferNoHinting);
            const QString family = font.familyName().trimmed();
            if (!font.isValid() || family.isEmpty()) {
                continue;
            }
            const QString style = font.styleName().trimmed();
            const QString faceKey = family.toCaseFolded() + QLatin1Char('\n') + style.toCaseFolded();
            if (faces.contains(faceKey)) {
                continue;
            }
            faces.insert(faceKey);
            const QString display = style.isEmpty() || style.compare(QStringLiteral("Regular"), Qt::CaseInsensitive) == 0
                ? family
                : QStringLiteral("%1 — %2").arg(family, style);
            fonts.append(QVariantMap {
                { QStringLiteral("family"), family },
                { QStringLiteral("style"), style },
                { QStringLiteral("display"), display },
                { QStringLiteral("path"), path },
            });
        }
    }
    std::sort(fonts.begin(), fonts.end(), [](const QVariant &left, const QVariant &right) {
        const auto leftMap = left.toMap();
        const auto rightMap = right.toMap();
        const int familyOrder = QString::localeAwareCompare(
            leftMap.value(QStringLiteral("family")).toString(),
            rightMap.value(QStringLiteral("family")).toString());
        if (familyOrder != 0) {
            return familyOrder < 0;
        }
        return QString::localeAwareCompare(
            leftMap.value(QStringLiteral("style")).toString(),
            rightMap.value(QStringLiteral("style")).toString()) < 0;
    });
    return fonts;
}

} // namespace

FileBridge::FileBridge(QObject *parent)
    : QObject(parent)
{
}

QString FileBridge::lastError() const
{
    return m_lastError;
}

QVariantList FileBridge::fontCatalog() const
{
    return m_installedFonts;
}

bool FileBridge::fontCatalogReady() const
{
    return m_fontCatalogReady;
}

bool FileBridge::fontCatalogScanning() const
{
    return m_fontCatalogScanning;
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

bool FileBridge::readFontAsync(int requestId, const QUrl &url)
{
    if (requestId <= 0) {
        return false;
    }
    auto *watcher = new QFutureWatcher<QVariantMap>(this);
    connect(watcher, &QFutureWatcher<QVariantMap>::finished, this, [this, watcher, requestId]() {
        const QVariantMap raw = watcher->result();
        watcher->deleteLater();
        QVariantMap result;
        if (raw.value(QStringLiteral("ok")).toBool()) {
            result = success(raw);
            emit fontRead(result.value(QStringLiteral("path")).toString(),
                          result.value(QStringLiteral("byteCount")).toLongLong());
        } else {
            result = failure(raw.value(QStringLiteral("code")).toString(),
                             raw.value(QStringLiteral("message")).toString());
        }
        emit fontReadCompleted(requestId, result);
    });
    watcher->setFuture(QtConcurrent::run([url]() {
        FileBridge bridge;
        return bridge.readFont(url);
    }));
    return true;
}

bool FileBridge::readBundledFontAsync(int requestId)
{
    if (requestId <= 0) {
        return false;
    }
    auto *watcher = new QFutureWatcher<QVariantMap>(this);
    connect(watcher, &QFutureWatcher<QVariantMap>::finished, this, [this, watcher, requestId]() {
        const QVariantMap raw = watcher->result();
        watcher->deleteLater();
        QVariantMap result;
        if (raw.value(QStringLiteral("ok")).toBool()) {
            result = success(raw);
            emit fontRead(result.value(QStringLiteral("path")).toString(),
                          result.value(QStringLiteral("byteCount")).toLongLong());
        } else {
            result = failure(raw.value(QStringLiteral("code")).toString(),
                             raw.value(QStringLiteral("message")).toString());
        }
        emit fontReadCompleted(requestId, result);
    });
    watcher->setFuture(QtConcurrent::run(readBundledFont));
    return true;
}

QString FileBridge::localFilePath(const QUrl &url)
{
    QString path;
    QVariantMap error;
    return localPath(url, &path, &error) ? path : QString();
}

QUrl FileBridge::localFileUrl(const QString &path) const
{
    if (path.isEmpty() || !QFileInfo(path).isAbsolute()) {
        return {};
    }
    return QUrl::fromLocalFile(QDir::cleanPath(path));
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

bool FileBridge::scanInstalledFontsAsync()
{
    if (m_fontCatalogScanning || m_fontCatalogReady) {
        return false;
    }
    return beginFontCatalogScan();
}

bool FileBridge::refreshInstalledFontsAsync()
{
    if (m_fontCatalogScanning) {
        return false;
    }
    return beginFontCatalogScan();
}

bool FileBridge::beginFontCatalogScan()
{
    m_fontCatalogScanning = true;
    emit fontCatalogScanningChanged();
    auto *watcher = new QFutureWatcher<QVariantList>(this);
    connect(watcher, &QFutureWatcher<QVariantList>::finished, this, [this, watcher]() {
        m_installedFonts = watcher->result();
        watcher->deleteLater();
        const bool becameReady = !m_fontCatalogReady;
        m_fontCatalogReady = true;
        m_fontCatalogScanning = false;
        emit fontCatalogChanged();
        if (becameReady) {
            emit fontCatalogReadyChanged();
        }
        emit fontCatalogScanningChanged();
    });
    watcher->setFuture(QtConcurrent::run(buildFontCatalog));
    return true;
}

QVariantMap FileBridge::readTextDocument(const QUrl &url)
{
    QString path;
    QVariantMap pathError;
    if (!localPath(url, &path, &pathError)) {
        return pathError;
    }

    const QFileInfo info(path);
    if (!info.exists() || !info.isFile()) {
        return failure(QStringLiteral("DOCUMENT_NOT_FOUND"), QStringLiteral("The selected text file does not exist."));
    }
    if (info.size() > maximumDocumentBytes) {
        return failure(QStringLiteral("DOCUMENT_TOO_LARGE"), QStringLiteral("The selected text file exceeds the supported size."));
    }

    QFile file(path);
    if (!file.open(QIODevice::ReadOnly)) {
        return failure(QStringLiteral("DOCUMENT_READ_FAILED"), file.errorString());
    }
    const QByteArray bytes = file.read(maximumDocumentBytes + 1);
    if (bytes.size() > maximumDocumentBytes) {
        return failure(QStringLiteral("DOCUMENT_TOO_LARGE"), QStringLiteral("The selected text file exceeds the supported size."));
    }

    QStringDecoder decoder(QStringConverter::Utf8);
    const QString text = decoder.decode(bytes);
    if (decoder.hasError()) {
        return failure(QStringLiteral("DOCUMENT_INVALID_UTF8"), QStringLiteral("The selected text file is not valid UTF-8."));
    }
    if (text.size() > maximumDocumentCharacters) {
        return failure(QStringLiteral("DOCUMENT_TOO_LARGE"), QStringLiteral("The selected text file contains too many characters."));
    }

    emit textDocumentRead(path, text.size(), bytes.size());
    return success({
        { QStringLiteral("path"), path },
        { QStringLiteral("data"), text },
        { QStringLiteral("characterCount"), text.size() },
        { QStringLiteral("byteCount"), bytes.size() },
    });
}

QVariantMap FileBridge::writeTextDocument(const QUrl &url, const QString &text)
{
    QString path;
    QVariantMap pathError;
    if (!localPath(url, &path, &pathError)) {
        return pathError;
    }
    if (text.size() > maximumDocumentCharacters) {
        return failure(QStringLiteral("DOCUMENT_TOO_LARGE"), QStringLiteral("The document contains too many characters."));
    }

    const QByteArray bytes = text.toUtf8();
    if (bytes.size() > maximumDocumentBytes) {
        return failure(QStringLiteral("DOCUMENT_TOO_LARGE"), QStringLiteral("The document exceeds the supported size."));
    }

    const QFileInfo destination(path);
    if (!destination.dir().exists()) {
        return failure(QStringLiteral("DOCUMENT_DIRECTORY_NOT_FOUND"), QStringLiteral("The destination directory does not exist."));
    }

    QSaveFile file(path);
    if (!file.open(QIODevice::WriteOnly)) {
        return failure(QStringLiteral("DOCUMENT_WRITE_FAILED"), file.errorString());
    }
    if (file.write(bytes) != bytes.size()) {
        file.cancelWriting();
        return failure(QStringLiteral("DOCUMENT_WRITE_FAILED"), file.errorString());
    }
    if (!file.commit()) {
        return failure(QStringLiteral("DOCUMENT_WRITE_FAILED"), file.errorString());
    }

    emit textDocumentWritten(path, text.size(), bytes.size());
    return success({
        { QStringLiteral("path"), path },
        { QStringLiteral("characterCount"), text.size() },
        { QStringLiteral("byteCount"), bytes.size() },
    });
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

bool FileBridge::writeSvgAsync(int requestId, const QUrl &url, const QString &svg)
{
    if (requestId <= 0) {
        return false;
    }
    auto *watcher = new QFutureWatcher<QVariantMap>(this);
    connect(watcher, &QFutureWatcher<QVariantMap>::finished, this, [this, watcher, requestId]() {
        const QVariantMap raw = watcher->result();
        watcher->deleteLater();
        QVariantMap result;
        if (raw.value(QStringLiteral("ok")).toBool()) {
            result = success(raw);
            emit svgWritten(result.value(QStringLiteral("path")).toString(),
                            result.value(QStringLiteral("byteCount")).toLongLong());
        } else {
            result = failure(raw.value(QStringLiteral("code")).toString(),
                             raw.value(QStringLiteral("message")).toString());
        }
        emit svgWriteCompleted(requestId, result);
    });
    watcher->setFuture(QtConcurrent::run([url, svg]() {
        FileBridge bridge;
        return bridge.writeSvg(url, svg);
    }));
    return true;
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
