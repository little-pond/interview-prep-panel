#!/usr/bin/env bash
# Interview Prep Panel — NotebookLM ingestion + distillation pipeline
# Prereqs: `notebooklm login` (valid auth) + build/{name}_urls.txt
# Resumable: tracks notebook IDs + added source IDs across runs.
# Usage:
#   bash pipeline.sh              # run all 7 coaches
#   bash pipeline.sh madeline_mann  # re-run single coach
set -uo pipefail
cd "$(dirname "$0")"

declare -a experts=(
  "madeline_mann|Madeline Mann: Interview Prep|MANN"
  "bryan_creely|Bryan Creely: Recruiter POV|CREELY"
  "richard_mcmunn|Richard McMunn: Behavioral Answers|MCMUNN"
  "andrew_lacivita|Andrew LaCivita: Strategic Interviewing|LACIVITA"
  "jeff_su|Jeff Su: Career & Resume|SU"
  "exponent|Exponent: Tech Interviews|EXPONENT"
  "product_alliance|Product Alliance: PM/PMM Interviews|PRODUCTALLIANCE"
)

ONLY="${1:-}"

# preflight auth check
if ! notebooklm list >/dev/null 2>&1; then
  echo "ERROR: not authenticated. Run in a real Terminal:  notebooklm login"
  exit 1
fi
echo "Auth OK"

for e in "${experts[@]}"; do
  IFS='|' read -r name nbname tag <<< "$e"
  [ -n "$ONLY" ] && [ "$ONLY" != "$name" ] && continue
  urls="${name}_urls.txt"
  [ -s "$urls" ] || { echo "SKIP $name: no urls file"; continue; }

  echo
  echo "=== $name ($tag) ==="

  # 1. create or reuse notebook
  nbid_file="${name}_notebook_id.txt"
  if [ -s "$nbid_file" ]; then
    nbid=$(cat "$nbid_file")
    echo "  reuse notebook $nbid"
  else
    raw=$(notebooklm create "$nbname" --json 2>&1)
    nbid=$(echo "$raw" | python3 -c "
import sys, re
text = sys.stdin.read()
m = re.search(r'\"id\"\s*:\s*\"([0-9a-f]{8}-[0-9a-f-]+)\"', text)
print(m.group(1) if m else '')
" 2>/dev/null)
    if [ -z "$nbid" ]; then
      nbid=$(echo "$raw" | grep -oiE '[0-9a-f-]{8,}' | grep '-' | head -1)
    fi
    if [ -z "$nbid" ]; then
      echo "  ERROR: could not parse notebook id. Output: $raw"
      continue
    fi
    echo "$nbid" > "$nbid_file"
    echo "  created notebook $nbid"
  fi

  # 2. bulk add YouTube sources (resumable via _added_urls.txt)
  added_file="${name}_added_urls.txt"; touch "$added_file"
  ids_file="${name}_source_ids.txt"; touch "$ids_file"

  total=$(grep -c . "$urls" || echo 0)
  added_count=$(grep -c . "$added_file" || echo 0)
  echo "  $added_count/$total already added — processing remaining..."

  i=0
  ok=0
  fail=0
  while IFS= read -r url; do
    [ -z "$url" ] && continue
    i=$((i+1))

    # skip already-added
    grep -qxF "$url" "$added_file" && continue

    raw=$(notebooklm source add -n "$nbid" "$url" --json 2>&1)
    sid=$(echo "$raw" | python3 -c "
import sys, re
text = sys.stdin.read()
m = re.search(r'\"id\"\s*:\s*\"([0-9a-f]{8}-[0-9a-f-]+)\"', text)
print(m.group(1) if m else '')
" 2>/dev/null)
    if [ -n "$sid" ]; then
      echo "$url" >> "$added_file"
      echo "$sid" >> "$ids_file"
      ok=$((ok+1))
    else
      fail=$((fail+1))
      # log failures quietly
      echo "FAIL $url :: $raw" >> "${name}_add_errors.log" 2>/dev/null || true
    fi

    printf "\r  [%d/%d] ok=%d fail=%d" "$i" "$total" "$ok" "$fail"
    sleep 0.8
  done < "$urls"

  final_added=$(grep -c . "$added_file" || echo 0)
  echo
  echo "  sources in notebook: $final_added  (added this run: $ok, failed: $fail)"

  # 3. wait for sources to index (poll until all ready or timeout 10 min)
  echo "  waiting for sources to index..."
  deadline=$(($(date +%s) + 600))
  while IFS= read -r sid; do
    [ -z "$sid" ] && continue
    if [ "$(date +%s)" -gt "$deadline" ]; then
      echo "  WARNING: index wait timed out after 10 min — querying anyway"
      break
    fi
    notebooklm source wait -n "$nbid" "$sid" --timeout 60 >/dev/null 2>&1 || true
  done < "$ids_file"
  echo "  sources ready"

  # 4. distillation queries -> retrieval dump
  dump="${name}_retrieval.md"
  echo "  running distillation queries..."
  {
    echo "# $nbname — Retrieval Dump"
    echo "> notebook: \`$nbid\` | sources: $final_added | $(date)"
    for q in \
      "What are this expert's core frameworks, mental models, and step-by-step methods for job interviews? List each with a short description." \
      "What catchphrases, signature expressions, and recurring quotes does this expert use? Quote them exactly." \
      "What does this expert strongly disagree with? What common interview advice do they reject or call a mistake?" \
      "What interview topics, question types, and candidate situations does this expert cover most frequently?" \
      "How does this expert advise candidates to prepare for interviews? What is their pre-interview ritual or system?" \
      "What is this expert's advice specific to tech, product, or PM interviews? What unique frameworks do they apply?"; do
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
echo "DONE. Summary:"
for e in "${experts[@]}"; do
  IFS='|' read -r name _ tag <<< "$e"
  added=$(grep -c . "${name}_added_urls.txt" 2>/dev/null || echo 0)
  nbid=$(cat "${name}_notebook_id.txt" 2>/dev/null || echo TBD)
  printf "  %-20s %s  sources=%s\n" "$tag" "$nbid" "$added"
done
echo
echo "Next: run  bash distill.sh  to update expert_knowledge/ KB files from retrieval dumps."
