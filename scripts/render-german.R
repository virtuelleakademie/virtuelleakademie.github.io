#!/usr/bin/env Rscript
# render-german.R
# Moves German .de.html files from docs/ to docs/de/ and fixes relative paths
# Run this AFTER quarto render to organize German content

library(fs)

cat("Organizing German content...\n")

# Get project root
project_root <- getwd()
docs_dir <- file.path(project_root, "docs")
de_dir <- file.path(docs_dir, "de")

# Create German output directory
dir_create(de_dir)

# Find all .de.html files in docs/
de_files <- dir_ls(
  path = docs_dir,
  recurse = TRUE,
  glob = "*.de.html"
)

# Exclude files already in de/ directory
de_files <- de_files[!grepl("/de/", de_files)]

if (length(de_files) == 0) {
  cat("No German content files found (*.de.html in docs/)\n")
  cat("Run 'quarto render' first to generate the site.\n")
  quit(status = 0)
}

cat(sprintf("Found %d German content files to organize\n\n", length(de_files)))

# Function to fix relative paths in HTML content
# When moving from docs/X/file.html to docs/de/X/file.html,
# all relative paths need one more ../ prefix because we're one level deeper
fix_relative_paths <- function(html_content) {
  # Simple approach: add ../ prefix to all relative paths starting with ../
  # This handles href="...", src="...", and other attributes

  # Match href or src attributes with relative paths starting with ../
  # Replace "../ with "../../ (add one more level)
  html_content <- gsub(
    '(href|src)="(\\.\\./)',
    '\\1="../\\2',
    html_content
  )

  # Also fix paths in JSON (like search.json references)
  html_content <- gsub(
    '"(\\.\\./)+search\\.json"',
    '"../\\1search.json"',
    html_content
  )

  # Fix offset in quarto config
  html_content <- gsub(
    '"quarto:offset" content="(\\.\\./)*"',
    '"quarto:offset" content="../\\1"',
    html_content
  )

  return(html_content)
}

# Track results
success_count <- 0
fail_count <- 0

# Process each German file
for (f in de_files) {
  # Get relative path from docs/
  rel_from_docs <- path_rel(f, docs_dir)

  # Calculate destination path
  # index.de.html -> de/index.html
  # teaching/index.de.html -> de/teaching/index.html
  dest_rel <- sub("\\.de\\.html$", ".html", rel_from_docs)
  dest_path <- file.path(de_dir, dest_rel)
  dest_dir <- dirname(dest_path)

  cat(sprintf("Processing: %s\n", rel_from_docs))
  cat(sprintf("       -> de/%s\n", dest_rel))

  # Create destination directory
  dir_create(dest_dir)

  # Read, fix paths, and write to new location

  result <- tryCatch({
    # Read the HTML content
    html_content <- readLines(f, warn = FALSE)
    html_content <- paste(html_content, collapse = "\n")

    # Fix relative paths
    html_content <- fix_relative_paths(html_content)

    # Write to destination
    writeLines(html_content, dest_path)

    # Delete original
    file_delete(f)

    TRUE
  }, error = function(e) {
    cat(sprintf("  ERROR: %s\n", e$message))
    FALSE
  })

  if (result) {
    success_count <- success_count + 1

    # Also move associated _files directory if it exists
    files_dir <- sub("\\.html$", "_files", f)
    if (dir_exists(files_dir)) {
      dest_files_dir <- sub("\\.html$", "_files", dest_path)
      tryCatch({
        # Remove destination if exists
        if (dir_exists(dest_files_dir)) {
          dir_delete(dest_files_dir)
        }
        file_move(files_dir, dest_files_dir)
        cat("     (moved _files directory)\n")
      }, error = function(e) {
        cat(sprintf("  WARNING: Could not move _files: %s\n", e$message))
      })
    }
    cat("\n")
  } else {
    fail_count <- fail_count + 1
  }
}

cat(sprintf(
  "\nOrganization complete:\n  Processed: %d\n  Failed: %d\n",
  success_count,
  fail_count
))

if (fail_count > 0) {
  quit(status = 1)
}
