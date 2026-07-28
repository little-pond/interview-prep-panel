#!/usr/bin/env bash
#
# interview-prep-panel installer
#
#   curl -fsSL https://raw.githubusercontent.com/little-pond/interview-prep-panel/main/install.sh | bash
#
# Options (environment variables):
#   SKILLS_DIR=~/.claude/skills   install location (default: ~/.claude/skills)
#   BUILD_CORPUS=1                also pull the ~940MB transcript corpus (needs yt-dlp)
#
set -euo pipefail

REPO_URL="https://github.com/little-pond/interview-prep-panel.git"
NAME="interview-prep-panel"
SKILLS_DIR="${SKILLS_DIR:-$HOME/.claude/skills}"
DEST="$SKILLS_DIR/$NAME"

# colors only when stdout is a terminal
if [ -t 1 ]; then C='\033[1;36m'; G='\033[1;32m'; Y='\033[1;33m'; R='\033[1;31m'; Z='\033[0m'; else C=''; G=''; Y=''; R=''; Z=''; fi
info(){ printf "${C}▸${Z} %s\n" "$1"; }
ok(){   printf "${G}✓${Z} %s\n" "$1"; }
warn(){ printf "${Y}!${Z} %s\n" "$1"; }
err(){  printf "${R}✗${Z} %s\n" "$1" >&2; }

# --- prereqs ---------------------------------------------------------------
command -v git >/dev/null 2>&1 || { err "git is required — install git and re-run."; exit 1; }

mkdir -p "$SKILLS_DIR"

# --- install or update -----------------------------------------------------
if [ -d "$DEST/.git" ]; then
  info "Updating existing install at $DEST"
  git -C "$DEST" pull --ff-only || { err "Update failed (local changes?). Resolve, or remove $DEST and re-run."; exit 1; }
  ok "Updated."
elif [ -e "$DEST" ]; then
  err "$DEST already exists and is not a git checkout. Move/remove it and re-run."
  exit 1
else
  info "Cloning into $DEST"
  git clone --depth 1 "$REPO_URL" "$DEST"
  ok "Skill installed (works in KB-only mode right away)."
fi

# --- optional: build Layer-1 corpus ----------------------------------------
if [ "${BUILD_CORPUS:-0}" = "1" ]; then
  if command -v yt-dlp >/dev/null 2>&1; then
    info "Building transcript corpus (~940MB, ~45–60 min)…"
    bash "$DEST/build/pull_transcripts.sh"
    ok "Corpus built — live retrieval enabled."
  else
    warn "BUILD_CORPUS=1 set, but yt-dlp is not installed."
    warn "Install it (brew install yt-dlp), then run:  bash \"$DEST/build/pull_transcripts.sh\""
  fi
fi

# --- next steps ------------------------------------------------------------
printf "\n"
ok "Done.  Skill installed at: $DEST"
cat <<EOF

  Next:
    • In Claude Code, just ask an interview question — the panel auto-routes:
        "I have a PMM interview in two weeks — give me a full prep plan."
    • Prompt ideas:            $DEST/PROMPTS.md
    • Full guide:              $DEST/README.md
    • (Optional) live quote retrieval — build the ~940MB corpus (needs yt-dlp):
        bash "$DEST/build/pull_transcripts.sh"
      or re-run this installer with:  BUILD_CORPUS=1

EOF
