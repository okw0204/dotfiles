---
name: managing-llm-wiki
description: Manages the user's Obsidian-based LLM Wiki. Use this skill whenever the user mentions `LLM Wiki`, wants to ingest or import source material into `LLM Wiki/raw/`, passes a URL or web page to be incorporated as source, wants to update or reorganize synthesized notes in `LLM Wiki/wiki/`, wants to refresh `LLM Wiki/index.md` or `LLM Wiki/log.md`, wants to ask questions grounded in that wiki, or wants a lint/health-check of the wiki. Use it even when the user does not explicitly say `ingest`, `query`, or `lint`, as long as the request is clearly about operating this LLM Wiki while preserving the raw/wiki boundary, Japanese writing style, frontmatter tag rules, and `[[wikilink]]` conventions.
argument-hint: [ingest <path> | query <question> | lint <scope>]
---

# Managing LLM Wiki

This skill operates the user's Obsidian-based LLM Wiki in small, safe steps. It keeps immutable source material in `raw/`, writes durable knowledge into `wiki/`, and avoids pulling unrelated vault content into the workflow unless the user explicitly asks.

## Managed Scope

- Vault root: `/home/okw/ghq/github.com/okw0204/Obsidian`
- LLM Wiki root: `/home/okw/ghq/github.com/okw0204/Obsidian/LLM Wiki`
- Immutable source area: `LLM Wiki/raw/`
- Writable knowledge area: `LLM Wiki/wiki/`, `LLM Wiki/index.md`, `LLM Wiki/log.md`

Treat these rules as the boundary of the skill:

- Do not ingest `Knowledge/`, `Ideas/`, `Inbox/`, or other existing note areas unless the user explicitly names them as source and wants them copied into `LLM Wiki/raw/` first.
- Do not edit files under `LLM Wiki/raw/` after they become source material.
- Prefer Japanese in wiki prose.
- Prefer Obsidian `[[wikilink]]` links for internal references.
- Match nearby frontmatter style. In this wiki, default to a minimal frontmatter with `tags` unless the surrounding files establish a stronger local pattern.
- Keep changes small and reversible. If one focused note update is enough, do not redesign the whole wiki.

## First Step: Parse The Request

Prefer mapping the request into one of these three entry points:

- `ingest <path>`
- `query <question>`
- `lint <scope>`

If the user already uses one of these forms, keep it.

If the user writes natural language instead, infer the mode from intent:

- Requests to add, import, copy, summarize, incorporate, or turn a file/article/note/PDF/web source into the wiki map to `ingest`
- Requests to answer, explain, compare, summarize what the wiki says, or search existing LLM Wiki knowledge map to `query`
- Requests to health-check, audit, lint, clean up, find contradictions, find stale pages, find orphans, or assess wiki maintenance gaps map to `lint`

Only stop and ask when the intent is genuinely ambiguous. Do not force the user to learn the `ingest` or `query` vocabulary before this skill becomes usable.

## Workflow: `ingest <path>`

Use this flow when the user wants to add new source material into the LLM Wiki.

1. Resolve the path and confirm it exists.
2. Decide whether the source is already inside `LLM Wiki/raw/`.
3. If the source is outside `raw/`, copy it into `LLM Wiki/raw/` without mutating the original.
4. Read the source and identify the minimum durable knowledge worth capturing now.
5. Create or update one or more notes in `LLM Wiki/wiki/`, including relevant entity or concept pages when the new source clearly changes the existing synthesis.
6. Update `LLM Wiki/index.md` if a new durable entry point or link should appear there.
7. Append an operation record to `LLM Wiki/log.md` with an absolute timestamp in `YYYY-MM-DD HH:MM:SS` format.
8. Report what was copied, what wiki pages changed, and what was intentionally left for later.

### Ingest Guardrails

- Preserve the original source. `raw/` is an immutable store, not a scratchpad.
- If the input is an existing vault note outside `LLM Wiki/`, copy it into `raw/` first instead of treating the original note as live source.
- If the input is a URL, keep the URL in the raw note or metadata and prefer storing a local immutable copy such as cleaned Markdown, exported text, or the downloaded file.
- Start small. One source can become one concise source-summary or concept page; do not invent a heavy taxonomy on the first pass.
- Prefer updating an existing wiki page when the new source clearly extends it. Create a new page when merging would make the old page muddy.
- When naming a new note, choose a stable Japanese title that will still make sense as a wikilink later.

### Ingest Output Shape

Unless the user asks for something else, finish with:

1. `Copied to raw`: source path and destination path
2. `Updated wiki`: changed note paths
3. `Index/log`: whether `index.md` and `log.md` changed
4. `Next useful step`: optional follow-up such as another `ingest` or a focused `query`

## Workflow: `query <question>`

Use this flow when the user wants an answer grounded in the current LLM Wiki.

1. Search `LLM Wiki/wiki/`, `LLM Wiki/index.md`, and, if needed, relevant files in `LLM Wiki/raw/`.
2. Prefer synthesized wiki pages over raw sources when both exist.
3. Answer in Japanese with concise references to the most relevant note paths.
4. If the question reveals a durable gap in the wiki and the evidence is already available, make a small targeted update in `LLM Wiki/wiki/` and log it.
5. If the answer would require new source material, say so plainly instead of pretending the wiki already knows.

### Query Guardrails

- Default to read-first behavior. Do not create broad new note trees just because a question was asked.
- Good answers can compound: a comparison, analysis, or newly discovered connection may be filed back into the wiki when it would clearly improve future retrieval.
- Only write during `query` when the new note or edit would clearly improve future retrieval, not just this one reply.
- Keep answers grounded in the managed scope. Do not silently mix in unrelated vault knowledge.
- When citing internal knowledge, prefer clickable note paths or note names that map cleanly to `[[wikilink]]` targets.

### Query Output Shape

Unless the user asks for a different format, respond with:

1. A short Japanese answer
2. `Relevant notes`: the most useful note paths
3. `Wiki updates`: `none` or the files updated during the query
4. `Gap`: missing source or uncertainty, if any

## Workflow: `lint <scope>`

Use this flow when the user wants a health-check of the LLM Wiki rather than a new source ingest or a grounded answer.

`lint` is the maintenance pass described by the LLM Wiki pattern: periodically ask the LLM to inspect the wiki as a persistent, compounding artifact and identify where its structure or synthesis is weakening.

A lint pass looks for:

- Contradictions between pages.
- Stale claims that newer sources have superseded.
- Orphan pages with no useful inbound or outbound links.
- Important concepts mentioned across the wiki but lacking their own page.
- Missing cross-references between related pages.
- Data gaps that could be filled by a new source or focused web search.
- New questions worth investigating next.

Keep `lint` scoped and lightweight unless the user asks for a broader maintenance pass. If lint findings produce persistent wiki changes, record them in `LLM Wiki/log.md` like other operations.

## Note Writing Conventions

When creating or updating wiki notes:

- Follow the local spacing style: use half-width spaces between Japanese and alphanumeric text where needed, and use `、。` for punctuation.
- Use frontmatter tags as the canonical tag source.
- Keep frontmatter minimal unless the local file set clearly uses more fields.
- Use headings that make the page scannable.
- Add `[[wikilink]]` references to adjacent concepts instead of duplicating the same explanation in multiple notes.
- Prefer synthesis over raw extraction. A wiki page should explain why the source matters, not merely copy it.

A safe default for a new wiki note is:

```yaml
---
tags:
  - AI
---
```

## Decision Rules

- If a task mainly changes Markdown content, edit files directly and keep them valid for Obsidian.
- If a task is just about locating information, search before reading whole files.
- If an `ingest` request points at a directory, process only the clearly relevant files and say what was skipped.
- If the source is noisy or too large, first create a compact summary page, then leave deeper restructuring for a later pass.
- If the user asks for a broader redesign, do that in a separate step after the minimal ingest/query work is complete.

## Completion Checklist

Before finishing, verify:

- The operation stayed inside the allowed write targets.
- `raw/` sources were not edited in place.
- New or updated notes use sensible Japanese titles and `[[wikilink]]`-friendly naming.
- `LLM Wiki/log.md` records any persistent ingest/query-side change.
- The final response tells the user exactly what changed.
