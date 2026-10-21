#include "ReleaseChecker.h"

#include <QCoreApplication>
#include <QJsonDocument>
#include <QJsonObject>
#include <QNetworkReply>
#include <QNetworkRequest>
#include <QRegularExpression>
#include <QVersionNumber>

namespace {

constexpr auto latestReleaseApi =
    "https://api.github.com/repos/leomoon-studios/leomoon-parsinegar/releases/latest";
constexpr qsizetype maximumResponseBytes = 1024 * 1024;

QVersionNumber releaseVersion(const QString &text)
{
    static const QRegularExpression pattern(QStringLiteral("^v?([0-9]+)\\.([0-9]+)\\.([0-9]+)$"));
    const auto match = pattern.match(text);
    if (!match.hasMatch())
        return {};
    bool majorValid = false;
    bool minorValid = false;
    bool patchValid = false;
    const int major = match.captured(1).toInt(&majorValid);
    const int minor = match.captured(2).toInt(&minorValid);
    const int patch = match.captured(3).toInt(&patchValid);
    if (!majorValid || !minorValid || !patchValid)
        return {};
    return QVersionNumber(major, minor, patch);
}

} // namespace

ReleaseChecker::ReleaseChecker(QObject *parent)
    : QObject(parent)
{
}

QString ReleaseChecker::newerVersion(const QByteArray &releaseJson,
                                     const QString &currentVersion)
{
    if (releaseJson.isEmpty() || releaseJson.size() > maximumResponseBytes)
        return {};
    const QJsonDocument document = QJsonDocument::fromJson(releaseJson);
    if (!document.isObject())
        return {};
    const QJsonObject release = document.object();
    if (release.value(QStringLiteral("draft")).toBool()
        || release.value(QStringLiteral("prerelease")).toBool())
        return {};
    const QString tag = release.value(QStringLiteral("tag_name")).toString();
    const QVersionNumber latest = releaseVersion(tag);
    const QVersionNumber current = releaseVersion(currentVersion);
    if (latest.isNull() || current.isNull() || QVersionNumber::compare(latest, current) <= 0)
        return {};
    return tag.startsWith(QLatin1Char('v')) ? tag.mid(1) : tag;
}

void ReleaseChecker::checkForUpdates()
{
    if (m_checked)
        return;
    m_checked = true;

    QNetworkRequest request(QUrl(QString::fromUtf8(latestReleaseApi)));
    request.setRawHeader("Accept", "application/vnd.github+json");
    request.setRawHeader("User-Agent", "LeoMoon-ParsiNegar/"
        + QCoreApplication::applicationVersion().toUtf8());
    request.setTransferTimeout(8000);
    request.setAttribute(QNetworkRequest::RedirectPolicyAttribute,
                         QNetworkRequest::NoLessSafeRedirectPolicy);
    QNetworkReply *reply = m_network.get(request);
    connect(reply, &QNetworkReply::finished, this, [this, reply]() {
        reply->deleteLater();
        if (reply->error() != QNetworkReply::NoError
            || reply->attribute(QNetworkRequest::HttpStatusCodeAttribute).toInt() != 200
            || reply->bytesAvailable() > maximumResponseBytes)
            return;
        const QString version = newerVersion(reply->readAll(),
            QCoreApplication::applicationVersion());
        if (!version.isEmpty())
            emit updateAvailable(version);
    });
}
