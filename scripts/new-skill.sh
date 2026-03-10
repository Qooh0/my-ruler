#!/usr/bin/env bash
set -euo pipefail

SKILLS_DIR="templates/.ruler/skills"

usage() {
  cat <<EOF
Usage: $(basename "$0") <skill-name>

Create a new skill template in ${SKILLS_DIR}/<skill-name>/SKILL.md

Options:
  -h, --help    Show this help message

Example:
  $(basename "$0") code-review
  $(basename "$0") security-audit
EOF
  exit "${1:-0}"
}

# Parse arguments
if [[ $# -lt 1 ]] || [[ "$1" == "-h" ]] || [[ "$1" == "--help" ]]; then
  usage 0
fi

SKILL_NAME="$1"

# Validate skill name (lowercase, hyphens, numbers only)
if [[ ! "$SKILL_NAME" =~ ^[a-z][a-z0-9-]*$ ]]; then
  echo "Error: Skill name must start with a lowercase letter and contain only lowercase letters, numbers, and hyphens." >&2
  exit 1
fi

# Resolve project root (where this script lives -> one level up)
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
SKILL_PATH="${PROJECT_ROOT}/${SKILLS_DIR}/${SKILL_NAME}"

# Check if skill already exists
if [[ -d "$SKILL_PATH" ]]; then
  echo "Error: Skill '${SKILL_NAME}' already exists at ${SKILL_PATH}" >&2
  exit 1
fi

# Create skill directory and SKILL.md
mkdir -p "$SKILL_PATH"
cat > "${SKILL_PATH}/SKILL.md" <<TEMPLATE
---
name: ${SKILL_NAME}
description: TODO - Describe when this skill should be used
---

# ${SKILL_NAME}

TODO: Write the skill instructions here.

## Guidelines

- Guideline 1
- Guideline 2
TEMPLATE

echo "Created skill: ${SKILL_PATH}/SKILL.md"
echo ""
echo "Next steps:"
echo "  1. Edit ${SKILLS_DIR}/${SKILL_NAME}/SKILL.md"
echo "  2. Run 'npm run build' to rebuild"
echo "  3. Run 'my-ruler sync <target>' to distribute"
