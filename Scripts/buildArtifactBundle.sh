#!/bin/bash

set -euo pipefail

# Check if TAILWINDCSS_VERSION environment variable is set
if [[ -z "${TAILWINDCSS_VERSION:-}" ]]; then
    echo "Error: TAILWINDCSS_VERSION environment variable is not set"
    echo "Usage: TAILWINDCSS_VERSION=v3.4.0 $0"
    exit 1
fi

VERSION="$TAILWINDCSS_VERSION"
echo "Building artifact bundle for TailwindCSS version: $VERSION"

# Get the directory containing this script to find the template
TEMPLATE_FILE="$PWD/Scripts/info.template.json"

# Check if template file exists
if [[ ! -f "$TEMPLATE_FILE" ]]; then
    echo "Error: Template file not found at $TEMPLATE_FILE"
    exit 1
fi

# Create working directory
WORK_DIR="/tmp/tailwindcss.artifactbundle"
echo "Creating working directory: $WORK_DIR"
rm -rf "$WORK_DIR"
mkdir -p "$WORK_DIR"
cd "$WORK_DIR"

# GitHub release base URL
BASE_URL="https://github.com/tailwindlabs/tailwindcss/releases/download/$VERSION"

# Download and place binaries
download_binary() {
    local binary_name="$1"
    local target_path="$2"
    local target_dir
    target_dir=$(dirname "$target_path")

    echo "Downloading $binary_name..."
    mkdir -p "$target_dir"

    if curl -L "$BASE_URL/$binary_name" > "$target_path"; then
        chmod +x "$target_path"
        echo "✓ Downloaded and made executable: $target_path"
    else
        echo "✗ Failed to download $binary_name from $BASE_URL/$binary_name"
        exit 1
    fi
}

# Download each binary to its target location
download_binary "tailwindcss-linux-x64" "tailwindcss-$VERSION-linux-x64/bin/tailwindcss"
download_binary "tailwindcss-macos-x64" "tailwindcss-$VERSION-macos-x64/bin/tailwindcss"
download_binary "tailwindcss-macos-arm64" "tailwindcss-$VERSION-macos-arm64/bin/tailwindcss"

# Create info.json from template, replacing %VERSION% with actual version
echo "Creating info.json from template..."
sed "s/%VERSION%/$VERSION/g" "$TEMPLATE_FILE" > "info.json"
echo "✓ Created info.json with version $VERSION"

# Create ZIP file
ZIP_FILE="/tmp/tailwindcss.artifactbundle.zip"
echo "Creating ZIP file: $ZIP_FILE"

# Remove existing ZIP file if it exists
rm -f "$ZIP_FILE"

# Create ZIP with the artifact bundle as the only child in root
cd /tmp
zip -r "tailwindcss.artifactbundle.zip" "tailwindcss.artifactbundle"

echo "✓ Created ZIP file: $ZIP_FILE"

# Compute checksum using Swift Package Manager
echo "Computing checksum..."
CHECKSUM=$(swift package compute-checksum "$ZIP_FILE")

echo ""
echo "=== BUILD COMPLETE ==="
echo "ZIP file path: $ZIP_FILE"
echo "Checksum: $CHECKSUM"
