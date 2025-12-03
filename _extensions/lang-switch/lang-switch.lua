-- lang-switch.lua
-- Quarto extension for bilingual (EN/DE) language switching
-- Injects language switcher configuration and dependencies into HTML pages

-- Only run for HTML output
if not quarto.doc.is_format("html") then
  return {}
end

-- Add CSS/JS dependencies
quarto.doc.add_html_dependency({
  name = "lang-switch",
  version = "1.0.0",
  scripts = {{ path = "lang-switch.js", attribs = {defer = "true"} }},
  stylesheets = {"lang-switch.css"}
})

function Pandoc(doc)
  local meta = doc.meta
  local str = pandoc.utils.stringify

  -- Get current document language (default: en)
  local current_lang = "en"
  if meta["lang"] then
    current_lang = str(meta["lang"])
    -- Handle full locale codes like "en-US" or "de-DE"
    current_lang = current_lang:match("^(%a+)") or current_lang
  end

  -- Get translation URL if specified in frontmatter
  local translation_url = ""
  if meta["translation"] then
    translation_url = str(meta["translation"])
  end

  -- Check if translation exists (based on frontmatter)
  local has_translation = translation_url ~= ""

  -- Build configuration JSON for JavaScript
  local config_json = string.format([[
<script id="lang-switch-config" type="application/json">
{
  "currentLang": "%s",
  "translationUrl": "%s",
  "hasTranslation": %s,
  "languages": [
    {"code": "en", "name": "English", "dir": "/"},
    {"code": "de", "name": "Deutsch", "dir": "/de/"}
  ],
  "defaultLang": "en"
}
</script>
]], current_lang, translation_url, has_translation and "true" or "false")

  quarto.doc.include_text("before-body", config_json)

  return doc
end
