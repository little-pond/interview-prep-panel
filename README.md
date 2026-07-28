# interview-prep-panel

[![PyPI](https://img.shields.io/pypi/v/interview-prep-panel)](https://pypi.org/project/interview-prep-panel/)
[![Claude Code skill](https://img.shields.io/badge/Claude%20Code-skill-8A63D2)](https://claude.com/claude-code)
[![Coaches](https://img.shields.io/badge/coaches-7-2ea44f)](#the-panel)
[![Corpus](https://img.shields.io/badge/corpus-4.4M%20words-1f6feb)](#how-it-works--dual-layer-architecture)
[![Install](https://img.shields.io/badge/install-curl%20%7C%20pip%20%7C%20git-000000)](#install--setup)
[![Python](https://img.shields.io/badge/python-3.8%2B-3776AB?logo=python&logoColor=white)](pyproject.toml)
[![License: MIT](https://img.shields.io/badge/license-MIT-green)](LICENSE)

A routable **7-coach interview-prep expert panel** for [Claude Code](https://claude.com/claude-code).
Each coach is a **digital twin** distilled from their own YouTube channel — you ask an interview
question, the panel routes it to the right coach(es) and answers in their voice, using their real
frameworks and verbatim phrasing.

> Built as a study in **distilling creators into routable digital twins** with a fully-local,
> no-auth **dual-layer** architecture (retrieval corpus + persona KB).

---

## Contents
- [What it is](#what-it-is)
- [The panel](#the-panel)
- [How it works — dual-layer architecture](#how-it-works--dual-layer-architecture)
- [Install & setup](#install--setup)
- [Using it](#using-it)
- [Routing reference](#routing-reference)
- [Building / refreshing the corpus](#building--refreshing-the-corpus)
- [Adding a coach](#adding-a-coach)
- [Repo layout](#repo-layout)
- [How it was built](#how-it-was-built)
- [Notes & troubleshooting](#notes--troubleshooting)
- [Credits](#credits)

---

## What it is

An expert panel you talk to like a coach. Ask *"how do I answer 'tell me about yourself' for a
marketing role?"* and Madeline Mann's twin answers with her actual 3-part "theme song" structure.
Ask *"prep me for a PMM interview in two weeks"* and Exponent + Product Alliance + Jeff Su convene a
roundtable and hand you a plan. It can also **run live mock interviews** and **grade your answers**.

**Who it's for:** anyone prepping for a job interview — behavioral, salary negotiation, or tech
PM/PMM/SWE rounds.

## The panel

| Coach | Tag | Domain | Channel |
|---|---|---|---|
| **Madeline Mann** | `MANN` | All-round interview Q&A, salary negotiation, job search | [@SelfMadeMillennial](https://www.youtube.com/@SelfMadeMillennial) |
| **Bryan Creely** | `CREELY` | Recruiter POV, red flags, decoding rejection, negotiation | [@ALifeAfterLayoff](https://www.youtube.com/@ALifeAfterLayoff) |
| **Richard McMunn** | `MCMUNN` | STAR/behavioral model answers, story bank | [@CareerVidz](https://www.youtube.com/@CareerVidz) |
| **Andrew LaCivita** | `LACIVITA` | Storytelling frameworks, exec interviews, strategic framing | [@andylacivita](https://www.youtube.com/@andylacivita) |
| **Jeff Su** | `SU` | Concise tactical career/interview/resume, big-tech marketing | [@JeffSu](https://www.youtube.com/@JeffSu) |
| **Exponent** | `EXPONENT` | Tech interviews — PM, PMM, SWE — mock interviews | [@tryexponent](https://www.youtube.com/@tryexponent) |
| **Product Alliance** | `PRODUCTALLIANCE` | PM/PMM interviews at top tech companies | [@ProductAlliance](https://www.youtube.com/@ProductAlliance) |

## How it works — dual-layer architecture

Fully local. No login, no external service.

- **Layer 1 — Transcript corpus (retrieval).** Up to 300 real videos per coach, one clean
  transcript per file under `build/transcripts/{name}/`, `grep`-searchable. This is *what the coach
  actually said*. **Not committed to this repo** (it's ~940 MB of creators' captions) — you
  regenerate it locally (see [below](#building--refreshing-the-corpus)).
- **Layer 2 — Expert KB (persona).** `expert_knowledge/{name}_kb.md` — each coach's distilled
  frameworks, terminology, signature phrases (verbatim), and anti-patterns. **These ship in the
  repo.**

**Fusion:** the panel greps the corpus for the substance, then delivers it using the coach's
frameworks and voice from the KB.

> Works **KB-only out of the box** — the 7 KBs are committed and rich, so the panel is useful the
> moment you install it. Building the corpus (Layer 1) adds live quote-level retrieval.

## Install & setup

**Requirements:** `git` (curl method) **or** Python 3.8+ (pip method); optional `yt-dlp` only if you build the transcript corpus. macOS/Linux.

### Option 1 · curl one-liner

Clones into `~/.claude/skills/` and is ready to use:

```bash
curl -fsSL https://raw.githubusercontent.com/little-pond/interview-prep-panel/main/install.sh | bash
```

Re-running it later **updates** the skill. Options:

```bash
# Install to a custom location
curl -fsSL .../install.sh | SKILLS_DIR=~/my-skills bash

# Also build the ~940MB transcript corpus during install (needs yt-dlp)
curl -fsSL .../install.sh | BUILD_CORPUS=1 bash
```

### Option 2 · pip

Installs a small CLI (Python 3.8+) that fetches the skill into your skills dir:

```bash
pip install git+https://github.com/little-pond/interview-prep-panel
interview-prep-panel install                 # → ~/.claude/skills/interview-prep-panel
interview-prep-panel install --build-corpus  # also pull the corpus (needs yt-dlp)
```

Re-run `interview-prep-panel install` anytime to update. `interview-prep-panel path` prints where it lives.

### Option 3 · manual

<details><summary>git clone</summary>

```bash
git clone https://github.com/little-pond/interview-prep-panel \
  ~/.claude/skills/interview-prep-panel
```
</details>

Then, in Claude Code, just **ask an interview question** — the skill auto-triggers on interview
intent. It works **KB-only out of the box**; build the corpus (below) for live quote-level retrieval.

## Using it

See **[PROMPTS.md](./PROMPTS.md)** for a full copy-paste prompt library. The essentials:

- **Auto-route (default):** just ask. `How do I answer "what's your greatest weakness"?`
- **Single coach:** name them. `Ask Bryan Creely why I keep getting ghosted.`
- **Roundtable:** ask something broad. `I have a PMM interview in two weeks — full prep plan.`
- **Mock interview:** `Run a live mock for a PMM role — you interview me and grade me at the end.`
- **Critique your drafts:** `Grade this answer: [paste]` / `Turn these into one CARL story: [paste].`

You get the best results when you give your **role, company, the job description, and your real
projects/numbers**. The coaches critique and rewrite what you bring; they don't invent your metrics.

## Routing reference

The panel understands intent, not just keywords. Rough map:

| If you want… | You'll hear from |
|---|---|
| General Q&A, salary, "tell me about yourself" | Mann |
| Why you got rejected / recruiter reality | Creely |
| A word-for-word model answer | McMunn |
| Exec/leadership, strategic framing | LaCivita |
| Crisp frameworks, resume, AI-assisted prep | Su |
| PM/PMM/SWE case & mock | Exponent |
| Company-specific PM/PMM loops | Product Alliance |

Multi-intent questions convene a **roundtable** (max 4 coaches) with a synthesis at the end. Full
routing table is in [`SKILL.md`](./SKILL.md).

## Building / refreshing the corpus

The corpus is git-ignored; regenerate or update it locally:

```bash
bash build/pull_transcripts.sh        # pull all coaches (~300 videos each)
bash update_knowledge.sh jeff_su      # re-grab URLs + re-pull ONE coach
```

To re-distill a coach's KB after refreshing, feed their corpus back through the distillation prompt
(the 7 committed KBs were each built from a stratified ~95k-word sample of the coach's channel).

## Adding a coach

Use [`distill_anyone.md`](./distill_anyone.md) — change 3 variables (name, channel URL, domain),
run the pipeline, generate the KB, then add the coach to the panel + routing tables in `SKILL.md`.

## Repo layout

```
interview-prep-panel/
├── SKILL.md              # the skill: routing + dual-layer fusion protocol
├── README.md            # this guide
├── PROMPTS.md           # copy-paste prompt library
├── distill_anyone.md    # one-prompt distiller for adding coaches
├── update_knowledge.sh  # refresh wrapper
├── expert_knowledge/    # the 7 Persona Protocol KBs  ✅ committed
└── build/
    ├── *_urls.txt          # yt-dlp URL lists (committed)
    ├── pull_transcripts.sh # corpus builder (Layer 1)
    ├── pipeline.sh         # legacy NotebookLM path (unused — see notes)
    ├── transcripts/        # Layer 1 corpus        🚫 git-ignored (~940MB)
    └── subs/ · samples/    # raw + sampled captions 🚫 git-ignored
```

## How it was built

1. **`yt-dlp`** grabs up to 300 video URLs per channel.
2. **`build/pull_transcripts.sh`** downloads EN captions (json3) and parses them into one clean
   transcript per video — a local, grep-able corpus (~4.4M words total).
3. A **stratified ~95k-word sample** spanning each full channel is distilled (by an LLM, in parallel
   across all 7 coaches) into a **Persona Protocol KB** — frameworks, verbatim signature phrases,
   and anti-patterns — grounded strictly in the transcripts.
4. `SKILL.md` wires the coaches into a router with single-expert and roundtable logic.

## Notes & troubleshooting

- **KB-only vs. full:** the panel works immediately on the committed KBs. Build the corpus for
  live, quote-level retrieval.
- **NotebookLM (unused):** the original design targeted NotebookLM for Layer 1, but its CLI's
  non-browser cookie replay is blocked by Google (a valid fresh login still bounces to sign-in), so
  Layer 1 was moved to a local grep corpus. `build/pipeline.sh` is retained but unused.
- **`yt-dlp` errors / missing captions:** some videos (Shorts, music) have no EN captions; the
  puller skips them with `--ignore-errors`. Update yt-dlp if extraction breaks
  (`brew upgrade yt-dlp`).

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
