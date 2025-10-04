#!/usr/bin/env bash
# build_epub.sh — One-shot EPUB build using Pandoc
# How to Set Boundaries Without Guilt by Antonius Coriolanus

set -euo pipefail

# ───────────────────────────────
# Configuration
# ───────────────────────────────
OUTPUT_FILE="How_to_Set_Boundaries_Without_Guilt.epub"
METADATA="build/metadata.yaml"
CSS="build/styles.css"
MANUSCRIPT_DIR="manuscript"
COVER_IMAGE="assets/cover/front_cover.jpg"   # optional, comment out if not present

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

# ───────────────────────────────
# Preflight Checks
# ───────────────────────────────
echo "🔍 Checking build prerequisites..."

if [[ ! -f "${METADATA}" ]]; then
  echo "❌ Error: ${METADATA} not found."
  exit 1
fi

if [[ ! -f "${CSS}" ]]; then
  echo "❌ Error: ${CSS} not found."
  exit 1
fi

MISSING=false
for file in "${CHAPTERS[@]}"; do
  if [[ ! -f "${MANUSCRIPT_DIR}/${file}" && ! -f "${file}" ]]; then
    echo "⚠️  Warning: ${file} not found."
    MISSING=true
  fi
done
if [[ "$MISSING" = true ]]; then
  echo "⚠️  Some chapters missing. Continue anyway? (Ctrl+C to abort)"
  sleep 3
fi

# ───────────────────────────────
# Build Command
# ───────────────────────────────
echo "📦 Building EPUB..."

# Build argument list
PANDOC_ARGS=(
  --from=markdown+smart
  --to=epub3
  --output="${OUTPUT_FILE}"
  --metadata-file="${METADATA}"
  --css="${CSS}"
  --toc
  --toc-depth=3
  --split-level=2
)

# Include cover if it exists
if [[ -f "${COVER_IMAGE}" ]]; then
  PANDOC_ARGS+=(--epub-cover-image="${COVER_IMAGE}")
  echo "🖼  Using cover image: ${COVER_IMAGE}"
else
  echo "ℹ️  No cover image found, skipping."
fi

# Append chapter files
for file in "${CHAPTERS[@]}"; do
  if [[ -f "${MANUSCRIPT_DIR}/${file}" ]]; then
    PANDOC_ARGS+=("${MANUSCRIPT_DIR}/${file}")
  elif [[ -f "${file}" ]]; then
    PANDOC_ARGS+=("${file}")
  fi
done

# Run Pandoc
pandoc "${PANDOC_ARGS[@]}"

echo "✅ EPUB created successfully: ${OUTPUT_FILE}"
echo "📊 File size: $(du -h "${OUTPUT_FILE}" | cut -f1)"

# ───────────────────────────────
# Validation (optional)
# ───────────────────────────────
if command -v epubcheck &> /dev/null; then
  echo "🔍 Validating EPUB..."
  epubcheck "${OUTPUT_FILE}"
else
  echo "ℹ️  epubcheck not installed; skipping validation."
fi

echo "🎉 Build complete!"
