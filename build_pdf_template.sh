#!/usr/bin/env bash
# build_pdf_template.sh — Portable PDF build script for How to Set Boundaries Without Guilt
# Customize the variables below for your specific book

set -euo pipefail

# ============================================================================
# CONFIGURATION - Edit these for your book
# ============================================================================

OUTPUT_FILE="How_to_Set_Boundaries_Without_Guilt.pdf"
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
  "back_matter.md"  # acknowledgments, resources, about the author
)

# ============================================================================
# OPTIONAL FEATURES - Uncomment to enable
# ============================================================================

# Unicode support (requires scripts/unicode-to-text.lua)
# LUA_FILTER="--lua-filter=scripts/unicode-to-text.lua"
LUA_FILTER=""

# Section numbering
# NUMBER_SECTIONS="--number-sections"
NUMBER_SECTIONS=""

# ============================================================================
# BUILD PROCESS - Usually no need to edit below this line
# ============================================================================

# Build chapter list with full paths
CHAPTER_FILES=()
for chapter in "${CHAPTERS[@]}"; do
  CHAPTER_FILES+=("${MANUSCRIPT_DIR}/${chapter}")
done

# Check prerequisites
echo "🔍 Checking build prerequisites..."
if [[ ! -f "${METADATA}" ]]; then
  echo "❌ Error: ${METADATA} not found."
  exit 1
fi

if ! command -v xelatex &> /dev/null; then
  echo "❌ Error: xelatex not found. Install BasicTeX or MacTeX."
  exit 1
fi

# Run Pandoc
echo "📦 Building PDF..."
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
  --variable geometry:margin=1in \
  --variable fontsize=12pt \
  --variable linestretch=1.25 \
  --variable colorlinks=true \
  --variable linkcolor=black \
  --variable toccolor=black \
  --variable urlcolor=blue \
  --variable mainfont="Helvetica Neue" \
  --variable documentclass=extbook \
  --variable papersize=letter \
  --variable classoption="14pt,openany" \
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
