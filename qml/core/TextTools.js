// Copyright (c) 2026 LeoMoon Studios
// Source-text transformations ported from the original ParsiNegar editor.
var TextTools = (function () {
    "use strict";

    // Keep these lists in this shared transformation module so the plugin and
    // desktop app can use the same Persian verb-aware cleanup implementation.
    // The stems are ported from variables.py in the original Python app.
    var pastVerbStems = "آراست|آرامید|آزرد|آزمود|آسود|آشامید|آشفت|آغازید|آغشت|آفرید|آگند|آلود|آمد|آمرزید|آموخت|آمیخت|آورد|آویخت|آهیخت|ارزید|افتاد|افراشت|افروخت|افزود|افسرد|افشاند|افگند|انباشت|انجامید|انداخت|اندوخت|اندود|اندیشید|انگاشت|انگیخت|اوباشت|ایستاد|باخت|بارید|بافت|بالید|بایست|بخشود|بخشید|برازید|برد|برید|بست|بسود|بسیجید|بلعید|بود|بوسید|بویید|بیخت|پاشید|پالود|پخت|پذیرفت|پراکند|پرداخت|پرستید|پرسید|پرورد|پرید|پژمرد|پژوهید|پسندید|پلاسید|پلکید|پناهید|پنداشت|پوسید|پوشید|پویید|پیچید|پیراست|پیمود|پیوست|تاخت|تافت|تپید|تراشید|تراوید|ترسید|ترشید|ترکید|تکاند|تکانید|تنید|توانست|جست|جُست|جَست|جنبید|جنگید|جوشید|جوید|جهید|چاپید|چایید|چپید|چربید|چرخید|چرید|چسبید|چشید|چکید|چلاند|چلانید|چمید|چید|خارید|خاست|خایید|خراشید|خرامید|خروشید|خرید|خزید|خست|خشکید|خلید|خمید|خوابید|خواست|خواند|خورد|خوفید|خیسید|داد|داشت|دانست|درخشید|دروید|درید|دزدید|دمید|دوخت|دوشید|دوید|دیدم|ربود|رخشید|رسید|رست|رَست|رُست|رشت|رفت|رُفت|روفت|رقصید|رمید|رنجید|رندید|رویید|ریخت|رید|زارید|زایید|زد|زدود|زیست|ساخت|سپرد|سپوخت|ستد|سترد|ستود|ستیزید|سرود|سرشت|سرید|سزید|سفت|سگالید|سنجید|سوخت|سود|شاشید|شایست|شتافت|شد|شست|شکافت|شکست|شکفت|شکیفت|شگفت|شمرد|شناخت|شنید|شورید|طلبید|طوفید|غارتید|غرید|غلطید|غنود|فرستاد|فرسود|فرمود|فروخت|فریفت|فشرد|فهمید|قاپید|قبولاند|کاست|کاشت|کاوید|کرد|کشت|کشید|مکشید|کفت|کفید|کند|کوچید|کوشید|کوفت|گایید|گداخت|گذاشت|گذشت|گرازید|گرایید|گردید|گرفت|گروید|گریخت|گریست|گزارد|گزید|گُزید|گَزید|گسارد|گسترد|گسست|گشت|گشود|گفت|گماشت|گنجید|گندید|گوارید|گوزید|لرزید|لغزید|لمدنی|لندید|لنگید|لهید|لیسید|ماسید|مالید|ماند|مرد|مکید|مولید|مویید|نازید|نالید|نامید|نشست|نکوهید|نگاشت|نگریست|نمود|نواخت|نوردید|نوشت|نوشید|نهاد|نهفت|نیوشید|ورزید|وزید|هراسید|هشت|یارست|یازید|یافت";
    var presentVerbStems = "آرای|آرام|آزار|آزمای|آسای|آشام|آشوب|آغاز|آغار|آفرین|آگن|آلای|آی|آمرز|آموز|آمیز|آور|آویز|آهنج|ارز|افت|افراز|افروز|افزای|افسر|افشان|افگن|انبار|انجام|انداز|اندوز|اندای|اندیش|انگار|انگیز|اوبار|ایست|باز|بار|باش|باف|بال|بای|بخشای|بخش|براز|بر|بُر|بَر|بند|بساو|بسیج|بلع|بو|بوس|بوی|بیز|پاش|پالای|پز|پذیر|پراکن|پرداز|پرست|پرس|پرور|پر|پژمر|پژوه|پسند|پلاس|پلک|پناه|پندار|پوس|پوش|پوی|پیچ|پیرای|پیمای|پیوند|تاز|تاب|تپ|توپ|تراش|تراو|ترس|ترش|ترک|تکان|تن|توان|جه|جوی|جنب|جنگ|جوش|جو|چاپ|چای|چپ|چرب|چرخ|چر|چسب|چش|چک|چلان|چم|چین|خار|خیز|خای|خراش|خرام|خروش|خر|خز|خست|خشک|خل|خم|خواب|خواه|خوان|خور|خوف|خیس|ده|دار|دان|درخش|درو|در|دزد|دم|دوز|دوش|دو|بین|ربای|رخش|رس|ره|روی|رشت|رو|روب|رقص|رم|رنج|رند|روی|ریز|رین|زار|زای|زن|زدای|زی|ساز|سپر|سپوز|ستان|ستر|ستان|ستیز|سرای|سرشت|سر|سز|سنب|سگال|سنج|سوز|سای|شاش|شای|شتاب|شو|شوی|شکاف|شکن|شکوف|شکیب|شمر|شناس|شنو|شور|طلب|طوف|غارت|غر|غلط|غنو|فرست|فرسای|فرمای|فروش|فریب|فشر|فهم|قاپ|قبولان|کاه|کار|کاو|کن|کار|کُش|کش|کِش|کَش|کف|کن|کوچ|کوش|کوب|گای|گداز|گذار|گذر|گراز|گرای|گرد|گیر|گرو|گریز|گری|گزار|گز|گزین|گسار|گستر|گسل|گشای|گو|گمار|گنج|گند|گوار|گوز|لرز|لغز|لم|لند|لنگ|لهید|لیس|ماس|مال|مان|میر|مک|مول|موی|ناز|نال|نام|نشین|نکوه|نگار|نگر|نمای|نواز|نورد|نویس|نوش|نه|نهنب|نیوش|ورز|وز|هراس|هل|یار|یاز|یاب";
    var pastVerbPattern = new RegExp("(می|نمی)(" + pastVerbStems + ")(م|ی|یم|ید|ند|\\s|\\.|،|!|؛)", "g");
    var presentVerbPattern = new RegExp("(می|نمی)(" + presentVerbStems + ")(م|ی|د|یم|ید|ند)", "g");

    var operations = Object.freeze([
        { id: "arabicYehToPersian", group: "persian", labelKey: "tools.arabicYehToPersian", descriptionKey: "tools.arabicYehToPersianDescription", conflicts: ["persianYehToArabic"] },
        { id: "arabicKafToPersian", group: "persian", labelKey: "tools.arabicKafToPersian", descriptionKey: "tools.arabicKafToPersianDescription", conflicts: ["persianKafToArabic"] },
        { id: "normalizeHehYeh", group: "persian", labelKey: "tools.normalizeHehYeh", descriptionKey: "tools.normalizeHehYehDescription", conflicts: ["legacyHehYeh"] },
        { id: "tehMarbutaToHeh", group: "persian", labelKey: "tools.tehMarbutaToHeh", descriptionKey: "tools.tehMarbutaToHehDescription", conflicts: [] },
        { id: "alefFathatan", group: "persian", labelKey: "tools.alefFathatan", descriptionKey: "tools.alefFathatanDescription", conflicts: [] },
        { id: "persianDigits", group: "cleanup", labelKey: "tools.persianDigits", descriptionKey: "tools.persianDigitsDescription", conflicts: ["englishDigits"] },
        { id: "persianQuotes", group: "cleanup", labelKey: "tools.persianQuotes", descriptionKey: "tools.persianQuotesDescription", conflicts: ["englishQuotes"] },
        { id: "repairZwnj", group: "cleanup", labelKey: "tools.repairZwnj", descriptionKey: "tools.repairZwnjDescription", conflicts: [] },
        { id: "removeDiacritics", group: "cleanup", labelKey: "tools.removeDiacritics", descriptionKey: "tools.removeDiacriticsDescription", conflicts: [] },
        { id: "removeTatweel", group: "cleanup", labelKey: "tools.removeTatweel", descriptionKey: "tools.removeTatweelDescription", conflicts: [] },
        { id: "persianYehToArabic", group: "alternate", labelKey: "tools.persianYehToArabic", descriptionKey: "tools.persianYehToArabicDescription", conflicts: ["arabicYehToPersian"] },
        { id: "persianKafToArabic", group: "alternate", labelKey: "tools.persianKafToArabic", descriptionKey: "tools.persianKafToArabicDescription", conflicts: ["arabicKafToPersian"] },
        { id: "legacyHehYeh", group: "alternate", labelKey: "tools.legacyHehYeh", descriptionKey: "tools.legacyHehYehDescription", conflicts: ["normalizeHehYeh"] },
        { id: "englishDigits", group: "alternate", labelKey: "tools.englishDigits", descriptionKey: "tools.englishDigitsDescription", conflicts: ["persianDigits"] },
        { id: "englishQuotes", group: "alternate", labelKey: "tools.englishQuotes", descriptionKey: "tools.englishQuotesDescription", conflicts: ["persianQuotes"] }
    ]);

    function defaults() {
        var result = {};
        for (var index = 0; index < operations.length; index++) result[operations[index].id] = false;
        return result;
    }
    function operation(id) {
        for (var index = 0; index < operations.length; index++) if (operations[index].id === id) return operations[index];
        return null;
    }
    function groups(group) { return operations.filter(function (item) { return item.group === group; }); }
    function copyState(value) {
        var result = defaults();
        if (!value || typeof value !== "object") return result;
        for (var index = 0; index < operations.length; index++) {
            var id = operations[index].id;
            result[id] = value[id] === true;
        }
        // Keep persisted or externally supplied state valid too. If an older
        // state somehow contains both sides of a reverse pair, the first
        // operation in the list wins deterministically.
        for (var operationIndex = 0; operationIndex < operations.length; operationIndex++) {
            var item = operations[operationIndex];
            if (!result[item.id]) continue;
            for (var conflictIndex = 0; conflictIndex < item.conflicts.length; conflictIndex++) result[item.conflicts[conflictIndex]] = false;
        }
        return result;
    }
    function withToggled(value, id) {
        var item = operation(id);
        var result = copyState(value);
        if (!item) return result;
        result[id] = !result[id];
        if (result[id]) for (var index = 0; index < item.conflicts.length; index++) result[item.conflicts[index]] = false;
        return result;
    }
    function persianDigits(text) {
        return text.replace(/[0٠]/g, "۰").replace(/[1١]/g, "۱").replace(/[2٢]/g, "۲")
            .replace(/[3٣]/g, "۳").replace(/[4٤]/g, "۴").replace(/[5٥]/g, "۵")
            .replace(/[6٦]/g, "۶").replace(/[7٧]/g, "۷").replace(/[8٨]/g, "۸")
            .replace(/[9٩]/g, "۹").replace(/%/g, "٪")
            .replace(/([۰-۹])\.([۰-۹])/g, "$1٫$2").replace(/([۰-۹]),([۰-۹])/g, "$1٬$2");
    }
    function englishDigits(text) {
        return text.replace(/[۰٠]/g, "0").replace(/[۱١]/g, "1").replace(/[۲٢]/g, "2")
            .replace(/[۳٣]/g, "3").replace(/[۴٤]/g, "4").replace(/[۵٥]/g, "5")
            .replace(/[۶٦]/g, "6").replace(/[۷٧]/g, "7").replace(/[۸٨]/g, "8")
            .replace(/[۹٩]/g, "9").replace(/٪/g, "%")
            .replace(/([0-9])٫([0-9])/g, "$1.$2").replace(/([0-9])٬([0-9])/g, "$1,$2");
    }
    function repairZwnj(text) {
        return text.replace(pastVerbPattern, "$1‌$2$3").replace(presentVerbPattern, "$1‌$2$3")
            .replace(/(می|نمی)توان/g, "$1‌توان")
            .replace(/(‌)+/g, "‌").replace(/([\.،«»:؛\sآادذرزژوة])‌/g, "$1")
            .replace(/‌([a-zA-Z0-9\[\]\n\s\.،«»:؛])/g, "$1")
            .replace(/می /g, "می‌").replace(/نمی /g, "نمی‌").replace(/می‌و /g, "می و ")
            .replace(/ه\s(ام|ای|ایم|اید|اند|است)(?=[\]\.،:»\)\s]|$)/g, "ه‌$1")
            .replace(/\sها(ی|یی|یم|یت|یش|مان|تان|شان)?(?=[\]\.،:»\)\s]|$)/g, "‌ها$1");
    }
    function applyOne(text, id) {
        switch (id) {
        case "arabicYehToPersian": return text.replace(/[يى]/g, "ی");
        case "arabicKafToPersian": return text.replace(/ك/g, "ک");
        case "normalizeHehYeh": return text.replace(/ه[‌‎][یي]\s/g, "هٔ ").replace(/ه ی /g, "هٔ ")
            .replace(/ۀ/g, "هٔ").replace(/هء /g, "هٔ ").replace(/ه‌یی/g, "ه‌ای");
        case "tehMarbutaToHeh": return text.replace(/ة/g, "ه");
        case "alefFathatan": return text.replace(/ا"/g, "اً");
        case "persianDigits": return persianDigits(text);
        case "persianQuotes": return text.replace(/"(.*?)"/g, "«$1»").replace(/«([a-zA-Z]*?)»/g, '"$1"');
        case "repairZwnj": return repairZwnj(text);
        case "removeDiacritics": return text.replace(/[ًٌٍَُِّْٰٔ]/g, "");
        case "removeTatweel": return text.replace(/ـ/g, "");
        case "persianYehToArabic": return text.replace(/ی/g, "ي");
        case "persianKafToArabic": return text.replace(/ک/g, "ك");
        case "legacyHehYeh": return text.replace(/هٔ /g, "ه‌ی ");
        case "englishDigits": return englishDigits(text);
        case "englishQuotes": return text.replace(/[«»]/g, '"');
        default: return text;
        }
    }
    function applyEnabled(text, state) {
        var output = String(text === undefined || text === null ? "" : text);
        var enabled = copyState(state);
        var applied = [];
        for (var index = 0; index < operations.length; index++) {
            var id = operations[index].id;
            if (!enabled[id]) continue;
            var next = applyOne(output, id);
            if (next !== output) applied.push(id);
            output = next;
        }
        return { text: output, applied: applied };
    }
    return Object.freeze({ operations: operations, defaults: defaults, groups: groups, copyState: copyState, withToggled: withToggled, applyOne: applyOne, applyEnabled: applyEnabled });
}());
