#!/bin/bash

set -e

CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)

# Determine default base branch (main/master)
BASE_BRANCH=$(basename $(git symbolic-ref refs/remotes/origin/HEAD))

# Ensures not on base branch!
if [ "$CURRENT_BRANCH" == "$BASE_BRANCH" ]; then
  echo "You are already on the $BASE_BRANCH branch. Switch to a feature branch first."
  exit 1
fi

echo "Checking out to base branch ($BASE_BRANCH)..."
git checkout "$BASE_BRANCH"

echo "Pulling $BASE_BRANCH..."
git pull origin "$BASE_BRANCH" 

echo "Going back to initial branch ($CURRENT_BRANCH)..."
git checkout "$CURRENT_BRANCH"

echo "Rebasing onto $BASE_BRANCH..."
git rebase "$BASE_BRANCH"

git status
echo "Rebase completed successfully on the latest $BASE_BRANCH branch!"
