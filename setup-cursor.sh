#!/bin/bash

# setup-cursor.sh - Creates a symlink to the commands folder in ~/.cursor/commands/shared directory

set -e  # Exit on any error

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source directory containing the commands
COMMANDS_DIR="$SCRIPT_DIR/commands"

# Target directory for Cursor commands
CURSOR_COMMANDS_DIR="$HOME/.cursor/commands"
SHARED_SYMLINK="$CURSOR_COMMANDS_DIR/shared"

echo "Setting up Cursor commands symlink..."
echo "Source directory: $COMMANDS_DIR"
echo "Target symlink: $SHARED_SYMLINK"

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

# Check if the shared symlink already exists
if [ -e "$SHARED_SYMLINK" ] || [ -L "$SHARED_SYMLINK" ]; then
    if [ -L "$SHARED_SYMLINK" ] && [ "$(readlink "$SHARED_SYMLINK")" = "$COMMANDS_DIR" ]; then
        echo "✓ Symlink already exists and is correct: shared"
        symlink_status="already_exists"
    else
        echo "⚠ Target already exists and is not the expected symlink: shared"
        echo "  Existing target: $(readlink "$SHARED_SYMLINK" 2>/dev/null || echo "not a symlink")"
        echo "  Expected target: $COMMANDS_DIR"
        echo "  Please remove the existing file/directory and run this script again."
        exit 1
    fi
else
    # Create the symlink to the commands directory
    ln -s "$COMMANDS_DIR" "$SHARED_SYMLINK"
    echo "✓ Created symlink: shared -> $COMMANDS_DIR"
    symlink_status="created"
fi

echo ""
echo "Setup complete!"

if [ "$symlink_status" = "created" ]; then
    echo "✓ Created symlink: $SHARED_SYMLINK -> $COMMANDS_DIR"
    echo ""
    echo "The shared commands are now available in Cursor at:"
    echo "  ~/.cursor/commands/shared/"
    echo "You can now use these commands in Cursor!"
elif [ "$symlink_status" = "already_exists" ]; then
    echo "✓ Symlink already exists and is correctly configured."
    echo ""
    echo "The shared commands are available in Cursor at:"
    echo "  ~/.cursor/commands/shared/"
fi
