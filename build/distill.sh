#!/usr/bin/env bash
# Reads each {name}_retrieval.md from NotebookLM queries and regenerates
# expert_knowledge/{name}_kb.md using Claude.
# Run AFTER pipeline.sh has completed.
set -uo pipefail
cd "$(dirname "$0")"

ONLY="${1:-}"

declare -a experts=(
  "madeline_mann|Madeline Mann|MANN|career coach known for STAR stories and confidence building"
  "bryan_creely|Bryan Creely|CREELY|recruiter who reveals insider hiring process"
  "richard_mcmunn|Richard McMunn|MCMUNN|UK-based behavioral interview specialist using STAR"
  "andrew_lacivita|Andrew LaCivita|LACIVITA|strategic interviewer focused on employer mindset"
  "jeff_su|Jeff Su|SU|Google PM who teaches resume and career strategy"
  "exponent|Exponent|EXPONENT|tech interview prep platform covering product/PM/eng"
  "product_alliance|Product Alliance|PRODUCTALLIANCE|PM/PMM interview prep community"
)

KB_DIR="../expert_knowledge"

for e in "${experts[@]}"; do
  IFS='|' read -r name display tag desc <<< "$e"
  [ -n "$ONLY" ] && [ "$ONLY" != "$name" ] && continue

  dump="${name}_retrieval.md"
  kb="$KB_DIR/${name}_kb.md"

  if [ ! -s "$dump" ]; then
    echo "SKIP $name: no retrieval dump found (run pipeline.sh first)"
    continue
  fi

  echo "=== distilling $name → $kb ==="

  python3 - "$dump" "$display" "$tag" "$desc" "$kb" <<'PYEOF'
import sys, subprocess, json

dump_path, display, tag, desc, kb_path = sys.argv[1], sys.argv[2], sys.argv[3], sys.argv[4], sys.argv[5]
retrieval = open(dump_path).read()

prompt = f"""You are distilling interview coaching expertise into a reusable Persona Protocol KB file.

Source material (NotebookLM retrieval dump from ~300 YouTube videos by {display}):
---
{retrieval[:20000]}
---

Write a complete expert_knowledge KB file for {display} ({desc}).
Use EXACTLY this structure:

# {display} — Persona Protocol
## Role
[2-3 sentences: who they are, their credibility, their coaching philosophy]

## Thinking Models
[5-8 named frameworks/models this expert uses, each with name + 2-sentence description.
Extract from the retrieval dump — use their actual names if they have branded frameworks.]

## Signature Phrases & Catchphrases
[10-15 verbatim phrases, expressions, or recurring lines this expert uses.
Format: - "exact quote" — context/situation]

## What They Reject
[5-8 things this expert explicitly argues AGAINST or calls wrong.
Format: - ❌ Common advice: [what they reject] → Their alternative: [what they say instead]]

## Core Coverage Areas
[6-10 topic areas this expert covers most, with a 1-sentence description of their angle]

## Anti-Patterns (when generating in their voice)
[5 things to NEVER do when answering as this expert]

## Retrieval Logic
When answering as {display}, first grep the local corpus for the question keywords,
then use these KB frameworks to structure the response in their voice.
Tag: [{tag}]
"""

result = subprocess.run(
    ["claude", "-p", prompt],
    capture_output=True, text=True, timeout=600
)
if result.returncode != 0:
    print(f"  ERROR from claude: {result.stderr[:200]}")
    sys.exit(1)

kb_content = result.stdout.strip()
with open(kb_path, "w") as f:
    f.write(kb_content)
    f.write("\n")
print(f"  wrote {kb_path} ({len(kb_content)} chars)")
PYEOF

done

echo
echo "KB files updated in $KB_DIR/"
echo "Diff preview:"
for e in "${experts[@]}"; do
  IFS='|' read -r name _ _ _ <<< "$e"
  kb="../expert_knowledge/${name}_kb.md"
  [ -f "$kb" ] && echo "  $kb  ($(wc -l < "$kb") lines)"
done
