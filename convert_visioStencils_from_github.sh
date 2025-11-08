#!/bin/bash

# convert_from_github.sh
# Clone a Visio stencils repository, convert all stencils, then clean up

set -e

REPO_URL="https://github.com/bhdicaire/visioStencils.git"
TEMP_DIR="./temp_visio_repo"
STENCILS_PATH="$TEMP_DIR/Stencils"

echo "Starting conversion from GitHub repository..."
echo "Repository: $REPO_URL"
echo ""

# Clone the repository
echo "Cloning repository..."
if [ -d "$TEMP_DIR" ]; then
    echo "Removing existing temp directory..."
    rm -rf "$TEMP_DIR"
fi

git clone "$REPO_URL" "$TEMP_DIR"

# Check if stencils directory exists
if [ ! -d "$STENCILS_PATH" ]; then
    echo "ERROR: Stencils directory not found at $STENCILS_PATH"
    rm -rf "$TEMP_DIR"
    exit 1
fi

# Count files
FILE_COUNT=$(find "$STENCILS_PATH" -type f \( -iname '*.vss' -o -iname '*.vssx' \) | wc -l | tr -d ' ')
echo "Found $FILE_COUNT Visio stencil files to convert"
echo ""

# Run the conversion script
echo "Starting conversion..."
osascript batch_convert_visio_to_graffle.applescript \
    --skip \
    --batch \
    --visio-stencil-folder "$STENCILS_PATH"

CONVERSION_STATUS=$?

# Clean up
echo ""
echo "Cleaning up..."
rm -rf "$TEMP_DIR"

echo "Done!"

exit $CONVERSION_STATUS
