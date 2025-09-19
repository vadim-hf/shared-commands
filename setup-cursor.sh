#!/bin/bash

# setup-cursor.sh - Creates symlinks to all files in this project in ~/.cursor/commands directory

set -e  # Exit on any error

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source directory containing the commands
COMMANDS_DIR="$SCRIPT_DIR/commands"

# Target directory for Cursor commands
CURSOR_COMMANDS_DIR="$HOME/.cursor/commands"

echo "Setting up Cursor commands symlinks..."
echo "Source directory: $COMMANDS_DIR"
echo "Target directory: $CURSOR_COMMANDS_DIR"

# Check if the commands directory exists
if [ ! -d "$COMMANDS_DIR" ]; then
    echo "Error: Commands directory not found: $COMMANDS_DIR"
    echo "Please create a 'commands' folder in the same directory as this script."
    exit 1
fi

# Create the ~/.cursor/commands directory if it doesn't exist
if [ ! -d "$CURSOR_COMMANDS_DIR" ]; then
    echo "Creating directory: $CURSOR_COMMANDS_DIR"
    mkdir -p "$CURSOR_COMMANDS_DIR"
fi

# Counter for created symlinks
created_count=0
skipped_count=0

# Loop through all files in the commands directory
for file in "$COMMANDS_DIR"/*; do
    # Skip if it's a directory
    if [ -d "$file" ]; then
        continue
    fi
    
    # Get the filename without the path
    filename="$(basename "$file")"
    
    # Skip README files and shell scripts
    if [[ "$filename" =~ ^README.*$ ]] || [[ "$filename" =~ .*\.sh$ ]]; then
        continue
    fi
    
    # Target symlink path
    target_path="$CURSOR_COMMANDS_DIR/$filename"
    
    # Check if target already exists
    if [ -e "$target_path" ] || [ -L "$target_path" ]; then
        if [ -L "$target_path" ] && [ "$(readlink "$target_path")" = "$file" ]; then
            echo "✓ Symlink already exists and is correct: $filename"
            ((skipped_count++))
        else
            echo "⚠ Target already exists (skipping): $filename"
            ((skipped_count++))
        fi
    else
        # Create the symlink
        ln -s "$file" "$target_path"
        echo "✓ Created symlink: $filename"
        ((created_count++))
    fi
done

echo ""
echo "Setup complete!"
echo "Created: $created_count symlinks"
echo "Skipped: $skipped_count files"

if [ $created_count -gt 0 ]; then
    echo ""
    echo "Symlinks created in: $CURSOR_COMMANDS_DIR"
    echo "You can now use these commands in Cursor!"
fi
