.pragma library
.import "i18n/English.js" as EnglishStrings
.import "i18n/Persian.js" as PersianStrings
.import "i18n/Arabic.js" as ArabicStrings

// Copyright (c) 2026 LeoMoon Studios
// Language registry and English fallback for the localized interface dictionaries.
var InterfaceStrings = (function () {
  "use strict";

  var values = Object.freeze({
    en: EnglishStrings.values,
    fa: PersianStrings.values,
    ar: ArabicStrings.values
  });
  var languages = Object.freeze(["en", "fa", "ar"]);

  function normalize(language) { return language === "fa" || language === "ar" ? language : "en"; }
  function text(language, key) {
    var selected = values[normalize(language)];
    return Object.prototype.hasOwnProperty.call(selected, key) ? selected[key] : values.en[key] || key;
  }

  return Object.freeze({ languages: languages, normalize: normalize, text: text });
}());
