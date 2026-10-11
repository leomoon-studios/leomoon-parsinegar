#include "UnicodeSvgExporter.h"

#include <QBuffer>
#include <QColor>
#include <QFile>
#include <QFileInfo>
#include <QFont>
#include <QFontDatabase>
#include <QGlyphRun>
#include <QPainter>
#include <QPainterPath>
#include <QRawFont>
#include <QRegularExpression>
#include <QSet>
#include <QSvgGenerator>
#include <QTextLayout>
#include <QTextOption>
#include <QTransform>

#include <algorithm>
#include <cmath>

namespace {

constexpr auto fontResource = ":/qt/qml/LeoMoon/ParsiNegar/assets/fonts/IranNastaliq.ttf";
constexpr auto unicodeFontResource = ":/qt/qml/LeoMoon/ParsiNegar/assets/fonts/Vazirmatn[wght].ttf";
constexpr qsizetype maximumFontBytes = 5 * 1024 * 1024;
constexpr qsizetype maximumSvgBytes = 16 * 1024 * 1024;
constexpr qsizetype maximumTextLength = 50000;
constexpr int maximumPathElements = 1000000;

QByteArray fontData;
QString fontFamily;
QByteArray unicodeFontData;
QString unicodeFontFamily;

bool registerBundledFont(const char *resource, const QString &expectedFamily,
                         QByteArray *data, QString *family)
{
    QFile file(QString::fromUtf8(resource));
    if (!file.open(QIODevice::ReadOnly) || file.size() <= 0 || file.size() > maximumFontBytes)
        return false;
    const QByteArray header = file.peek(4);
    if (header != QByteArray::fromHex("00010000") && header != QByteArrayLiteral("OTTO"))
        return false;
    const QByteArray bytes = file.read(maximumFontBytes + 1);
    if (bytes.isEmpty() || bytes.size() > maximumFontBytes || bytes.size() != file.size())
        return false;
    const int fontId = QFontDatabase::addApplicationFontFromData(bytes);
    if (fontId < 0)
        return false;
    const QStringList families = QFontDatabase::applicationFontFamilies(fontId);
    if (!families.contains(expectedFamily))
        return false;
    *data = bytes;
    *family = expectedFamily;
    return true;
}

QVariantMap failure(const QString &code, const QString &message)
{
    return {
        {QStringLiteral("ok"), false},
        {QStringLiteral("code"), code},
        {QStringLiteral("message"), message},
    };
}

bool optionNumber(const QVariantMap &options, const QString &key, double fallback,
                  double minimum, double maximum, double *value)
{
    if (!options.contains(key)) {
        *value = fallback;
        return true;
    }
    bool converted = false;
    const double candidate = options.value(key).toDouble(&converted);
    if (!converted || !std::isfinite(candidate) || candidate < minimum || candidate > maximum)
        return false;
    *value = candidate;
    return true;
}

QString codePointLabel(uint codePoint)
{
    return QStringLiteral("U+%1").arg(codePoint, 4, 16, QLatin1Char('0')).toUpper();
}

QVariantList missingCharacters(const QString &text, const QRawFont &font)
{
    QVariantList missing;
    QSet<uint> seen;
    for (qsizetype index = 0; index < text.size(); ++index) {
        char32_t codePoint = text.at(index).unicode();
        if (text.at(index).isHighSurrogate() && index + 1 < text.size()
            && text.at(index + 1).isLowSurrogate()) {
            codePoint = QChar::surrogateToUcs4(text.at(index), text.at(++index));
        }
        if (QChar::isSpace(codePoint) || QChar::category(codePoint) == QChar::Other_Format
            || seen.contains(codePoint)
            || font.supportsCharacter(codePoint)) {
            continue;
        }
        seen.insert(codePoint);
        missing.append(QVariantMap {
            {QStringLiteral("character"), QString::fromUcs4(&codePoint, 1)},
            {QStringLiteral("codePoint"), codePoint},
            {QStringLiteral("label"), codePointLabel(codePoint)},
        });
    }
    return missing;
}

struct LineOutline {
    QPainterPath path;
    QRectF bounds;
};

} // namespace

bool UnicodeSvgExporter::initialize()
{
    if (isReady())
        return true;
    return registerBundledFont(fontResource, QStringLiteral("IranNastaliq"), &fontData, &fontFamily)
        && registerBundledFont(unicodeFontResource, QStringLiteral("Vazirmatn"),
                               &unicodeFontData, &unicodeFontFamily);
}

bool UnicodeSvgExporter::isReady()
{
    return !fontFamily.isEmpty() && !unicodeFontFamily.isEmpty();
}

QVariantMap UnicodeSvgExporter::render(const QString &text, const QVariantMap &options,
                                       const QString &selectedFontPath,
                                       const QString &expectedFamily,
                                       const QString &expectedStyle)
{
    if (!isReady())
        return failure(QStringLiteral("INVALID_FONT"), QStringLiteral("The bundled Unicode fonts are unavailable."));
    if (text.size() > maximumTextLength)
        return failure(QStringLiteral("EXPORT_TEXT_TOO_LARGE"), QStringLiteral("The source text exceeds the SVG export limit."));
    if (text.isEmpty())
        return failure(QStringLiteral("INVALID_OPTION"), QStringLiteral("Enter text before exporting."));

    QByteArray selectedFontData = fontData;
    QString selectedFamily = fontFamily;
    QString selectedStyle;
    if (selectedFontPath == QLatin1String("bundled:Vazirmatn")) {
        selectedFontData = unicodeFontData;
        selectedFamily = unicodeFontFamily;
    } else if (!selectedFontPath.isEmpty() && selectedFontPath != QLatin1String("bundled:IranNastaliq")) {
        const QFileInfo info(selectedFontPath);
        const QString suffix = info.suffix().toLower();
        if (!info.isAbsolute() || !info.isFile() || !info.isReadable()
            || (suffix != QLatin1String("ttf") && suffix != QLatin1String("otf"))) {
            return failure(QStringLiteral("INVALID_FONT"), QStringLiteral("The selected font file is unavailable."));
        }
        if (info.size() <= 0 || info.size() > maximumFontBytes)
            return failure(QStringLiteral("FONT_TOO_LARGE"), QStringLiteral("The selected font exceeds the supported size."));
        QFile selectedFile(info.absoluteFilePath());
        if (!selectedFile.open(QIODevice::ReadOnly))
            return failure(QStringLiteral("FONT_READ_FAILED"), selectedFile.errorString());
        const QByteArray header = selectedFile.peek(4);
        if (header != QByteArray::fromHex("00010000") && header != QByteArrayLiteral("OTTO"))
            return failure(QStringLiteral("INVALID_FONT"), QStringLiteral("The selected file is not TrueType or OpenType."));
        selectedFontData = selectedFile.read(maximumFontBytes + 1);
        if (selectedFontData.size() > maximumFontBytes)
            return failure(QStringLiteral("FONT_TOO_LARGE"), QStringLiteral("The selected font exceeds the supported size."));
        if (selectedFontData.size() != selectedFile.size())
            return failure(QStringLiteral("FONT_READ_FAILED"), QStringLiteral("The selected font could not be read completely."));
    }

    double fontSize = 0;
    double lineSpacing = 0;
    if (!optionNumber(options, QStringLiteral("fontSize"), 48, 0.01, 4096, &fontSize)
        || !optionNumber(options, QStringLiteral("lineSpacing"), 1.2, 0.01, 10, &lineSpacing)) {
        return failure(QStringLiteral("INVALID_OPTION"), QStringLiteral("Invalid font size or line spacing."));
    }
    const QVariantMap bounds = options.value(QStringLiteral("bounds")).toMap();
    double padding = 0;
    double requestedWidth = 0;
    double requestedHeight = 0;
    if (!optionNumber(bounds, QStringLiteral("padding"), 0, 0, 100000, &padding)
        || (bounds.contains(QStringLiteral("width"))
            && !optionNumber(bounds, QStringLiteral("width"), 0, 0.01, 1000000, &requestedWidth))
        || (bounds.contains(QStringLiteral("height"))
            && !optionNumber(bounds, QStringLiteral("height"), 0, 0.01, 1000000, &requestedHeight))) {
        return failure(QStringLiteral("INVALID_OPTION"), QStringLiteral("Invalid SVG dimensions."));
    }
    const QString alignment = options.value(QStringLiteral("alignment"), QStringLiteral("right")).toString();
    if (alignment != QLatin1String("left") && alignment != QLatin1String("center")
        && alignment != QLatin1String("right")) {
        return failure(QStringLiteral("INVALID_OPTION"), QStringLiteral("Invalid alignment."));
    }
    const QString fill = options.value(QStringLiteral("fill"), QStringLiteral("#000000")).toString();
    static const QRegularExpression fillPattern(QStringLiteral("^#[0-9a-fA-F]{6}([0-9a-fA-F]{2})?$"));
    if (!fillPattern.match(fill).hasMatch())
        return failure(QStringLiteral("INVALID_OPTION"), QStringLiteral("Invalid fill color."));

    const int pixelSize = std::clamp(qRound(fontSize), 1, 4096);
    const QRawFont expectedFont(selectedFontData, pixelSize, QFont::PreferNoHinting);
    if (!expectedFont.isValid())
        return failure(QStringLiteral("INVALID_FONT"), QStringLiteral("The selected font could not be loaded."));
    if (!selectedFontPath.isEmpty() && !selectedFontPath.startsWith(QLatin1String("bundled:"))) {
        selectedFamily = expectedFont.familyName();
        selectedStyle = expectedFont.styleName();
        if (selectedFamily.compare(expectedFamily, Qt::CaseInsensitive) != 0
            || selectedStyle.compare(expectedStyle, Qt::CaseInsensitive) != 0) {
            return failure(QStringLiteral("INVALID_FONT"), QStringLiteral("The selected font changed after it was listed."));
        }
    }
    const QByteArray expectedHead = expectedFont.fontTable("head");
    const QByteArray expectedName = expectedFont.fontTable("name");
    const QVariantList missing = missingCharacters(text, expectedFont);

    QFont font(selectedFamily);
    if (!selectedStyle.isEmpty())
        font.setStyleName(selectedStyle);
    font.setPixelSize(pixelSize);
    font.setStyleStrategy(static_cast<QFont::StyleStrategy>(
        QFont::NoFontMerging | QFont::PreferNoHinting));
    QList<LineOutline> lines;
    double maximumLineWidth = 0;
    int pathElements = 0;
    for (const QString &lineText : text.split(QLatin1Char('\n'), Qt::KeepEmptyParts)) {
        QTextOption textOption;
        textOption.setTextDirection(lineText.isRightToLeft() ? Qt::RightToLeft : Qt::LeftToRight);
        textOption.setWrapMode(QTextOption::NoWrap);
        QTextLayout layout(lineText, font);
        layout.setTextOption(textOption);
        layout.beginLayout();
        QTextLine line = layout.createLine();
        if (line.isValid())
            line.setLineWidth(1000000000.0);
        layout.endLayout();

        LineOutline outline;
        outline.path.setFillRule(Qt::WindingFill);
        for (const QGlyphRun &run : layout.glyphRuns()) {
            const QRawFont rawFont = run.rawFont();
            if (!rawFont.isValid() || rawFont.familyName() != selectedFamily
                || rawFont.fontTable("head") != expectedHead
                || rawFont.fontTable("name") != expectedName) {
                return failure(QStringLiteral("INVALID_FONT"),
                    QStringLiteral("Qt substituted a different font for the selected font."));
            }
            const QList<quint32> glyphs = run.glyphIndexes();
            const QList<QPointF> positions = run.positions();
            if (glyphs.size() != positions.size())
                return failure(QStringLiteral("INVALID_OUTLINE"), QStringLiteral("Invalid shaped glyph positions."));
            for (qsizetype index = 0; index < glyphs.size(); ++index) {
                const QPainterPath glyphPath = rawFont.pathForGlyph(glyphs.at(index));
                pathElements += glyphPath.elementCount();
                if (pathElements > maximumPathElements)
                    return failure(QStringLiteral("SVG_TOO_LARGE"), QStringLiteral("The outlined text is too complex."));
                outline.path.addPath(QTransform::fromTranslate(
                    positions.at(index).x(), positions.at(index).y()).map(glyphPath));
            }
        }
        outline.bounds = outline.path.boundingRect();
        maximumLineWidth = std::max(maximumLineWidth, outline.bounds.width());
        lines.append(std::move(outline));
    }

    const double width = bounds.contains(QStringLiteral("width"))
        ? requestedWidth : std::max(1.0, maximumLineWidth + 2 * padding);
    if (!std::isfinite(width) || width <= 0 || width > 1000000 || width < maximumLineWidth + 2 * padding)
        return failure(QStringLiteral("BOUNDS_TOO_SMALL"), QStringLiteral("The requested width is too small."));
    const double contentWidth = width - 2 * padding;
    QPainterPath combined;
    combined.setFillRule(Qt::WindingFill);
    double lineTop = 0;
    double layoutHeight = 0;
    for (qsizetype index = 0; index < lines.size(); ++index) {
        const LineOutline &line = lines.at(index);
        const double freeSpace = contentWidth - line.bounds.width();
        const double alignmentOffset = alignment == QLatin1String("right") ? freeSpace
            : alignment == QLatin1String("center") ? freeSpace / 2 : 0;
        combined.addPath(QTransform::fromTranslate(
            padding + alignmentOffset - line.bounds.left(), padding + lineTop - line.bounds.top())
            .map(line.path));
        const double lineHeight = std::max(fontSize, line.bounds.height());
        layoutHeight = lineTop + lineHeight;
        lineTop += lineHeight * lineSpacing;
    }

    const double automaticHeight = layoutHeight + 2 * padding;
    const double height = bounds.contains(QStringLiteral("height"))
        ? requestedHeight : std::max(1.0, automaticHeight);
    if (!std::isfinite(height) || height <= 0 || height > 1000000
        || height < automaticHeight) {
        return failure(QStringLiteral("BOUNDS_TOO_SMALL"), QStringLiteral("The requested height is too small."));
    }

    QByteArray svgBytes;
    QBuffer buffer(&svgBytes);
    if (!buffer.open(QIODevice::WriteOnly))
        return failure(QStringLiteral("EXPORT_FAILED"), QStringLiteral("Could not create the SVG buffer."));
    QSvgGenerator generator;
    generator.setOutputDevice(&buffer);
    generator.setSize(QSize(qCeil(width), qCeil(height)));
    generator.setViewBox(QRectF(0, 0, width, height));
    QPainter painter;
    if (!painter.begin(&generator))
        return failure(QStringLiteral("EXPORT_FAILED"), QStringLiteral("Could not start SVG drawing."));
    painter.setPen(Qt::NoPen);
    painter.setBrush(QColor(fill));
    painter.drawPath(combined);
    painter.end();
    if (svgBytes.size() > maximumSvgBytes)
        return failure(QStringLiteral("SVG_TOO_LARGE"), QStringLiteral("The SVG exceeds the supported size."));

    return {
        {QStringLiteral("ok"), true},
        {QStringLiteral("svg"), QString::fromUtf8(svgBytes)},
        {QStringLiteral("font"), QVariantMap {{QStringLiteral("family"), selectedFamily},
                                               {QStringLiteral("style"), selectedStyle}}},
        {QStringLiteral("missingGlyphs"), missing},
        {QStringLiteral("convertedText"), text},
    };
}
