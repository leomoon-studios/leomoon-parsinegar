// Copyright (c) 2026 LeoMoon Studios
// Small, dependency-free interface dictionary for the English/Persian UI.
var InterfaceStrings = (function () {
  "use strict";

  var values = {
    en: {
      "app.title": "ParsiNegar Desktop", "app.subtitle": "Text tools for Persian, Arabic, Urdu, Kurdish, and Hebrew.", "theme.light": "Light theme", "theme.dark": "Dark theme",
      "editor.source": "Source text", "editor.characterCount": "%1 of %2 characters",
      "toggle.reverse": "Apply bidi visual ordering", "toggle.reverseDescription": "For applications that do not handle right-to-left layout",
      "toggle.video": "Special convert for VideoStudio Pro", "toggle.videoDescription": "Available in Compatibility mode",
      "placeholder": "Enter your text…", "mode.unicode": "Unicode mode", "mode.compatibility": "Compatibility mode",
      "mode.unicodeDescription": "Standard Unicode presentation forms for applications that accept Unicode text.", "mode.compatibilityDescription": "Legacy Maryam/LMN character codes. Requires a compatible LMN font.",
      "button.convert": "Convert", "button.settings": "Settings", "status.converting": "Converting and copying…", "status.converted": "Converted and copied.",
      "export.title": "Export SVG", "export.mode": "Mode", "export.font": "Font", "export.chooseFont": "Choose font…",
      "export.fontRequired": "Choose a Maryam-compatible font", "export.fontSize": "Font size", "export.moreOptions": "More options",
      "export.lineSpacing": "Line spacing", "export.alignment": "Alignment", "export.alignLeft": "Left", "export.alignCenter": "Center", "export.alignRight": "Right",
      "export.width": "Width", "export.height": "Height", "export.padding": "Padding", "export.auto": "Auto", "export.save": "Save SVG…",
      "export.success": "SVG curves saved.", "export.processing": "Creating SVG curves…", "export.error.noText": "Enter text before exporting.", "export.error.fontRequired": "Choose a compatible TTF/OTF font for this mode.",
      "export.error.invalidOption": "Check the export size and spacing values.", "export.error.invalidFont": "The selected font could not be read.",
      "export.error.missingGlyphs": "The selected font is missing required glyphs:", "export.warning.missingGlyphs": "Warning: SVG saved with the font's missing-glyph outlines for:", "export.error.bounds": "The SVG width or height is too small for this text.",
      "export.error.unsupportedGlyph": "The selected font contains a glyph that cannot be exported as curves.", "export.error.save": "The SVG file could not be saved.", "export.error.picker": "The file chooser could not be opened.", "export.error.generic": "SVG export failed.",
      "export.error.textTooLarge": "SVG export is limited to 50,000 characters.", "export.error.fontTooLarge": "The selected font exceeds the 50 MiB limit.", "export.error.svgTooLarge": "The generated SVG exceeds the 16 MiB limit.", "export.error.dimensions": "The generated SVG exceeds the supported dimensions.",
      "export.error.invalidPath": "Choose a valid local file path.",
      "status.textTooLarge": "Conversion is limited to 250,000 characters.", "status.failure": "Conversion failed: ", "status.settingsDirectory": "Could not create the settings directory.", "button.back": "Back", "settings.title": "Settings", "settings.interfaceLanguage": "INTERFACE LANGUAGE",
      "settings.interfaceLanguageDescription": "Choose the language used by this interface.", "language.english": "English", "language.persian": "پارسی",
      "settings.language": "SHAPING PROFILE", "settings.textShaping": "TEXT SHAPING", "settings.namedLigatures": "NAMED LIGATURES",
      "settings.profileLabel.standardPersianArabic": "Persian/Arabic", "settings.profileLabel.kurdishUrdu": "Kurdish/Urdu", "settings.profileLabel.hebrew": "Hebrew",
      "settings.profileDescription.standardPersianArabic": "Uses standard Unicode letter forms for Persian and Arabic.",
      "settings.profileDescription.kurdishUrdu": "Uses alternative Kurdish and Urdu letter forms. Some glyphs require a compatible font.",
      "settings.profileDescription.hebrew": "Uses bidi visual ordering only. Hebrew does not require contextual shaping.",
      "settings.hebrewNoticeTitle": "Hebrew uses bidi only",
      "settings.hebrewNoticeDescription": "Contextual shaping and ligature options do not apply to Hebrew. Compatibility mode is unavailable.",
      "settings.deleteHarakat": "Delete Harakat", "settings.deleteHarakatDescription": "Remove vowel and diacritic marks",
      "settings.shiftHarakat": "Shift Harakat position", "settings.shiftHarakatDescription": "Move retained marks for reversed display order",
      "settings.deleteTatweel": "Delete Tatweel", "settings.deleteTatweelDescription": "Remove the Arabic elongation character",
      "settings.supportZWJ": "Support ZWJ", "settings.supportZWJDescription": "Honor zero-width joiner shaping",
      "settings.unshapedIsolated": "Use unshaped isolated letters", "settings.unshapedIsolatedDescription": "Keep original code points for isolated forms",
      "settings.supportLigatures": "Enable ligatures", "settings.supportLigaturesDescription": "Master switch for every named ligature",
      "settings.fontNotice": "These ligatures require matching glyph support in the font used by the target application.",
      "settings.reset": "Reset to ParsiNegar defaults", "settings.breadcrumb": "Settings > ",
      "settings.status.recovered": "Invalid or outdated settings were replaced with safe defaults.", "settings.status.loadFailure": "Could not load settings: ", "settings.status.saveFailure": "Could not save settings: ",
      "settings.group.sentences": "Sentence ligatures", "settings.group.words": "Word ligatures", "settings.group.letters": "Letter ligatures",
      "settings.rialDescription": "Convert ریال or ريال to ﷼"
    },
    fa: {
      "app.title": "پارسی‌نگار دسکتاپ", "app.subtitle": "ابزارهای متن پارسی، عربی، اردو، کردی و عبری", "theme.light": "پوستهٔ روشن", "theme.dark": "پوستهٔ تیره",
      "editor.source": "متن مبدأ", "editor.characterCount": "%1 از %2 نویسه",
      "toggle.reverse": "اعمال ترتیب نمایشی دوجهته", "toggle.reverseDescription": "برای برنامه‌هایی که چیدمان راست‌به‌چپ را پشتیبانی نمی‌کنند",
      "toggle.video": "تبدیل ویژه برای VideoStudio Pro", "toggle.videoDescription": "در حالت سازگاری در دسترس است",
      "placeholder": "متن خود را وارد کنید…", "mode.unicode": "حالت یونیکد", "mode.compatibility": "حالت سازگاری",
      "mode.unicodeDescription": "فرم‌های نمایشی استاندارد یونیکد برای برنامه‌هایی که متن یونیکد را می‌پذیرند.", "mode.compatibilityDescription": "کدهای قدیمی مریم/LMN؛ به یک فونت سازگار با LMN نیاز دارد.",
      "button.convert": "تبدیل", "button.settings": "تنظیمات", "status.converting": "در حال تبدیل و کپی…", "status.converted": "تبدیل و کپی شد.",
      "export.title": "خروجی SVG", "export.mode": "حالت", "export.font": "فونت", "export.chooseFont": "انتخاب فونت…",
      "export.fontRequired": "یک فونت سازگار با مریم انتخاب کنید", "export.fontSize": "اندازهٔ فونت", "export.moreOptions": "گزینه‌های بیشتر",
      "export.lineSpacing": "فاصلهٔ خطوط", "export.alignment": "تراز", "export.alignLeft": "چپ", "export.alignCenter": "وسط", "export.alignRight": "راست",
      "export.width": "پهنا", "export.height": "ارتفاع", "export.padding": "حاشیه", "export.auto": "خودکار", "export.save": "ذخیرهٔ SVG…",
      "export.success": "منحنی‌های SVG ذخیره شدند.", "export.processing": "در حال ساخت منحنی‌های SVG…", "export.error.noText": "پیش از گرفتن خروجی، متن را وارد کنید.", "export.error.fontRequired": "برای این حالت یک فونت TTF/OTF سازگار انتخاب کنید.",
      "export.error.invalidOption": "مقدارهای اندازه و فاصلهٔ خروجی را بررسی کنید.", "export.error.invalidFont": "خواندن فونت انتخاب‌شده ممکن نشد.",
      "export.error.missingGlyphs": "فونت انتخاب‌شده گلیف‌های لازم را ندارد:", "export.warning.missingGlyphs": "هشدار: فایل SVG ذخیره شد؛ برای این نویسه‌ها از نماد گلیفِ ناموجود فونت استفاده شد:", "export.error.bounds": "پهنا یا ارتفاع SVG برای این متن کافی نیست.",
      "export.error.unsupportedGlyph": "یکی از گلیف‌های فونت انتخاب‌شده را نمی‌توان به منحنی تبدیل کرد.", "export.error.save": "ذخیرهٔ پروندهٔ SVG ممکن نشد.", "export.error.picker": "باز کردن انتخاب‌گر پرونده ممکن نشد.", "export.error.generic": "گرفتن خروجی SVG ناموفق بود.",
      "export.error.textTooLarge": "خروجی SVG به ۵۰٬۰۰۰ نویسه محدود است.", "export.error.fontTooLarge": "اندازهٔ فونت انتخاب‌شده از حد ۵۰ مگابایت بیشتر است.", "export.error.svgTooLarge": "اندازهٔ SVG ساخته‌شده از حد ۱۶ مگابایت بیشتر است.", "export.error.dimensions": "ابعاد SVG ساخته‌شده از محدودهٔ پشتیبانی‌شده بیشتر است.",
      "export.error.invalidPath": "یک مسیر محلی معتبر انتخاب کنید.",
      "status.textTooLarge": "تبدیل به ۲۵۰٬۰۰۰ نویسه محدود است.", "status.failure": "تبدیل ناموفق بود: ", "status.settingsDirectory": "ساخت پوشهٔ تنظیمات ممکن نشد.", "button.back": "بازگشت", "settings.title": "تنظیمات", "settings.interfaceLanguage": "زبان رابط",
      "settings.interfaceLanguageDescription": "زبان نمایش متن‌ها و کنترل‌های این افزونه را انتخاب کنید.", "language.english": "English", "language.persian": "پارسی",
      "settings.language": "نمایهٔ شکل‌دهی", "settings.textShaping": "شکل‌دهی متن", "settings.namedLigatures": "لیگچرهای نام‌دار",
      "settings.profileLabel.standardPersianArabic": "پارسی/عربی", "settings.profileLabel.kurdishUrdu": "کردی/اردو", "settings.profileLabel.hebrew": "عبری",
      "settings.profileDescription.standardPersianArabic": "از شکل‌های استاندارد یونیکد حروف برای پارسی و عربی استفاده می‌کند.",
      "settings.profileDescription.kurdishUrdu": "از شکل‌های جایگزین حروف کردی و اردو استفاده می‌کند؛ برخی گلیف‌ها به فونت سازگار نیاز دارند.",
      "settings.profileDescription.hebrew": "فقط ترتیب نمایشی دوجهته را اعمال می‌کند؛ عبری به شکل‌دهی زمینه‌ای نیاز ندارد.",
      "settings.hebrewNoticeTitle": "عبری فقط از ترتیب دوجهته استفاده می‌کند",
      "settings.hebrewNoticeDescription": "گزینه‌های شکل‌دهی زمینه‌ای و لیگچر برای عبری کاربرد ندارند. حالت سازگاری در دسترس نیست.",
      "settings.deleteHarakat": "حذف اعراب", "settings.deleteHarakatDescription": "اعراب و نشانه‌های آوایی را حذف می‌کند",
      "settings.shiftHarakat": "جابه‌جایی جایگاه اعراب", "settings.shiftHarakatDescription": "اعراب باقی‌مانده را برای ترتیب نمایش معکوس جابه‌جا می‌کند",
      "settings.deleteTatweel": "حذف تطویل", "settings.deleteTatweelDescription": "نویسهٔ کشیدهٔ خط عربی را حذف می‌کند",
      "settings.supportZWJ": "پشتیبانی از ZWJ", "settings.supportZWJDescription": "اتصال‌دهندهٔ بدون عرض را هنگام شکل‌دهی در نظر می‌گیرد",
      "settings.unshapedIsolated": "استفاده از نویسهٔ اصلی برای حروف جداافتاده", "settings.unshapedIsolatedDescription": "نویسهٔ اصلی یونیکد را برای حالت جداافتاده نگه می‌دارد",
      "settings.supportLigatures": "فعال‌سازی لیگچرها", "settings.supportLigaturesDescription": "کلید اصلی همهٔ لیگچرهای نام‌دار",
      "settings.fontNotice": "این لیگچرها فقط زمانی درست نمایش داده می‌شوند که فونت برنامهٔ مقصد از گلیف‌های متناظر پشتیبانی کند.",
      "settings.reset": "بازنشانی پیش‌فرض‌های پارسی‌نگار", "settings.breadcrumb": "تنظیمات > ",
      "settings.status.recovered": "تنظیمات نامعتبر یا قدیمی با پیش‌فرض‌های امن جایگزین شدند.", "settings.status.loadFailure": "بارگذاری تنظیمات ممکن نشد: ", "settings.status.saveFailure": "ذخیرهٔ تنظیمات ممکن نشد: ",
      "settings.group.sentences": "لیگچرهای عبارتی", "settings.group.words": "لیگچرهای واژه‌ای", "settings.group.letters": "لیگچرهای حرفی",
      "settings.rialDescription": "تبدیل ریال یا ريال به ﷼"
    }
  };

  var languages = Object.freeze(["en", "fa"]);
  function normalize(language) { return language === "fa" ? "fa" : "en"; }
  function text(language, key) {
    var selected = values[normalize(language)];
    return Object.prototype.hasOwnProperty.call(selected, key) ? selected[key] : values.en[key] || key;
  }
  return Object.freeze({ languages: languages, normalize: normalize, text: text });
}());
