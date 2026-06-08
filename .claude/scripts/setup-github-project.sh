#!/usr/bin/env bash
set -euo pipefail

REPO="${1:-$(gh repo view --json nameWithOwner -q .nameWithOwner)}"
OWNER="${REPO%%/*}"
REPO_NAME="${REPO##*/}"
# Capitalize the repo name for the project title (e.g. sapiens-dtj → Sapiens-dtj Workflow).
REPO_NAME_CAP="$(tr '[:lower:]' '[:upper:]' <<< "${REPO_NAME:0:1}")${REPO_NAME:1}"
PROJECT_TITLE="${2:-$REPO_NAME_CAP Workflow}"

check_project_scope() {
  if ! gh auth status 2>&1 | grep -q "'project'"; then
    echo "ERROR: gh token missing 'project' scope."
    echo "Run: gh auth refresh -s project --hostname github.com"
    exit 1
  fi
}

find_or_create_project() {
  local existing
  existing=$(gh project list --owner "$OWNER" --format json \
    --jq ".projects[] | select(.title==\"$PROJECT_TITLE\") | .number" | head -n1)
  if [ -n "$existing" ]; then
    PROJECT_NUMBER="$existing"
    echo "Project '$PROJECT_TITLE' exists (#$PROJECT_NUMBER) — reusing."
  else
    PROJECT_NUMBER=$(gh project create --owner "$OWNER" --title "$PROJECT_TITLE" \
      --format json --jq '.number')
    echo "Created project '$PROJECT_TITLE' (#$PROJECT_NUMBER)."
  fi
  PROJECT_ID=$(gh project view "$PROJECT_NUMBER" --owner "$OWNER" --format json --jq '.id')
}

link_project_to_repo() {
  gh project link "$PROJECT_NUMBER" --owner "$OWNER" --repo "$REPO" 2>/dev/null \
    && echo "Linked project to $REPO." \
    || echo "Project already linked to $REPO."
}

create_field() {
  local name="$1"
  local options="$2"
  local existing
  existing=$(gh project field-list "$PROJECT_NUMBER" --owner "$OWNER" --format json \
    --jq ".fields[] | select(.name==\"$name\") | .id")
  if [ -n "$existing" ]; then
    echo "Field '$name' exists — skipping."
  else
    gh project field-create "$PROJECT_NUMBER" --owner "$OWNER" \
      --name "$name" --data-type SINGLE_SELECT \
      --single-select-options "$options" > /dev/null
    echo "Created field: $name ($options)"
  fi
}

configure_status_options() {
  # Replace the built-in Status options with the workflow lifecycle set.
  # Full-replacement semantics are safe here: the board is fresh (or already configured).
  local status_field_id current_options
  status_field_id=$(gh project field-list "$PROJECT_NUMBER" --owner "$OWNER" --format json \
    --jq '.fields[] | select(.name=="Status") | .id')
  current_options=$(gh project field-list "$PROJECT_NUMBER" --owner "$OWNER" --format json \
    --jq '[.fields[] | select(.name=="Status") | .options[].name] | join(",")')
  if [ "$current_options" = "Backlog,Todo,In Progress,Implemented,Done" ]; then
    echo "Status options already configured — skipping."
    return
  fi
  gh api graphql -f query='
    mutation($fieldId: ID!) {
      updateProjectV2Field(input: {
        fieldId: $fieldId,
        singleSelectOptions: [
          {name: "Backlog",     color: GRAY,   description: "Captured, not yet planned"},
          {name: "Todo",        color: BLUE,   description: "Planned, not started"},
          {name: "In Progress", color: YELLOW, description: "Implementation in progress"},
          {name: "Implemented", color: GREEN,  description: "PRs open, awaiting review and merge"},
          {name: "Done",        color: PURPLE, description: "Released and closed"}
        ]
      }) { projectV2Field { ... on ProjectV2SingleSelectField { id } } }
    }' -f fieldId="$status_field_id" > /dev/null
  echo "Configured Status options: Backlog, Todo, In Progress, Implemented, Done."
}

check_project_scope
find_or_create_project
link_project_to_repo
create_field "Type" "Feature,Refactor,Bug"
create_field "Sprint" "Sprint 1"
configure_status_options

echo ""
echo "Done. Board '$PROJECT_TITLE' (#$PROJECT_NUMBER) ready."
echo "Existing milestones and retired labels are left untouched and ignored."
echo ""
echo "Manual step (views are not configurable via the GitHub API):"
echo "  1. Open: $(gh project view "$PROJECT_NUMBER" --owner "$OWNER" --format json --jq '.url')"
echo "  2. On 'View 1' tab: ▾ → Layout: Board → group by Status."
echo "  3. Optional second view: Layout: Table, group by Sprint."
