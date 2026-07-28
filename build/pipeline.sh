#!/usr/bin/env bash
# Interview Prep Panel — NotebookLM ingestion pipeline
# Prereqs: `notebooklm login` (valid auth) + build/{name}_urls.txt already grabbed via yt-dlp.
# Resumable: tracks created notebooks + added sources so you can re-run after an interruption.
set -uo pipefail
cd "$(dirname "$0")"

# name | NotebookLM notebook title | panel TAG
declare -a experts=(
  "madeline_mann|Madeline Mann: Interview Prep|MANN"
  "bryan_creely|Bryan Creely: Recruiter POV|CREELY"
  "richard_mcmunn|Richard McMunn: Behavioral Answers|MCMUNN"
  "andrew_lacivita|Andrew LaCivita: Strategic Interviewing|LACIVITA"
  "jeff_su|Jeff Su: Career & Resume|SU"
  "exponent|Exponent: Tech Interviews|EXPONENT"
  "product_alliance|Product Alliance: PM/PMM Interviews|PRODUCTALLIANCE"
)

# optional arg = single expert name to (re)run
ONLY="${1:-}"

# preflight auth check
if ! notebooklm list >/dev/null 2>&1; then
  echo "ERROR: notebooklm not authenticated. Run:  notebooklm login"; exit 1
fi

for e in "${experts[@]}"; do
  IFS='|' read -r name nbname tag <<< "$e"
  [ -n "$ONLY" ] && [ "$ONLY" != "$name" ] && continue
  urls="${name}_urls.txt"
  [ -s "$urls" ] || { echo "SKIP $name: no urls file"; continue; }

  echo "=== $name ($tag) ==="

  # 1. create notebook (reuse saved id if present)
  if [ -s "${name}_notebook_id.txt" ]; then
    nbid=$(cat "${name}_notebook_id.txt")
    echo "  reuse notebook $nbid"
  else
    out=$(notebooklm create "$nbname" 2>&1)
    nbid=$(echo "$out" | grep -oiE '[0-9a-f]{8,}' | head -1)
    if [ -z "$nbid" ]; then echo "  !! could not parse notebook id from: $out"; continue; fi
    echo "$nbid" > "${name}_notebook_id.txt"
    echo "  created notebook $nbid"
  fi

  # 2. bulk add sources (resumable via _added.txt)
  added="${name}_added.txt"; touch "$added"
  total=$(grep -c . "$urls"); i=0
  while IFS= read -r url; do
    [ -z "$url" ] && continue
    i=$((i+1))
    grep -qxF "$url" "$added" && continue
    if notebooklm source add -n "$nbid" "$url" >/dev/null 2>&1; then
      echo "$url" >> "$added"
    fi
    printf "\r  adding %d/%d" "$i" "$total"
    sleep 1
  done < "$urls"
  echo "   ($(grep -c . "$added") sources indexed)"

  # 3. DNA queries -> retrieval dump for KB generation
  dump="${name}_retrieval.md"
  {
    echo "# $nbname — Retrieval Dump"
    echo
    echo "> notebook: \`$nbid\` | sources: $(grep -c . "$added")"
    for q in \
      "What are this expert's core frameworks, mental models, and step-by-step methods for job interviews? List each with a short description." \
      "What catchphrases, signature expressions, and recurring quotes does this expert use? Quote them exactly." \
      "What does this expert strongly disagree with? What common interview advice do they reject or call a mistake?" \
      "What interview topics, question types, and candidate situations does this expert cover most frequently?" ; do
      echo
      echo "## Q: $q"
      echo
      notebooklm ask -n "$nbid" "$q" 2>&1
      echo
    done
  } > "$dump"
  echo "  wrote $dump"
done

echo
echo "ALL DONE. Notebook IDs:"
for e in "${experts[@]}"; do
  IFS='|' read -r name _ tag <<< "$e"
  printf "  %-16s %-16s %s\n" "$tag" "$name" "$(cat ${name}_notebook_id.txt 2>/dev/null || echo TBD)"
done