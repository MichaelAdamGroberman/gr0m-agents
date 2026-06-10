#!/usr/bin/env bash
# build-skill.sh — assemble the installable .skill bundle from this repo.
# Output: dist/agent-team-builder.skill (a zip of a skill dir: SKILL.md + templates/).
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
NAME="agent-team-builder"
STAGE="$(mktemp -d)"; trap 'rm -rf "$STAGE"' EXIT
DIST="$ROOT/dist"; mkdir -p "$DIST"

mkdir -p "$STAGE/$NAME/templates"
cp "$ROOT/skill/SKILL.md" "$STAGE/$NAME/SKILL.md"

# templates/ = the scaffold itself, minus repo/meta files that don't belong in a skill
copy_excludes=(
  --exclude '.git' --exclude 'dist' --exclude 'skill' --exclude 'scripts'
  --exclude '.github' --exclude '*.skill' --exclude 'LICENSE'
  --exclude 'CONTRIBUTING.md' --exclude 'CODE_OF_CONDUCT.md'
  --exclude 'SECURITY.md' --exclude 'CHANGELOG.md' --exclude '.gitignore'
)
if command -v rsync >/dev/null; then
  rsync -a "${copy_excludes[@]}" "$ROOT"/ "$STAGE/$NAME/templates"/
else
  # tar-based fallback honoring the same excludes
  ( cd "$ROOT" && tar --exclude='.git' --exclude='dist' --exclude='skill' \
      --exclude='scripts' --exclude='.github' --exclude='*.skill' \
      --exclude='LICENSE' --exclude='CONTRIBUTING.md' --exclude='CODE_OF_CONDUCT.md' \
      --exclude='SECURITY.md' --exclude='CHANGELOG.md' --exclude='.gitignore' \
      -cf - . ) | ( cd "$STAGE/$NAME/templates" && tar -xf - )
fi

rm -f "$DIST/$NAME.skill"
if command -v zip >/dev/null; then
  ( cd "$STAGE" && zip -rqX "$DIST/$NAME.skill" "$NAME" )
else
  ( cd "$STAGE" && python3 -c "import shutil,sys;shutil.make_archive(sys.argv[1],'zip','.',sys.argv[2])" "$DIST/$NAME" "$NAME" && mv "$DIST/$NAME.zip" "$DIST/$NAME.skill" )
fi
echo "built $DIST/$NAME.skill"
