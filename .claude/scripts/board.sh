#!/usr/bin/env bash
set -euo pipefail

# Project board primitive. Self-resolving: finds the project by title and
# field/option IDs by name. Resolution is cached in the gitignored
# .claude/state/board.json and refreshed on lookup miss or after field mutations.
#
# Usage: board.sh <subcommand> [args]
#
# Subcommands:
#   current-sprint                              → highest "Sprint N" with active (non-Done) work
#   next-sprint-number                          → max(N)+1
#   ensure-sprint <K>                           → append "Sprint K" option if missing
#   add-issue <issue-number>                    → add issue to board, print item ID
#   item-id-for-issue <issue-number>            → print board item ID (empty if absent)
#   set-status <issue-number> <status-name>     → set Status (adds to board if needed)
#   set-type <issue-number> <type-name>         → set Type (adds to board if needed)
#   set-sprint <issue-number> "Sprint K"        → set Sprint (adds to board if needed)
#   list-sprint "Sprint K" [--open-only]        → JSON [{number,title,labels,status,type,state}]
#   set-draft <title> <body> <type-name>        → create draft item (Status=Backlog), print item ID
#   list-drafts                                 → JSON [{id,title,body,type,status}]
#   delete-item <item-id>                       → remove item from board

REPO="$(gh repo view --json nameWithOwner -q .nameWithOwner)"
OWNER="${REPO%%/*}"
REPO_NAME="${REPO##*/}"
# Capitalize the repo name for the project title (e.g. sapiens-dtj → Sapiens-dtj Workflow).
REPO_NAME_CAP="$(tr '[:lower:]' '[:upper:]' <<< "${REPO_NAME:0:1}")${REPO_NAME:1}"
PROJECT_TITLE="${BOARD_PROJECT_TITLE:-$REPO_NAME_CAP Workflow}"
CACHE_FILE="$(git rev-parse --show-toplevel)/.claude/state/board.json"

resolve_board_live() {
  PROJECT_NUMBER=$(gh project list --owner "$OWNER" --format json \
    --jq ".projects[] | select(.title==\"$PROJECT_TITLE\") | .number" | head -n1)
  if [ -z "$PROJECT_NUMBER" ]; then
    echo "ERROR: No board titled '$PROJECT_TITLE' found — provision the project board first." >&2
    exit 1
  fi
  # repositoryOwner covers both user- and org-owned projects.
  FIELDS_JSON=$(gh api graphql -f query='
    query($owner: String!, $number: Int!) {
      repositoryOwner(login: $owner) { ... on ProjectV2Owner { projectV2(number: $number) { id fields(first: 30) { nodes {
        ... on ProjectV2SingleSelectField { id name options { id name color description } }
      } } } } }
    }' -f owner="$OWNER" -F number="$PROJECT_NUMBER" \
    --jq '.data.repositoryOwner.projectV2')
  PROJECT_ID=$(echo "$FIELDS_JSON" | jq -r '.id')
  mkdir -p "$(dirname "$CACHE_FILE")"
  # `board` holds the resolved project node: {id, fields: {nodes: [...]}}.
  jq -n --arg title "$PROJECT_TITLE" --argjson number "$PROJECT_NUMBER" --argjson board "$FIELDS_JSON" \
    '{title: $title, project_number: $number, board: $board}' > "$CACHE_FILE"
}

resolve_board() {
  # Cache hit requires a parseable file for the same project title.
  if [ -f "$CACHE_FILE" ] && [ "$(jq -r '.title // empty' "$CACHE_FILE" 2>/dev/null)" = "$PROJECT_TITLE" ]; then
    PROJECT_NUMBER=$(jq -r '.project_number' "$CACHE_FILE")
    FIELDS_JSON=$(jq -c '.board' "$CACHE_FILE")
    PROJECT_ID=$(echo "$FIELDS_JSON" | jq -r '.id')
    return
  fi
  resolve_board_live
}

field_id() {
  local name="$1" id
  id=$(echo "$FIELDS_JSON" | jq -r ".fields.nodes[] | select(.name==\"$name\") | .id")
  if [ -z "$id" ]; then
    # Refresh-on-miss: cache may be stale.
    resolve_board_live
    id=$(echo "$FIELDS_JSON" | jq -r ".fields.nodes[] | select(.name==\"$name\") | .id")
  fi
  if [ -z "$id" ]; then
    echo "ERROR: Field '$name' not found on the board." >&2
    exit 1
  fi
  echo "$id"
}

option_id() {
  local field="$1" option="$2" id
  id=$(echo "$FIELDS_JSON" | jq -r ".fields.nodes[] | select(.name==\"$field\") | .options[] | select(.name==\"$option\") | .id")
  if [ -z "$id" ]; then
    # Refresh-on-miss: option may have been added since the cache was written.
    resolve_board_live
    id=$(echo "$FIELDS_JSON" | jq -r ".fields.nodes[] | select(.name==\"$field\") | .options[] | select(.name==\"$option\") | .id")
  fi
  if [ -z "$id" ]; then
    echo "ERROR: Option '$option' not found on field '$field'." >&2
    exit 1
  fi
  echo "$id"
}

issue_item_id() {
  local issue_number="$1"
  gh api graphql -f query='
    query($owner: String!, $repo: String!, $num: Int!) {
      repository(owner: $owner, name: $repo) {
        issue(number: $num) { projectItems(first: 20) { nodes { id project { number } } } }
      }
    }' -f owner="$OWNER" -f repo="$REPO_NAME" -F num="$issue_number" \
    --jq ".data.repository.issue.projectItems.nodes[] | select(.project.number==$PROJECT_NUMBER) | .id" | head -n1
}

add_issue() {
  local issue_number="$1"
  local url
  url=$(gh issue view "$issue_number" --repo "$REPO" --json url -q .url)
  gh project item-add "$PROJECT_NUMBER" --owner "$OWNER" --url "$url" --format json --jq '.id'
}

item_for_issue_or_add() {
  # Self-healing: add the issue to the board if it is not on it yet.
  local issue_number="$1"
  local item_id
  item_id=$(issue_item_id "$issue_number")
  if [ -z "$item_id" ]; then
    item_id=$(add_issue "$issue_number")
  fi
  echo "$item_id"
}

set_field_on_item() {
  local item_id="$1" field_name="$2" option_name="$3"
  gh project item-edit --id "$item_id" --project-id "$PROJECT_ID" \
    --field-id "$(field_id "$field_name")" \
    --single-select-option-id "$(option_id "$field_name" "$option_name")" > /dev/null
}

set_field_on_issue() {
  local issue_number="$1" field_name="$2" option_name="$3"
  local item_id
  item_id=$(item_for_issue_or_add "$issue_number")
  set_field_on_item "$item_id" "$field_name" "$option_name"
  echo "Issue #$issue_number → $field_name: $option_name"
}

current_sprint() {
  # Highest-numbered sprint that still has live work — at least one issue not
  # yet Done. A fully-released sprint (all issues Done) is no longer active, so
  # its option name is skipped even if it sorts highest.
  local sprint
  sprint=$(list_items | jq -r '
    [ .[]
      | select(.kind=="Issue")
      | select(.status != "Done")
      | .sprint
      | select(. != null)
      | select(test("^Sprint [0-9]+$")) ]
    | unique
    | sort_by(ltrimstr("Sprint ") | tonumber)
    | last // empty')
  if [ -z "$sprint" ]; then
    echo "ERROR: No active sprint on the board." >&2
    exit 1
  fi
  echo "$sprint"
}

next_sprint_number() {
  # Drives sprint naming — never trust the cache here.
  resolve_board_live
  local max
  max=$(echo "$FIELDS_JSON" | jq -r '.fields.nodes[] | select(.name=="Sprint") | .options[].name' \
    | grep -E '^Sprint [0-9]+$' | sed 's/Sprint //' | sort -n | tail -n1)
  echo $(( ${max:-0} + 1 ))
}

ensure_sprint() {
  # Mutates the option set from a full snapshot — never trust the cache here.
  resolve_board_live
  local k="$1"
  local existing
  existing=$(echo "$FIELDS_JSON" | jq -r ".fields.nodes[] | select(.name==\"Sprint\") | .options[] | select(.name==\"Sprint $k\") | .id")
  if [ -n "$existing" ]; then
    echo "Sprint $k option exists — skipping."
    return
  fi
  # Full-replacement semantics: resend every existing option WITH its id, then append.
  # gh api graphql cannot pass list variables — inline the options as GraphQL literals
  # (color is an enum, so it must be unquoted).
  local options_literal
  options_literal=$(echo "$FIELDS_JSON" | jq -r ".fields.nodes[] | select(.name==\"Sprint\") | .options[] | \"{id: \\\"\(.id)\\\", name: \\\"\(.name)\\\", color: \(.color), description: \\\"\(.description)\\\"}\"" | paste -sd, -)
  options_literal="$options_literal, {name: \"Sprint $k\", color: GRAY, description: \"\"}"
  gh api graphql -f query="
    mutation {
      updateProjectV2Field(input: {fieldId: \"$(field_id Sprint)\", singleSelectOptions: [$options_literal]}) {
        projectV2Field { ... on ProjectV2SingleSelectField { id } }
      }
    }" > /dev/null
  # Pick up the new option (and its ID) in the cache.
  resolve_board_live
  echo "Created sprint option: Sprint $k"
}

list_items() {
  # Paginated dump of all board items with single-select field values flattened.
  local cursor="" page result="[]"
  while :; do
    page=$(gh api graphql -f query='
      query($pid: ID!, $cursor: String) {
        node(id: $pid) { ... on ProjectV2 { items(first: 100, after: $cursor) {
          pageInfo { hasNextPage endCursor }
          nodes {
            id
            content {
              __typename
              ... on Issue { number title state labels(first: 20) { nodes { name } } }
              ... on DraftIssue { title body }
            }
            fieldValues(first: 20) { nodes {
              ... on ProjectV2ItemFieldSingleSelectValue { name field { ... on ProjectV2FieldCommon { name } } }
            } }
          }
        } } }
      }' -f pid="$PROJECT_ID" -f cursor="$cursor" --jq '.data.node.items')
    result=$(jq -n --argjson acc "$result" --argjson page "$page" '$acc + $page.nodes')
    if [ "$(echo "$page" | jq -r '.pageInfo.hasNextPage')" != "true" ]; then break; fi
    cursor=$(echo "$page" | jq -r '.pageInfo.endCursor')
  done
  echo "$result" | jq '[.[] | {
    id,
    kind: .content.__typename,
    number: .content.number,
    title: .content.title,
    body: .content.body,
    state: .content.state,
    labels: [.content.labels.nodes[]?.name],
    status: ([.fieldValues.nodes[] | select(.field.name? == "Status") | .name] | first),
    type:   ([.fieldValues.nodes[] | select(.field.name? == "Type")   | .name] | first),
    sprint: ([.fieldValues.nodes[] | select(.field.name? == "Sprint") | .name] | first)
  }]'
}

list_sprint() {
  local sprint="$1" open_only="${2:-}"
  local items
  items=$(list_items | jq --arg s "$sprint" '[.[] | select(.kind=="Issue" and .sprint==$s)]')
  if [ "$open_only" = "--open-only" ]; then
    items=$(echo "$items" | jq '[.[] | select(.state=="OPEN")]')
  fi
  echo "$items" | jq '[.[] | {number, title, labels, status, type, state}]'
}

set_draft() {
  local title="$1" body="$2" type_name="$3"
  local item_id
  item_id=$(gh project item-create "$PROJECT_NUMBER" --owner "$OWNER" \
    --title "$title" --body "$body" --format json --jq '.id')
  set_field_on_item "$item_id" "Type" "$type_name"
  set_field_on_item "$item_id" "Status" "Backlog"
  echo "$item_id"
}

list_drafts() {
  list_items | jq '[.[] | select(.kind=="DraftIssue") | {id, title, body, type, status}]'
}

delete_item() {
  local item_id="$1"
  gh project item-delete "$PROJECT_NUMBER" --owner "$OWNER" --id "$item_id" > /dev/null
  echo "Deleted board item: $item_id"
}

SUBCOMMAND="${1:-}"
[ -z "$SUBCOMMAND" ] && { echo "ERROR: subcommand required." >&2; exit 1; }
shift

resolve_board

case "$SUBCOMMAND" in
  current-sprint)      current_sprint ;;
  next-sprint-number)  next_sprint_number ;;
  ensure-sprint)       ensure_sprint "$1" ;;
  add-issue)           add_issue "$1" ;;
  item-id-for-issue)   issue_item_id "$1" ;;
  set-status)          set_field_on_issue "$1" "Status" "$2" ;;
  set-type)            set_field_on_issue "$1" "Type" "$2" ;;
  set-sprint)          set_field_on_issue "$1" "Sprint" "$2" ;;
  list-sprint)         list_sprint "$1" "${2:-}" ;;
  set-draft)           set_draft "$1" "${2:-}" "$3" ;;
  list-drafts)         list_drafts ;;
  delete-item)         delete_item "$1" ;;
  *) echo "ERROR: unknown subcommand '$SUBCOMMAND'." >&2; exit 1 ;;
esac
