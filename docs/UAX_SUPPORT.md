# Unicode 17 support matrix

| Rules | Implementation | Validation |
| --- | --- | --- |
| LB1 | class resolution with General_Category | LineBreakTest |
| LB2–LB8a | endpoints, hard breaks, SP/ZW/ZWJ | LineBreakTest + edge tests |
| LB9–LB10 | combining token collapse, full U+0041 fallback | LineBreakTest |
| LB11–LB18 | WJ/GL, punctuation, SP contexts | LineBreakTest |
| LB19–LB22 | quotation/EAW, CB, hyphens, Hebrew, IN | LineBreakTest |
| LB23–LB25 | alphanumerics and numeric contexts | LineBreakTest |
| LB26–LB30 | Hangul, alphabetics, Brahmic, parentheses | LineBreakTest |
| LB30a–LB31 | RI parity, emoji modifier, fallback | LineBreakTest |
| WB1–WB4 | endpoints/newline/ZWJ/WSegSpace/ignored characters | WordBreakTest |
| WB5–WB13b | letters, Hebrew quotes, numbers, Katakana, extenders | WordBreakTest |
| WB15–WB16, WB999 | RI parity and default break | WordBreakTest |
| SB1–SB5 | endpoints, paragraph separators and ignored characters | SentenceBreakTest |
| SB6–SB11, SB998 | numeric/abbreviation/suffix contexts and fallback | SentenceBreakTest |
| Extended graphemes | kawaz/grapheme 0.10.4 | upstream implementation + wrapping tests |

All 21,794 official cases are run without skipped cases or test-specific
exceptions. Default UAX rules are used; no language tailoring is claimed.
