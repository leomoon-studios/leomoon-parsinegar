// Copyright (c) 2026 LeoMoon Studios
// Plugin conversion core. Load only with the conversion UI; no host APIs.
var ParsiNegar = (function () {
  "use strict";

  // Original order is significant: the first occurrence of a key wins.
  // This lookup is constructed once per script instance, never per conversion.
  var maryam = (function () {
    var pairs = [
      ["\u0640","@"],
      ["\ufe81","A"],
      ["\ufe82","B"],
      ["\ufe8d","H"],
      ["\ufe8e","I"],
      ["\ufe83","C"],
      ["\ufe84","D"],
      ["\ufe87","\u00e3H"],
      ["\ufe88","\u00e3I"],
      ["\ufe8f","J"],
      ["\ufe91","M"],
      ["\ufe92","L"],
      ["\ufe90","K"],
      ["\ufb56","N"],
      ["\ufb58","Q"],
      ["\ufb59","P"],
      ["\ufb57","O"],
      ["\ufe95","R"],
      ["\ufe97","U"],
      ["\ufe98","T"],
      ["\ufe96","S"],
      ["\ufe99","V"],
      ["\ufe9b","Y"],
      ["\ufe9c","X"],
      ["\ufe9a","W"],
      ["\ufe9d","Z"],
      ["\ufe9f","]"],
      ["\ufea0","\\"],
      ["\ufe9e","["],
      ["\ufb7a","^"],
      ["\ufb7c","a"],
      ["\ufb7d","`"],
      ["\ufb7b","_"],
      ["\ufea1","b"],
      ["\ufea3","e"],
      ["\ufea4","d"],
      ["\ufea2","c"],
      ["\ufea5","f"],
      ["\ufea7","i"],
      ["\ufea8","h"],
      ["\ufea6","g"],
      ["\ufea9","j"],
      ["\ufeaa","k"],
      ["\ufeab","l"],
      ["\ufeac","m"],
      ["\ufead","n"],
      ["\ufeae","o"],
      ["\ufeaf","p"],
      ["\ufeb0","q"],
      ["\ufb8a","r"],
      ["\ufb8b","s"],
      ["\ufeb1","t"],
      ["\ufeb3","w"],
      ["\ufeb4","v"],
      ["\ufeb2","u"],
      ["\ufeb5","x"],
      ["\ufeb7","{"],
      ["\ufeb8","z"],
      ["\ufeb6","y"],
      ["\ufeb9","|"],
      ["\ufebb","\u201a"],
      ["\ufebc","~"],
      ["\ufeba","}"],
      ["\ufebd","\u0192"],
      ["\ufebf","\u2020"],
      ["\ufec0","\u2026"],
      ["\ufebe","\u201e"],
      ["\ufec1","\u00f3"],
      ["\ufec3","\u00f6"],
      ["\ufec4","\u00f5"],
      ["\ufec2","\u00f4"],
      ["\ufec5","\u00c8"],
      ["\ufec7","\u00cb"],
      ["\ufec8","\u00ca"],
      ["\ufec6","\u00c9"],
      ["\ufec9","\u00cc"],
      ["\ufecb","\u00f8"],
      ["\ufecc","\u00f7"],
      ["\ufeca","\u00cd"],
      ["\ufecd","\u00f9"],
      ["\ufecf","\u00fc"],
      ["\ufed0","\u00fb"],
      ["\ufece","\u00fa"],
      ["\ufed1","\u203a"],
      ["\ufed3","\u00ce"],
      ["\ufed4","\u00ff"],
      ["\ufed2","\u0153"],
      ["\ufed5","\u00a1"],
      ["\ufed7","\u00a4"],
      ["\ufed8","\u00a3"],
      ["\ufed6","\u00a2"],
      ["\ufb8e","\u00a5"],
      ["\ufb90","\u00a8"],
      ["\ufb91","\u00a7"],
      ["\ufb8f","\u00a6"],
      ["\ufed9","\u00a5"],
      ["\ufedb","\u00a8"],
      ["\ufedc","\u00a7"],
      ["\ufeda","\u00a6"],
      ["\ufb92","\u00a9"],
      ["\ufb94","\u00ac"],
      ["\ufb95","\u00ab"],
      ["\ufb93","\u00aa"],
      ["\ufedd","\u00cf"],
      ["\ufedf","\u00b2"],
      ["\ufee0","\u00b1"],
      ["\ufede","\u00ae"],
      ["\ufee1","\u00b3"],
      ["\ufee3","\u00b6"],
      ["\ufee4","\u00b5"],
      ["\ufee2","\u00b4"],
      ["\ufee5","\u00b7"],
      ["\ufee7","\u00ba"],
      ["\ufee8","\u00b9"],
      ["\ufee6","\u00b8"],
      ["\ufeed","\u00bb"],
      ["\ufeee","\u00bc"],
      ["\ufe85","\u00e2\u00bb"],
      ["\ufe86","\u00e2\u00bc"],
      ["\ufee9","\u00bd"],
      ["\ufeeb","\u00c0"],
      ["\ufeec","\u00bf"],
      ["\ufeea","\u00be"],
      ["\ufe93","\u00e4\u00bd"],
      ["\ufe94","\u00e4\u00be"],
      ["\ufbfc","\u00c1"],
      ["\ufbfe","\u00c4"],
      ["\ufbff","\u00c3"],
      ["\ufbfd","\u00c2"],
      ["\ufef1","\u00e5\u00c1"],
      ["\ufef3","\u00c4"],
      ["\ufef4","\u00c3"],
      ["\ufef2","\u00e5\u00c2"],
      ["\ufe89","\u00e2\u00c1"],
      ["\ufe8b","G"],
      ["\ufe8c","F"],
      ["\ufe8a","\u00e2\u00c2"],
      ["\ufe80","E"],
      ["\ufef5","\u00d0\u00af"],
      ["\ufef6","\u00d0\u00b0"],
      ["\ufefb","\u00af"],
      ["\ufefc","\u00b0"],
      ["\ufef7","\u00e1\u00af"],
      ["\ufef8","\u00e1\u00b0"],
      ["\ufef9","\u00e3\u00af"],
      ["\ufefa","\u00e3\u00b0"],
      ["\u0654","\u00e2"],
      ["",""],
      ["\u064e","\u00d2"],
      ["\u0650","\u00df"],
      ["\u064f","\u00d4"],
      ["\u0651","\u00d8"],
      ["\u0670","\u00d1"],
      ["\u0652","\u00d6"],
      ["\u064b","\u00d3"],
      ["\u064d","\u00e0"],
      ["\u064c","\u00d5"],
      ["\ufc60","\u00da"],
      ["\ufc61","\u00db"],
      ["\ufc5e","\u00de"],
      ["\u06f1","1"],
      ["\u06f2","2"],
      ["\u06f3","3"],
      ["\u06f4","4"],
      ["\u06f5","5"],
      ["\u06f6","6"],
      ["\u06f7","7"],
      ["\u06f8","8"],
      ["\u06f9","9"],
      ["\u06f0","0"],
      ["1","1"],
      ["2","2"],
      ["3","3"],
      ["4","4"],
      ["5","5"],
      ["6","6"],
      ["7","7"],
      ["8","8"],
      ["9","9"],
      ["0","0"],
      ["!","!"],
      ["\"","\""],
      ["%","%"],
      ["\u066a","%"],
      ["(","("],
      ["[","["],
      ["{","{"],
      [")",")"],
      ["]","]"],
      ["}","}"],
      ["*","*"],
      ["+","+"],
      [",",","],
      ["\u066b",","],
      ["\u066c",","],
      ["-","-"],
      [".","."],
      ["/","/"],
      [":",":"],
      [";",";"],
      ["\u061b",";"],
      ["<","<"],
      ["\u00ab","<"],
      ["=","="],
      ["\u00bb",">"],
      [">",">"],
      ["?","?"],
      ["\u061f","?"],
      ["\ufc5f","\u00dd"],
      ["\ufc5e","\u00dc"],
      ["\ufc5f","\u00de"],
      ["\ufdf2","$H"],
      ["\ufba5","\u00e1\u00be"]
    ];
    var lookup = Object.create(null);
    pairs.forEach(function (pair) {
      if (pair[0] !== "" && !Object.prototype.hasOwnProperty.call(lookup, pair[0])) lookup[pair[0]] = pair[1];
    });
    return Object.freeze(lookup);
  }());

  var defaultShaperOptions = Object.freeze({
    language: "Arabic",
    deleteHarakat: false,
    shiftHarakatPosition: false,
    deleteTatweel: false,
    supportZWJ: true,
    useUnshapedInsteadOfIsolated: false,
    supportLigatures: true
  });

  function readReshaperOptions(options) {
    if (options === undefined) return defaultShaperOptions;
    if (options === null || typeof options !== "object" || Array.isArray(options) ||
        Object.prototype.toString.call(options) !== "[object Object]") {
      throw new TypeError("reshaperOptions must be an object");
    }
    if (Object.getOwnPropertySymbols(options).length) throw new TypeError("Unknown reshaper option");
    var result = {};
    Object.keys(defaultShaperOptions).forEach(function (key) { result[key] = defaultShaperOptions[key]; });
    Object.getOwnPropertyNames(options).forEach(function (key) {
      if (!Object.prototype.hasOwnProperty.call(defaultShaperOptions, key) && key !== "ligatures") {
        throw new TypeError("Unknown reshaper option: " + key);
      }
      if (key !== "ligatures" || options[key] === undefined) {
        result[key] = options[key];
        return;
      }
      if (options[key] === null || typeof options[key] !== "object" || Array.isArray(options[key]) ||
          Object.prototype.toString.call(options[key]) !== "[object Object]") {
        throw new TypeError("ligatures must be an object");
      }
      if (Object.getOwnPropertySymbols(options[key]).length) throw new TypeError("Unknown ligature option");
      var ligatures = {};
      Object.getOwnPropertyNames(options[key]).forEach(function (name) { ligatures[name] = options[key][name]; });
      result.ligatures = Object.freeze(ligatures);
    });
    return Object.freeze(result);
  }

  function requireText(text) {
    if (typeof text !== "string") throw new TypeError("Text must be a primitive string");
    return text;
  }

  function normalize(text) {
    return requireText(text).replace(/\u0649/g, "\u06cc").replace(/\u0627"/g, "\u0627\u064b");
  }

  function applyCustomLigatures(text) {
    return requireText(text)
      .replace(/\ufeea\u0654/g, "\ufba5")
      .replace(/\u064e\u0651|\u0651\u064e/g, "\ufc60")
      .replace(/\u064f\u0651|\u0651\u064f/g, "\ufc61")
      .replace(/\u0650\u0651|\u0651\u0650/g, "\ufc62")
      .replace(/\u0670\u0651|\u0651\u0670/g, "\ufc63")
      .replace(/\u064b\u0651|\u0651\u064b/g, "\ufc5f")
      .replace(/\u064c\u0651|\u0651\u064c/g, "\ufc5e")
      .replace(/\u064d\u0651|\u0651\u064d/g, "\ufc5f");
  }

  function normalizeCompatibility(text) {
    return requireText(text).replace(/[\u0660-\u0669]/g, function (digit) {
      return String.fromCharCode(digit.charCodeAt(0) + 0x90);
    }).replace(/%/g, "\u066a").replace(/\u060c/g, ",");
  }

  function mapMaryam(text, videoStudioPro) {
    if (videoStudioPro === undefined) videoStudioPro = false;
    if (typeof videoStudioPro !== "boolean") throw new TypeError("videoStudioPro must be a boolean");
    var normalized = normalizeCompatibility(text);
    var output = [];
    // Code-point iteration also preserves the original handling of unsupported
    // supplementary characters: drop the character as one unmapped unit.
    for (var character of normalized) {
      if (character === " " || character === "\n") output.push(character);
      else if (Object.prototype.hasOwnProperty.call(maryam, character)) output.push(maryam[character]);
    }
    // Match split("\n") + per-line append + strip("\n"), not whitespace trim.
    var result = output.join("").replace(/^\n+|\n+$/g, "");
    return videoStudioPro ? result.replace(/\u0153/g, "\u00fe") : result;
  }

  function readOptions(options) {
    if (options === undefined) options = {};
    if (options === null || typeof options !== "object" || Array.isArray(options) ||
        Object.prototype.toString.call(options) !== "[object Object]") {
      throw new TypeError("Options must be an object");
    }
    if (Object.getOwnPropertySymbols(options).length) throw new TypeError("Unknown option");
    Object.getOwnPropertyNames(options).forEach(function (key) {
      if (key !== "reverseWords" && key !== "videoStudioPro" && key !== "shapingProfile" && key !== "reshaperOptions") {
        throw new TypeError("Unknown option: " + key);
      }
    });
    var result = {};
    ["reverseWords", "videoStudioPro"].forEach(function (key) {
      var value = Object.prototype.hasOwnProperty.call(options, key) ? options[key] : undefined;
      if (value === undefined) value = key === "reverseWords";
      if (typeof value !== "boolean") throw new TypeError(key + " must be a boolean");
      result[key] = value;
    });
    var shapingProfile = Object.prototype.hasOwnProperty.call(options, "shapingProfile") ? options.shapingProfile : undefined;
    result.reshaperOptions = readReshaperOptions(
      Object.prototype.hasOwnProperty.call(options, "reshaperOptions") ? options.reshaperOptions : undefined
    );
    if (shapingProfile === undefined) shapingProfile = result.reshaperOptions.language === "Kurdish"
      ? "kurdishUrdu" : "standardPersianArabic";
    if (shapingProfile !== "standardPersianArabic" && shapingProfile !== "kurdishUrdu" && shapingProfile !== "hebrew") {
      throw new RangeError("Unknown shaping profile: " + shapingProfile);
    }
    result.shapingProfile = shapingProfile;
    var mappedLanguage = shapingProfile === "standardPersianArabic" ? "Arabic"
      : shapingProfile === "kurdishUrdu" ? "Kurdish" : null;
    if (mappedLanguage !== null && result.reshaperOptions.language !== mappedLanguage) {
      var mappedOptions = {};
      Object.keys(result.reshaperOptions).forEach(function (key) { mappedOptions[key] = result.reshaperOptions[key]; });
      mappedOptions.language = mappedLanguage;
      result.reshaperOptions = Object.freeze(mappedOptions);
    }
    return result;
  }

  function convert(text, mode, options, bidiApi, reshaperApi) {
    requireText(text);
    if (mode !== "unicode" && mode !== "compatibility") throw new RangeError("Mode must be unicode or compatibility");
    var settings = readOptions(options);
    if (settings.shapingProfile === "hebrew" && mode === "compatibility") {
      var compatibilityError = new RangeError("Hebrew supports Unicode mode only");
      compatibilityError.code = "HEBREW_COMPATIBILITY_UNSUPPORTED";
      throw compatibilityError;
    }
    if (settings.reverseWords && (!bidiApi || typeof bidiApi.getDisplay !== "function")) {
      throw new TypeError("A bidi API is required when reverseWords is enabled");
    }
    var result;
    if (settings.shapingProfile === "hebrew") result = text;
    else {
      if (!reshaperApi || typeof reshaperApi.reshape !== "function") throw new TypeError("A reshaper API is required");
      var shaped = requireText(reshaperApi.reshape(normalize(text), settings.reshaperOptions));
      result = applyCustomLigatures(shaped);
    }
    // Preserve whole-input auto detection. Do not split paragraphs or force RTL.
    if (settings.reverseWords) result = requireText(bidiApi.getDisplay(result));
    return mode === "compatibility" ? mapMaryam(result, settings.videoStudioPro) : result;
  }

  return Object.freeze({
    convert: convert,
    normalize: normalize,
    applyCustomLigatures: applyCustomLigatures,
    normalizeCompatibility: normalizeCompatibility,
    mapMaryam: mapMaryam
  });
}());
