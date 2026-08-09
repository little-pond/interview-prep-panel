# interview-prep-panel

[![PyPI](https://img.shields.io/pypi/v/interview-prep-panel)](https://pypi.org/project/interview-prep-panel/)
[![Claude Code skill](https://img.shields.io/badge/Claude%20Code-skill-8A63D2)](https://claude.com/claude-code)
[![Coaches](https://img.shields.io/badge/coaches-7-2ea44f)](#the-panel)
[![Sources](https://img.shields.io/badge/NotebookLM%20sources-1580-1f6feb)](#how-it-works--dual-layer-architecture)
[![Install](https://img.shields.io/badge/install-curl%20%7C%20pip%20%7C%20git-000000)](#install--setup)
[![Python](https://img.shields.io/badge/python-3.8%2B-3776AB?logo=python&logoColor=white)](pyproject.toml)
[![License: MIT](https://img.shields.io/badge/license-MIT-green)](LICENSE)

A routable **7-coach interview-prep expert panel** for [Claude Code](https://claude.com/claude-code).
Each coach is a **digital twin** distilled from their own YouTube channel via NotebookLM — you ask
an interview question, the panel routes it to the right coach(es) and answers in their voice, using
their real frameworks and verbatim phrasing.

> Built as a study in **distilling creators into routable digital twins** using a
> NotebookLM-powered dual-layer architecture (NotebookLM retrieval + local persona KB).

---

## Contents
- [What it is](#what-it-is)
- [The panel](#the-panel)
- [How it works — dual-layer architecture](#how-it-works--dual-layer-architecture)
- [Install & setup](#install--setup)
- [Using it](#using-it)
- [Routing reference](#routing-reference)
- [Upgrading / refreshing the KB](#upgrading--refreshing-the-kb)
- [Adding a coach](#adding-a-coach)
- [Repo layout](#repo-layout)
- [How it was built](#how-it-was-built)
- [Credits](#credits)

---

## What it is

An expert panel you talk to like a coach. Ask *"how do I answer 'tell me about yourself' for a
marketing role?"* and Madeline Mann's twin answers with her actual 3-part "theme song" structure.
Ask *"prep me for a PMM interview in two weeks"* and Exponent + Product Alliance + Jeff Su convene a
roundtable and hand you a plan. It can also **run live mock interviews** and **grade your answers**.

**One hard rule across the whole panel:** every story answer uses **PAR format** (Problem → Action →
Result). STAR is banned — PAR keeps answers tight and interviewer-focused.

**Who it's for:** anyone prepping for a job interview — behavioral, salary negotiation, or tech
PM/PMM/SWE rounds.

## The panel

| Coach | Tag | Domain | Channel |
|---|---|---|---|
| **Madeline Mann** | `MANN` | All-round interview Q&A, salary negotiation, job search | [@SelfMadeMillennial](https://www.youtube.com/@SelfMadeMillennial) |
| **Bryan Creely** | `CREELY` | Recruiter POV, red flags, decoding rejection, negotiation | [@ALifeAfterLayoff](https://www.youtube.com/@ALifeAfterLayoff) |
| **Richard McMunn** | `MCMUNN` | PAR-format model answers, word-for-word scripts, story bank | [@CareerVidz](https://www.youtube.com/@CareerVidz) |
| **Andrew LaCivita** | `LACIVITA` | Storytelling frameworks, exec interviews, strategic framing | [@andylacivita](https://www.youtube.com/@andylacivita) |
| **Jeff Su** | `SU` | Concise tactical career/interview/resume, big-tech marketing | [@JeffSu](https://www.youtube.com/@JeffSu) |
| **Exponent** | `EXPONENT` | Tech interviews — PM, PMM, SWE — mock interviews | [@tryexponent](https://www.youtube.com/@tryexponent) |
| **Product Alliance** | `PRODUCTALLIANCE` | PM/PMM interviews at top tech companies | [@ProductAlliance](https://www.youtube.com/@ProductAlliance) |

## How it works — dual-layer architecture

- **Layer 1 — NotebookLM notebooks (retrieval).** ~1,580 YouTube videos across 7 coaches are
  ingested into Google NotebookLM as sources. `build/pipeline.sh` runs 6 distillation queries
  against each notebook and writes the raw retrieval dumps (`build/*_retrieval.md`). This is the
  source of substance — what the coach actually said, at scale.
- **Layer 2 — Expert KB (persona).** `expert_knowledge/{name}_kb.md` — each coach's distilled
  frameworks, terminology, signature phrases (verbatim), and anti-patterns, generated from the
  NotebookLM retrieval dumps by `build/distill.sh`. **These ship in the repo.**

**Fusion:** the panel answers using the KB's structure and voice, grounded in the substance retrieved
from the NotebookLM notebooks.

> Works **KB-only out of the box** — the 7 KBs are committed and rich, so the panel is useful the
> moment you install it. Run `/upgrade` to re-distill from the live notebooks.

### NotebookLM notebooks (current)

| Coach | Notebook ID | Sources |
|---|---|---|
| Madeline Mann | `6e1aca1e-b423-4989-a490-ee7147e59dc9` | 176 |
| Bryan Creely | `5650534e-c9de-4613-b6c6-c8e20343d2b5` | 289 |
| Richard McMunn | `90d374cf-156f-4257-85be-d360912b0537` | 297 |
| Andrew LaCivita | `91754876-cad9-4b03-a35c-81b9d6353421` | 299 |
| Jeff Su | `c69831d2-4f09-4755-8f53-0616cfe75f03` | 188 |
| Exponent | `ad0bee0d-719f-49b6-8eea-da27b199a1d5` | 298 |
| Product Alliance | `dbfa03e9-27ea-40eb-90ca-1581dfa536ca` | 33 |

## Install & setup

**Requirements:** `git` (curl method) **or** Python 3.8+ (pip method). macOS/Linux.

### Option 1 · curl one-liner

```bash
curl -fsSL https://raw.githubusercontent.com/little-pond/interview-prep-panel/main/install.sh | bash
```

Re-running it later **updates** the skill.

### Option 2 · pip

```bash
pip install git+https://github.com/little-pond/interview-prep-panel
interview-prep-panel install
```

### Option 3 · manual

```bash
git clone https://github.com/little-pond/interview-prep-panel \
  ~/.claude/skills/interview-prep-panel
```

Then in Claude Code, just **ask an interview question** — the skill auto-triggers on interview intent.

## Using it

See **[PROMPTS.md](./PROMPTS.md)** for a full copy-paste prompt library. The essentials:

- **Auto-route (default):** just ask. `How do I answer "what's your greatest weakness"?`
- **Single coach:** name them. `Ask Bryan Creely why I keep getting ghosted.`
- **Roundtable:** ask something broad. `I have a PMM interview in two weeks — full prep plan.`
- **Mock interview:** `Run a live mock for a PMM role — you interview me and grade me at the end.`
- **Critique your drafts:** `Grade this answer: [paste]`
- **Upgrade:** `upgrade panel` or `/upgrade` — re-runs the NotebookLM pipeline and regenerates all 7 KBs.

You get the best results when you give your **role, company, the job description, and your real
projects/numbers**. The coaches critique and rewrite what you bring; they don't invent your metrics.

## Routing reference

| If you want… | You'll hear from |
|---|---|
| General Q&A, salary, "tell me about yourself" | Mann |
| Why you got rejected / recruiter reality | Creely |
| A word-for-word PAR model answer | McMunn |
| Exec/leadership, strategic framing | LaCivita |
| Crisp frameworks, resume, big-tech prep | Su |
| PM/PMM/SWE case & mock | Exponent |
| Company-specific PM/PMM loops | Product Alliance |

Multi-intent questions convene a **roundtable** (max 4 coaches) with a synthesis at the end. Full
routing table is in [`SKILL.md`](./SKILL.md).

## Upgrading / refreshing the KB

Say **`upgrade panel`** or **`/upgrade`** in Claude Code. The skill runs:

```bash
# Step 1 — retry any un-added URLs, re-run 6 distillation queries per notebook
bash build/pipeline.sh

# Step 2 — regenerate all 7 expert_knowledge/*_kb.md from fresh retrieval dumps
bash build/distill.sh
```

**Prerequisites:** the `notebooklm` CLI must be authenticated (`notebooklm list` should succeed).
The pipeline is resumable — already-added URLs are skipped.

To refresh a single coach only:
```bash
bash build/pipeline.sh madeline_mann
bash build/distill.sh madeline_mann
```

## Adding a coach

Use [`distill_anyone.md`](./distill_anyone.md) — change 3 variables (name, channel URL, domain),
run the pipeline, generate the KB, then add the coach to the panel + routing tables in `SKILL.md`.

## Repo layout

```
interview-prep-panel/
├── SKILL.md                  # skill: routing, PAR hard rule, upgrade command
├── README.md                 # this guide
├── PROMPTS.md                # copy-paste prompt library
├── distill_anyone.md         # one-prompt distiller for adding coaches
├── update_knowledge.sh       # refresh wrapper
├── expert_knowledge/         # 7 Persona Protocol KBs  ✅ committed
└── build/
    ├── *_urls.txt            # YouTube URL lists per coach  ✅ committed
    ├── *_notebook_id.txt     # NotebookLM notebook IDs      ✅ committed
    ├── *_retrieval.md        # NotebookLM distillation dumps ✅ committed
    ├── pipeline.sh           # NotebookLM ingest + retrieval queries
    └── distill.sh            # KB regeneration from retrieval dumps
```

## How it was built

1. **`yt-dlp`** grabs up to 300 video URLs per channel into `build/*_urls.txt`.
2. **`build/pipeline.sh`** adds each YouTube URL as a source to a dedicated Google NotebookLM
   notebook, waits for indexing, then runs 6 distillation queries (frameworks, catchphrases,
   disagreements, coverage, prep ritual, tech-specific) and saves the results to `*_retrieval.md`.
3. **`build/distill.sh`** feeds each retrieval dump to Claude and generates a structured
   **Persona Protocol KB** — frameworks, verbatim signature phrases, anti-patterns — saved to
   `expert_knowledge/{name}_kb.md`.
4. **`SKILL.md`** wires the coaches into a router with single-expert and roundtable logic, plus
   the PAR hard rule and `/upgrade` command.

The notebooklm CLI required patching to handle Google's migration from `notebooklm.google.com`
to `notebook.google.com` and to use Playwright (instead of httpx) for authenticated token fetches.

## Credits

Every coach's KB is distilled from their own publicly available YouTube content, for **educational
interview-prep purposes**. All frameworks and quotes belong to their creators — please support them
directly:
[Madeline Mann](https://www.youtube.com/@SelfMadeMillennial) ·
[Bryan Creely](https://www.youtube.com/@ALifeAfterLayoff) ·
[Richard McMunn](https://www.youtube.com/@CareerVidz) ·
[Andrew LaCivita](https://www.youtube.com/@andylacivita) ·
[Jeff Su](https://www.youtube.com/@JeffSu) ·
[Exponent](https://www.youtube.com/@tryexponent) ·
[Product Alliance](https://www.youtube.com/@ProductAlliance)
