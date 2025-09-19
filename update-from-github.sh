#!/bin/bash

# update-from-github.sh - Updates this folder from GitHub repository

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo -e "${BLUE}🔄 Updating shared commands from GitHub...${NC}"
echo -e "Repository directory: ${SCRIPT_DIR}"

# Change to the script directory
cd "$SCRIPT_DIR"

# Check if this is a git repository
if [ ! -d ".git" ]; then
    echo -e "${RED}❌ Error: This directory is not a Git repository${NC}"
    echo "Please ensure you're running this script from a Git repository."
    exit 1
fi

# Check if we have a remote origin
if ! git remote get-url origin >/dev/null 2>&1; then
    echo -e "${RED}❌ Error: No 'origin' remote found${NC}"
    echo "Please configure a Git remote named 'origin'."
    exit 1
fi

# Show current remote
REMOTE_URL=$(git remote get-url origin)
echo -e "Remote URL: ${REMOTE_URL}"

# Check for uncommitted changes
if [ -n "$(git status --porcelain)" ]; then
    echo -e "${YELLOW}⚠️  Warning: You have uncommitted changes:${NC}"
    git status --short
    echo ""
    read -p "Do you want to continue? This will not affect your local changes. (y/N): " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${YELLOW}Update cancelled.${NC}"
        exit 0
    fi
fi

# Fetch latest changes from remote
echo -e "${BLUE}📡 Fetching latest changes...${NC}"
if git fetch origin; then
    echo -e "${GREEN}✓ Fetch completed${NC}"
else
    echo -e "${RED}❌ Failed to fetch from remote${NC}"
    exit 1
fi

# Get current branch
CURRENT_BRANCH=$(git branch --show-current)
echo -e "Current branch: ${CURRENT_BRANCH}"

# Check if remote branch exists
if git show-ref --verify --quiet "refs/remotes/origin/${CURRENT_BRANCH}"; then
    # Show what changes would be pulled
    BEHIND_COUNT=$(git rev-list --count HEAD..origin/${CURRENT_BRANCH})
    
    if [ "$BEHIND_COUNT" -eq 0 ]; then
        echo -e "${GREEN}✓ Already up to date${NC}"
    else
        echo -e "${YELLOW}📥 ${BEHIND_COUNT} commit(s) behind remote${NC}"
        echo -e "${BLUE}Changes to be pulled:${NC}"
        git log --oneline HEAD..origin/${CURRENT_BRANCH}
        echo ""
        
        # Pull the changes
        echo -e "${BLUE}⬇️  Pulling changes...${NC}"
        if git pull origin "${CURRENT_BRANCH}"; then
            echo -e "${GREEN}✓ Successfully updated from GitHub${NC}"
            
            # Show summary of what was updated
            echo -e "\n${GREEN}📋 Update Summary:${NC}"
            echo -e "• Pulled ${BEHIND_COUNT} commit(s)"
            echo -e "• Repository is now up to date"
            
            # Suggest running setup scripts if they exist
            if [ -f "setup-cursor.sh" ] || [ -f "setup-claude.sh" ]; then
                echo -e "\n${BLUE}💡 Tip: You may want to run the setup scripts to update symlinks:${NC}"
                [ -f "setup-cursor.sh" ] && echo -e "  ./setup-cursor.sh"
                [ -f "setup-claude.sh" ] && echo -e "  ./setup-claude.sh"
            fi
        else
            echo -e "${RED}❌ Failed to pull changes${NC}"
            echo -e "${YELLOW}This might be due to merge conflicts or other issues.${NC}"
            exit 1
        fi
    fi
else
    echo -e "${YELLOW}⚠️  Remote branch '${CURRENT_BRANCH}' not found${NC}"
    echo -e "Available remote branches:"
    git branch -r
    exit 1
fi

echo -e "\n${GREEN}🎉 Update completed successfully!${NC}"
