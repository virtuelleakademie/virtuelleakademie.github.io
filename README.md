# Virtuelle Akademie

Academic website for Virtuelle Akademie - Research and resources on AI in higher education teaching.

**Live site:** <https://virtuelleakademie.github.io/>

## Overview

This is a bilingual (EN/DE) Quarto-based static website hosted on GitHub Pages, using babelquarto for multilingual support. The site covers:

- **Research**: Publications, projects, and collaborations
- **Teaching**: BFH Weiterbildung courses, CAS Hochschuldidaktik
- **Workshops**: Special topics and bespoke workshops
- **Blog**: Posts and articles

## Quick Start

### Prerequisites

- [Quarto](https://quarto.org/docs/get-started/) (v1.4+)
- [R](https://www.r-project.org/)
- R package: babelquarto

```r
install.packages('babelquarto', repos = c('https://ropensci.r-universe.dev', 'https://cloud.r-project.org'))
```

### Build the Site

```bash
# Full bilingual build (EN + DE)
make render
# or
Rscript -e "babelquarto::render_website()"

# Preview (render then serve)
make preview

# Just serve docs/ without rendering
make serve
```

### Output

Generated files go to `docs/` for GitHub Pages:

- English pages: `docs/`
- German pages: `docs/de/`

## Project Structure

```text
.
├── _quarto.yml          # Main config (English + babelquarto settings)
├── _quarto-de.yml       # German language profile
├── index.qmd            # Homepage (EN)
├── index.de.qmd         # Homepage (DE)
├── teaching/            # Teaching section
├── research/            # Research section
├── workshops/           # Workshops section
├── posts/               # Blog posts
├── about/               # About section
├── styles/              # Custom SCSS styling
└── docs/                # Generated output (don't edit)
```

## Adding Content

### New Page (Bilingual)

1. Create `section/page.qmd` (English) and `section/page.de.qmd` (German)
2. Add English file to sidebar in `_quarto.yml`
3. Add German file to sidebar in `_quarto-de.yml`
4. Run `make render`

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

## License

Content is provided for educational purposes by Virtuelle Akademie, BFH.
