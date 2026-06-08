#!/usr/bin/env bash
set -e

REPO="${1:-$(gh repo view --json nameWithOwner -q .nameWithOwner)}"

create_label() {
  local name="$1"
  local description="$2"
  local color="$3"
  echo "Creating label: $name"
  gh label create "$name" \
    --repo "$REPO" \
    --description "$description" \
    --color "$color" \
    --force
}

create_label "requirement"          "PO requirement"                             "e4e669"
create_label "user-story"           "BA-created story"                           "c2e0c6"
create_label "requirement-updated"  "Requirement updated after change"           "fef2c0"
create_label "refactoring"          "Tech-lead refactoring task"                 "1d76db"
create_label "bug"                  "Bug issue (production or development)"       "d73a4a"

echo "Done. All labels created."
