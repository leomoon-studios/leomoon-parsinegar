// Copyright (c) 2026 LeoMoon Studios
// Hand-reviewed expectations derived from the pinned original ParsiNegar behavior.
var TextToolsFixtures = Object.freeze({
    schemaVersion: 1,
    source: Object.freeze({
        kind: "hand-reviewed",
        reference: "Original ParsiNegar text tools and Persian verb cleanup"
    }),
    cases: Object.freeze([
        { id: "arabic-yeh-to-persian", operation: "arabicYehToPersian", input: "ي ى ی\nLatin", expected: "ی ی ی\nLatin", rationale: "Normalizes both Arabic yeh forms while preserving Persian yeh, Latin text, and newlines." },
        { id: "arabic-kaf-to-persian", operation: "arabicKafToPersian", input: "ك کتاب", expected: "ک کتاب", rationale: "Normalizes Arabic kaf without changing an existing Persian kaf." },
        { id: "normalize-heh-yeh", operation: "normalizeHehYeh", input: "خانۀ خوب هء من ه‌یی", expected: "خانهٔ خوب هٔ من ه‌ای", rationale: "Normalizes precomposed, hamza, and legacy heh-ye spellings to the standard form." },
        { id: "teh-marbuta-to-heh", operation: "tehMarbutaToHeh", input: "مدرسة و خانه", expected: "مدرسه و خانه", rationale: "Replaces Arabic teh marbuta while preserving an existing Persian heh." },
        { id: "alef-fathatan", operation: "alefFathatan", input: "لطفا\" بفرمایید", expected: "لطفاً بفرمایید", rationale: "Converts the original editor's quote shorthand into alef with fathatan." },
        { id: "persian-digits", operation: "persianDigits", input: "Latin 12.5%, Arabic ٣, Persian ۴\n1,000", expected: "Latin ۱۲٫۵٪, Arabic ۳, Persian ۴\n۱٬۰۰۰", rationale: "Converts Latin and Arabic-Indic digits plus contextual decimal and grouping marks." },
        { id: "persian-quotes", operation: "persianQuotes", input: "\"سلام\" و \"test\"", expected: "«سلام» و \"test\"", rationale: "Uses Persian quotation marks for Persian text while retaining Latin quotations." },
        { id: "repair-zwnj", operation: "repairZwnj", input: "می روم، نمیخواستند میدان\nخانه ها می\nروم", expected: "می‌روم، نمی‌خواستند میدان\nخانه‌ها می\nروم", rationale: "Repairs verb and plural boundaries, avoids the noun میدان, and preserves hard line boundaries." },
        { id: "remove-diacritics", operation: "removeDiacritics", input: "سَلَامٌ عَلَیْکُم هٔ", expected: "سلام علیکم ه", rationale: "Removes supported Arabic combining marks, including the combining hamza used by heh-ye." },
        { id: "remove-tatweel", operation: "removeTatweel", input: "ســلام\ntext", expected: "سلام\ntext", rationale: "Removes tatweel without joining lines or changing other scripts." },
        { id: "persian-yeh-to-arabic", operation: "persianYehToArabic", input: "ی ي", expected: "ي ي", rationale: "Converts Persian yeh to the requested Arabic form." },
        { id: "persian-kaf-to-arabic", operation: "persianKafToArabic", input: "ک ك", expected: "ك ك", rationale: "Converts Persian kaf to the requested Arabic form." },
        { id: "legacy-heh-yeh", operation: "legacyHehYeh", input: "خانهٔ خوب", expected: "خانه‌ی خوب", rationale: "Converts standard heh-ye into the legacy ZWNJ and yeh spelling." },
        { id: "english-digits", operation: "englishDigits", input: "۱۲٫۵٪ و ٣٬٠٠٠", expected: "12.5% و 3,000", rationale: "Converts Persian and Arabic-Indic digits plus decimal, grouping, and percent marks." },
        { id: "english-quotes", operation: "englishQuotes", input: "«سلام» و «test»", expected: "\"سلام\" و \"test\"", rationale: "Converts Persian opening and closing quotation marks to double quotes." }
    ]),
    orderedEnabled: Object.freeze({
        input: "ي ك ة \"12.5%\" سَـلام می روم",
        enabled: Object.freeze({
            arabicYehToPersian: true,
            arabicKafToPersian: true,
            tehMarbutaToHeh: true,
            persianDigits: true,
            persianQuotes: true,
            repairZwnj: true,
            removeDiacritics: true,
            removeTatweel: true
        }),
        expected: "ی ک ه «۱۲٫۵٪» سلام می‌روم",
        applied: Object.freeze([
            "arabicYehToPersian",
            "arabicKafToPersian",
            "tehMarbutaToHeh",
            "persianDigits",
            "persianQuotes",
            "repairZwnj",
            "removeDiacritics",
            "removeTatweel"
        ]),
        rationale: "Enabled tools run once in the documented operation-list order before conversion."
    })
});
