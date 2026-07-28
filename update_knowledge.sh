#!/usr/bin/env bash
# Refresh the panel's knowledge. Re-grabs URLs, then re-runs the NotebookLM ingestion pipeline.
# Usage:
#   bash update_knowledge.sh            # all coaches
#   bash update_knowledge.sh jeff_su    # one coach
set -uo pipefail
cd "$(dirname "$0")"

declare -A channels=(
  [madeline_mann]="https://www.youtube.com/@SelfMadeMillennial"
  [bryan_creely]="https://www.youtube.com/@ALifeAfterLayoff"
  [richard_mcmunn]="https://www.youtube.com/@CareerVidz"
  [andrew_lacivita]="https://www.youtube.com/@andylacivita"
  [jeff_su]="https://www.youtube.com/@JeffSu"
  [exponent]="https://www.youtube.com/@tryexponent"
  [product_alliance]="https://www.youtube.com/@ProductAlliance"
)

ONLY="${1:-}"
for name in "${!channels[@]}"; do
  [ -n "$ONLY" ] && [ "$ONLY" != "$name" ] && continue
  echo "Refreshing URLs: $name"
  yt-dlp "${channels[$name]}/videos" --flat-playlist --print url --playlist-end 300 \
    > "build/${name}_urls.txt" 2>/dev/null
  echo "  $(grep -c . build/${name}_urls.txt) urls"
done

echo "Running ingestion pipeline..."
bash build/pipeline.sh "$ONLY"