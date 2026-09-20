// Copyright (c) 2026 LeoMoon Studios
// Pure settings validation and serialization; no host or filesystem APIs.
var ReshaperSettings = (function () {
  "use strict";
  var flags = Object.freeze([
    "deleteHarakat", "shiftHarakatPosition", "deleteTatweel", "supportZWJ",
    "useUnshapedInsteadOfIsolated", "supportLigatures"
  ]);
  var metadata = {
    "shapingProfiles": [
      { "id": "standardPersianArabic", "language": "Arabic" },
      { "id": "kurdishUrdu", "language": "Kurdish" },
      { "id": "hebrew", "language": null }
    ],
    "languages": [
      "Arabic",
      "Kurdish"
    ],
    "defaults": {
      "language": "Arabic",
      "deleteHarakat": true,
      "shiftHarakatPosition": false,
      "deleteTatweel": false,
      "supportZWJ": true,
      "useUnshapedInsteadOfIsolated": false,
      "supportLigatures": true,
      "ligatures": {
        "ARABIC LIGATURE BISMILLAH AR-RAHMAN AR-RAHEEM": false,
        "ARABIC LIGATURE JALLAJALALOUHOU": false,
        "ARABIC LIGATURE SALLALLAHOU ALAYHE WASALLAM": false,
        "ARABIC LIGATURE ALLAH": true,
        "ARABIC LIGATURE AKBAR": false,
        "ARABIC LIGATURE ALAYHE": false,
        "ARABIC LIGATURE MOHAMMAD": false,
        "ARABIC LIGATURE RASOUL": false,
        "ARABIC LIGATURE SALAM": false,
        "ARABIC LIGATURE SALLA": false,
        "ARABIC LIGATURE WASALLAM": false,
        "RIAL SIGN": false,
        "ARABIC LIGATURE AIN WITH ALEF MAKSURA": false,
        "ARABIC LIGATURE AIN WITH JEEM": false,
        "ARABIC LIGATURE AIN WITH JEEM WITH MEEM": false,
        "ARABIC LIGATURE AIN WITH MEEM": false,
        "ARABIC LIGATURE AIN WITH MEEM WITH ALEF MAKSURA": false,
        "ARABIC LIGATURE AIN WITH MEEM WITH MEEM": false,
        "ARABIC LIGATURE AIN WITH MEEM WITH YEH": false,
        "ARABIC LIGATURE AIN WITH YEH": false,
        "ARABIC LIGATURE ALEF MAKSURA WITH SUPERSCRIPT ALEF": false,
        "ARABIC LIGATURE ALEF WITH FATHATAN": false,
        "ARABIC LIGATURE BEH WITH ALEF MAKSURA": false,
        "ARABIC LIGATURE BEH WITH HAH": false,
        "ARABIC LIGATURE BEH WITH HAH WITH YEH": false,
        "ARABIC LIGATURE BEH WITH HEH": false,
        "ARABIC LIGATURE BEH WITH JEEM": false,
        "ARABIC LIGATURE BEH WITH KHAH": false,
        "ARABIC LIGATURE BEH WITH KHAH WITH YEH": false,
        "ARABIC LIGATURE BEH WITH MEEM": false,
        "ARABIC LIGATURE BEH WITH NOON": false,
        "ARABIC LIGATURE BEH WITH REH": false,
        "ARABIC LIGATURE BEH WITH YEH": false,
        "ARABIC LIGATURE BEH WITH ZAIN": false,
        "ARABIC LIGATURE DAD WITH ALEF MAKSURA": false,
        "ARABIC LIGATURE DAD WITH HAH": false,
        "ARABIC LIGATURE DAD WITH HAH WITH ALEF MAKSURA": false,
        "ARABIC LIGATURE DAD WITH HAH WITH YEH": false,
        "ARABIC LIGATURE DAD WITH JEEM": false,
        "ARABIC LIGATURE DAD WITH KHAH": false,
        "ARABIC LIGATURE DAD WITH KHAH WITH MEEM": false,
        "ARABIC LIGATURE DAD WITH MEEM": false,
        "ARABIC LIGATURE DAD WITH REH": false,
        "ARABIC LIGATURE DAD WITH YEH": false,
        "ARABIC LIGATURE FEH WITH ALEF MAKSURA": false,
        "ARABIC LIGATURE FEH WITH HAH": false,
        "ARABIC LIGATURE FEH WITH JEEM": false,
        "ARABIC LIGATURE FEH WITH KHAH": false,
        "ARABIC LIGATURE FEH WITH KHAH WITH MEEM": false,
        "ARABIC LIGATURE FEH WITH MEEM": false,
        "ARABIC LIGATURE FEH WITH MEEM WITH YEH": false,
        "ARABIC LIGATURE FEH WITH YEH": false,
        "ARABIC LIGATURE GHAIN WITH ALEF MAKSURA": false,
        "ARABIC LIGATURE GHAIN WITH JEEM": false,
        "ARABIC LIGATURE GHAIN WITH MEEM": false,
        "ARABIC LIGATURE GHAIN WITH MEEM WITH ALEF MAKSURA": false,
        "ARABIC LIGATURE GHAIN WITH MEEM WITH MEEM": false,
        "ARABIC LIGATURE GHAIN WITH MEEM WITH YEH": false,
        "ARABIC LIGATURE GHAIN WITH YEH": false,
        "ARABIC LIGATURE HAH WITH ALEF MAKSURA": false,
        "ARABIC LIGATURE HAH WITH JEEM": false,
        "ARABIC LIGATURE HAH WITH JEEM WITH YEH": false,
        "ARABIC LIGATURE HAH WITH MEEM": false,
        "ARABIC LIGATURE HAH WITH MEEM WITH ALEF MAKSURA": false,
        "ARABIC LIGATURE HAH WITH MEEM WITH YEH": false,
        "ARABIC LIGATURE HAH WITH YEH": false,
        "ARABIC LIGATURE HEH WITH ALEF MAKSURA": false,
        "ARABIC LIGATURE HEH WITH JEEM": false,
        "ARABIC LIGATURE HEH WITH MEEM": false,
        "ARABIC LIGATURE HEH WITH MEEM WITH JEEM": false,
        "ARABIC LIGATURE HEH WITH MEEM WITH MEEM": false,
        "ARABIC LIGATURE HEH WITH SUPERSCRIPT ALEF": false,
        "ARABIC LIGATURE HEH WITH YEH": false,
        "ARABIC LIGATURE JEEM WITH ALEF MAKSURA": false,
        "ARABIC LIGATURE JEEM WITH HAH": false,
        "ARABIC LIGATURE JEEM WITH HAH WITH ALEF MAKSURA": false,
        "ARABIC LIGATURE JEEM WITH HAH WITH YEH": false,
        "ARABIC LIGATURE JEEM WITH MEEM": false,
        "ARABIC LIGATURE JEEM WITH MEEM WITH ALEF MAKSURA": false,
        "ARABIC LIGATURE JEEM WITH MEEM WITH HAH": false,
        "ARABIC LIGATURE JEEM WITH MEEM WITH YEH": false,
        "ARABIC LIGATURE JEEM WITH YEH": false,
        "ARABIC LIGATURE KAF WITH ALEF": false,
        "ARABIC LIGATURE KAF WITH ALEF MAKSURA": false,
        "ARABIC LIGATURE KAF WITH HAH": false,
        "ARABIC LIGATURE KAF WITH JEEM": false,
        "ARABIC LIGATURE KAF WITH KHAH": false,
        "ARABIC LIGATURE KAF WITH LAM": false,
        "ARABIC LIGATURE KAF WITH MEEM": false,
        "ARABIC LIGATURE KAF WITH MEEM WITH MEEM": false,
        "ARABIC LIGATURE KAF WITH MEEM WITH YEH": false,
        "ARABIC LIGATURE KAF WITH YEH": false,
        "ARABIC LIGATURE KHAH WITH ALEF MAKSURA": false,
        "ARABIC LIGATURE KHAH WITH HAH": false,
        "ARABIC LIGATURE KHAH WITH JEEM": false,
        "ARABIC LIGATURE KHAH WITH MEEM": false,
        "ARABIC LIGATURE KHAH WITH YEH": false,
        "ARABIC LIGATURE LAM WITH ALEF": true,
        "ARABIC LIGATURE LAM WITH ALEF MAKSURA": false,
        "ARABIC LIGATURE LAM WITH ALEF WITH HAMZA ABOVE": true,
        "ARABIC LIGATURE LAM WITH ALEF WITH HAMZA BELOW": true,
        "ARABIC LIGATURE LAM WITH ALEF WITH MADDA ABOVE": true,
        "ARABIC LIGATURE LAM WITH HAH": false,
        "ARABIC LIGATURE LAM WITH HAH WITH ALEF MAKSURA": false,
        "ARABIC LIGATURE LAM WITH HAH WITH MEEM": false,
        "ARABIC LIGATURE LAM WITH HAH WITH YEH": false,
        "ARABIC LIGATURE LAM WITH HEH": false,
        "ARABIC LIGATURE LAM WITH JEEM": false,
        "ARABIC LIGATURE LAM WITH JEEM WITH JEEM": false,
        "ARABIC LIGATURE LAM WITH JEEM WITH MEEM": false,
        "ARABIC LIGATURE LAM WITH JEEM WITH YEH": false,
        "ARABIC LIGATURE LAM WITH KHAH": false,
        "ARABIC LIGATURE LAM WITH KHAH WITH MEEM": false,
        "ARABIC LIGATURE LAM WITH MEEM": false,
        "ARABIC LIGATURE LAM WITH MEEM WITH HAH": false,
        "ARABIC LIGATURE LAM WITH MEEM WITH YEH": false,
        "ARABIC LIGATURE LAM WITH YEH": false,
        "ARABIC LIGATURE MEEM WITH ALEF": false,
        "ARABIC LIGATURE MEEM WITH ALEF MAKSURA": false,
        "ARABIC LIGATURE MEEM WITH HAH": false,
        "ARABIC LIGATURE MEEM WITH HAH WITH JEEM": false,
        "ARABIC LIGATURE MEEM WITH HAH WITH MEEM": false,
        "ARABIC LIGATURE MEEM WITH HAH WITH YEH": false,
        "ARABIC LIGATURE MEEM WITH JEEM": false,
        "ARABIC LIGATURE MEEM WITH JEEM WITH HAH": false,
        "ARABIC LIGATURE MEEM WITH JEEM WITH KHAH": false,
        "ARABIC LIGATURE MEEM WITH JEEM WITH MEEM": false,
        "ARABIC LIGATURE MEEM WITH JEEM WITH YEH": false,
        "ARABIC LIGATURE MEEM WITH KHAH": false,
        "ARABIC LIGATURE MEEM WITH KHAH WITH JEEM": false,
        "ARABIC LIGATURE MEEM WITH KHAH WITH MEEM": false,
        "ARABIC LIGATURE MEEM WITH KHAH WITH YEH": false,
        "ARABIC LIGATURE MEEM WITH MEEM": false,
        "ARABIC LIGATURE MEEM WITH MEEM WITH YEH": false,
        "ARABIC LIGATURE MEEM WITH YEH": false,
        "ARABIC LIGATURE NOON WITH ALEF MAKSURA": false,
        "ARABIC LIGATURE NOON WITH HAH": false,
        "ARABIC LIGATURE NOON WITH HAH WITH ALEF MAKSURA": false,
        "ARABIC LIGATURE NOON WITH HAH WITH MEEM": false,
        "ARABIC LIGATURE NOON WITH HAH WITH YEH": false,
        "ARABIC LIGATURE NOON WITH HEH": false,
        "ARABIC LIGATURE NOON WITH JEEM": false,
        "ARABIC LIGATURE NOON WITH JEEM WITH ALEF MAKSURA": false,
        "ARABIC LIGATURE NOON WITH JEEM WITH HAH": false,
        "ARABIC LIGATURE NOON WITH JEEM WITH MEEM": false,
        "ARABIC LIGATURE NOON WITH JEEM WITH YEH": false,
        "ARABIC LIGATURE NOON WITH KHAH": false,
        "ARABIC LIGATURE NOON WITH MEEM": false,
        "ARABIC LIGATURE NOON WITH MEEM WITH ALEF MAKSURA": false,
        "ARABIC LIGATURE NOON WITH MEEM WITH YEH": false,
        "ARABIC LIGATURE NOON WITH NOON": false,
        "ARABIC LIGATURE NOON WITH REH": false,
        "ARABIC LIGATURE NOON WITH YEH": false,
        "ARABIC LIGATURE NOON WITH ZAIN": false,
        "ARABIC LIGATURE QAF WITH ALEF MAKSURA": false,
        "ARABIC LIGATURE QAF WITH HAH": false,
        "ARABIC LIGATURE QAF WITH MEEM": false,
        "ARABIC LIGATURE QAF WITH MEEM WITH HAH": false,
        "ARABIC LIGATURE QAF WITH MEEM WITH MEEM": false,
        "ARABIC LIGATURE QAF WITH MEEM WITH YEH": false,
        "ARABIC LIGATURE QAF WITH YEH": false,
        "ARABIC LIGATURE QALA USED AS KORANIC STOP SIGN": false,
        "ARABIC LIGATURE REH WITH SUPERSCRIPT ALEF": false,
        "ARABIC LIGATURE SAD WITH ALEF MAKSURA": false,
        "ARABIC LIGATURE SAD WITH HAH": false,
        "ARABIC LIGATURE SAD WITH HAH WITH HAH": false,
        "ARABIC LIGATURE SAD WITH HAH WITH YEH": false,
        "ARABIC LIGATURE SAD WITH KHAH": false,
        "ARABIC LIGATURE SAD WITH MEEM": false,
        "ARABIC LIGATURE SAD WITH MEEM WITH MEEM": false,
        "ARABIC LIGATURE SAD WITH REH": false,
        "ARABIC LIGATURE SAD WITH YEH": false,
        "ARABIC LIGATURE SALLA USED AS KORANIC STOP SIGN": false,
        "ARABIC LIGATURE SEEN WITH ALEF MAKSURA": false,
        "ARABIC LIGATURE SEEN WITH HAH": false,
        "ARABIC LIGATURE SEEN WITH HAH WITH JEEM": false,
        "ARABIC LIGATURE SEEN WITH HEH": false,
        "ARABIC LIGATURE SEEN WITH JEEM": false,
        "ARABIC LIGATURE SEEN WITH JEEM WITH ALEF MAKSURA": false,
        "ARABIC LIGATURE SEEN WITH JEEM WITH HAH": false,
        "ARABIC LIGATURE SEEN WITH KHAH": false,
        "ARABIC LIGATURE SEEN WITH KHAH WITH ALEF MAKSURA": false,
        "ARABIC LIGATURE SEEN WITH KHAH WITH YEH": false,
        "ARABIC LIGATURE SEEN WITH MEEM": false,
        "ARABIC LIGATURE SEEN WITH MEEM WITH HAH": false,
        "ARABIC LIGATURE SEEN WITH MEEM WITH JEEM": false,
        "ARABIC LIGATURE SEEN WITH MEEM WITH MEEM": false,
        "ARABIC LIGATURE SEEN WITH REH": false,
        "ARABIC LIGATURE SEEN WITH YEH": false,
        "ARABIC LIGATURE SHADDA WITH DAMMATAN ISOLATED FORM": false,
        "ARABIC LIGATURE SHADDA WITH KASRATAN ISOLATED FORM": false,
        "ARABIC LIGATURE SHADDA WITH FATHA ISOLATED FORM": false,
        "ARABIC LIGATURE SHADDA WITH DAMMA ISOLATED FORM": false,
        "ARABIC LIGATURE SHADDA WITH KASRA ISOLATED FORM": false,
        "ARABIC LIGATURE SHADDA WITH SUPERSCRIPT ALEF": false,
        "ARABIC LIGATURE SHADDA WITH FATHA MEDIAL FORM": false,
        "ARABIC LIGATURE SHADDA WITH DAMMA MEDIAL FORM": false,
        "ARABIC LIGATURE SHADDA WITH KASRA MEDIAL FORM": false,
        "ARABIC LIGATURE SHADDA WITH FATHA": false,
        "ARABIC LIGATURE SHADDA WITH DAMMA": false,
        "ARABIC LIGATURE SHADDA WITH KASRA": false,
        "ARABIC LIGATURE SHEEN WITH ALEF MAKSURA": false,
        "ARABIC LIGATURE SHEEN WITH HAH": false,
        "ARABIC LIGATURE SHEEN WITH HAH WITH MEEM": false,
        "ARABIC LIGATURE SHEEN WITH HAH WITH YEH": false,
        "ARABIC LIGATURE SHEEN WITH HEH": false,
        "ARABIC LIGATURE SHEEN WITH JEEM": false,
        "ARABIC LIGATURE SHEEN WITH JEEM WITH YEH": false,
        "ARABIC LIGATURE SHEEN WITH KHAH": false,
        "ARABIC LIGATURE SHEEN WITH MEEM": false,
        "ARABIC LIGATURE SHEEN WITH MEEM WITH KHAH": false,
        "ARABIC LIGATURE SHEEN WITH MEEM WITH MEEM": false,
        "ARABIC LIGATURE SHEEN WITH REH": false,
        "ARABIC LIGATURE SHEEN WITH YEH": false,
        "ARABIC LIGATURE TAH WITH ALEF MAKSURA": false,
        "ARABIC LIGATURE TAH WITH HAH": false,
        "ARABIC LIGATURE TAH WITH MEEM": false,
        "ARABIC LIGATURE TAH WITH MEEM WITH HAH": false,
        "ARABIC LIGATURE TAH WITH MEEM WITH MEEM": false,
        "ARABIC LIGATURE TAH WITH MEEM WITH YEH": false,
        "ARABIC LIGATURE TAH WITH YEH": false,
        "ARABIC LIGATURE TEH WITH ALEF MAKSURA": false,
        "ARABIC LIGATURE TEH WITH HAH": false,
        "ARABIC LIGATURE TEH WITH HAH WITH JEEM": false,
        "ARABIC LIGATURE TEH WITH HAH WITH MEEM": false,
        "ARABIC LIGATURE TEH WITH HEH": false,
        "ARABIC LIGATURE TEH WITH JEEM": false,
        "ARABIC LIGATURE TEH WITH JEEM WITH ALEF MAKSURA": false,
        "ARABIC LIGATURE TEH WITH JEEM WITH MEEM": false,
        "ARABIC LIGATURE TEH WITH JEEM WITH YEH": false,
        "ARABIC LIGATURE TEH WITH KHAH": false,
        "ARABIC LIGATURE TEH WITH KHAH WITH ALEF MAKSURA": false,
        "ARABIC LIGATURE TEH WITH KHAH WITH MEEM": false,
        "ARABIC LIGATURE TEH WITH KHAH WITH YEH": false,
        "ARABIC LIGATURE TEH WITH MEEM": false,
        "ARABIC LIGATURE TEH WITH MEEM WITH ALEF MAKSURA": false,
        "ARABIC LIGATURE TEH WITH MEEM WITH HAH": false,
        "ARABIC LIGATURE TEH WITH MEEM WITH JEEM": false,
        "ARABIC LIGATURE TEH WITH MEEM WITH KHAH": false,
        "ARABIC LIGATURE TEH WITH MEEM WITH YEH": false,
        "ARABIC LIGATURE TEH WITH NOON": false,
        "ARABIC LIGATURE TEH WITH REH": false,
        "ARABIC LIGATURE TEH WITH YEH": false,
        "ARABIC LIGATURE TEH WITH ZAIN": false,
        "ARABIC LIGATURE THAL WITH SUPERSCRIPT ALEF": false,
        "ARABIC LIGATURE THEH WITH ALEF MAKSURA": false,
        "ARABIC LIGATURE THEH WITH HEH": false,
        "ARABIC LIGATURE THEH WITH JEEM": false,
        "ARABIC LIGATURE THEH WITH MEEM": false,
        "ARABIC LIGATURE THEH WITH NOON": false,
        "ARABIC LIGATURE THEH WITH REH": false,
        "ARABIC LIGATURE THEH WITH YEH": false,
        "ARABIC LIGATURE THEH WITH ZAIN": false,
        "ARABIC LIGATURE UIGHUR KIRGHIZ YEH WITH HAMZA ABOVE WITH ALEF MAKSURA": false,
        "ARABIC LIGATURE YEH WITH ALEF MAKSURA": false,
        "ARABIC LIGATURE YEH WITH HAH": false,
        "ARABIC LIGATURE YEH WITH HAH WITH YEH": false,
        "ARABIC LIGATURE YEH WITH HAMZA ABOVE WITH AE": false,
        "ARABIC LIGATURE YEH WITH HAMZA ABOVE WITH ALEF": false,
        "ARABIC LIGATURE YEH WITH HAMZA ABOVE WITH ALEF MAKSURA": false,
        "ARABIC LIGATURE YEH WITH HAMZA ABOVE WITH E": false,
        "ARABIC LIGATURE YEH WITH HAMZA ABOVE WITH HAH": false,
        "ARABIC LIGATURE YEH WITH HAMZA ABOVE WITH HEH": false,
        "ARABIC LIGATURE YEH WITH HAMZA ABOVE WITH JEEM": false,
        "ARABIC LIGATURE YEH WITH HAMZA ABOVE WITH KHAH": false,
        "ARABIC LIGATURE YEH WITH HAMZA ABOVE WITH MEEM": false,
        "ARABIC LIGATURE YEH WITH HAMZA ABOVE WITH NOON": false,
        "ARABIC LIGATURE YEH WITH HAMZA ABOVE WITH OE": false,
        "ARABIC LIGATURE YEH WITH HAMZA ABOVE WITH REH": false,
        "ARABIC LIGATURE YEH WITH HAMZA ABOVE WITH U": false,
        "ARABIC LIGATURE YEH WITH HAMZA ABOVE WITH WAW": false,
        "ARABIC LIGATURE YEH WITH HAMZA ABOVE WITH YEH": false,
        "ARABIC LIGATURE YEH WITH HAMZA ABOVE WITH YU": false,
        "ARABIC LIGATURE YEH WITH HAMZA ABOVE WITH ZAIN": false,
        "ARABIC LIGATURE YEH WITH HEH": false,
        "ARABIC LIGATURE YEH WITH JEEM": false,
        "ARABIC LIGATURE YEH WITH JEEM WITH YEH": false,
        "ARABIC LIGATURE YEH WITH KHAH": false,
        "ARABIC LIGATURE YEH WITH MEEM": false,
        "ARABIC LIGATURE YEH WITH MEEM WITH MEEM": false,
        "ARABIC LIGATURE YEH WITH MEEM WITH YEH": false,
        "ARABIC LIGATURE YEH WITH NOON": false,
        "ARABIC LIGATURE YEH WITH REH": false,
        "ARABIC LIGATURE YEH WITH YEH": false,
        "ARABIC LIGATURE YEH WITH ZAIN": false,
        "ARABIC LIGATURE ZAH WITH MEEM": false
      }
    },
    "ligatureGroups": [
      {
        "id": "sentences",
        "label": "Sentence ligatures",
        "ligatures": [
          {
            "name": "ARABIC LIGATURE BISMILLAH AR-RAHMAN AR-RAHEEM",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE JALLAJALALOUHOU",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE SALLALLAHOU ALAYHE WASALLAM",
            "enabled": false
          }
        ]
      },
      {
        "id": "words",
        "label": "Word ligatures",
        "ligatures": [
          {
            "name": "ARABIC LIGATURE ALLAH",
            "enabled": true
          },
          {
            "name": "ARABIC LIGATURE AKBAR",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE ALAYHE",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE MOHAMMAD",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE RASOUL",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE SALAM",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE SALLA",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE WASALLAM",
            "enabled": false
          },
          {
            "name": "RIAL SIGN",
            "enabled": false
          }
        ]
      },
      {
        "id": "letters",
        "label": "Letter ligatures",
        "ligatures": [
          {
            "name": "ARABIC LIGATURE AIN WITH ALEF MAKSURA",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE AIN WITH JEEM",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE AIN WITH JEEM WITH MEEM",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE AIN WITH MEEM",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE AIN WITH MEEM WITH ALEF MAKSURA",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE AIN WITH MEEM WITH MEEM",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE AIN WITH MEEM WITH YEH",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE AIN WITH YEH",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE ALEF MAKSURA WITH SUPERSCRIPT ALEF",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE ALEF WITH FATHATAN",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE BEH WITH ALEF MAKSURA",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE BEH WITH HAH",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE BEH WITH HAH WITH YEH",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE BEH WITH HEH",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE BEH WITH JEEM",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE BEH WITH KHAH",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE BEH WITH KHAH WITH YEH",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE BEH WITH MEEM",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE BEH WITH NOON",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE BEH WITH REH",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE BEH WITH YEH",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE BEH WITH ZAIN",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE DAD WITH ALEF MAKSURA",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE DAD WITH HAH",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE DAD WITH HAH WITH ALEF MAKSURA",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE DAD WITH HAH WITH YEH",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE DAD WITH JEEM",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE DAD WITH KHAH",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE DAD WITH KHAH WITH MEEM",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE DAD WITH MEEM",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE DAD WITH REH",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE DAD WITH YEH",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE FEH WITH ALEF MAKSURA",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE FEH WITH HAH",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE FEH WITH JEEM",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE FEH WITH KHAH",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE FEH WITH KHAH WITH MEEM",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE FEH WITH MEEM",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE FEH WITH MEEM WITH YEH",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE FEH WITH YEH",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE GHAIN WITH ALEF MAKSURA",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE GHAIN WITH JEEM",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE GHAIN WITH MEEM",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE GHAIN WITH MEEM WITH ALEF MAKSURA",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE GHAIN WITH MEEM WITH MEEM",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE GHAIN WITH MEEM WITH YEH",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE GHAIN WITH YEH",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE HAH WITH ALEF MAKSURA",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE HAH WITH JEEM",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE HAH WITH JEEM WITH YEH",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE HAH WITH MEEM",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE HAH WITH MEEM WITH ALEF MAKSURA",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE HAH WITH MEEM WITH YEH",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE HAH WITH YEH",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE HEH WITH ALEF MAKSURA",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE HEH WITH JEEM",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE HEH WITH MEEM",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE HEH WITH MEEM WITH JEEM",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE HEH WITH MEEM WITH MEEM",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE HEH WITH SUPERSCRIPT ALEF",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE HEH WITH YEH",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE JEEM WITH ALEF MAKSURA",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE JEEM WITH HAH",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE JEEM WITH HAH WITH ALEF MAKSURA",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE JEEM WITH HAH WITH YEH",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE JEEM WITH MEEM",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE JEEM WITH MEEM WITH ALEF MAKSURA",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE JEEM WITH MEEM WITH HAH",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE JEEM WITH MEEM WITH YEH",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE JEEM WITH YEH",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE KAF WITH ALEF",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE KAF WITH ALEF MAKSURA",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE KAF WITH HAH",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE KAF WITH JEEM",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE KAF WITH KHAH",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE KAF WITH LAM",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE KAF WITH MEEM",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE KAF WITH MEEM WITH MEEM",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE KAF WITH MEEM WITH YEH",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE KAF WITH YEH",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE KHAH WITH ALEF MAKSURA",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE KHAH WITH HAH",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE KHAH WITH JEEM",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE KHAH WITH MEEM",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE KHAH WITH YEH",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE LAM WITH ALEF",
            "enabled": true
          },
          {
            "name": "ARABIC LIGATURE LAM WITH ALEF MAKSURA",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE LAM WITH ALEF WITH HAMZA ABOVE",
            "enabled": true
          },
          {
            "name": "ARABIC LIGATURE LAM WITH ALEF WITH HAMZA BELOW",
            "enabled": true
          },
          {
            "name": "ARABIC LIGATURE LAM WITH ALEF WITH MADDA ABOVE",
            "enabled": true
          },
          {
            "name": "ARABIC LIGATURE LAM WITH HAH",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE LAM WITH HAH WITH ALEF MAKSURA",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE LAM WITH HAH WITH MEEM",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE LAM WITH HAH WITH YEH",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE LAM WITH HEH",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE LAM WITH JEEM",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE LAM WITH JEEM WITH JEEM",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE LAM WITH JEEM WITH MEEM",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE LAM WITH JEEM WITH YEH",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE LAM WITH KHAH",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE LAM WITH KHAH WITH MEEM",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE LAM WITH MEEM",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE LAM WITH MEEM WITH HAH",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE LAM WITH MEEM WITH YEH",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE LAM WITH YEH",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE MEEM WITH ALEF",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE MEEM WITH ALEF MAKSURA",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE MEEM WITH HAH",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE MEEM WITH HAH WITH JEEM",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE MEEM WITH HAH WITH MEEM",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE MEEM WITH HAH WITH YEH",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE MEEM WITH JEEM",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE MEEM WITH JEEM WITH HAH",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE MEEM WITH JEEM WITH KHAH",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE MEEM WITH JEEM WITH MEEM",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE MEEM WITH JEEM WITH YEH",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE MEEM WITH KHAH",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE MEEM WITH KHAH WITH JEEM",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE MEEM WITH KHAH WITH MEEM",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE MEEM WITH KHAH WITH YEH",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE MEEM WITH MEEM",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE MEEM WITH MEEM WITH YEH",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE MEEM WITH YEH",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE NOON WITH ALEF MAKSURA",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE NOON WITH HAH",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE NOON WITH HAH WITH ALEF MAKSURA",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE NOON WITH HAH WITH MEEM",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE NOON WITH HAH WITH YEH",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE NOON WITH HEH",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE NOON WITH JEEM",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE NOON WITH JEEM WITH ALEF MAKSURA",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE NOON WITH JEEM WITH HAH",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE NOON WITH JEEM WITH MEEM",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE NOON WITH JEEM WITH YEH",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE NOON WITH KHAH",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE NOON WITH MEEM",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE NOON WITH MEEM WITH ALEF MAKSURA",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE NOON WITH MEEM WITH YEH",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE NOON WITH NOON",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE NOON WITH REH",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE NOON WITH YEH",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE NOON WITH ZAIN",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE QAF WITH ALEF MAKSURA",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE QAF WITH HAH",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE QAF WITH MEEM",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE QAF WITH MEEM WITH HAH",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE QAF WITH MEEM WITH MEEM",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE QAF WITH MEEM WITH YEH",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE QAF WITH YEH",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE QALA USED AS KORANIC STOP SIGN",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE REH WITH SUPERSCRIPT ALEF",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE SAD WITH ALEF MAKSURA",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE SAD WITH HAH",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE SAD WITH HAH WITH HAH",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE SAD WITH HAH WITH YEH",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE SAD WITH KHAH",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE SAD WITH MEEM",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE SAD WITH MEEM WITH MEEM",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE SAD WITH REH",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE SAD WITH YEH",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE SALLA USED AS KORANIC STOP SIGN",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE SEEN WITH ALEF MAKSURA",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE SEEN WITH HAH",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE SEEN WITH HAH WITH JEEM",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE SEEN WITH HEH",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE SEEN WITH JEEM",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE SEEN WITH JEEM WITH ALEF MAKSURA",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE SEEN WITH JEEM WITH HAH",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE SEEN WITH KHAH",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE SEEN WITH KHAH WITH ALEF MAKSURA",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE SEEN WITH KHAH WITH YEH",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE SEEN WITH MEEM",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE SEEN WITH MEEM WITH HAH",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE SEEN WITH MEEM WITH JEEM",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE SEEN WITH MEEM WITH MEEM",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE SEEN WITH REH",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE SEEN WITH YEH",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE SHADDA WITH DAMMATAN ISOLATED FORM",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE SHADDA WITH KASRATAN ISOLATED FORM",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE SHADDA WITH FATHA ISOLATED FORM",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE SHADDA WITH DAMMA ISOLATED FORM",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE SHADDA WITH KASRA ISOLATED FORM",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE SHADDA WITH SUPERSCRIPT ALEF",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE SHADDA WITH FATHA MEDIAL FORM",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE SHADDA WITH DAMMA MEDIAL FORM",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE SHADDA WITH KASRA MEDIAL FORM",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE SHADDA WITH FATHA",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE SHADDA WITH DAMMA",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE SHADDA WITH KASRA",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE SHEEN WITH ALEF MAKSURA",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE SHEEN WITH HAH",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE SHEEN WITH HAH WITH MEEM",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE SHEEN WITH HAH WITH YEH",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE SHEEN WITH HEH",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE SHEEN WITH JEEM",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE SHEEN WITH JEEM WITH YEH",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE SHEEN WITH KHAH",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE SHEEN WITH MEEM",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE SHEEN WITH MEEM WITH KHAH",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE SHEEN WITH MEEM WITH MEEM",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE SHEEN WITH REH",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE SHEEN WITH YEH",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE TAH WITH ALEF MAKSURA",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE TAH WITH HAH",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE TAH WITH MEEM",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE TAH WITH MEEM WITH HAH",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE TAH WITH MEEM WITH MEEM",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE TAH WITH MEEM WITH YEH",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE TAH WITH YEH",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE TEH WITH ALEF MAKSURA",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE TEH WITH HAH",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE TEH WITH HAH WITH JEEM",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE TEH WITH HAH WITH MEEM",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE TEH WITH HEH",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE TEH WITH JEEM",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE TEH WITH JEEM WITH ALEF MAKSURA",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE TEH WITH JEEM WITH MEEM",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE TEH WITH JEEM WITH YEH",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE TEH WITH KHAH",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE TEH WITH KHAH WITH ALEF MAKSURA",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE TEH WITH KHAH WITH MEEM",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE TEH WITH KHAH WITH YEH",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE TEH WITH MEEM",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE TEH WITH MEEM WITH ALEF MAKSURA",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE TEH WITH MEEM WITH HAH",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE TEH WITH MEEM WITH JEEM",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE TEH WITH MEEM WITH KHAH",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE TEH WITH MEEM WITH YEH",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE TEH WITH NOON",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE TEH WITH REH",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE TEH WITH YEH",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE TEH WITH ZAIN",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE THAL WITH SUPERSCRIPT ALEF",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE THEH WITH ALEF MAKSURA",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE THEH WITH HEH",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE THEH WITH JEEM",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE THEH WITH MEEM",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE THEH WITH NOON",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE THEH WITH REH",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE THEH WITH YEH",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE THEH WITH ZAIN",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE UIGHUR KIRGHIZ YEH WITH HAMZA ABOVE WITH ALEF MAKSURA",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE YEH WITH ALEF MAKSURA",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE YEH WITH HAH",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE YEH WITH HAH WITH YEH",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE YEH WITH HAMZA ABOVE WITH AE",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE YEH WITH HAMZA ABOVE WITH ALEF",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE YEH WITH HAMZA ABOVE WITH ALEF MAKSURA",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE YEH WITH HAMZA ABOVE WITH E",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE YEH WITH HAMZA ABOVE WITH HAH",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE YEH WITH HAMZA ABOVE WITH HEH",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE YEH WITH HAMZA ABOVE WITH JEEM",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE YEH WITH HAMZA ABOVE WITH KHAH",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE YEH WITH HAMZA ABOVE WITH MEEM",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE YEH WITH HAMZA ABOVE WITH NOON",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE YEH WITH HAMZA ABOVE WITH OE",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE YEH WITH HAMZA ABOVE WITH REH",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE YEH WITH HAMZA ABOVE WITH U",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE YEH WITH HAMZA ABOVE WITH WAW",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE YEH WITH HAMZA ABOVE WITH YEH",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE YEH WITH HAMZA ABOVE WITH YU",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE YEH WITH HAMZA ABOVE WITH ZAIN",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE YEH WITH HEH",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE YEH WITH JEEM",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE YEH WITH JEEM WITH YEH",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE YEH WITH KHAH",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE YEH WITH MEEM",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE YEH WITH MEEM WITH MEEM",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE YEH WITH MEEM WITH YEH",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE YEH WITH NOON",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE YEH WITH REH",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE YEH WITH YEH",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE YEH WITH ZAIN",
            "enabled": false
          },
          {
            "name": "ARABIC LIGATURE ZAH WITH MEEM",
            "enabled": false
          }
        ]
      }
    ]
  };
  function freeze(value) {
    if (value && typeof value === "object" && !Object.isFrozen(value)) {
      Object.keys(value).forEach(function (key) { freeze(value[key]); });
      Object.freeze(value);
    }
    return value;
  }
  freeze(metadata);
  function object(value) {
    return value !== null && typeof value === "object" && !Array.isArray(value) &&
      Object.prototype.toString.call(value) === "[object Object]";
  }
  function copy(value) { return JSON.parse(JSON.stringify(value)); }
  function sanitizeTextTools(value) {
    var result = {};
    if (!object(value)) return result;
    Object.keys(value).forEach(function (name) {
      if (typeof value[name] === "boolean") result[name] = value[name];
    });
    return result;
  }
  function sanitizeUiLanguage(value) { return value === "fa" || value === "ar" ? value : "en"; }
  function desktopDefaults() {
    return {
      conversionMode: "unicode",
      reverseWords: true,
      videoStudioPro: false,
      editorFontSize: 14,
      keyboardDrawerOpen: false,
      fontPaths: { unicode: "", compatibility: "" },
      exportSettings: {
        advancedVisible: false,
        automaticWidth: true,
        automaticHeight: true,
        alignment: "right",
        fontSize: "48",
        lineSpacing: "1.2",
        width: "800",
        height: "300",
        padding: "20",
        precision: "3",
        fontIndex: "",
        fill: "#000000",
        axes: ""
      }
    };
  }
  function savedText(value, fallback) {
    return typeof value === "string" && value.length <= 4096 ? value : fallback;
  }
  function sanitizeExportSettings(value) {
    var result = copy(desktopDefaults().exportSettings);
    if (!object(value)) return result;
    ["advancedVisible", "automaticWidth", "automaticHeight"].forEach(function (name) {
      if (typeof value[name] === "boolean") result[name] = value[name];
    });
    if (["left", "center", "right"].indexOf(value.alignment) !== -1) result.alignment = value.alignment;
    ["fontSize", "lineSpacing", "width", "height", "padding", "precision", "fontIndex", "fill", "axes"].forEach(function (name) {
      result[name] = savedText(value[name], result[name]);
    });
    return result;
  }
  function sanitizeDesktop(value) {
    var result = desktopDefaults();
    if (!object(value)) return result;
    if (value.conversionMode === "compatibility") result.conversionMode = "compatibility";
    ["reverseWords", "videoStudioPro", "keyboardDrawerOpen"].forEach(function (name) {
      if (typeof value[name] === "boolean") result[name] = value[name];
    });
    if (typeof value.editorFontSize === "number" && isFinite(value.editorFontSize) &&
        value.editorFontSize >= 10 && value.editorFontSize <= 48)
      result.editorFontSize = Math.round(value.editorFontSize);
    if (object(value.fontPaths)) {
      ["unicode", "compatibility"].forEach(function (mode) {
        if (typeof value.fontPaths[mode] === "string" && value.fontPaths[mode].length <= 4096)
          result.fontPaths[mode] = value.fontPaths[mode];
      });
    }
    result.exportSettings = sanitizeExportSettings(value.exportSettings);
    return result;
  }
  function profileForLanguage(language) { return language === "Kurdish" ? "kurdishUrdu" : "standardPersianArabic"; }
  function profileLanguage(metadata, profile) {
    for (var index = 0; index < metadata.shapingProfiles.length; index++) {
      if (metadata.shapingProfiles[index].id === profile) return metadata.shapingProfiles[index].language;
    }
    return "Arabic";
  }
  function sanitizeShapingProfile(metadata, value, legacyLanguage) {
    if (value === undefined) return profileForLanguage(legacyLanguage);
    for (var index = 0; index < metadata.shapingProfiles.length; index++) {
      if (metadata.shapingProfiles[index].id === value) return value;
    }
    return "standardPersianArabic";
  }
  function defaults(metadata) {
    var result = copy(metadata.defaults);
    // Original ParsiNegar retained Harakat; the generic reshaper deletes them by default.
    result.deleteHarakat = false;
    // ParsiNegar Express converts the common Persian currency word by default.
    result.ligatures["RIAL SIGN"] = true;
    return result;
  }
  function sanitize(metadata, value) {
    var result = defaults(metadata);
    if (!object(value)) return result;
    if (metadata.languages.indexOf(value.language) !== -1) result.language = value.language;
    flags.forEach(function (name) {
      if (typeof value[name] === "boolean") result[name] = value[name];
    });
    if (object(value.ligatures)) Object.keys(result.ligatures).forEach(function (name) {
      if (typeof value.ligatures[name] === "boolean") result.ligatures[name] = value.ligatures[name];
    });
    return result;
  }
  function parse(metadata, raw) {
    try {
      var document = JSON.parse(String(raw || ""));
      if (!object(document) || document.schemaVersion !== 1 || !object(document.settings)) {
        throw new Error("Unsupported settings file");
      }
      var settings = sanitize(metadata, document.settings);
      var shapingProfile = sanitizeShapingProfile(metadata, document.shapingProfile, document.settings.language);
      var language = profileLanguage(metadata, shapingProfile);
      if (language !== null) settings.language = language;
      return {
        settings: settings,
        shapingProfile: shapingProfile,
        uiLanguage: sanitizeUiLanguage(document.uiLanguage),
        desktop: sanitizeDesktop(document.desktop),
        textTools: sanitizeTextTools(document.textTools),
        recovered: false
      };
    } catch (error) {
      return { settings: defaults(metadata), shapingProfile: "standardPersianArabic", uiLanguage: "en", desktop: desktopDefaults(), textTools: {}, recovered: true };
    }
  }
  function serialize(metadata, value, uiLanguage, shapingProfile, desktop, textTools) {
    var settings = sanitize(metadata, value);
    var profile = sanitizeShapingProfile(metadata, shapingProfile, settings.language);
    var language = profileLanguage(metadata, profile);
    if (language !== null) settings.language = language;
    delete settings.language;
    return JSON.stringify({
      schemaVersion: 1,
      uiLanguage: sanitizeUiLanguage(uiLanguage),
      shapingProfile: profile,
      desktop: sanitizeDesktop(desktop),
      textTools: sanitizeTextTools(textTools),
      settings: settings
    }, null, 2) + "\n";
  }
  return Object.freeze({ metadata: metadata, flags: flags, copy: copy, defaults: defaults, sanitize: sanitize,
    desktopDefaults: desktopDefaults, sanitizeDesktop: sanitizeDesktop, sanitizeExportSettings: sanitizeExportSettings, sanitizeTextTools: sanitizeTextTools,
    sanitizeUiLanguage: sanitizeUiLanguage, sanitizeShapingProfile: sanitizeShapingProfile,
    profileForLanguage: profileForLanguage, profileLanguage: profileLanguage, parse: parse, serialize: serialize });
}());
