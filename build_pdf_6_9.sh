#!/usr/bin/env bash
# build_pdf_6x9.sh — PDF build script for 6×9 in trim (KDP-ready)

set -euo pipefail

# ============================================================================
# CONFIGURATION
# ============================================================================

OUTPUT_FILE="How_to_Set_Boundaries_Without_Guilt_6x9.pdf"
METADATA="build/metadata.yaml"
MANUSCRIPT_DIR="manuscript"

# Chapter files in reading order
CHAPTERS=(
  "chapter_01.md"
  "chapter_02.md"
  "chapter_03.md"
  "chapter_04.md"
  "chapter_05.md"
  "chapter_06.md"
  "chapter_07.md"
  "back_matter.md"
)

# Optional Lua filter / numbering
LUA_FILTER=""
NUMBER_SECTIONS=""

# ============================================================================
# BUILD
# ============================================================================

# Build chapter list with full paths
CHAPTER_FILES=()
for chapter in "${CHAPTERS[@]}"; do
  CHAPTER_FILES+=("${MANUSCRIPT_DIR}/${chapter}")
done

echo "🔍 Checking build prerequisites..."
[[ -f "${METADATA}" ]] || { echo "❌ Error: ${METADATA} not found."; exit 1; }
command -v xelatex >/dev/null || { echo "❌ Error: xelatex not found. Install BasicTeX or MacTeX."; exit 1; }

echo "📦 Building 6×9 PDF..."
pandoc \
  --from=markdown+smart \
  --to=pdf \
  --output="${OUTPUT_FILE}" \
  --metadata-file="${METADATA}" \
  --pdf-engine=xelatex \
  ${LUA_FILTER} \
  ${NUMBER_SECTIONS} \
  --toc \
  --toc-depth=3 \
  --top-level-division=chapter \
  --variable geometry:margin=0.75in \
  --variable geometry:paperwidth=6in \
  --variable geometry:paperheight=9in \
  --variable fontsize=12pt \
  --variable linestretch=1.25 \
  --variable colorlinks=true \
  --variable linkcolor=black \
  --variable toccolor=black \
  --variable urlcolor=blue \
  --variable mainfont="Helvetica Neue" \
  --variable documentclass=extbook \
  --variable classoption="12pt,openany" \
  --variable block-headings \
  "${CHAPTER_FILES[@]}"

if [[ $? -eq 0 ]]; then
  echo "✅ PDF created successfully: ${OUTPUT_FILE}"
  echo "📊 File size: $(du -h "${OUTPUT_FILE}" | cut -f1)"
else
  echo "❌ Build failed."
  exit 1
fi

echo "🎉 Build complete!"
