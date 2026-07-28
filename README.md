# interview-prep-panel

A routable **7-coach interview-prep expert panel** with a **fully-local dual-layer knowledge
architecture** (no auth, no external service), inspired by `30x-growth-marketing-panel`.

- **Layer 1 — Local transcript corpus (`build/transcripts/{name}/*.txt`):** up to 300 real YouTube
  videos per coach (~4.4M words total), one clean transcript per file, `grep`-searchable. The
  deep-retrieval layer — source of truth for what each coach actually said.
- **Layer 2 — Expert KB (`expert_knowledge/*_kb.md`):** distilled persona protocol — frameworks,
  signature phrases (verbatim), anti-patterns. Provides voice + structure.

> The panel originally targeted NotebookLM for Layer 1, but the `notebooklm` CLI's non-browser cookie
> replay is blocked by Google (a valid fresh login still bounces to sign-in). Layer 1 was moved to a
> local grep-able corpus instead — same depth (all ~300 videos/coach), no login. The old NotebookLM
> pipeline (`build/pipeline.sh`) is retained but unused.

## The panel

| Tag | Coach | Channel | Domain |
|---|---|---|---|
| MANN | Madeline Mann | @SelfMadeMillennial | All-round interview Q&A, salary negotiation, job search |
| CREELY | Bryan Creely | @ALifeAfterLayoff | Recruiter POV, red flags, rejection, negotiation |
| MCMUNN | Richard McMunn | @CareerVidz | STAR/behavioral model answers, story bank |
| LACIVITA | Andrew LaCivita | @andylacivita | Storytelling frameworks, exec interviews, strategic framing |
| SU | Jeff Su | @JeffSu | Concise tactical career/interview/resume, big-tech marketing |
| EXPONENT | Exponent | @tryexponent | Tech interviews — PM, PMM, SWE, mock interviews |
| PRODUCTALLIANCE | Product Alliance | @ProductAlliance | PM/PMM interviews at top tech companies |

## Usage

Invoke the skill and ask an interview question. It routes to the right coach(es), greps their local
transcript corpus, and answers in their voice. Name a coach ("ask Creely…") for a single deep dive,
or ask a broad question for a roundtable.

## The transcript corpus is NOT in this repo

Layer 1 (`build/transcripts/`, `build/subs/`, samples, `*_corpus.txt`) is **git-ignored** — it's
~940 MB and contains creators' copyrighted YouTube captions. The repo ships the **recipe**; you
regenerate the corpus locally:

```bash
bash build/pull_transcripts.sh          # pull all ~300 videos/coach into build/transcripts/
bash update_knowledge.sh jeff_su        # re-grab URLs + re-pull one coach
```

Then (re)distill `expert_knowledge/{name}_kb.md` from the corpus (the 7 committed KBs were built this
way). Add a new coach with `distill_anyone.md`.

## Layout

```
interview-prep-panel/
├── SKILL.md                     # routing + dual-layer fusion protocol
├── README.md
├── distill_anyone.md            # one-prompt distiller for adding coaches
├── update_knowledge.sh          # refresh wrapper
├── expert_knowledge/            # {name}_kb.md persona files (generated)
└── build/
    ├── {name}_urls.txt          # yt-dlp URL lists (done)
    ├── {name}_notebook_id.txt   # saved notebook IDs (after ingest)
    ├── {name}_retrieval.md      # raw DNA retrieval dumps (after ingest)
    └── pipeline.sh              # ingestion pipeline
```
