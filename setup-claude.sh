#!/bin/bash

# setup-claude.sh - Creates a symlink to the commands directory in ~/.claude/commands folder

set -e  # Exit on any error

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source directory containing the commands
COMMANDS_DIR="$SCRIPT_DIR/commands"

# Target directory for Claude commands
CLAUDE_COMMANDS_DIR="$HOME/.claude/commands"

# Target symlink path
SYMLINK_PATH="$CLAUDE_COMMANDS_DIR/shared-commands"

echo "Setting up Claude commands symlink..."
echo "Source directory: $COMMANDS_DIR"
echo "Target symlink: $SYMLINK_PATH"

# Check if the commands directory exists
if [ ! -d "$COMMANDS_DIR" ]; then
    echo "Error: Commands directory not found: $COMMANDS_DIR"
    echo "Please create a 'commands' folder in the same directory as this script."
    exit 1
fi

# Create the ~/.claude/commands directory if it doesn't exist
if [ ! -d "$CLAUDE_COMMANDS_DIR" ]; then
    echo "Creating directory: $CLAUDE_COMMANDS_DIR"
    mkdir -p "$CLAUDE_COMMANDS_DIR"
fi

# Check if target already exists
if [ -e "$SYMLINK_PATH" ] || [ -L "$SYMLINK_PATH" ]; then
    if [ -L "$SYMLINK_PATH" ] && [ "$(readlink "$SYMLINK_PATH")" = "$COMMANDS_DIR" ]; then
        echo "✓ Symlink already exists and is correct: shared-commands"
        echo "No action needed."
    else
        echo "⚠ Target already exists: $SYMLINK_PATH"
        echo "Please remove it manually if you want to recreate the symlink."
        exit 1
    fi
else
    # Create the symlink
    ln -s "$COMMANDS_DIR" "$SYMLINK_PATH"
    echo "✓ Created symlink: shared-commands -> $COMMANDS_DIR"
    echo ""
    echo "Setup complete!"
    echo "Your shared commands are now available at: $SYMLINK_PATH"
fi
