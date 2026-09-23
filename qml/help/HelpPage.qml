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
    readonly property bool rightToLeft: controller.uiLanguage === "fa" || controller.uiLanguage === "ar"

    LayoutMirroring.enabled: rightToLeft
    LayoutMirroring.childrenInherit: true

    readonly property var englishSections: [
        {
            heading: "What ParsiNegar does",
            body: "LeoMoon ParsiNegar prepares Persian, Arabic, Kurdish, Urdu, and Hebrew text for applications with incomplete shaping or bidirectional-text support. Enter or paste source text, choose a shaping profile and conversion mode, then select Convert. The converted result is copied to the clipboard for use in another application.\n\nParsiNegar prepares character forms and visual order. The font selected in the destination application still determines how the pasted text looks."
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
            body: "The Document menu provides New, Open, Save, and Save As for UTF-8 text documents. Desktop preserves the document's original line-ending style when possible and warns before discarding unsaved changes.\n\nUndo and Redo restore source edits, selections, cursor positions, and paragraph breaks."
        },
        {
            heading: "Keyboard shortcuts",
            body: "Conversion and pages\nCtrl+Enter: Convert\nCtrl+,: Toggle Settings\nCtrl+T: Toggle Text Tools\nCtrl+E: Toggle Export\nCtrl+H: Toggle Help\n\nEditing\nCtrl+Z: Undo\nCtrl+Y or Ctrl+Shift+Z: Redo\nCtrl+Scroll up: Increase editor text size\nCtrl+Scroll down: Decrease editor text size\n\nDocuments\nCtrl+N: New\nCtrl+O: Open\nCtrl+S: Save\nCtrl+Shift+S: Save As\n\nOn macOS, document, editing, and editor-size shortcuts use Command instead of Ctrl. Conversion and page shortcuts remain Ctrl combinations. The selected editor text size is saved between launches."
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
            heading: "پارسی‌نگار لیومون چه کاری انجام می‌دهد؟",
            body: "پارسی‌نگار لیومون متن پارسی، عربی، کردی، اردو و عبری را برای برنامه‌هایی آماده می‌کند که شکل‌دهی متن یا نمایش متن دوجهته را کامل پشتیبانی نمی‌کنند. متن مبدأ را وارد یا بچسبانید، نمایهٔ شکل‌دهی و حالت تبدیل را انتخاب کنید و تبدیل را بزنید. نتیجه در کلیپ‌بورد کپی می‌شود تا در برنامهٔ دیگر استفاده کنید.\n\nپارسی‌نگار صورت نویسه‌ها و ترتیب دیداری را آماده می‌کند، اما ظاهر نهایی متن به فونت انتخاب‌شده در برنامهٔ مقصد بستگی دارد."
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
            body: "منوی پرونده گزینه‌های پروندهٔ نو، باز کردن، ذخیره و ذخیره با نام را برای پرونده‌های متنی UTF-8 فراهم می‌کند. برنامه تا حد امکان سبک اصلی شکست خط را نگه می‌دارد و پیش از کنارگذاشتن تغییرات ذخیره‌نشده هشدار می‌دهد.\n\nواگردانی و انجام دوباره، ویرایش متن، انتخاب، جایگاه نشانگر و شکست پاراگراف را بازمی‌گردانند."
        },
        {
            heading: "میان‌برهای صفحه‌کلید",
            body: "تبدیل و صفحه‌ها\nتبدیل: \u2066Ctrl+Enter\u2069\nباز یا بستن تنظیمات: \u2066Ctrl+,\u2069\nباز یا بستن ابزارهای متن: \u2066Ctrl+T\u2069\nباز یا بستن خروجی: \u2066Ctrl+E\u2069\nباز یا بستن راهنما: \u2066Ctrl+H\u2069\n\nویرایش\nواگردانی: \u2066Ctrl+Z\u2069\nانجام دوباره: \u2066Ctrl+Y\u2069 یا \u2066Ctrl+Shift+Z\u2069\nافزایش اندازهٔ متن ویرایشگر: \u2066Ctrl+Scroll Up\u2069\nکاهش اندازهٔ متن ویرایشگر: \u2066Ctrl+Scroll Down\u2069\n\nپرونده‌ها\nپروندهٔ نو: \u2066Ctrl+N\u2069\nباز کردن: \u2066Ctrl+O\u2069\nذخیره: \u2066Ctrl+S\u2069\nذخیره با نام: \u2066Ctrl+Shift+S\u2069\n\nدر macOS، میان‌برهای پرونده، ویرایش و اندازهٔ متن به‌جای Ctrl از Command استفاده می‌کنند. میان‌برهای تبدیل و صفحه‌ها همچنان با Ctrl کار می‌کنند. اندازهٔ انتخاب‌شدهٔ متن ویرایشگر میان اجراهای برنامه ذخیره می‌شود."
        },
        {
            heading: "رفع اشکال",
            body: "اگر نتیجه جدا، وارونه یا نادرست است، نمایهٔ شکل‌دهی، حالت تبدیل، فونت مقصد و گزینهٔ ترتیب نمایشی دوجهته را بررسی کنید.\n\nاگر خروجی مانند نمادهای نامرتبط است، حالت سازگاری بدون فونت مریم سازگار استفاده شده است.\n\nاگر نویسه‌ای نادرست است، فونتی انتخاب کنید که آن را دارد. در Photoshop، گزینه‌های All Caps و Small Caps را خاموش کنید. گزینهٔ VideoStudio Pro را فقط برای همان برنامه به کار ببرید."
        },
        {
            heading: "تنظیمات و حریم خصوصی",
            body: "برنامه زبان رابط، اندازهٔ فونت ویرایشگر، گزینه‌های شکل‌دهی، کلیدهای ابزار متن و انتخاب‌های SVG را در پروندهٔ تنظیمات ویژهٔ این سیستم ذخیره می‌کند:",
            path: root.displayedSettingsFilePath,
            footer: "متن مبدأ، خروجی تبدیل‌شده، کلیپ‌بورد، پیام‌های وضعیت و تاریخچهٔ واگردانی در این پرونده ذخیره نمی‌شوند."
        }
    ]

    readonly property var arabicSections: [
        {
            heading: "ما الذي يفعله LeoMoon ParsiNegar؟",
            body: "يُعدّ LeoMoon ParsiNegar النصوص الفارسية والعربية والكردية والأردية والعبرية للتطبيقات التي لا تدعم التشكيل أو النص ثنائي الاتجاه دعمًا كاملًا. أدخل النص المصدر أو الصقه، واختر ملف التشكيل ووضع التحويل، ثم اختر تحويل. تُنسخ النتيجة إلى الحافظة لاستخدامها في تطبيق آخر.\n\nيُعدّ پارسی‌نگار أشكال الحروف وترتيبها المرئي، بينما يظل مظهر النص النهائي معتمدًا على الخط المحدد في التطبيق الهدف."
        },
        {
            heading: "البدء السريع",
            body: "1. أدخل النص المصدر أو الصقه. يلصق النص العادي فقط من دون خطوط صفحة الويب أو ألوانها أو روابطها أو تنسيق HTML.\n2. اختر في الإعدادات الفارسي/العربي أو الكردي/الأردي أو العبري.\n3. اختر وضع Unicode ما لم يكن التطبيق الهدف يتطلب خطًا قديمًا متوافقًا مع Maryam.\n4. فعّل تطبيق الترتيب المرئي ثنائي الاتجاه فقط عندما لا يدعم التطبيق الهدف التخطيط من اليمين إلى اليسار.\n5. فعّل أدوات النص المطلوبة واختر تحويل.\n6. الصق النتيجة المنسوخة في التطبيق الهدف واختر خطًا مناسبًا."
        },
        {
            heading: "أوضاع التحويل",
            body: "وضع Unicode هو الاختيار المعتاد للتطبيقات الحديثة. يهيّئ نص Unicode للتطبيقات ذات تشكيل النص غير المكتمل. استخدم خط Unicode يدعم النص الهدف.\n\nيستخدم وضع التوافق خطوط Maryam/LMN القديمة المتوافقة للتطبيقات القديمة التي لا تدعم نص Unicode. بعد اللصق، اختر خط Maryam المطابق. من دونه تظهر النتيجة كرموز غير مرتبطة. وضع التوافق غير متاح للعبرية وقد لا يحافظ على النص اللاتيني كما هو.\n\nملف العبرية يعمل في وضع Unicode فقط، ويستخدم الترتيب المرئي ثنائي الاتجاه من دون تشكيل سياقي على نمط العربية."
        },
        {
            heading: "الاتجاه والنص المختلط",
            body: "يستخدم كل فقرة أول حرف قوي فيها لتحديد الاتجاه. تُحاذى الفقرات اللاتينية إلى اليسار، وتُحاذى الفقرات الفارسية والعربية والأردية والكردية والعبرية إلى اليمين.\n\nيُستخدم تطبيق الترتيب المرئي ثنائي الاتجاه عندما يعامل التطبيق الهدف النص من اليمين إلى اليسار كنص عادي من اليسار إلى اليمين. يرتب كل فقرة على حدة قبل التحويل. اتركه معطّلًا عندما يتعامل التطبيق الهدف مع النص ثنائي الاتجاه بصورة صحيحة."
        },
        {
            heading: "أدوات النص",
            body: "أدوات النص تحويلات اختيارية للنص المصدر. لكل أداة مفتاح خاص بها. تعمل الأدوات المفعّلة معًا مباشرة قبل التحويل، وتحدّث النص المصدر، ثم تصبح تعديلًا واحدًا قابلًا للتراجع.\n\nيشمل تطبيع الفارسية الياء والكاف وهاء-ياء والتاء المربوطة والألف مع تنوين الفتح. يشمل تنظيف الكتابة الأرقام الفارسية وعلامات الاقتباس وإصلاح ZWNJ المراعي للأفعال والحركات والتطويل. توفر الأشكال البديلة الياء والكاف العربيتين وهاء-ياء القديمة والأرقام الإنجليزية وعلامات الاقتباس الإنجليزية.\n\nلا يمكن تفعيل التحويلات المتعاكسة معًا. يتعرف إصلاح ZWNJ على الأفعال الفارسية الشائعة، ولذلك يستطيع إصلاح «می خواهم» من دون تغيير كلمات غير مرتبطة مثل «میدان» بلا داعٍ."
        },
        {
            heading: "تصدير SVG",
            body: "يُنشئ تصدير SVG منحنيات متجهية قابلة للتحرير من النص المحوّل. اختر الخط واضبط حجمه وتباعد الأسطر والمحاذاة، ثم احفظ SVG. يبدأ تصدير Unicode بخط Vazirmatn المضمّن. يتطلب تصدير التوافق خط TTF أو OTF متوافقًا مع Maryam.\n\nافتح الخيارات الإضافية فقط للعرض أو الارتفاع الثابت والحشو والدقة ولون التعبئة وفهرس الخط ومحاور الخط المتغير. العرض والارتفاع التلقائيان مفعّلان افتراضيًا ويعطّلان حقولهما إلى أن توقفهما.\n\nيستخدم SVG الخط المحدد بدقة. إذا كان يفتقد حرفًا رسوميًا مطلوبًا، يحذّر پارسی‌نگار من أن SVG المحفوظ يحتوي على مخطط الحرف المفقود في الخط."
        },
        {
            heading: "المستندات والتحرير",
            body: "توفر قائمة المستند جديد وفتح وحفظ وحفظ باسم لمستندات نصية بترميز UTF-8. يحافظ سطح المكتب على نمط نهاية السطر الأصلي للمستند عندما يكون ذلك ممكنًا، ويحذّر قبل تجاهل التغييرات غير المحفوظة.\n\nيعيد التراجع والإعادة تعديلات المصدر والتحديدات ومواضع المؤشر وفواصل الفقرات."
        },
        {
            heading: "اختصارات لوحة المفاتيح",
            body: "التحويل والصفحات\nتحويل: \u2066Ctrl+Enter\u2069\nفتح أو إغلاق الإعدادات: \u2066Ctrl+,\u2069\nفتح أو إغلاق أدوات النص: \u2066Ctrl+T\u2069\nفتح أو إغلاق التصدير: \u2066Ctrl+E\u2069\nفتح أو إغلاق المساعدة: \u2066Ctrl+H\u2069\n\nالتحرير\nتراجع: \u2066Ctrl+Z\u2069\nإعادة: \u2066Ctrl+Y\u2069 أو \u2066Ctrl+Shift+Z\u2069\nزيادة حجم نص المحرر: \u2066Ctrl+Scroll Up\u2069\nتقليل حجم نص المحرر: \u2066Ctrl+Scroll Down\u2069\n\nالمستندات\nجديد: \u2066Ctrl+N\u2069\nفتح: \u2066Ctrl+O\u2069\nحفظ: \u2066Ctrl+S\u2069\nحفظ باسم: \u2066Ctrl+Shift+S\u2069\n\nفي macOS، تستخدم اختصارات المستندات والتحرير وحجم نص المحرر Command بدلًا من Ctrl. أما اختصارات التحويل والصفحات فتبقى تركيبات Ctrl. يُحفظ حجم نص المحرر المحدد بين مرات تشغيل التطبيق."
        },
        {
            heading: "استكشاف الأخطاء",
            body: "إذا كان النص الملصق مفصولًا أو معكوسًا أو بترتيب خاطئ، فتحقق من الملف والوضع وخط التطبيق الهدف وإعداد الترتيب المرئي ثنائي الاتجاه.\n\nإذا ظهرت النتيجة كرموز عشوائية، فربما استُخدم وضع التوافق من دون خط Maryam المطابق.\n\nإذا كان حرف مفقودًا، فاختر خط التطبيق الهدف أو التصدير الذي يحتويه. في Photoshop، عطّل All Caps وSmall Caps في إعدادات Character. استخدم خيار VideoStudio Pro لهذا التطبيق فقط."
        },
        {
            heading: "الإعدادات والخصوصية",
            body: "يحفظ سطح المكتب تفضيلات الواجهة وحجم خط المحرر وخيارات التشكيل ومفاتيح أدوات النص وخيارات تصدير SVG في ملف الإعدادات الخاص بهذه المنصة:",
            path: root.displayedSettingsFilePath,
            footer: "لا يحفظ مسودة المحرر أو الناتج المحوّل أو محتويات الحافظة أو رسائل الحالة أو محفوظات التراجع في ملف الإعدادات هذا."
        }
    ]

    readonly property var sections: controller.uiLanguage === "fa" ? persianSections : controller.uiLanguage === "ar" ? arabicSections : englishSections

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
            readonly property bool overflowing: helpContent.implicitHeight > height + 0.5
            readonly property real scrollGutter: overflowing ? ScrollBar.vertical.width + 6 : 0
            Layout.fillWidth: true
            Layout.fillHeight: true
            contentWidth: availableWidth
            clip: true
            leftPadding: root.rightToLeft ? scrollGutter : 0
            rightPadding: root.rightToLeft ? 0 : scrollGutter
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
                                horizontalAlignment: root.rightToLeft ? Text.AlignRight : Text.AlignLeft
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
                                horizontalAlignment: root.rightToLeft ? Text.AlignRight : Text.AlignLeft
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
                                horizontalAlignment: root.rightToLeft ? Text.AlignRight : Text.AlignLeft
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
                                horizontalAlignment: root.rightToLeft ? Text.AlignRight : Text.AlignLeft
                                wrapMode: Text.Wrap
                            }
                        }
                    }
                }
            }
        }
    }
}
