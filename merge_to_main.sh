#!/bin/bash
# A script to safely merge the 'dev' branch into 'main' and return to 'dev'.

# Set colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

# Define the required working directory
REQUIRED_DIR="/home/hyfer/automationLab"

echo -e "${GREEN}Starting merge process from dev to main...${NC}"

# 1. NEW: Check if the current directory is correct
echo "Verifying working directory..."
if [ "$PWD" != "$REQUIRED_DIR" ]; then
  echo -e "${RED}Error: This script must be run from the '$REQUIRED_DIR' directory.${NC}"
  echo -e "Your current directory is: $PWD"
  exit 1
fi
echo "Working directory is correct."

# 2. Check if the current branch is 'dev'
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
if [ "$CURRENT_BRANCH" != "dev" ]; then
  echo -e "${RED}Error: You must be on the 'dev' branch to run this script.${NC}"
  exit 1
fi

echo "Current branch is 'dev'. Continuing..."

# 3. Switch to the 'main' branch
echo "Switching to 'main' branch..."
git checkout main
if [ $? -ne 0 ]; then
  echo -e "${RED}Error: Failed to checkout 'main' branch.${NC}"
  git checkout dev # Switch back to dev on failure
  exit 1
fi

# 4. Pull the latest changes for 'main' to avoid conflicts
echo "Pulling latest changes for 'main'..."
git pull origin main
if [ $? -ne 0 ]; then
  echo -e "${RED}Error: Failed to pull from origin/main.${NC}"
  git checkout dev # Switch back to dev on failure
  exit 1
fi

# 5. Merge 'dev' into 'main'
echo "Merging 'dev' into 'main'..."
git merge dev
if [ $? -ne 0 ]; then
  echo -e "${RED}Error: Merge failed. Please resolve conflicts manually.${NC}"
  # Note: Git will leave you in a conflicted state to resolve.
  exit 1
fi

# 6. Push the updated 'main' branch
echo "Pushing 'main' to remote..."
git push origin main
if [ $? -ne 0 ]; then
  echo -e "${RED}Error: Failed to push to origin/main.${NC}"
  git checkout dev # Switch back to dev on failure
  exit 1
fi

# 7. Switch back to the 'dev' branch
echo "Switching back to 'dev' branch..."
git checkout dev
if [ $? -ne 0 ]; then
  echo -e "${RED}Error: Failed to checkout 'dev' branch.${NC}"
  exit 1
fi

# 8. Final validation
FINAL_BRANCH=$(git rev-parse --abbrev-ref HEAD)
echo -e "${GREEN}--------------------------------------------------${NC}"
echo -e "${GREEN}Successfully merged dev into main and pushed.${NC}"
echo -e "Current branch is now: ${GREEN}${FINAL_BRANCH}${NC}"
echo -e "${GREEN}--------------------------------------------------${NC}"


