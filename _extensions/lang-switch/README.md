# lang-switch: Quarto Language Switching Extension

A custom Quarto extension for adding bilingual (English/German) support to Quarto websites with same-page language switching.

## Overview

This extension provides:

- A language switcher dropdown in the navbar
- Convention-based file naming (`page.qmd` + `page.de.qmd`)
- Same-page language switching (click DE on any page to go to its German translation)
- "Translation unavailable" toast notification when a translation doesn't exist
- Full integration with Quarto's build system

## How It Works

```text
┌─────────────────────────────────────────────────────────────┐
│                    Build Process                             │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  1. quarto render                                           │
│     ├── Renders index.qmd → docs/index.html                 │
│     ├── Renders index.de.qmd → docs/index.de.html           │
│     └── lang-switch.lua injects config into each page       │
│                                                             │
│  2. render-german.R                                         │
│     └── Moves docs/*.de.html → docs/de/*.html               │
│                                                             │
├─────────────────────────────────────────────────────────────┤
│                    Result                                    │
├─────────────────────────────────────────────────────────────┤
│  docs/                                                      │
│  ├── index.html          (English, links to /de/)           │
│  └── de/                                                    │
│      └── index.html      (German, links to /)               │
└─────────────────────────────────────────────────────────────┘
```

### Components

| Component | Purpose |
|-----------|---------|
| `lang-switch.lua` | Lua filter that injects language configuration into each page |
| `lang-switch.js` | JavaScript that creates the navbar dropdown and handles navigation |
| `lang-switch.css` | Styling for the dropdown and toast notifications |
| `build-translations.R` | Scans project and generates `_translations.yml` registry |
| `render-german.R` | Moves German HTML files to `/de/` subdirectory |

## Installation

The extension is already installed in this project at `_extensions/lang-switch/`.

### Dependencies

- Quarto >= 1.3.0
- R with the `fs` and `yaml` packages

```r
install.packages(c("fs", "yaml"))
```

## Configuration

### Project Configuration (`_quarto.yml`)

The extension requires these settings in `_quarto.yml`:

```yaml
# Set default language
lang: en

# Include German files in render
project:
  render:
    - "*.qmd"
    - "**/*.de.qmd"

# Enable the filter
filters:
  - lang-switch
```

### Language Configuration (`_lang-config.yml`)

Optional configuration file for UI translations:

```yaml
languages:
  - code: en
    name: English
    dir: /
    default: true
  - code: de
    name: Deutsch
    dir: /de/

navbar:
  en:
    research: Research
    teaching: Teaching
  de:
    research: Forschung
    teaching: Lehre

footer:
  en: "© 2025 Your Site | English tagline"
  de: "© 2025 Your Site | German tagline"
```

## Usage

### Adding a New Translated Page

1. **Create the German file** alongside the English file:

   ```text
   teaching/
   ├── index.qmd        (English - existing)
   └── index.de.qmd     (German - new)
   ```

2. **Add frontmatter to the German file**:

   ```yaml
   ---
   title: "Lehre"
   lang: de
   translation: /teaching/index.html
   ---

   German content here...
   ```

3. **Update the English file** with translation link:

   ```yaml
   ---
   title: "Teaching"
   lang: en
   translation: /de/teaching/index.html
   ---
   ```

4. **Build the site**:

   ```bash
   make render
   ```

### Frontmatter Reference

| Field | Required | Description |
|-------|----------|-------------|
| `lang` | Yes | Language code (`en` or `de`) |
| `translation` | No | Path to the translated version |
| `title` | Yes | Page title (in the appropriate language) |

### File Naming Convention

| English File | German File | English URL | German URL |
|--------------|-------------|-------------|------------|
| `index.qmd` | `index.de.qmd` | `/` | `/de/` |
| `about/index.qmd` | `about/index.de.qmd` | `/about/` | `/de/about/` |
| `posts/my-post.qmd` | `posts/my-post.de.qmd` | `/posts/my-post.html` | `/de/posts/my-post.html` |

## Build Commands

The Makefile provides these commands:

```bash
# Full bilingual build (recommended)
make render

# Preview with live reload
make preview

# Build translation registry only
make translations

# Render English only
make render-en

# Move German files only (after quarto render)
make render-de
```

### What Each Command Does

**`make render`**

1. Runs `build-translations.R` to scan for translation pairs
2. Runs `quarto render` to build all content
3. Runs `render-german.R` to move `.de.html` files to `/de/`

**`make preview`**

1. Runs `build-translations.R`
2. Starts `quarto preview` with live reload

## Translation Registry

The `build-translations.R` script generates `_translations.yml`:

```yaml
generated: "2025-12-03 14:55:00"
total_pages: 25
translated: 5
translations:
  /index.html:
    en: /index.html
    de: /de/index.html
  /about/index.html:
    en: /about/index.html
    de: ~  # No translation yet
```

This registry helps track translation progress and can be used for future enhancements.

## Language Switcher Behavior

### When Translation Exists

Clicking the language switcher navigates to the equivalent page:

- On `/teaching/` → Click "Deutsch" → Goes to `/de/teaching/`
- On `/de/about/` → Click "English" → Goes to `/about/`

### When Translation Doesn't Exist

If `translation:` is not set in frontmatter, clicking the other language shows a toast notification:

```text
┌──────────────────────────────┐
│  Translation unavailable     │
└──────────────────────────────┘
```

The toast appears for 3 seconds and fades out.

## Customization

### Styling the Switcher

Edit `_extensions/lang-switch/lang-switch.css`:

```css
/* Change dropdown appearance */
.lang-switch-dropdown .nav-link {
  background-color: #f0f0f0;
  border-radius: 8px;
}

/* Change active language highlight */
.lang-switch-dropdown .dropdown-item.active {
  background-color: #4b2e83;  /* Your brand color */
}

/* Change toast appearance */
.lang-switch-toast {
  background-color: #333;
  border-radius: 8px;
}
```

### Adding More Languages

1. Update the Lua filter (`lang-switch.lua`):

   ```lua
   local config_json = string.format([[
   {
     "languages": [
       {"code": "en", "name": "English", "dir": "/"},
       {"code": "de", "name": "Deutsch", "dir": "/de/"},
       {"code": "fr", "name": "Français", "dir": "/fr/"}
     ]
   }
   ]])
   ```

2. Create `.fr.qmd` files for French content

3. Update `render-german.R` to handle French files (or create `render-french.R`)

## Troubleshooting

### Language switcher doesn't appear

**Check:** Is the filter enabled in `_quarto.yml`?

```yaml
filters:
  - lang-switch
```

**Check:** Is the page being rendered as HTML?

```bash
quarto render mypage.qmd --to html
```

### German pages don't have the switcher

**Check:** Are `.de.qmd` files included in the render list?

```yaml
project:
  render:
    - "**/*.de.qmd"
```

### Translations not linking correctly

**Check:** Is the `translation:` frontmatter path correct?

- Use absolute paths starting with `/`
- English pages link to `/de/...`
- German pages link to `/...` (without `/de/`)

### "Translation unavailable" always shows

**Check:** Did you add `translation:` to the frontmatter?

```yaml
---
lang: en
translation: /de/path/to/page.html  # Must be set!
---
```

### Build errors with R scripts

**Check:** Are R packages installed?

```r
install.packages(c("fs", "yaml"))
```

**Check:** Are you running from the project root?

```bash
cd /path/to/project
make render
```

## Architecture Notes

### Why Not Pure Quarto?

Quarto doesn't natively support multilingual websites (as of 2025). This extension works around that limitation by:

1. Using Lua filters to inject per-page configuration
2. Using JavaScript to modify the navbar at runtime
3. Using R scripts to reorganize output files

### Why R Scripts?

Lua filters in Quarto process one document at a time and can't see other files. R scripts provide:

- Cross-file awareness (scanning for translation pairs)
- File system operations (moving files to `/de/`)
- Build orchestration

### Future Improvements

When Quarto adds native i18n support, this extension may become obsolete. Until then, potential enhancements include:

- [ ] SEO: Add `<link rel="alternate" hreflang="de">` tags
- [ ] Persistence: Remember user's language preference
- [ ] Auto-detect: Suggest language based on browser settings
- [ ] Navbar translation: Dynamically translate nav items

## License

MIT License - Feel free to use, modify, and distribute.

## Credits

Developed for [Virtuelle Akademie](https://virtuelleakademie.ch) at Bern University of Applied Sciences.

Inspired by:

- [babelquarto](https://docs.ropensci.org/babelquarto/)
- [Multi-language Quarto - Mario Angst](https://marioangst.com/en/blog/posts/multi-language-quarto/)
