#!/bin/bash

# setup-ai-tool.sh - Combined setup script for AI tools (Claude and/or Cursor)

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source directory containing the commands
COMMANDS_DIR="$SCRIPT_DIR/commands"

echo -e "${BLUE}🚀 AI Tools Commands Setup${NC}"
echo -e "${CYAN}This script will set up shared commands for your AI tools.${NC}"
echo ""

# Check if the commands directory exists
if [ ! -d "$COMMANDS_DIR" ]; then
    echo -e "${RED}❌ Error: Commands directory not found: $COMMANDS_DIR${NC}"
    echo "Please create a 'commands' folder in the same directory as this script."
    exit 1
fi

echo -e "${BLUE}Available commands in ${COMMANDS_DIR}:${NC}"
for file in "$COMMANDS_DIR"/*; do
    if [ -f "$file" ]; then
        filename="$(basename "$file")"
        echo -e "  • $filename"
    fi
done
echo ""

# Function to setup Claude commands
setup_claude() {
    echo -e "${BLUE}🔧 Setting up Claude commands...${NC}"
    
    # Target directory for Claude commands
    CLAUDE_COMMANDS_DIR="$HOME/.claude/commands"
    SYMLINK_PATH="$CLAUDE_COMMANDS_DIR/shared-commands"
    
    echo "Source directory: $COMMANDS_DIR"
    echo "Target symlink: $SYMLINK_PATH"
    
    # Create the ~/.claude/commands directory if it doesn't exist
    if [ ! -d "$CLAUDE_COMMANDS_DIR" ]; then
        echo "Creating directory: $CLAUDE_COMMANDS_DIR"
        mkdir -p "$CLAUDE_COMMANDS_DIR"
    fi
    
    # Check if target already exists
    if [ -e "$SYMLINK_PATH" ] || [ -L "$SYMLINK_PATH" ]; then
        if [ -L "$SYMLINK_PATH" ] && [ "$(readlink "$SYMLINK_PATH")" = "$COMMANDS_DIR" ]; then
            echo -e "${GREEN}✓ Claude symlink already exists and is correct: shared-commands${NC}"
        else
            echo -e "${YELLOW}⚠ Target already exists: $SYMLINK_PATH${NC}"
            echo "Please remove it manually if you want to recreate the symlink."
            return 1
        fi
    else
        # Create the symlink
        ln -s "$COMMANDS_DIR" "$SYMLINK_PATH"
        echo -e "${GREEN}✓ Created Claude symlink: shared-commands -> $COMMANDS_DIR${NC}"
    fi
}

# Function to setup Cursor commands
setup_cursor() {
    echo -e "${BLUE}🔧 Setting up Cursor commands...${NC}"
    
    # Target directory for Cursor commands
    CURSOR_COMMANDS_DIR="$HOME/.cursor/commands"
    SHARED_SYMLINK="$CURSOR_COMMANDS_DIR/shared"
    
    echo "Source directory: $COMMANDS_DIR"
    echo "Target symlink: $SHARED_SYMLINK"
    
    # Create the ~/.cursor/commands directory if it doesn't exist
    if [ ! -d "$CURSOR_COMMANDS_DIR" ]; then
        echo "Creating directory: $CURSOR_COMMANDS_DIR"
        mkdir -p "$CURSOR_COMMANDS_DIR"
    fi
    
    # Check if the shared symlink already exists
    if [ -e "$SHARED_SYMLINK" ] || [ -L "$SHARED_SYMLINK" ]; then
        if [ -L "$SHARED_SYMLINK" ] && [ "$(readlink "$SHARED_SYMLINK")" = "$COMMANDS_DIR" ]; then
            echo -e "${GREEN}✓ Symlink already exists and is correct: shared${NC}"
            symlink_status="already_exists"
        else
            echo -e "${YELLOW}⚠ Target already exists and is not the expected symlink: shared${NC}"
            echo "  Existing target: $(readlink "$SHARED_SYMLINK" 2>/dev/null || echo "not a symlink")"
            echo "  Expected target: $COMMANDS_DIR"
            echo "  Please remove the existing file/directory and run this script again."
            return 1
        fi
    else
        # Create the symlink to the commands directory
        ln -s "$COMMANDS_DIR" "$SHARED_SYMLINK"
        echo -e "${GREEN}✓ Created symlink: shared -> $COMMANDS_DIR${NC}"
        symlink_status="created"
    fi
    
    echo ""
    echo -e "${GREEN}Cursor setup complete!${NC}"
    
    if [ "$symlink_status" = "created" ]; then
        echo -e "${GREEN}✓ Created symlink: $SHARED_SYMLINK -> $COMMANDS_DIR${NC}"
    elif [ "$symlink_status" = "already_exists" ]; then
        echo -e "${GREEN}✓ Symlink already exists and is correctly configured.${NC}"
    fi
}

# Ask user which AI tool they use
echo -e "${CYAN}Which AI tool(s) do you use?${NC}"
echo "1) Claude only"
echo "2) Cursor only"
echo "3) Both Claude and Cursor"
echo "4) None (exit)"
echo ""
read -p "Please enter your choice (1-4): " choice

case $choice in
    1)
        echo ""
        echo -e "${BLUE}Setting up for Claude only...${NC}"
        echo ""
        setup_claude
        echo ""
        echo -e "${GREEN}🎉 Claude setup completed successfully!${NC}"
        echo -e "Your shared commands are now available at: ${HOME}/.claude/commands/shared-commands"
        ;;
    2)
        echo ""
        echo -e "${BLUE}Setting up for Cursor only...${NC}"
        echo ""
        setup_cursor
        echo ""
        echo -e "${GREEN}🎉 Cursor setup completed successfully!${NC}"
        echo -e "Your shared commands are now available in: ${HOME}/.cursor/commands/shared/"
        ;;
    3)
        echo ""
        echo -e "${BLUE}Setting up for both Claude and Cursor...${NC}"
        echo ""
        echo -e "${CYAN}Step 1: Setting up Claude${NC}"
        setup_claude
        echo ""
        echo -e "${CYAN}Step 2: Setting up Cursor${NC}"
        setup_cursor
        echo ""
        echo -e "${GREEN}🎉 Setup completed successfully for both tools!${NC}"
        echo -e "Claude commands: ${HOME}/.claude/commands/shared-commands"
        echo -e "Cursor commands: ${HOME}/.cursor/commands/shared/"
        ;;
    4)
        echo ""
        echo -e "${YELLOW}No AI tool selected. Exiting...${NC}"
        exit 0
        ;;
    *)
        echo ""
        echo -e "${RED}❌ Invalid choice. Please run the script again and select 1-4.${NC}"
        exit 1
        ;;
esac

echo ""
echo -e "${GREEN}✨ All done! You can now use the shared commands in your selected AI tool(s).${NC}"
