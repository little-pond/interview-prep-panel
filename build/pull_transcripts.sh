#!/usr/bin/env bash
# Pull EN subtitles for ALL videos per coach (up to 300) into a local searchable corpus.
# Output:
#   subs/{name}/{vid}.en*.json3        raw subs (skipped if already present)
#   transcripts/{name}/{vid}.txt       one clean transcript per video (full, uncapped)
#   {name}_corpus.txt                  all videos concatenated (for distillation input)
# This local corpus is the Layer-1 retrieval substitute (grep-able, no auth).
set -uo pipefail
cd "$(dirname "$0")"

names=(madeline_mann bryan_creely richard_mcmunn andrew_lacivita jeff_su exponent product_alliance)

for name in "${names[@]}"; do
  urls="${name}_urls.txt"
  [ -s "$urls" ] || { echo "SKIP $name (no urls)"; continue; }
  sub="subs/${name}"; tdir="transcripts/${name}"; mkdir -p "$sub" "$tdir"
  total=$(grep -c . "$urls")
  echo "=== $name: fetching subtitles for up to $total videos ==="
  yt-dlp -a "$urls" \
    --skip-download --write-subs --write-auto-subs --no-overwrites \
    --sub-langs "en.*,en" --sub-format json3 \
    --sleep-requests 1 --ignore-errors --no-warnings \
    -o "${sub}/%(id)s.%(ext)s" >>"${name}_subs.log" 2>&1 || true

  python3 - "$sub" "$tdir" "${name}_corpus.txt" <<'PY'
import json,glob,os,sys,collections
subdir,tdir,corpus=sys.argv[1],sys.argv[2],sys.argv[3]
byid=collections.defaultdict(list)
for f in glob.glob(os.path.join(subdir,"*.json3")):
    vid=os.path.basename(f).split(".")[0]
    byid[vid].append(f)
def pick(fs):  # prefer manual .en over auto .en-orig
    return sorted(fs, key=lambda x: (".en-orig." in x, x))[0]
vids=0; total_words=0
with open(corpus,"w") as cf:
    for vid,fs in byid.items():
        try: d=json.load(open(pick(fs)))
        except Exception: continue
        seg=[t.get("utf8","") for ev in d.get("events",[]) for t in (ev.get("segs") or []) if t.get("utf8","").strip()]
        txt=" ".join(" ".join(seg).split())
        if not txt: continue
        vids+=1; total_words+=len(txt.split())
        open(os.path.join(tdir,f"{vid}.txt"),"w").write(txt)
        cf.write(f"\n\n===== VIDEO {vid} =====\n\n{txt}")
print(f"  {name if False else os.path.basename(tdir)}: {vids} videos, {total_words} words")
PY
done

echo "ALL TRANSCRIPTS DONE"
echo "=== corpus sizes ==="
for name in "${names[@]}"; do
  n=$(ls "transcripts/${name}" 2>/dev/null | wc -l | tr -d ' ')
  w=$(wc -w < "${name}_corpus.txt" 2>/dev/null | tr -d ' ')
  printf "  %-18s %3s videos  %8s words\n" "$name" "$n" "$w"
done