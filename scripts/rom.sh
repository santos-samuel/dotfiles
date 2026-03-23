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

# Check that no branch in the stack is checked out in a worktree.
# If a branch is checked out in a worktree, --update-refs will silently skip it,
# leaving the stack in a broken state after the rebase.
# Collect all branches currently checked out in any worktree.
WORKTREE_BRANCHES=$(git worktree list --porcelain | awk '/^branch / { sub("refs/heads/", "", $2); print $2 }')

# Find fork point between base and stack's top branch
BASE_REF=$(git merge-base "$BASE_BRANCH" "$CURRENT_BRANCH")
CURRENT_REF=$(git rev-parse "$CURRENT_BRANCH")

STACK_CONFLICT=0
while IFS= read -r branch; do
  # These are not intermediate stack branches — skip them.
  [ "$branch" = "$BASE_BRANCH" ] && continue
  [ "$branch" = "$CURRENT_BRANCH" ] && continue

  # Skip branches that don't exist locally.
  branch_ref=$(git rev-parse "$branch" 2>/dev/null) || continue

  # A branch is "in the stack" if it sits strictly between the fork point and
  # the current branch tip: fork-point -> branch -> current.
  if git merge-base --is-ancestor "$BASE_REF" "$branch_ref" 2>/dev/null && \
     git merge-base --is-ancestor "$branch_ref" "$CURRENT_REF" 2>/dev/null; then
    echo "ERROR: Branch '$branch' is part of the stack and is checked out in a worktree."
    echo "       --update-refs cannot update it during rebase, leaving the stack broken."
    echo "       Close or move the worktree first, then re-run rom."
    STACK_CONFLICT=1
  fi
done <<< "$WORKTREE_BRANCHES"

# Report all conflicts before aborting so the user can fix them all at once.
[ "$STACK_CONFLICT" -eq 1 ] && exit 1

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
