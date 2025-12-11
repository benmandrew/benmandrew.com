#!/bin/bash

set -e

cd "$(dirname "$0")" || exit 1

SUBDIR_PATHS=$(find ../_site -type d -print)

DEST_DIR="../_site/favicon"

TMP_DIR=$(mktemp -d)
trap 'rm -rf "$TMP_DIR"' EXIT

npx realfavicon generate favicon.png favicon-settings.json "$DEST_DIR"/output-data.json "$DEST_DIR"

for path in $SUBDIR_PATHS; do
    html_files=$(find "$path" -maxdepth 1 -type f -name "*.html")
    if [ -z "$html_files" ]; then
        continue
    fi
    echo "Processing $path"
    TMP_PATH="${path/"../"/$TMP_DIR/}"
    echo "$html_files" | xargs npx realfavicon inject "$DEST_DIR"/output-data.json "$TMP_PATH"
    mv -u "$TMP_PATH"/*.html "$path"
done
