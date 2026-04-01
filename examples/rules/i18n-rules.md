---
domain: internationalization-localization
applies_to: all user-facing UI, date/time display, number formatting, form inputs, email templates, error messages
---

# Internationalization & Localization Rules

## Inviolable Rules

1. **NO hardcoded user-visible strings** — all strings extracted to locale files. Zero exceptions, including error messages, toast notifications, validation messages, and placeholder text.
2. **Date and time values stored as UTC** — timezone conversion happens at the display layer only, never at the storage layer.
3. **Currency amounts stored as integer minor units (cents)** — locale-aware formatting applied at display only (see `e-commerce-rules.md`).
4. **Plural forms MUST use the locale's plural rules** — not `count === 1 ? 'item' : 'items'` (fails Arabic, Russian, Polish, and others).
5. **RTL layout support MUST be tested for any locale with RTL languages** (Arabic, Hebrew, Persian, Urdu) — use CSS logical properties (`margin-inline-start`, not `margin-left`).
6. **Locale detection priority: user preference → `Accept-Language` header → default** — never infer locale from IP alone.

## String Extraction

### Key Naming Convention
```
Format: {domain}.{component}.{semantic_name}
Example: checkout.summary.order_total
         auth.errors.invalid_credentials
         common.actions.save
```

### Key Stability
- Keys are stable identifiers — if the English string changes, the key does not change.
- Key removal requires deprecation: mark as `@deprecated` in locale file, remove after all consumers updated.
- Keys represent meaning, not content: `errors.required_field` not `errors.this_field_is_required`.

### Interpolation
- Use **named placeholders**, not positional: `"Hello, {firstName}"` not `"Hello, %s"`.
- No string concatenation to form sentences: `"Hello {firstName}, you have {count} messages"` not `"Hello " + name + ", you have " + n + " messages"`.
- Translators see the full sentence with named context — never fragments.

### Missing Translation Fallback
1. Project default locale (e.g., `en`).
2. If still missing: render the key itself (`auth.errors.invalid_credentials`).
3. Never render empty string for a missing translation.
4. Log missing keys in non-production environments.

## Date and Time Formatting

```javascript
// ✅ Correct — locale-aware
new Intl.DateTimeFormat(locale, { dateStyle: 'medium' }).format(date)

// ❌ Wrong — locale-dependent separator hardcoded
date.toLocaleDateString('en', { ... }) // hardcoded 'en'

// ❌ Wrong — manual format string
`${date.getDate()}/${date.getMonth() + 1}/${date.getFullYear()}`
```

- Relative time ("2 hours ago"): use `Intl.RelativeTimeFormat` — not hardcoded English strings.
- Always show timezone abbreviation or offset when displaying times across timezones.
- Calendar systems: if locale requires non-Gregorian calendar (Persian, Islamic, Japanese), use ICU-compliant library (e.g., `@formatjs/intl`, Temporal API).

## Number and Currency Formatting

```javascript
// ✅ Correct — locale-aware
new Intl.NumberFormat(locale, { style: 'currency', currency: 'BRL' }).format(amount / 100)

// ❌ Wrong — hardcoded separator
amount.toFixed(2).replace('.', ',')
```

- Decimal separator is locale-dependent (`.` in en-US, `,` in pt-BR and de) — never hardcode.
- Large number grouping separator: `,` (en), `.` (pt-BR, de), ` ` (fr) — use `Intl.NumberFormat`.
- Percentage: `50%` vs `50 %` (with space in fr) — locale-dependent, use `Intl.NumberFormat` with `style: 'percent'`.

## RTL (Right-to-Left) Support

### CSS Logical Properties
```css
/* ✅ Correct — adapts to text direction */
padding-inline-start: 16px;
margin-inline-end: 8px;
border-inline-start: 2px solid;
text-align: start;

/* ❌ Wrong — direction-hardcoded */
padding-left: 16px;
margin-right: 8px;
border-left: 2px solid;
text-align: left;
```

- Apply `dir="rtl"` on `<html>` when locale is RTL — not per-element.
- Icons with directional meaning (arrows, back/forward, progress) MUST flip in RTL:
  ```css
  [dir="rtl"] .arrow-icon { transform: scaleX(-1); }
  ```
- Flexbox order is direction-aware with logical properties — avoid `order` overrides to achieve RTL.

## Locale File Structure

```
locales/
  en/
    common.json      ← shared across features
    auth.json
    checkout.json
  pt-BR/
    common.json
    auth.json
    checkout.json
```

- One locale file per feature domain — not a single monolithic file.
- Locale files are flat JSON (no deep nesting beyond 2 levels) — deep nesting makes keys hard to identify and type.
- Locale files versioned with the code — translations updated in the same PR as the new strings.

## Testing

```
VERIFY: Switch UI to RTL locale (ar or he).
  → All layout elements follow logical flow direction.
  → Directional icons (arrows, chevrons, progress bars) are mirrored.
  → No text or element bleeds out of container.
  SUCCESS: layout correct. FAILURE: elements overlap or appear in wrong order.

VERIFY: Render the number 1234567.89 in locales: en-US, pt-BR, de-DE.
  → en-US: 1,234,567.89 | pt-BR: 1.234.567,89 | de-DE: 1.234.567,89
  FAILURE: raw number appears without locale formatting.

VERIFY: Test pluralization with count = 0, 1, 2, 11, 21 in en and ru.
  → English: 0 items, 1 item, 2 items, 11 items, 21 items.
  → Russian: requires 4 plural forms — verify i18n library handles them correctly.
  FAILURE: "1 items" or wrong Russian plural form.

QUERY: Grep for hardcoded date format strings in component files.
  → Pattern: /"\d{1,2}\/\d{1,2}\/\d{4}"/ or /\.toLocaleDateString\(\)/ without locale arg.
  → Expected: 0 matches.
  FAILURE: manual format string found (locale-breaking date format).

QUERY: Grep for string concatenation in UI components.
  → Pattern: /["'`][A-Z][a-z].*["'`]\s*\+/ (sentence fragments being concatenated)
  → Expected: 0 matches in user-visible strings.
  FAILURE: fragmented strings (breaks grammar in RTL and inflected languages).
```

## Character Encoding Rules

### UTF-8 Everywhere
- **Source files**: UTF-8 without BOM
- **HTTP responses**: `Content-Type` header includes `charset=utf-8`
- **Database**: use `utf8mb4` (MySQL) or ensure UTF-8 collation (PostgreSQL uses UTF-8 by default). Never `utf8` on MySQL — it only supports 3-byte chars (no emoji, some CJK missing).
- **File I/O**: always specify encoding explicitly — `fs.readFile(path, 'utf-8')`, `open(path, encoding='utf-8')`

### Unicode Normalization
- **String comparison**: normalize to NFC before comparing user input (accented characters have multiple valid byte representations: `é` can be U+00E9 or U+0065 + U+0301)
- **Search**: normalize both query and target to the same form before matching
- **Database indexes on text columns with accents**: use ICU collation or normalize at write time
- **URL slugs**: normalize and transliterate (remove diacritics) — `"São Paulo"` → `"sao-paulo"`

### Combining Characters and Emoji
- **String length for user-visible limits**: use grapheme cluster count, not code point count — `"é"` can be 1 or 2 code points but is always 1 visible character
- **Truncation**: never truncate mid-grapheme-cluster — use `Intl.Segmenter` or equivalent library
- **Emoji in user input**: support in text fields — requires `utf8mb4` on MySQL, standard UTF-8 elsewhere
- **Zero-width characters**: strip ZWJ, ZWNJ, and other invisible characters from security-sensitive inputs (usernames, slugs, search queries) to prevent visual spoofing
