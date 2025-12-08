# Virtuelle Akademie

Academic website for Virtuelle Akademie - Research and resources on AI in higher education teaching.

**Live site:** <https://virtuelleakademie.github.io/>

## Overview

This is a bilingual (EN/DE) Quarto-based static website hosted on GitHub Pages. The site covers:

- **Research**: Publications, projects, and collaborations
- **Teaching**: BFH Weiterbildung courses, CAS Hochschuldidaktik
- **Workshops**: Special topics and bespoke workshops
- **Blog**: Posts and articles

## Quick Start

### Prerequisites

- [Quarto](https://quarto.org/docs/get-started/) (v1.4+)
- [R](https://www.r-project.org/) (for post-render scripts)
- R package: `fs` (`install.packages("fs")`)

### Build the Site

```bash
# Full build (renders EN + DE, runs post-render script)
quarto render

# Preview with live reload
quarto preview

# Clean build (removes cached files)
quarto render --clean
```

### Output

Generated files go to `docs/` for GitHub Pages:

- English pages: `docs/`
- German pages: `docs/de/`

## Project Structure

```text
.
├── _quarto.yml          # Main site configuration
├── index.qmd            # Homepage (EN)
├── index.de.qmd         # Homepage (DE)
├── teaching/            # Teaching section
├── research/            # Research section
├── workshops/           # Workshops section
├── posts/               # Blog posts
├── about/               # About section
├── styles/              # Custom SCSS styling
├── scripts/             # Build scripts (render-german.R)
└── docs/                # Generated output (don't edit)
```

## Adding Content

### New Page (Bilingual)

1. Create `section/page.qmd` (English) and `section/page.de.qmd` (German)
2. Add YAML frontmatter with `translation:` field pointing to the other version
3. Add English file to its sidebar and German file to the `-de` sidebar in `_quarto.yml`
4. Run `quarto render`

### New Workshop

Workshops are typically hosted in separate repositories:

- Create a new repo (e.g., `ki-lehre-refresher`)
- Add a link card to the relevant page in this site

## Git Workflow

```bash
make branch name=feature-name    # Create new branch
make commit msg="Description"    # Add and commit changes
make push                        # Push current branch
make merge                       # Merge to main (admin)
```

## Related Repositories

- [ki-lehre-beginner](https://github.com/virtuelleakademie/ki-lehre-beginner)
- [ki-lehre-intermediate](https://github.com/virtuelleakademie/ki-lehre-intermediate)
- [ki-lehre-advanced](https://github.com/virtuelleakademie/ki-lehre-advanced)
- [ki-lehre-refresher](https://github.com/virtuelleakademie/ki-lehre-refresher)

