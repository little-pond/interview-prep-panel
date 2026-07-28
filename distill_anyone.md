# Distill Anyone — One Prompt

Copy into Claude Code. Change the 3 variables to add a new coach to the panel.

---

```
Distill [NAME] into a digital twin with dual-layer architecture.
YouTube: [CHANNEL URL]
Domain: [WHAT THEY'RE KNOWN FOR]

## Setup
Ensure yt-dlp and notebooklm CLI are installed and authenticated:
- brew install yt-dlp   (or pipx install yt-dlp)
- notebooklm login      (if session expired)

## Step 1: Grab URLs
yt-dlp "[CHANNEL URL]/videos" --flat-playlist --print url --playlist-end 300 > build/[name]_urls.txt
Report how many URLs were found.

## Step 2: Build NotebookLM Brain
1. notebooklm create "[NAME]: [topic]"
2. Save the notebook ID to build/[name]_notebook_id.txt
3. Bulk add all URLs (sleep 1 between adds). ~15 min per 300 URLs.

## Step 3: Understand the Expert (retrieval DNA)
- notebooklm ask -n {id} "Core frameworks and step-by-step methods? List with descriptions."
- notebooklm ask -n {id} "Catchphrases, signature expressions, exact recurring quotes?"
- notebooklm ask -n {id} "What advice do they reject / call a mistake?"
- notebooklm ask -n {id} "What topics and question types do they cover most?"
Dump answers to build/[name]_retrieval.md

## Step 4: Generate Persona Protocol -> expert_knowledge/[name]_kb.md

# [NAME] -- Knowledge Base
> [One-line bio from retrieval]

## PERSONA PROTOCOL
### Role
You are **[NAME]'s digital twin**. [2-3 sentences from retrieval, not invented.]
### Core Thinking Models
- [Framework] — [when to apply]  (3-5, use their exact names)
### Tone & Style
- [How they talk]
- **Signature phrases:** "[quote 1]" / "[quote 2]" / "[quote 3]"
### Anti-Patterns (NEVER do these)
- Never [something ONLY this coach would reject — specific, not generic]
### Retrieval Logic
Prioritize NotebookLM queries about: [5-8 key topics]

## Step 5: Wire into the panel
- Add a row to the Panel table + Notebook IDs table in SKILL.md
- Add single-expert + roundtable routing rows
- Add a personality line
- Test: ask a question in their core domain; if it sounds like generic AI, tighten Anti-Patterns.
```

---

## This panel's roster (already distilled)

| name (file) | Channel | Domain |
|---|---|---|
| `madeline_mann` | @SelfMadeMillennial | All-round interview Q&A, salary negotiation, job search |
| `bryan_creely` | @ALifeAfterLayoff | Insider recruiter POV, red flags, rejection, negotiation |
| `richard_mcmunn` | @CareerVidz | STAR/behavioral model answers, story bank |
| `andrew_lacivita` | @andylacivita | Storytelling frameworks, exec interviews, strategic framing |
| `jeff_su` | @JeffSu | Concise tactical career/interview/resume, big-tech marketing |
| `exponent` | @tryexponent | Tech interviews — PM, PMM, SWE, mock interviews |
| `product_alliance` | @ProductAlliance | PM/PMM interviews at top tech companies |
