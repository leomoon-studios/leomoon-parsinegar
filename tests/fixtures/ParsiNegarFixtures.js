// Static expected outputs, not generated from conversion results.
var ParsiNegarFixtures = {
"conversion": {
  "schemaVersion": 1,
  "description": "Static hand-derived expectations; no conversion implementation produced these strings.",
  "sourceCommit": "09745df108c4f809575c6788d899bf867cd32c31",
  "stages": {
    "normalize": [
      {
        "input": "\u0649 \u0627\" \u0627\"",
        "expected": "\u06cc \u0627\u064b \u0627\u064b"
      },
      {
        "input": "\u064a \u0643",
        "expected": "\u064a \u0643"
      },
      {
        "input": "",
        "expected": ""
      }
    ],
    "customLigatures": [
      {
        "input": "\ufeea\u0654",
        "expected": "\ufba5"
      },
      {
        "input": "\u064e\u0651",
        "expected": "\ufc60"
      },
      {
        "input": "\u0651\u064e",
        "expected": "\ufc60"
      },
      {
        "input": "\u064f\u0651",
        "expected": "\ufc61"
      },
      {
        "input": "\u0651\u064f",
        "expected": "\ufc61"
      },
      {
        "input": "\u0650\u0651",
        "expected": "\ufc62"
      },
      {
        "input": "\u0651\u0650",
        "expected": "\ufc62"
      },
      {
        "input": "\u0670\u0651",
        "expected": "\ufc63"
      },
      {
        "input": "\u0651\u0670",
        "expected": "\ufc63"
      },
      {
        "input": "\u064b\u0651",
        "expected": "\ufc5f"
      },
      {
        "input": "\u0651\u064b",
        "expected": "\ufc5f"
      },
      {
        "input": "\u064c\u0651",
        "expected": "\ufc5e"
      },
      {
        "input": "\u0651\u064c",
        "expected": "\ufc5e"
      },
      {
        "input": "\u064d\u0651",
        "expected": "\ufc5f"
      },
      {
        "input": "\u0651\u064d",
        "expected": "\ufc5f"
      }
    ],
    "compatibilityNormalization": [
      {
        "input": "\u0660\u0661\u0662\u0663\u0664\u0665\u0666\u0667\u0668\u0669%\u060c",
        "expected": "\u06f0\u06f1\u06f2\u06f3\u06f4\u06f5\u06f6\u06f7\u06f8\u06f9\u066a,"
      },
      {
        "input": "\u06f1\u06f2\u06f3\u066b\u066c\u061b",
        "expected": "\u06f1\u06f2\u06f3\u066b\u066c\u061b"
      }
    ]
  },
  "cases": [
    {
      "id": "empty",
      "input": "",
      "expected": {
        "unicode": {
          "logical": "",
          "visual": ""
        },
        "compatibility": {
          "logical": "",
          "visual": "",
          "logicalVideoStudio": "",
          "visualVideoStudio": ""
        }
      },
      "source": {
        "kind": "hand-derived",
        "rationale": "Empty input stays empty."
      }
    },
    {
      "id": "blank-lines",
      "input": "\n\n",
      "expected": {
        "unicode": {
          "logical": "\n\n",
          "visual": "\n\n"
        },
        "compatibility": {
          "logical": "",
          "visual": "",
          "logicalVideoStudio": "",
          "visualVideoStudio": ""
        }
      },
      "source": {
        "kind": "hand-derived",
        "rationale": "Unicode keeps LF separators; Maryam strips only edge LFs."
      }
    },
    {
      "id": "spaces",
      "input": "  ",
      "expected": {
        "unicode": {
          "logical": "  ",
          "visual": "  "
        },
        "compatibility": {
          "logical": "  ",
          "visual": "  ",
          "logicalVideoStudio": "  ",
          "visualVideoStudio": "  "
        }
      },
      "source": {
        "kind": "hand-derived",
        "rationale": "Spaces are copied by the mapping's explicit space branch."
      }
    },
    {
      "id": "persian-salam",
      "input": "\u0633\u0644\u0627\u0645",
      "expected": {
        "unicode": {
          "logical": "\ufeb3\ufefc\ufee1",
          "visual": "\ufee1\ufefc\ufeb3"
        },
        "compatibility": {
          "logical": "w\u00b0\u00b3",
          "visual": "\u00b3\u00b0w",
          "logicalVideoStudio": "w\u00b0\u00b3",
          "visualVideoStudio": "\u00b3\u00b0w"
        }
      },
      "source": {
        "kind": "hand-derived",
        "rationale": "SEEN initial, LAM-ALEF final ligature, MEEM isolated; reverse the RTL run."
      }
    },
    {
      "id": "persian-peh",
      "input": "\u067e\u067e\u067e",
      "expected": {
        "unicode": {
          "logical": "\ufb58\ufb59\ufb57",
          "visual": "\ufb57\ufb59\ufb58"
        },
        "compatibility": {
          "logical": "QPO",
          "visual": "OPQ",
          "logicalVideoStudio": "QPO",
          "visualVideoStudio": "OPQ"
        }
      },
      "source": {
        "kind": "hand-derived",
        "rationale": "PEH initial/medial/final map to Q/P/O."
      }
    },
    {
      "id": "arabic-teh",
      "input": "\u062a\u062a",
      "expected": {
        "unicode": {
          "logical": "\ufe97\ufe96",
          "visual": "\ufe96\ufe97"
        },
        "compatibility": {
          "logical": "US",
          "visual": "SU",
          "logicalVideoStudio": "US",
          "visualVideoStudio": "SU"
        }
      },
      "source": {
        "kind": "hand-derived",
        "rationale": "TEH initial and final map to U/S."
      }
    },
    {
      "id": "hebrew",
      "input": "\u05d0\u05d1",
      "expected": {
        "unicode": {
          "logical": "\u05d0\u05d1",
          "visual": "\u05d1\u05d0"
        },
        "compatibility": {
          "logical": "",
          "visual": "",
          "logicalVideoStudio": "",
          "visualVideoStudio": ""
        }
      },
      "source": {
        "kind": "hand-derived",
        "rationale": "Hebrew is only reordered; its letters have no Maryam entries."
      }
    },
    {
      "id": "mixed-ltr",
      "input": "\u067e abc 12",
      "expected": {
        "unicode": {
          "logical": "\ufb56 abc 12",
          "visual": "abc 12 \ufb56"
        },
        "compatibility": {
          "logical": "N  12",
          "visual": " 12 N",
          "logicalVideoStudio": "N  12",
          "visualVideoStudio": " 12 N"
        }
      },
      "source": {
        "kind": "hand-derived",
        "rationale": "LTR word and digits retain their internal order; Maryam drops Latin letters but keeps their surrounding spaces."
      }
    },
    {
      "id": "punctuation",
      "input": "(\u067e)",
      "expected": {
        "unicode": {
          "logical": "(\ufb56)",
          "visual": "(\ufb56)"
        },
        "compatibility": {
          "logical": "(N)",
          "visual": "(N)",
          "logicalVideoStudio": "(N)",
          "visualVideoStudio": "(N)"
        }
      },
      "source": {
        "kind": "hand-derived",
        "rationale": "Reversal and mirroring of the surrounding parentheses cancel."
      }
    },
    {
      "id": "persian-digits",
      "input": "\u067e \u06f1\u06f2\u06f3",
      "expected": {
        "unicode": {
          "logical": "\ufb56 \u06f1\u06f2\u06f3",
          "visual": "\u06f1\u06f2\u06f3 \ufb56"
        },
        "compatibility": {
          "logical": "N 123",
          "visual": "123 N",
          "logicalVideoStudio": "N 123",
          "visualVideoStudio": "123 N"
        }
      },
      "source": {
        "kind": "hand-derived",
        "rationale": "The numeric run retains digit order."
      }
    },
    {
      "id": "arabic-digits",
      "input": "\u0660\u0661\u0662",
      "expected": {
        "unicode": {
          "logical": "\u0660\u0661\u0662",
          "visual": "\u0660\u0661\u0662"
        },
        "compatibility": {
          "logical": "012",
          "visual": "012",
          "logicalVideoStudio": "012",
          "visualVideoStudio": "012"
        }
      },
      "source": {
        "kind": "hand-derived",
        "rationale": "Arabic digits normalize to Persian digits before Maryam mapping."
      }
    },
    {
      "id": "percent-comma",
      "input": "%\u060c\u061b",
      "expected": {
        "unicode": {
          "logical": "%\u060c\u061b",
          "visual": "\u061b\u060c%"
        },
        "compatibility": {
          "logical": "%,;",
          "visual": ";,%",
          "logicalVideoStudio": "%,;",
          "visualVideoStudio": ";,%"
        }
      },
      "source": {
        "kind": "hand-derived",
        "rationale": "UnicodeData assigns U+061B bidi class AL, so it selects base R; the preceding ET/CS resolve to R and the sequence reverses. Compatibility then maps percent and the punctuation signs to their existing values."
      }
    },
    {
      "id": "retained-fatha",
      "input": "\u0628\u064e",
      "expected": {
        "unicode": {
          "logical": "\ufe8f\u064e",
          "visual": "\u064e\ufe8f"
        },
        "compatibility": {
          "logical": "J\u00d2",
          "visual": "\u00d2J",
          "logicalVideoStudio": "J\u00d2",
          "visualVideoStudio": "\u00d2J"
        }
      },
      "source": {
        "kind": "hand-derived",
        "rationale": "Marks are kept without shifting, so the legacy bidi stage moves FATHA before BEH."
      }
    },
    {
      "id": "fake-fathatan",
      "input": "\u0627\"",
      "expected": {
        "unicode": {
          "logical": "\ufe8d\u064b",
          "visual": "\u064b\ufe8d"
        },
        "compatibility": {
          "logical": "H\u00d3",
          "visual": "\u00d3H",
          "logicalVideoStudio": "H\u00d3",
          "visualVideoStudio": "\u00d3H"
        }
      },
      "source": {
        "kind": "hand-derived",
        "rationale": "Normalize ALEF plus quotation mark to ALEF/FATHATAN before shaping."
      }
    },
    {
      "id": "alef-maksura",
      "input": "\u0649",
      "expected": {
        "unicode": {
          "logical": "\ufbfc",
          "visual": "\ufbfc"
        },
        "compatibility": {
          "logical": "\u00c1",
          "visual": "\u00c1",
          "logicalVideoStudio": "\u00c1",
          "visualVideoStudio": "\u00c1"
        }
      },
      "source": {
        "kind": "hand-derived",
        "rationale": "Normalize U+0649 to Persian YEH; its isolated form maps to U+00C1."
      }
    },
    {
      "id": "heh-hamza",
      "input": "\u0628\u0647\u0654",
      "expected": {
        "unicode": {
          "logical": "\ufe91\ufba5",
          "visual": "\ufba5\ufe91"
        },
        "compatibility": {
          "logical": "M\u00e1\u00be",
          "visual": "\u00e1\u00beM",
          "logicalVideoStudio": "M\u00e1\u00be",
          "visualVideoStudio": "\u00e1\u00beM"
        }
      },
      "source": {
        "kind": "hand-derived",
        "rationale": "Replace final HEH plus HAMZA ABOVE with U+FBA5 before bidi; its Maryam value has two code points."
      }
    },
    {
      "id": "duplicate-maryam-keys",
      "input": "\ufc5e\ufc5f",
      "expected": {
        "unicode": {
          "logical": "\ufc5e\ufc5f",
          "visual": "\ufc5f\ufc5e"
        },
        "compatibility": {
          "logical": "\u00de\u00dd",
          "visual": "\u00dd\u00de",
          "logicalVideoStudio": "\u00de\u00dd",
          "visualVideoStudio": "\u00dd\u00de"
        }
      },
      "source": {
        "kind": "hand-derived",
        "rationale": "First FC5E/FC5F entries win over later duplicate values."
      }
    },
    {
      "id": "multi-character-mappings",
      "input": "\ufe87\ufe88",
      "expected": {
        "unicode": {
          "logical": "\ufe87\ufe88",
          "visual": "\ufe88\ufe87"
        },
        "compatibility": {
          "logical": "\u00e3H\u00e3I",
          "visual": "\u00e3I\u00e3H",
          "logicalVideoStudio": "\u00e3H\u00e3I",
          "visualVideoStudio": "\u00e3I\u00e3H"
        }
      },
      "source": {
        "kind": "hand-derived",
        "rationale": "Map each presentation form after bidi; do not reverse characters within expanded Maryam values."
      }
    },
    {
      "id": "video-studio-feh",
      "input": "\u0641\u0641",
      "expected": {
        "unicode": {
          "logical": "\ufed3\ufed2",
          "visual": "\ufed2\ufed3"
        },
        "compatibility": {
          "logical": "\u00ce\u0153",
          "visual": "\u0153\u00ce",
          "logicalVideoStudio": "\u00ce\u00fe",
          "visualVideoStudio": "\u00fe\u00ce"
        }
      },
      "source": {
        "kind": "hand-derived",
        "rationale": "FEH initial/final map to U+00CE/U+0153; VideoStudio replaces final mapped U+0153 with U+00FE."
      }
    },
    {
      "id": "multiline",
      "input": "\n\u067e\n\n\u062a\n",
      "expected": {
        "unicode": {
          "logical": "\n\ufb56\n\n\ufe95\n",
          "visual": "\n\ufb56\n\n\ufe95\n"
        },
        "compatibility": {
          "logical": "N\n\nR",
          "visual": "N\n\nR",
          "logicalVideoStudio": "N\n\nR",
          "visualVideoStudio": "N\n\nR"
        }
      },
      "source": {
        "kind": "hand-derived",
        "rationale": "Preserve internal blank lines and remove only mapped edge newlines."
      }
    },
    {
      "id": "edge-spaces",
      "input": "\n \n\u067e\n \n",
      "expected": {
        "unicode": {
          "logical": "\n \n\ufb56\n \n",
          "visual": "\n \n\ufb56\n \n"
        },
        "compatibility": {
          "logical": " \nN\n ",
          "visual": " \nN\n ",
          "logicalVideoStudio": " \nN\n ",
          "visualVideoStudio": " \nN\n "
        }
      },
      "source": {
        "kind": "hand-derived",
        "rationale": "Maryam strip-newlines must not trim surrounding spaces."
      }
    },
    {
      "id": "whole-input-base",
      "input": "abc\n\u067e abc",
      "expected": {
        "unicode": {
          "logical": "abc\n\ufb56 abc",
          "visual": "abc\n\ufb56 abc"
        },
        "compatibility": {
          "logical": "N ",
          "visual": "N ",
          "logicalVideoStudio": "N ",
          "visualVideoStudio": "N "
        }
      },
      "source": {
        "kind": "hand-derived",
        "rationale": "First-line Latin sets whole-input base L; independent per-line auto direction would reorder the second line differently."
      }
    },
    {
      "id": "unmapped",
      "input": "\ud83d\ude00x\t\r",
      "expected": {
        "unicode": {
          "logical": "\ud83d\ude00x\t\r",
          "visual": "\ud83d\ude00x\t\r"
        },
        "compatibility": {
          "logical": "",
          "visual": "",
          "logicalVideoStudio": "",
          "visualVideoStudio": ""
        }
      },
      "source": {
        "kind": "hand-derived",
        "rationale": "Unicode preserves unsupported text and separators; Maryam drops characters absent from its table, including TAB/CR."
      }
    },
    {
      "id": "zwnj",
      "input": "\u0628\u200c\u0628",
      "expected": {
        "unicode": {
          "logical": "\ufe8f\u200c\ufe8f",
          "visual": "\ufe8f\ufe8f"
        },
        "compatibility": {
          "logical": "JJ",
          "visual": "JJ",
          "logicalVideoStudio": "JJ",
          "visualVideoStudio": "JJ"
        }
      },
      "source": {
        "kind": "hand-derived",
        "rationale": "ZWNJ breaks joining; bidi removes its BN character only when ordering is enabled."
      }
    },
    {
      "id": "zwj",
      "input": "\u0628\u200d\u0628",
      "expected": {
        "unicode": {
          "logical": "\ufe91\ufe90",
          "visual": "\ufe90\ufe91"
        },
        "compatibility": {
          "logical": "MK",
          "visual": "KM",
          "logicalVideoStudio": "MK",
          "visualVideoStudio": "KM"
        }
      },
      "source": {
        "kind": "hand-derived",
        "rationale": "ZWJ supports joining and is removed by shaping."
      }
    },
    {
      "id": "tatweel",
      "input": "\u0628\u0640\u0628",
      "expected": {
        "unicode": {
          "logical": "\ufe91\u0640\ufe90",
          "visual": "\ufe90\u0640\ufe91"
        },
        "compatibility": {
          "logical": "M@K",
          "visual": "K@M",
          "logicalVideoStudio": "M@K",
          "visualVideoStudio": "K@M"
        }
      },
      "source": {
        "kind": "hand-derived",
        "rationale": "Tatweel is retained and maps to @."
      }
    },
    {
      "id": "allah",
      "input": "\u0627\u0644\u0644\u0647",
      "expected": {
        "unicode": {
          "logical": "\ufdf2",
          "visual": "\ufdf2"
        },
        "compatibility": {
          "logical": "$H",
          "visual": "$H",
          "logicalVideoStudio": "$H",
          "visualVideoStudio": "$H"
        }
      },
      "source": {
        "kind": "hand-derived",
        "rationale": "The default ALLAH ligature is preserved and expands to the literal two-character mapping."
      }
    },
    {
      "id": "lone-surrogate",
      "input": "\ud800",
      "expected": {
        "unicode": {
          "logical": "\ud800",
          "visual": "\ud800"
        },
        "compatibility": {
          "logical": "",
          "visual": "",
          "logicalVideoStudio": "",
          "visualVideoStudio": ""
        }
      },
      "source": {
        "kind": "hand-derived",
        "rationale": "Unicode preserves a lone UTF-16 surrogate; Compatibility drops it."
      }
    },
    {
      "id": "combined-marks-64e",
      "input": "\u0628\u064e\u0651",
      "expected": {
        "unicode": {
          "logical": "\ufe8f\ufc60",
          "visual": "\ufc60\ufe8f"
        },
        "compatibility": {
          "logical": "J\u00da",
          "visual": "\u00daJ",
          "logicalVideoStudio": "J\u00da",
          "visualVideoStudio": "\u00daJ"
        }
      },
      "source": {
        "kind": "hand-derived",
        "rationale": "The existing combined-diacritic rule accepts both mark orders; retain its exact presentation form and first Maryam mapping, including unmapped forms."
      }
    },
    {
      "id": "combined-marks-64e-shadda-first",
      "input": "\u0628\u0651\u064e",
      "expected": {
        "unicode": {
          "logical": "\ufe8f\ufc60",
          "visual": "\ufc60\ufe8f"
        },
        "compatibility": {
          "logical": "J\u00da",
          "visual": "\u00daJ",
          "logicalVideoStudio": "J\u00da",
          "visualVideoStudio": "\u00daJ"
        }
      },
      "source": {
        "kind": "hand-derived",
        "rationale": "The existing combined-diacritic rule accepts both mark orders; retain its exact presentation form and first Maryam mapping, including unmapped forms."
      }
    },
    {
      "id": "combined-marks-64f",
      "input": "\u0628\u064f\u0651",
      "expected": {
        "unicode": {
          "logical": "\ufe8f\ufc61",
          "visual": "\ufc61\ufe8f"
        },
        "compatibility": {
          "logical": "J\u00db",
          "visual": "\u00dbJ",
          "logicalVideoStudio": "J\u00db",
          "visualVideoStudio": "\u00dbJ"
        }
      },
      "source": {
        "kind": "hand-derived",
        "rationale": "The existing combined-diacritic rule accepts both mark orders; retain its exact presentation form and first Maryam mapping, including unmapped forms."
      }
    },
    {
      "id": "combined-marks-64f-shadda-first",
      "input": "\u0628\u0651\u064f",
      "expected": {
        "unicode": {
          "logical": "\ufe8f\ufc61",
          "visual": "\ufc61\ufe8f"
        },
        "compatibility": {
          "logical": "J\u00db",
          "visual": "\u00dbJ",
          "logicalVideoStudio": "J\u00db",
          "visualVideoStudio": "\u00dbJ"
        }
      },
      "source": {
        "kind": "hand-derived",
        "rationale": "The existing combined-diacritic rule accepts both mark orders; retain its exact presentation form and first Maryam mapping, including unmapped forms."
      }
    },
    {
      "id": "combined-marks-650",
      "input": "\u0628\u0650\u0651",
      "expected": {
        "unicode": {
          "logical": "\ufe8f\ufc62",
          "visual": "\ufc62\ufe8f"
        },
        "compatibility": {
          "logical": "J",
          "visual": "J",
          "logicalVideoStudio": "J",
          "visualVideoStudio": "J"
        }
      },
      "source": {
        "kind": "hand-derived",
        "rationale": "The existing combined-diacritic rule accepts both mark orders; retain its exact presentation form and first Maryam mapping, including unmapped forms."
      }
    },
    {
      "id": "combined-marks-650-shadda-first",
      "input": "\u0628\u0651\u0650",
      "expected": {
        "unicode": {
          "logical": "\ufe8f\ufc62",
          "visual": "\ufc62\ufe8f"
        },
        "compatibility": {
          "logical": "J",
          "visual": "J",
          "logicalVideoStudio": "J",
          "visualVideoStudio": "J"
        }
      },
      "source": {
        "kind": "hand-derived",
        "rationale": "The existing combined-diacritic rule accepts both mark orders; retain its exact presentation form and first Maryam mapping, including unmapped forms."
      }
    },
    {
      "id": "combined-marks-670",
      "input": "\u0628\u0670\u0651",
      "expected": {
        "unicode": {
          "logical": "\ufe8f\ufc63",
          "visual": "\ufc63\ufe8f"
        },
        "compatibility": {
          "logical": "J",
          "visual": "J",
          "logicalVideoStudio": "J",
          "visualVideoStudio": "J"
        }
      },
      "source": {
        "kind": "hand-derived",
        "rationale": "The existing combined-diacritic rule accepts both mark orders; retain its exact presentation form and first Maryam mapping, including unmapped forms."
      }
    },
    {
      "id": "combined-marks-670-shadda-first",
      "input": "\u0628\u0651\u0670",
      "expected": {
        "unicode": {
          "logical": "\ufe8f\ufc63",
          "visual": "\ufc63\ufe8f"
        },
        "compatibility": {
          "logical": "J",
          "visual": "J",
          "logicalVideoStudio": "J",
          "visualVideoStudio": "J"
        }
      },
      "source": {
        "kind": "hand-derived",
        "rationale": "The existing combined-diacritic rule accepts both mark orders; retain its exact presentation form and first Maryam mapping, including unmapped forms."
      }
    },
    {
      "id": "combined-marks-64b",
      "input": "\u0628\u064b\u0651",
      "expected": {
        "unicode": {
          "logical": "\ufe8f\ufc5f",
          "visual": "\ufc5f\ufe8f"
        },
        "compatibility": {
          "logical": "J\u00dd",
          "visual": "\u00ddJ",
          "logicalVideoStudio": "J\u00dd",
          "visualVideoStudio": "\u00ddJ"
        }
      },
      "source": {
        "kind": "hand-derived",
        "rationale": "The existing combined-diacritic rule accepts both mark orders; retain its exact presentation form and first Maryam mapping, including unmapped forms."
      }
    },
    {
      "id": "combined-marks-64b-shadda-first",
      "input": "\u0628\u0651\u064b",
      "expected": {
        "unicode": {
          "logical": "\ufe8f\ufc5f",
          "visual": "\ufc5f\ufe8f"
        },
        "compatibility": {
          "logical": "J\u00dd",
          "visual": "\u00ddJ",
          "logicalVideoStudio": "J\u00dd",
          "visualVideoStudio": "\u00ddJ"
        }
      },
      "source": {
        "kind": "hand-derived",
        "rationale": "The existing combined-diacritic rule accepts both mark orders; retain its exact presentation form and first Maryam mapping, including unmapped forms."
      }
    },
    {
      "id": "combined-marks-64c",
      "input": "\u0628\u064c\u0651",
      "expected": {
        "unicode": {
          "logical": "\ufe8f\ufc5e",
          "visual": "\ufc5e\ufe8f"
        },
        "compatibility": {
          "logical": "J\u00de",
          "visual": "\u00deJ",
          "logicalVideoStudio": "J\u00de",
          "visualVideoStudio": "\u00deJ"
        }
      },
      "source": {
        "kind": "hand-derived",
        "rationale": "The existing combined-diacritic rule accepts both mark orders; retain its exact presentation form and first Maryam mapping, including unmapped forms."
      }
    },
    {
      "id": "combined-marks-64c-shadda-first",
      "input": "\u0628\u0651\u064c",
      "expected": {
        "unicode": {
          "logical": "\ufe8f\ufc5e",
          "visual": "\ufc5e\ufe8f"
        },
        "compatibility": {
          "logical": "J\u00de",
          "visual": "\u00deJ",
          "logicalVideoStudio": "J\u00de",
          "visualVideoStudio": "\u00deJ"
        }
      },
      "source": {
        "kind": "hand-derived",
        "rationale": "The existing combined-diacritic rule accepts both mark orders; retain its exact presentation form and first Maryam mapping, including unmapped forms."
      }
    },
    {
      "id": "combined-marks-64d",
      "input": "\u0628\u064d\u0651",
      "expected": {
        "unicode": {
          "logical": "\ufe8f\ufc5f",
          "visual": "\ufc5f\ufe8f"
        },
        "compatibility": {
          "logical": "J\u00dd",
          "visual": "\u00ddJ",
          "logicalVideoStudio": "J\u00dd",
          "visualVideoStudio": "\u00ddJ"
        }
      },
      "source": {
        "kind": "hand-derived",
        "rationale": "The existing combined-diacritic rule accepts both mark orders; retain its exact presentation form and first Maryam mapping, including unmapped forms."
      }
    },
    {
      "id": "combined-marks-64d-shadda-first",
      "input": "\u0628\u0651\u064d",
      "expected": {
        "unicode": {
          "logical": "\ufe8f\ufc5f",
          "visual": "\ufc5f\ufe8f"
        },
        "compatibility": {
          "logical": "J\u00dd",
          "visual": "\u00ddJ",
          "logicalVideoStudio": "J\u00dd",
          "visualVideoStudio": "\u00ddJ"
        }
      },
      "source": {
        "kind": "hand-derived",
        "rationale": "The existing combined-diacritic rule accepts both mark orders; retain its exact presentation form and first Maryam mapping, including unmapped forms."
      }
    }
  ]
},
"maryam": {
  "schemaVersion": 1,
  "source": {
    "project": "ParsiNegar",
    "commit": "09745df108c4f809575c6788d899bf867cd32c31",
    "path": "src/variables.py",
    "sha256": "6ea3e366470d66e55d0d373f479663580bc6ef7cc5b7dbee7726361faca6fe0b"
  },
  "pairs": [
    [
      "\u0640",
      "@"
    ],
    [
      "\ufe81",
      "A"
    ],
    [
      "\ufe82",
      "B"
    ],
    [
      "\ufe8d",
      "H"
    ],
    [
      "\ufe8e",
      "I"
    ],
    [
      "\ufe83",
      "C"
    ],
    [
      "\ufe84",
      "D"
    ],
    [
      "\ufe87",
      "\u00e3H"
    ],
    [
      "\ufe88",
      "\u00e3I"
    ],
    [
      "\ufe8f",
      "J"
    ],
    [
      "\ufe91",
      "M"
    ],
    [
      "\ufe92",
      "L"
    ],
    [
      "\ufe90",
      "K"
    ],
    [
      "\ufb56",
      "N"
    ],
    [
      "\ufb58",
      "Q"
    ],
    [
      "\ufb59",
      "P"
    ],
    [
      "\ufb57",
      "O"
    ],
    [
      "\ufe95",
      "R"
    ],
    [
      "\ufe97",
      "U"
    ],
    [
      "\ufe98",
      "T"
    ],
    [
      "\ufe96",
      "S"
    ],
    [
      "\ufe99",
      "V"
    ],
    [
      "\ufe9b",
      "Y"
    ],
    [
      "\ufe9c",
      "X"
    ],
    [
      "\ufe9a",
      "W"
    ],
    [
      "\ufe9d",
      "Z"
    ],
    [
      "\ufe9f",
      "]"
    ],
    [
      "\ufea0",
      "\\"
    ],
    [
      "\ufe9e",
      "["
    ],
    [
      "\ufb7a",
      "^"
    ],
    [
      "\ufb7c",
      "a"
    ],
    [
      "\ufb7d",
      "`"
    ],
    [
      "\ufb7b",
      "_"
    ],
    [
      "\ufea1",
      "b"
    ],
    [
      "\ufea3",
      "e"
    ],
    [
      "\ufea4",
      "d"
    ],
    [
      "\ufea2",
      "c"
    ],
    [
      "\ufea5",
      "f"
    ],
    [
      "\ufea7",
      "i"
    ],
    [
      "\ufea8",
      "h"
    ],
    [
      "\ufea6",
      "g"
    ],
    [
      "\ufea9",
      "j"
    ],
    [
      "\ufeaa",
      "k"
    ],
    [
      "\ufeab",
      "l"
    ],
    [
      "\ufeac",
      "m"
    ],
    [
      "\ufead",
      "n"
    ],
    [
      "\ufeae",
      "o"
    ],
    [
      "\ufeaf",
      "p"
    ],
    [
      "\ufeb0",
      "q"
    ],
    [
      "\ufb8a",
      "r"
    ],
    [
      "\ufb8b",
      "s"
    ],
    [
      "\ufeb1",
      "t"
    ],
    [
      "\ufeb3",
      "w"
    ],
    [
      "\ufeb4",
      "v"
    ],
    [
      "\ufeb2",
      "u"
    ],
    [
      "\ufeb5",
      "x"
    ],
    [
      "\ufeb7",
      "{"
    ],
    [
      "\ufeb8",
      "z"
    ],
    [
      "\ufeb6",
      "y"
    ],
    [
      "\ufeb9",
      "|"
    ],
    [
      "\ufebb",
      "\u201a"
    ],
    [
      "\ufebc",
      "~"
    ],
    [
      "\ufeba",
      "}"
    ],
    [
      "\ufebd",
      "\u0192"
    ],
    [
      "\ufebf",
      "\u2020"
    ],
    [
      "\ufec0",
      "\u2026"
    ],
    [
      "\ufebe",
      "\u201e"
    ],
    [
      "\ufec1",
      "\u00f3"
    ],
    [
      "\ufec3",
      "\u00f6"
    ],
    [
      "\ufec4",
      "\u00f5"
    ],
    [
      "\ufec2",
      "\u00f4"
    ],
    [
      "\ufec5",
      "\u00c8"
    ],
    [
      "\ufec7",
      "\u00cb"
    ],
    [
      "\ufec8",
      "\u00ca"
    ],
    [
      "\ufec6",
      "\u00c9"
    ],
    [
      "\ufec9",
      "\u00cc"
    ],
    [
      "\ufecb",
      "\u00f8"
    ],
    [
      "\ufecc",
      "\u00f7"
    ],
    [
      "\ufeca",
      "\u00cd"
    ],
    [
      "\ufecd",
      "\u00f9"
    ],
    [
      "\ufecf",
      "\u00fc"
    ],
    [
      "\ufed0",
      "\u00fb"
    ],
    [
      "\ufece",
      "\u00fa"
    ],
    [
      "\ufed1",
      "\u203a"
    ],
    [
      "\ufed3",
      "\u00ce"
    ],
    [
      "\ufed4",
      "\u00ff"
    ],
    [
      "\ufed2",
      "\u0153"
    ],
    [
      "\ufed5",
      "\u00a1"
    ],
    [
      "\ufed7",
      "\u00a4"
    ],
    [
      "\ufed8",
      "\u00a3"
    ],
    [
      "\ufed6",
      "\u00a2"
    ],
    [
      "\ufb8e",
      "\u00a5"
    ],
    [
      "\ufb90",
      "\u00a8"
    ],
    [
      "\ufb91",
      "\u00a7"
    ],
    [
      "\ufb8f",
      "\u00a6"
    ],
    [
      "\ufed9",
      "\u00a5"
    ],
    [
      "\ufedb",
      "\u00a8"
    ],
    [
      "\ufedc",
      "\u00a7"
    ],
    [
      "\ufeda",
      "\u00a6"
    ],
    [
      "\ufb92",
      "\u00a9"
    ],
    [
      "\ufb94",
      "\u00ac"
    ],
    [
      "\ufb95",
      "\u00ab"
    ],
    [
      "\ufb93",
      "\u00aa"
    ],
    [
      "\ufedd",
      "\u00cf"
    ],
    [
      "\ufedf",
      "\u00b2"
    ],
    [
      "\ufee0",
      "\u00b1"
    ],
    [
      "\ufede",
      "\u00ae"
    ],
    [
      "\ufee1",
      "\u00b3"
    ],
    [
      "\ufee3",
      "\u00b6"
    ],
    [
      "\ufee4",
      "\u00b5"
    ],
    [
      "\ufee2",
      "\u00b4"
    ],
    [
      "\ufee5",
      "\u00b7"
    ],
    [
      "\ufee7",
      "\u00ba"
    ],
    [
      "\ufee8",
      "\u00b9"
    ],
    [
      "\ufee6",
      "\u00b8"
    ],
    [
      "\ufeed",
      "\u00bb"
    ],
    [
      "\ufeee",
      "\u00bc"
    ],
    [
      "\ufe85",
      "\u00e2\u00bb"
    ],
    [
      "\ufe86",
      "\u00e2\u00bc"
    ],
    [
      "\ufee9",
      "\u00bd"
    ],
    [
      "\ufeeb",
      "\u00c0"
    ],
    [
      "\ufeec",
      "\u00bf"
    ],
    [
      "\ufeea",
      "\u00be"
    ],
    [
      "\ufe93",
      "\u00e4\u00bd"
    ],
    [
      "\ufe94",
      "\u00e4\u00be"
    ],
    [
      "\ufbfc",
      "\u00c1"
    ],
    [
      "\ufbfe",
      "\u00c4"
    ],
    [
      "\ufbff",
      "\u00c3"
    ],
    [
      "\ufbfd",
      "\u00c2"
    ],
    [
      "\ufef1",
      "\u00e5\u00c1"
    ],
    [
      "\ufef3",
      "\u00c4"
    ],
    [
      "\ufef4",
      "\u00c3"
    ],
    [
      "\ufef2",
      "\u00e5\u00c2"
    ],
    [
      "\ufe89",
      "\u00e2\u00c1"
    ],
    [
      "\ufe8b",
      "G"
    ],
    [
      "\ufe8c",
      "F"
    ],
    [
      "\ufe8a",
      "\u00e2\u00c2"
    ],
    [
      "\ufe80",
      "E"
    ],
    [
      "\ufef5",
      "\u00d0\u00af"
    ],
    [
      "\ufef6",
      "\u00d0\u00b0"
    ],
    [
      "\ufefb",
      "\u00af"
    ],
    [
      "\ufefc",
      "\u00b0"
    ],
    [
      "\ufef7",
      "\u00e1\u00af"
    ],
    [
      "\ufef8",
      "\u00e1\u00b0"
    ],
    [
      "\ufef9",
      "\u00e3\u00af"
    ],
    [
      "\ufefa",
      "\u00e3\u00b0"
    ],
    [
      "\u0654",
      "\u00e2"
    ],
    [
      "",
      ""
    ],
    [
      "\u064e",
      "\u00d2"
    ],
    [
      "\u0650",
      "\u00df"
    ],
    [
      "\u064f",
      "\u00d4"
    ],
    [
      "\u0651",
      "\u00d8"
    ],
    [
      "\u0670",
      "\u00d1"
    ],
    [
      "\u0652",
      "\u00d6"
    ],
    [
      "\u064b",
      "\u00d3"
    ],
    [
      "\u064d",
      "\u00e0"
    ],
    [
      "\u064c",
      "\u00d5"
    ],
    [
      "\ufc60",
      "\u00da"
    ],
    [
      "\ufc61",
      "\u00db"
    ],
    [
      "\ufc5e",
      "\u00de"
    ],
    [
      "\u06f1",
      "1"
    ],
    [
      "\u06f2",
      "2"
    ],
    [
      "\u06f3",
      "3"
    ],
    [
      "\u06f4",
      "4"
    ],
    [
      "\u06f5",
      "5"
    ],
    [
      "\u06f6",
      "6"
    ],
    [
      "\u06f7",
      "7"
    ],
    [
      "\u06f8",
      "8"
    ],
    [
      "\u06f9",
      "9"
    ],
    [
      "\u06f0",
      "0"
    ],
    [
      "1",
      "1"
    ],
    [
      "2",
      "2"
    ],
    [
      "3",
      "3"
    ],
    [
      "4",
      "4"
    ],
    [
      "5",
      "5"
    ],
    [
      "6",
      "6"
    ],
    [
      "7",
      "7"
    ],
    [
      "8",
      "8"
    ],
    [
      "9",
      "9"
    ],
    [
      "0",
      "0"
    ],
    [
      "!",
      "!"
    ],
    [
      "\"",
      "\""
    ],
    [
      "%",
      "%"
    ],
    [
      "\u066a",
      "%"
    ],
    [
      "(",
      "("
    ],
    [
      "[",
      "["
    ],
    [
      "{",
      "{"
    ],
    [
      ")",
      ")"
    ],
    [
      "]",
      "]"
    ],
    [
      "}",
      "}"
    ],
    [
      "*",
      "*"
    ],
    [
      "+",
      "+"
    ],
    [
      ",",
      ","
    ],
    [
      "\u066b",
      ","
    ],
    [
      "\u066c",
      ","
    ],
    [
      "-",
      "-"
    ],
    [
      ".",
      "."
    ],
    [
      "/",
      "/"
    ],
    [
      ":",
      ":"
    ],
    [
      ";",
      ";"
    ],
    [
      "\u061b",
      ";"
    ],
    [
      "<",
      "<"
    ],
    [
      "\u00ab",
      "<"
    ],
    [
      "=",
      "="
    ],
    [
      "\u00bb",
      ">"
    ],
    [
      ">",
      ">"
    ],
    [
      "?",
      "?"
    ],
    [
      "\u061f",
      "?"
    ],
    [
      "\ufc5f",
      "\u00dd"
    ],
    [
      "\ufc5e",
      "\u00dc"
    ],
    [
      "\ufc5f",
      "\u00de"
    ],
    [
      "\ufdf2",
      "$H"
    ],
    [
      "\ufba5",
      "\u00e1\u00be"
    ]
  ]
},
"editor-corpus": {"source":"ParsiNegar src/#rnd/testCases.txt","purpose":"Whole-editor smoke input; no claimed golden output.","text":"\u0622 \u0628\u0622 \u0623 \u0628\u0623 \u0625 \u0628\u0625 \u0627 \u0644\u0627 \u0628\u0627 - \u0628\u0640 \u0640\u0628 - \ufdfc\n\u0628\u0628\u0628 \u0628 - \u067e\u067e\u067e \u067e - \u062a\u062a\u062a \u062a - \u062b\u062b\u062b \u062b\n\u062c\u062c\u062c \u062c - \u0686\u0686\u0686 \u0686 - \u062d\u062d\u062d \u062d - \u062e\u062e\u062e \u062e\n\u062f \u0628\u062f - \u0630 \u0628\u0630 - \u0631 \u0628\u0631 - \u0632 \u0628\u0632 - \u0698 \u0628\u0698\n\u0633\u0633\u0633 \u0633 - \u0634\u0634\u0634 \u0634 - \u0635\u0635\u0635 \u0635 - \u0636\u0636\u0636 \u0636\n\u0637\u0637\u0637 \u0637 - \u0638\u0638\u0638 \u0638 - \u0639\u0639\u0639 \u0639 - \u063a\u063a\u063a \u063a - \u0641\u0641\u0641 \u0641 - \u0642\u0642\u0642 \u0642\n\u06a9\u06a9\u06a9 \u06a9 - \u0643\u0643\u0643\u0643 \u0643 - \u06af\u06af\u06af \u06af - \u0644\u0644\u0644 \u0644 - \u0645\u0645\u0645 \u0645 - \u0646\u0646\u0646 \u0646\n\u0648 \u0628\u0648 - \u0624 \u0628\u0624 - \u0647\u0647\u0647 \u0647 - \u06cc\u06cc\u06cc \u06cc - \u064a\u064a\u064a \u064a - \u0626\u0626\u0626 \u0626\n\n\u0634\u062f \u0639\u0631\u0635\u0647\u200c\u06cc \u0632\u0645\u06cc\u0646 \u0686\u0648 \u0628\u0633\u0627\u0637 \u0627\u0631\u0645 \u062c\u0648\u0627\u0646 *** \u0627\u0632 \u067e\u0631\u062a\u0648 \u0633\u0639\u0627\u062f\u062a \u0634\u0627\u0647 \u062c\u0647\u0627\u0646 \u0633\u062a\u0627\u0646\n\u062e\u0627\u0642\u0627\u0646 \u0634\u0631\u0642 \u0648 \u063a\u0631\u0628 \u06a9\u0647 \u062f\u0631 \u0634\u0631\u0642 \u0648 \u063a\u0631\u0628\u060c \u0627\u0648\u0633\u062a *** \u0635\u0627\u062d\u0628\u200c\u0642\u0631\u0627\u0646 \u062e\u0633\u0631\u0648 \u0648 \u0634\u0627\u0647 \u062e\u062f\u0627\u06cc\u06af\u0627\u0646\n\u062e\u0648\u0631\u0634\u06cc\u062f \u0645\u0644\u06a9\u200c\u067e\u0631\u0648\u0631 \u0648 \u0633\u0644\u0637\u0627\u0646 \u062f\u0627\u062f\u06af\u0631 *** \u062f\u0627\u0631\u0627\u06cc \u062f\u0627\u062f\u06af\u0633\u062a\u0631 \u0648 \u06a9\u0633\u0631\u0627\u06cc \u06a9\u06cc\u200c\u0646\u0634\u0627\u0646\n\u0633\u0644\u0637\u0627\u0646\u200c\u0646\u0634\u0627\u0646 \u0639\u0631\u0635\u0647\u200c\u06cc \u0627\u0642\u0644\u06cc\u0645 \u0633\u0644\u0637\u0646\u062a *** \u0628\u0627\u0644\u0627\u0646\u0634\u06cc\u0646 \u0645\u0633\u0646\u062f \u0627\u06cc\u0648\u0627\u0646 \u0644\u0627\u0645\u06a9\u0627\u0646\n\u0627\u0639\u0638\u0645 \u062c\u0644\u0627\u0644 \u062f\u0648\u0644\u062a \u0648 \u062f\u06cc\u0646 \u0622\u0646\u06a9\u0647 \u0631\u0641\u0639\u062a\u0634 *** \u062f\u0627\u0631\u062f \u0647\u0645\u06cc\u0634\u0647 \u062a\u0648\u0633\u0646 \u0627\u06cc\u0627\u0645 \u0632\u06cc\u0631 \u0631\u0627\u0646\n\u062f\u0627\u0631\u0627\u06cc \u062f\u0647\u0631 \u0634\u0627\u0647 \u0634\u062c\u0627\u0639 \u0622\u0641\u062a\u0627\u0628 \u0645\u0644\u06a9 *** \u062e\u0627\u0642\u0627\u0646 \u06a9\u0627\u0645\u06af\u0627\u0631 \u0648 \u0634\u0647\u0646\u0634\u0627\u0647 \u0646\u0648\u062c\u0648\u0627\u0646\n\u0645\u0627\u0647\u06cc \u06a9\u0647 \u0634\u062f \u0628\u0647 \u0637\u0644\u0639\u062a\u0634 \u0627\u0641\u0631\u0648\u062e\u062a\u0647 \u0632\u0645\u06cc\u0646 *** \u0634\u0627\u0647\u06cc \u06a9\u0647 \u0634\u062f \u0628\u0647 \u0647\u0645\u062a\u0634 \u0627\u0641\u0631\u0627\u062e\u062a\u0647 \u0632\u0645\u0627\u0646\n\u0633\u06cc\u0645\u0631\u063a \u0648\u0647\u0645 \u0631\u0627 \u0646\u0628\u0648\u062f \u0642\u0648\u062a \u0639\u0631\u0648\u062c *** \u0622\u0646\u062c\u0627 \u06a9\u0647 \u0628\u0627\u0632 \u0647\u0645\u062a \u0627\u0648 \u0633\u0627\u0632\u062f \u0622\u0634\u06cc\u0627\u0646\n\u06af\u0631 \u062f\u0631 \u062e\u06cc\u0627\u0644 \u0686\u0631\u062e \u0641\u062a\u062f \u0639\u06a9\u0633 \u062a\u06cc\u063a \u0627\u0648 *** \u0627\u0632 \u06cc\u06a9\u062f\u06af\u0631 \u062c\u062f\u0627 \u0634\u0648\u062f \u0627\u062c\u0632\u0627\u06cc \u062a\u0648\u0623\u0645\u0627\u0646\n\u062d\u06a9\u0645\u0634 \u0631\u0648\u0627\u0646 \u0686\u0648 \u0628\u0627\u062f \u062f\u0631 \u0627\u0637\u0631\u0627\u0641 \u0628\u0631 \u0648 \u0628\u062d\u0631 *** \u0645\u0647\u0631\u0634 \u0646\u0647\u0627\u0646 \u0686\u0648 \u0631\u0648\u062d \u062f\u0631 \u0627\u0639\u0636\u0627\u06cc \u0627\u0646\u0633 \u0648 \u062c\u0627\u0646\n\u0627\u06cc \u0635\u0648\u0631\u062a \u062a\u0648 \u0645\u0644\u06a9 \u062c\u0645\u0627\u0644 \u0648 \u062c\u0645\u0627\u0644 \u0645\u0644\u06a9 *** \u0648\u06cc \u0637\u0644\u0639\u062a \u062a\u0648 \u062c\u0627\u0646 \u062c\u0647\u0627\u0646 \u0648 \u062c\u0647\u0627\u0646 \u062c\u0627\u0646\n\u062a\u062e\u062a \u062a\u0648 \u0631\u0634\u06a9 \u0645\u0633\u0646\u062f \u062c\u0645\u0634\u06cc\u062f \u0648 \u06a9\u06cc\u0642\u0628\u0627\u062f *** \u062a\u0627\u062c \u062a\u0648 \u063a\u0628\u0646 \u0627\u0641\u0633\u0631 \u062f\u0627\u0631\u0627 \u0648 \u0627\u0631\u062f\u0648\u0627\u0646\n\u062a\u0648 \u0622\u0641\u062a\u0627\u0628 \u0645\u0644\u06a9\u06cc \u0648 \u0647\u0631 \u062c\u0627 \u06a9\u0647 \u0645\u06cc\u200c\u0631\u0648\u06cc *** \u0686\u0648\u0646 \u0633\u0627\u06cc\u0647 \u0627\u0632 \u0642\u0641\u0627\u06cc \u062a\u0648 \u062f\u0648\u0644\u062a \u0628\u0648\u062f \u062f\u0648\u0627\u0646\n\u0627\u0631\u06a9\u0627\u0646 \u0646\u067e\u0631\u0648\u0631\u062f \u0686\u0648 \u062a\u0648 \u06af\u0648\u0647\u0631 \u0628\u0647 \u0647\u06cc\u0686 \u0642\u0631\u0646 *** \u06af\u0631\u062f\u0648\u0646 \u0646\u06cc\u0627\u0648\u0631\u062f \u0686\u0648 \u062a\u0648 \u0627\u062e\u062a\u0631 \u0628\u0647 \u0635\u062f\n\u0642\u0631\u0627\u0646 \u0628\u06cc\u200c\u0637\u0644\u0639\u062a \u062a\u0648 \u062c\u0627\u0646 \u0646\u06af\u0631\u0627\u06cc\u062f \u0628\u0647 \u06a9\u0627\u0644\u0628\u062f *** \u0628\u06cc\u200c\u0646\u0639\u0645\u062a \u062a\u0648 \u0645\u063a\u0632 \u0646\u0628\u0646\u062f\u062f \u062f\u0631 \u0627\u0633\u062a\u062e\u0648\u0627\u0646\n\u0647\u0631 \u062f\u0627\u0646\u0634\u06cc \u06a9\u0647 \u062f\u0631 \u062f\u0644 \u062f\u0641\u062a\u0631 \u0646\u06cc\u0627\u0645\u062f\u0647\u200c\u0633\u062a *** \u062f\u0627\u0631\u062f \u0686\u0648 \u0622\u0628 \u062e\u0627\u0645\u0647\u200c\u06cc \u062a\u0648 \u0628\u0631 \u0633\u0631 \u0632\u0628\u0627\u0646\n\u062f\u0633\u062a \u062a\u0648 \u0631\u0627 \u0628\u0647 \u0627\u0628\u0631 \u06a9\u0647 \u06cc\u0627\u0631\u062f \u0634\u0628\u06cc\u0647 \u06a9\u0631\u062f *** \u0686\u0648\u0646 \u0628\u062f\u0631\u0647 \u0628\u062f\u0631\u0647 \u0627\u06cc\u0646 \u062f\u0647\u062f \u0648 \u0642\u0637\u0631\u0647 \u0642\u0637\u0631\u0647 \u0622\u0646\n\u0628\u0627 \u067e\u0627\u06cc\u0647\u200c\u06cc \u062c\u0644\u0627\u0644 \u062a\u0648 \u0627\u0641\u0644\u0627\u06a9 \u067e\u0627\u06cc\u0645\u0627\u0644 *** \u0648\u0632 \u062f\u0633\u062a \u0628\u062d\u0631 \u062c\u0648\u062f \u062f\u0631 \u062f\u0647\u0631 \u062f\u0627\u0633\u062a\u0627\u0646\n\u0628\u0631 \u0686\u0631\u062e \u0639\u0644\u0645 \u0645\u0627\u0647\u06cc \u0648 \u0628\u0631 \u0641\u0631\u0642 \u0645\u0644\u06a9 \u062a\u0627\u062c *** \u0634\u0631\u0639 \u0627\u0632 \u062a\u0648 \u062f\u0631 \u062d\u0645\u0627\u06cc\u062a \u0648 \u062f\u06cc\u0646 \u0627\u0632 \u062a\u0648 \u062f\u0631 \u0627\u0645\u0627\u0646\n\u0627\u06cc \u062e\u0633\u0631\u0648 \u0645\u0646\u06cc\u0639 \u062c\u0646\u0627\u0628 \u0631\u0641\u06cc\u0639 \u0642\u062f\u0631 *** \u0648\u06cc \u062f\u0627\u0648\u0631 \u0639\u0638\u06cc\u0645 \u0645\u062b\u0627\u0644 \u0631\u0641\u06cc\u0639\u200c\u0634\u0627\u0646\n\u062a\u0633\u0651\u064e\u062a \u062a\u0633\u0651\u0650\u062a \u062a\u0633\u0651\u064f\u062a \u062a\u0633\u064e\u0651\u062a \u062a\u0633\u0650\u0651\u062a \u062a\u0633\u064f\u0651\u062a\n\u062a\u0633\u0651\u064b\u062a \u062a\u0633\u0651\u064d\u062a \u062a\u0633\u0651\u064c\u062a \u062a\u0633\u064b\u0651\u062a \u062a\u0633\u064d\u0651\u062a \u062a\u0633\u064c\u0651\u062a\n\u0628\u0650\u0633\u0652\u0645\u0650 \u0627\u0644\u0644\u0647\u0650 \u0627\u0644\u0631\u064e\u0651\u062d\u0652\u0645\u0670\u0646\u0650 \u0627\u0644\u0631\u064e\u0651\u062d\u0650\u064a\u0645\u0650\n\u0627\u0644\u0644\u064e\u0651\u0647\u064f\u0645\u064e\u0651 \u06a9\u064f\u0646\u0652 \u0644\u0650\u0648\u064e\u0644\u0650\u064a\u0650\u0651\u06a9\u064e \u0627\u0644\u062d\u064f\u062c\u064e\u0647\u0650 \u0628\u0646\u0650 \u0627\u0644\u062d\u064e\u0633\u064e\u0646 \u0635\u064e\u0644\u064e\u0648\u0627\u062a\u064f\u06a9\u064e \u0639\u0644\u064e\u064a\u0647\u0650 \u0648 \u0639\u064e\u0644\u064a \u0622\u0628\u0627\u0626\u0650\u0647\u0650\n\u0641\u0650\u064a \u0647\u064e\u0630\u0650\u0647\u0650 \u0627\u0644\u0633\u064e\u0651\u0627\u0639\u064e\u0647\u0650 \u0648\u064e \u0641\u0650\u064a \u06a9\u064f\u0644\u0650\u0651 \u0633\u064e\u0627\u0639\u064e\u0647\u064d \u0648\u064e\u0644\u0650\u064a\u0651\u0627\u064b \u0648\u064e \u062d\u064e\u0627\u0641\u0650\u0638\u0627\u064b \u0648\u064e \u0642\u064e\u0627\u0626\u0650\u062f\u0627\u064b \u0648\u064e \u0646\u064e\u0627\u0635\u0650\u0631\u0627\u064b\n\u0648\u064e \u062f\u064e\u0644\u0650\u064a\u0644\u064b\u0627 \u0648\u064e \u0639\u064e\u064a\u0652\u0646\u0627\u064b\u062d\u064e\u062a\u064e\u0651\u0649 \u062a\u064f\u0633\u0652\u06a9\u0650\u0646\u064e\u0647\u064f \u0623\u064e\u0631\u0652\u0636\u064e\u06a9\u064e \u0637\u064e\u0648\u0652\u0639\u0627\u064b \u0648\u064e \u062a\u064f\u0645\u064e\u062a\u0639\u064e\u0647\u064f \u0641\u0650\u064a\u0647\u064e\u0627 \u0637\u064e\u0648\u0650\u064a\u0644\u0627\u064b\n\u0647\u064f\u0648\u064e \u0623\u0646 \u062a\u064e\u0645\u0644\u0650\u06a9\u064e \u0646\u064e\u0641\u0633\u064e\u06a9\u064e \u0648\u064e \u062a\u064e\u06a9\u0638\u064f\u0645\u064e \u063a\u064e\u06cc\u0638\u064e\u06a9\u064e \u0648 \u0644\u0627\u06cc\u064e\u06a9\u064f\u0648\u0646\u064f \u0630\u0627\u0644\u0650\u06a9\u064e \u0627\u0650\u0644\u0651\u0627 \u0645\u064e\u0639\u064e \u0627\u0644\u0642\u064f\u062f\u0631\u064e\u0629\u0650\u061b\n\u062a \u062a\u200d \u200d\u062a\u200d \u200d\u062a \u062a\u200c\u062a\u200c\u062a \u0645\u06cc\u200c\u062e\u0648\u0627\u0647\u0645 \u0646\u0631\u0645\u200c\u0627\u0641\u0632\u0627\u0631 \u0633\u0627\u062f\u0647\u200c\u0627\u06cc \u0647\u064f\u0645\u064e\u0651 \u0647\u0645\u064e\u0651\n\u06cc\u0644\u064b\u0627 \u0628\u0646\u0650 \u062d\u062a\u064e\u0651\u06cc \u062d\u064e\u062a\u064e\u0651\u06cc \u062d\u064e\u062a\u064e\u0651\u0649 \u0644\u064b\u0627 \u0644\u0650\u0648\u064e\u0644\u0650\u064a\u0650\u0651\u06a9\u064e \u0647\u0645\u0647\u0654 \u0647\u0645\u0647\u0654\u060c \u0647\u0645\u0647\u060c \u0645\u064e\n(eng) (\u0633\u0627\u0644\u0645...) (\u06a9\u0627\u0645\u0644). (.. ..) (eng). \u00ab@# %\u060c\u00bb (#$ @$) ( \u0633\u0644\u0627\u0645 ) ( eng )\n\u0628\u0631\u0646\u0627\u0645\u0647 \u06f1\u06f1\u06f1 \u06f2\u06f2\u06f2 111 222 Adobe After Effects \u0622\u0633\u0627\u0646 (Adobe Effects) \u062a\u0633\u062a eng1 eng2 \u062a\u0633\u062a\n\u062ae e\u062a \u062ae\u062a ee\u062aee \u062a1\u062a\n\u0645\u0633\u0626\u0648\u0644\u06cc\u062a  -  \u0626\u200d  \u200d\u0626\u200d  \u200d\u0626  \u0626  -  \u06cc\u200d  \u200d\u06cc\u200d  \u200d\u06cc  \u06cc  -  \u200d\u062f  \u062f  \u200d-  \u200d\u0627  \u0627\n\u0698\u0647 \u0698\u064e\u0647 \u0627\u0698\u0647 \u0627\u0698\u064e\u0651\u0647\n\u0647\u0645\u0647\u200c\u06cc \u0647\u0645\u0647\u202b\u06cc \u0647\u0645\u0647 \u06cc \u0647\u0645\u06c0 \u0647\u0645\u0647\u0654 \u0647\u0645\u0647\u0621 \u0622\u0645\u0627\u062f\u0647\u200c\u06cc\u06cc\n\u0639\u0645\u0631\u0627\" \u062d\u062a\u0645\u0627\"\n33% 33.3 3,000,000 66.33\n\u062e\u0648\u0627\u0628\u06cc\u062f\u200c\u06cc. \u0686\u0646\u062f\u06cc\u0646\u200c\u200c\u200c \u0641\u0627\u0635\u0644\u0647 \u06cc \u0645\u062c\u0627\u0632\u06cc\n\u062a\u0633\u062a \u0645\u06cc \u0634\u0647  test\n\u0645\u0646 \u0645\u06cc \u0622\u06cc\u0645\u060c \u0646\u0645\u06cc \u0622\u06cc\u0645\u060c \u0645\u06cc \u0648 \u0645\u0646\u0628\u0631\u060c \u0622\u0645\u062f\u0647 \u0627\u0645\u060c \u0622\u0645\u062f\u0647 \u0627\u06cc\u060c \u0622\u0645\u062f\u0647 \u0627\u0633\u062a\u060c \u0622\u0645\u062f\u0647 \u0627\u06cc\u0645\u060c \u0622\u0645\u062f\u0647 \u0627\u06cc\u062f\u060c \u0622\u0645\u062f\u0647 \u0627\u0646\u062f.\n\u0645\u0646 \u0645\u06cc \u067e\u0633\u0646\u062f\u06cc\u062f\u060c \u0645\u06cc \u067e\u0633\u0646\u062f\u06cc\u062f\u0645\n\u0645\u06cc\u067e\u0633\u0646\u062f\u06cc\u062f\u0645\u060c \u0645\u06cc\u067e\u0633\u0646\u062f\u06cc\u062f\n\u0645\u06cc\u067e\u0627\u0634\u0645\u060c \u0645\u06cc\u067e\u0633\u0646\u062f\u0645\u060c\n\u0632\u0645\u06cc\u0646 \u0648 \u0645\u06cc\u062f\u0627\u0646 \u0628\u0627\u0632\u06cc\n \u0645\u06cc\u062f\u0627\u0646\n\u0645\u06cc\u062f\u0627\u0646\n \u0645\u06cc\u062f\u0627\u0646.\n\u0645\u06cc\u062f\u0627\u0646.\n \u0632\u0645\u06cc\u0646\n\u0632\u0645\u06cc\u0646\n \u0632\u0645\u06cc\u0646.\n\u0632\u0645\u06cc\u0646.\n \u0645\u06cc\u0627\u0646\n\u0645\u06cc\u0627\u0646\n \u0645\u06cc\u0627\u0646.\n\u0645\u06cc\u0627\u0646.\n \u0645\u06cc\u0627\u0646\u0647\n\u0645\u06cc\u0627\u0646\u0647\n \u0645\u06cc\u0627\u0646\u0647.\n\u0645\u06cc\u0627\u0646\u0647."}
};
