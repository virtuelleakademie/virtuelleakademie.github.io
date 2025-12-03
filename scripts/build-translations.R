#!/usr/bin/env Rscript
# build-translations.R
# Scans project for .qmd files and generates _translations.yml
# Run this before quarto render to build the translation registry

library(yaml)
library(fs)

cat("Building translation registry...\n")

# Get project root (where this script is run from)
project_root <- getwd()

# Find all .qmd files
qmd_files <- dir_ls(
  path = project_root,
  recurse = TRUE,
  glob = "*.qmd"
)

# Exclude directories we don't want to process
exclude_patterns <- c(
  "^_extensions/",
  "^docs/",
  "/template/",
  "^_site/",
  "^\\.quarto/"
)

for (pattern in exclude_patterns) {
  qmd_files <- qmd_files[!grepl(pattern, qmd_files)]
}

# Make paths relative
qmd_files <- path_rel(qmd_files, project_root)

# Build translation pairs
translations <- list()

for (f in qmd_files) {
  # Skip if this is already a .de.qmd file
  if (grepl("\\.de\\.qmd$", f)) next

  # Get base name and check for German translation
  base <- sub("\\.qmd$", "", f)
  de_file <- paste0(base, ".de.qmd")

  # Determine output paths (convert .qmd to .html)
  en_path <- sub("\\.qmd$", ".html", f)
  # Handle index files: teaching/index.qmd -> /teaching/
  en_path <- sub("/index\\.html$", "/", en_path)
  en_path <- sub("^index\\.html$", "/", en_path)
  # Ensure leading slash
  if (!startsWith(en_path, "/")) {
    en_path <- paste0("/", en_path)
  }

  de_path <- paste0("/de", en_path)

  # Check if German translation exists
  has_de <- file_exists(de_file)

  entry <- list(
    en = en_path,
    de = if (has_de) de_path else NA_character_
  )

  translations[[en_path]] <- entry

  if (has_de) {
    cat(sprintf("  [x] %s -> %s\n", en_path, de_path))
  } else {
    cat(sprintf("  [ ] %s (no German translation)\n", en_path))
  }
}

# Write registry
output <- list(
  generated = format(Sys.time(), "%Y-%m-%d %H:%M:%S"),
  total_pages = length(translations),
  translated = sum(sapply(translations, function(x) !is.na(x$de))),
  translations = translations
)

write_yaml(output, "_translations.yml")

cat(sprintf(
  "\nGenerated _translations.yml:\n  Total pages: %d\n  Translated: %d\n  Missing: %d\n",
  output$total_pages,
  output$translated,
  output$total_pages - output$translated
))
