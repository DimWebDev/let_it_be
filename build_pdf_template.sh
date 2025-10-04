#!/usr/bin/env bash
# build_pdf.sh — Portable PDF build script for any book project
# Customize the variables below for your specific book

set -euo pipefail

# ============================================================================
# CONFIGURATION - Edit these for your book
# ============================================================================

OUTPUT_FILE="My_Book.pdf"
METADATA="build/metadata.yaml"
MANUSCRIPT_DIR="manuscript"

# List your chapter files in order
CHAPTERS=(
  "00-front-matter.md"
  "01-chapter-one.md"
  "02-chapter-two.md"
  "99-back-matter.md"
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
  --variable documentclass=book \
  --variable papersize=letter \
  --variable classoption=openany \
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
