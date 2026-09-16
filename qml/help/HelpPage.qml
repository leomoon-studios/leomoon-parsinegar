pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

FocusScope {
    id: root

    required property var controller
    required property Typography typography
    property string settingsFilePath: ""
    readonly property alias helpScroll: helpScroll
    readonly property real contentImplicitHeight: helpContent.implicitHeight
    readonly property var firstSectionHeading: sectionRepeater.count > 0 ? sectionRepeater.itemAt(0).headingItem : null
    readonly property var firstSectionBody: sectionRepeater.count > 0 ? sectionRepeater.itemAt(0).bodyItem : null
    readonly property string displayedSettingsFilePath: settingsFilePath !== "" ? settingsFilePath : "settings.json"

    LayoutMirroring.enabled: controller.uiLanguage === "fa"
    LayoutMirroring.childrenInherit: true

    readonly property var englishSections: [
        {
            heading: "What ParsiNegar does",
            body: "ParsiNegar Desktop prepares Persian, Arabic, Kurdish, Urdu, and Hebrew text for applications with incomplete shaping or bidirectional-text support. Enter or paste source text, choose a shaping profile and conversion mode, then select Convert. The converted result is copied to the clipboard for use in another application.\n\nParsiNegar prepares character forms and visual order. The font selected in the destination application still determines how the pasted text looks."
        },
        {
            heading: "Quick start",
            body: "1. Enter or paste the source text. Paste inserts plain text only, without web-page fonts, colors, links, or HTML styling.\n2. In Settings, choose Persian/Arabic, Kurdish/Urdu, or Hebrew.\n3. Choose Unicode mode unless the destination application requires a legacy Maryam-compatible font.\n4. Enable Apply bidi visual ordering only when the destination application does not support right-to-left layout.\n5. Enable any needed Text tools and select Convert.\n6. Paste the copied result into the destination application and choose a suitable font."
        },
        {
            heading: "Conversion modes",
            body: "Unicode mode is the normal choice for modern applications. It produces contextually shaped Unicode presentation forms for software that accepts Unicode text but does not join Persian or Arabic letters correctly. Use a Unicode font that supports the target script.\n\nCompatibility mode is for older applications that require legacy Maryam or LMN mappings. After pasting, choose the matching Maryam-compatible font. Without it, the result appears as unrelated symbols. Compatibility mode is unavailable for Hebrew and may not preserve Latin text as expected.\n\nThe Hebrew profile is Unicode-only. It uses bidirectional visual ordering without contextual Arabic-style shaping."
        },
        {
            heading: "Direction and mixed text",
            body: "Each paragraph uses its first strong character to determine direction. Latin paragraphs are left-aligned. Persian, Arabic, Urdu, Kurdish, and Hebrew paragraphs are right-aligned.\n\nApply bidi visual ordering is for destination applications that treat right-to-left text as ordinary left-to-right text. It orders every paragraph separately before conversion. Leave it off when the destination application already handles bidi correctly."
        },
        {
            heading: "Text tools",
            body: "Text tools are optional source-text transformations. Every tool has its own toggle. Enabled tools run together immediately before conversion, update the source text, and become one undoable edit.\n\nPersian normalization covers yeh, kaf, heh-ye, teh marbuta, and alef with fathatan. Writing cleanup covers Persian digits, quotation marks, verb-aware ZWNJ repair, diacritics, and tatweel. Alternate forms provide Arabic yeh and kaf, legacy heh-ye, English digits, and English quotation marks.\n\nOpposite transformations cannot be enabled together. ZWNJ repair recognizes common Persian verbs, so it can repair می خواهم without blindly changing unrelated words such as میدان."
        },
        {
            heading: "Export SVG",
            body: "Export SVG creates editable vector curves from converted text. Choose a font, set font size, line spacing, and alignment, then save the SVG. Unicode export starts with bundled Vazirmatn. Compatibility export requires a Maryam-compatible TTF or OTF font.\n\nOpen More options only for fixed width or height, padding, precision, fill color, font index, or variable-font axes. Automatic width and height are enabled by default and disable their fields until turned off.\n\nThe SVG uses the exact selected font. If it lacks a required glyph, ParsiNegar warns that the saved SVG contains the font's missing-glyph outline."
        },
        {
            heading: "Documents and editing",
            body: "The Document menu provides New, Open, Save, and Save As for UTF-8 text documents. Desktop preserves the document's original line-ending style when possible and warns before discarding unsaved changes.\n\nUse Undo and Redo, or Ctrl+Z, Ctrl+Y, and Ctrl+Shift+Z, to restore source edits, selections, cursor positions, and paragraph breaks. Ctrl+Enter converts; Ctrl+, opens or closes Settings; Ctrl+T toggles Text Tools; Ctrl+E toggles Export; and Ctrl+H toggles Help.\n\nHold Ctrl and scroll over the editor to change its text size. On macOS, use Command and scroll. The selected size is saved between launches."
        },
        {
            heading: "Troubleshooting",
            body: "If pasted text is disconnected, reversed, or in the wrong order, check the profile, mode, destination font, and bidi visual ordering setting.\n\nIf the result looks like random symbols, Compatibility mode was probably used without its matching Maryam-compatible font.\n\nIf a character is missing, choose a destination or export font that contains it. In Photoshop, disable All Caps and Small Caps in the Character settings. Use the VideoStudio Pro option only for that application."
        },
        {
            heading: "Settings and privacy",
            body: "Desktop saves interface preferences, editor font size, shaping options, Text tool toggles, and SVG export choices in this platform-specific settings file:",
            path: root.displayedSettingsFilePath,
            footer: "It does not save the editor draft, converted output, clipboard contents, status messages, or undo history in that settings file."
        }
    ]

    readonly property var persianSections: [
        {
            heading: "پارسی‌نگار دسکتاپ چه کاری انجام می‌دهد؟",
            body: "پارسی‌نگار دسکتاپ متن پارسی، عربی، کردی، اردو و عبری را برای برنامه‌هایی آماده می‌کند که شکل‌دهی متن یا نمایش متن دوجهته را کامل پشتیبانی نمی‌کنند. متن مبدأ را وارد یا بچسبانید، نمایهٔ شکل‌دهی و حالت تبدیل را انتخاب کنید و تبدیل را بزنید. نتیجه در کلیپ‌بورد کپی می‌شود تا در برنامهٔ دیگر استفاده کنید.\n\nپارسی‌نگار صورت نویسه‌ها و ترتیب دیداری را آماده می‌کند، اما ظاهر نهایی متن به فونت انتخاب‌شده در برنامهٔ مقصد بستگی دارد."
        },
        {
            heading: "شروع سریع",
            body: "۱. متن مبدأ را وارد یا بچسبانید. چسباندن فقط متن ساده را وارد می‌کند و قالب‌بندی وب‌سایت را حذف می‌کند.\n۲. در تنظیمات، نمایهٔ پارسی/عربی، کردی/اردو یا عبری را انتخاب کنید.\n۳. مگر آن‌که برنامهٔ مقصد به فونت مریم نیاز داشته باشد، حالت یونیکد را انتخاب کنید.\n۴. فقط اگر برنامهٔ مقصد راست‌به‌چپ را پشتیبانی نمی‌کند، اعمال ترتیب نمایشی دوجهته را فعال کنید.\n۵. ابزارهای متن لازم را فعال کنید و تبدیل را بزنید.\n۶. نتیجه را در برنامهٔ مقصد بچسبانید و فونت مناسب را انتخاب کنید."
        },
        {
            heading: "حالت‌های تبدیل",
            body: "حالت یونیکد انتخاب عادی برای برنامه‌های جدید است. این حالت برای برنامه‌هایی است که متن یونیکد را می‌پذیرند، اما حروف پارسی یا عربی را درست به هم نمی‌چسبانند. از فونت یونیکدی استفاده کنید که از خط موردنظر پشتیبانی می‌کند.\n\nحالت سازگاری برای برنامه‌های قدیمی است که به کدگذاری مریم یا LMN نیاز دارند. پس از چسباندن، فونت سازگار با مریم را انتخاب کنید. بدون آن فونت، نتیجه مانند نمادهای نامرتبط دیده می‌شود. حالت سازگاری برای عبری در دسترس نیست.\n\nنمایهٔ عبری فقط با یونیکد کار می‌کند و ترتیب نمایشی دوجهته را بدون شکل‌دهی زمینه‌ای عربی اعمال می‌کند."
        },
        {
            heading: "جهت متن و متن آمیخته",
            body: "جهت هر پاراگراف از نخستین نویسهٔ قوی آن تعیین می‌شود. پاراگراف لاتین چپ‌چین و پاراگراف پارسی، عربی، اردو، کردی و عبری راست‌چین است.\n\nاعمال ترتیب نمایشی دوجهته برای برنامه‌هایی است که متن راست‌به‌چپ را مانند متن چپ‌به‌راست پردازش می‌کنند. اگر برنامهٔ مقصد دوجهته را درست پشتیبانی می‌کند، این گزینه را خاموش بگذارید."
        },
        {
            heading: "ابزارهای متن",
            body: "ابزارهای متن تبدیل‌های اختیاری و مستقل هستند. کلیدهای فعال درست پیش از تبدیل با هم اجرا می‌شوند، متن مبدأ را به‌روزرسانی می‌کنند و به‌صورت یک تغییر قابل واگردانی ثبت می‌شوند.\n\nیکنواخت‌سازی پارسی شامل ی، ک، هٔ، تاء مربوطة و الف با تنوین فتحه است. پاک‌سازی نوشتار رقم‌ها و گیومه‌های پارسی، اصلاح فاصلهٔ مجازی، اعراب و کشیده را پوشش می‌دهد. صورت‌های جایگزین نیز ی و ک عربی، ه‌ی قدیمی، رقم‌ها و گیومه‌های انگلیسی را فراهم می‌کنند.\n\nابزارهای وارون هم‌زمان فعال نمی‌شوند. اصلاح فاصلهٔ مجازی فعل‌های رایج را تشخیص می‌دهد، بنابراین می خواهم را اصلاح می‌کند و میدان را بی‌دلیل تغییر نمی‌دهد."
        },
        {
            heading: "خروجی SVG",
            body: "خروجی SVG متن تبدیل‌شده را به منحنی‌های برداری قابل ویرایش تبدیل می‌کند. فونت را انتخاب کنید، اندازهٔ فونت، فاصلهٔ خطوط و تراز را تنظیم کنید و SVG را ذخیره کنید. خروجی یونیکد با وزیرمتن داخلی آغاز می‌شود و خروجی سازگاری به فونت TTF یا OTF سازگار با مریم نیاز دارد.\n\nگزینه‌های بیشتر برای پهنا و ارتفاع ثابت، حاشیه، دقت، رنگ پُرکننده، نمایهٔ فونت و محورهای فونت متغیر است. پهنا و ارتفاع خودکار به‌صورت پیش‌فرض فعال هستند.\n\nاگر فونت نویسهٔ لازم را نداشته باشد، پارسی‌نگار هشدار می‌دهد که SVG از طرح گلیفِ ناموجود فونت استفاده کرده است."
        },
        {
            heading: "پرونده‌ها و ویرایش",
            body: "منوی پرونده گزینه‌های پروندهٔ نو، باز کردن، ذخیره و ذخیره با نام را برای پرونده‌های متنی UTF-8 فراهم می‌کند. دسکتاپ تا حد امکان سبک اصلی شکست خط را نگه می‌دارد و پیش از کنارگذاشتن تغییرات ذخیره‌نشده هشدار می‌دهد.\n\nبا واگردانی و انجام دوباره یا Ctrl+Z، Ctrl+Y و Ctrl+Shift+Z می‌توانید ویرایش متن، انتخاب، جایگاه نشانگر و شکست پاراگراف را بازگردانید. Ctrl+Enter تبدیل را اجرا می‌کند؛ Ctrl+, تنظیمات را باز یا بسته می‌کند؛ Ctrl+T ابزارهای متن، Ctrl+E خروجی و Ctrl+H راهنما را باز یا بسته می‌کنند.\n\nبرای تغییر اندازهٔ متن ویرایشگر، Ctrl را نگه دارید و روی ویرایشگر پیمایش کنید. در macOS از Command و پیمایش استفاده کنید. اندازهٔ انتخاب‌شده میان اجراهای برنامه ذخیره می‌شود."
        },
        {
            heading: "رفع اشکال",
            body: "اگر نتیجه جدا، وارونه یا نادرست است، نمایهٔ شکل‌دهی، حالت تبدیل، فونت مقصد و گزینهٔ ترتیب نمایشی دوجهته را بررسی کنید.\n\nاگر خروجی مانند نمادهای نامرتبط است، حالت سازگاری بدون فونت مریم سازگار استفاده شده است.\n\nاگر نویسه‌ای نادرست است، فونتی انتخاب کنید که آن را دارد. در Photoshop، گزینه‌های All Caps و Small Caps را خاموش کنید. گزینهٔ VideoStudio Pro را فقط برای همان برنامه به کار ببرید."
        },
        {
            heading: "تنظیمات و حریم خصوصی",
            body: "دسکتاپ زبان رابط، اندازهٔ فونت ویرایشگر، گزینه‌های شکل‌دهی، کلیدهای ابزار متن و انتخاب‌های SVG را در پروندهٔ تنظیمات ویژهٔ این سیستم ذخیره می‌کند:",
            path: root.displayedSettingsFilePath,
            footer: "متن مبدأ، خروجی تبدیل‌شده، کلیپ‌بورد، پیام‌های وضعیت و تاریخچهٔ واگردانی در این پرونده ذخیره نمی‌شوند."
        }
    ]

    readonly property var sections: controller.uiLanguage === "fa" ? persianSections : englishSections

    Keys.onEscapePressed: function(event) {
        controller.closeHelp()
        event.accepted = true
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: AppTheme.spacingMedium

        PageHeader {
            Layout.fillWidth: true
            title: root.controller.uiText("help.title")
        }

        ScrollView {
            id: helpScroll
            objectName: "helpScroll"
            Layout.fillWidth: true
            Layout.fillHeight: true
            contentWidth: availableWidth
            clip: true
            leftPadding: AppTheme.spacingLarge
            rightPadding: AppTheme.spacingLarge
            ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
            ScrollBar.vertical.policy: ScrollBar.AsNeeded

            Column {
                id: helpContent
                width: helpScroll.availableWidth
                spacing: AppTheme.spacingMedium
                LayoutMirroring.enabled: false
                LayoutMirroring.childrenInherit: false

                Repeater {
                    id: sectionRepeater
                    model: root.sections

                    delegate: Rectangle {
                        id: sectionCard
                        required property var modelData
                        required property int index
                        readonly property alias headingItem: sectionHeading
                        readonly property alias bodyItem: sectionBody
                        width: helpContent.width
                        implicitHeight: sectionContent.implicitHeight + AppTheme.spacingLarge * 2
                        radius: AppTheme.cornerRadius
                        color: AppTheme.surface
                        border.color: AppTheme.border
                        border.width: AppTheme.borderWidth
                        LayoutMirroring.enabled: false
                        LayoutMirroring.childrenInherit: false

                        ColumnLayout {
                            id: sectionContent
                            anchors.fill: parent
                            anchors.margins: AppTheme.spacingLarge
                            spacing: AppTheme.spacingSmall
                            LayoutMirroring.enabled: false
                            LayoutMirroring.childrenInherit: false

                            Text {
                                id: sectionHeading
                                Layout.fillWidth: true
                                text: sectionCard.modelData.heading
                                font.family: AppTheme.fontFamily
                                font.pixelSize: AppTheme.fontBody
                                font.weight: Font.DemiBold
                                color: AppTheme.foreground
                                textFormat: Text.PlainText
                                LayoutMirroring.enabled: false
                                horizontalAlignment: root.controller.uiLanguage === "fa" ? Text.AlignRight : Text.AlignLeft
                                wrapMode: Text.Wrap
                            }

                            Text {
                                id: sectionBody
                                Layout.fillWidth: true
                                text: sectionCard.modelData.body
                                font.family: AppTheme.fontFamily
                                font.pixelSize: AppTheme.fontBody
                                color: AppTheme.muted
                                textFormat: Text.PlainText
                                LayoutMirroring.enabled: false
                                horizontalAlignment: root.controller.uiLanguage === "fa" ? Text.AlignRight : Text.AlignLeft
                                wrapMode: Text.Wrap
                            }

                            Text {
                                Layout.fillWidth: true
                                visible: text !== ""
                                text: sectionCard.modelData.path || ""
                                font.family: AppTheme.fontFamily
                                font.pixelSize: AppTheme.fontBody
                                color: AppTheme.foreground
                                textFormat: Text.PlainText
                                LayoutMirroring.enabled: false
                                horizontalAlignment: root.controller.uiLanguage === "fa" ? Text.AlignRight : Text.AlignLeft
                                wrapMode: Text.WrapAnywhere
                            }

                            Text {
                                Layout.fillWidth: true
                                visible: text !== ""
                                text: sectionCard.modelData.footer || ""
                                font.family: AppTheme.fontFamily
                                font.pixelSize: AppTheme.fontBody
                                color: AppTheme.muted
                                textFormat: Text.PlainText
                                LayoutMirroring.enabled: false
                                horizontalAlignment: root.controller.uiLanguage === "fa" ? Text.AlignRight : Text.AlignLeft
                                wrapMode: Text.Wrap
                            }
                        }
                    }
                }
            }
        }
    }
}
