---
description: Ingest a file into LLM Wiki
---
Add the slash command arguments into LLM Wiki.

Always load and follow these AgentSkills first:
- `managing-llm-wiki`
- `obsidian-cli`
- `obsidian-markdown`

Target LLM Wiki:
- `@/home/okw/ghq/github.com/okw0204/Obsidian/LLM Wiki/wiki/`
- `@/home/okw/ghq/github.com/okw0204/Obsidian/LLM Wiki/raw/`

Behavior:
- If slash command arguments include a file path, treat it as `ingest <path>` and ingest it into LLM Wiki following `managing-llm-wiki`.
- If no file path is given, inspect `@/home/okw/ghq/github.com/okw0204/Obsidian/LLM Wiki/raw/` and identify source files that do not seem to have been added into the wiki yet.
- In the no-argument case, show the candidate files to the user and ask for confirmation before making any changes.
- If the user confirms, ingest all listed candidates in one pass using the same LLM Wiki workflow.

Requirements:
- Keep `raw/` immutable. If the source is outside `raw/`, copy it into `raw/` first.
- Write or update durable notes in `wiki/`, and update `index.md` and `log.md` when appropriate.
- Keep wiki prose in Japanese and prefer Obsidian `[[wikilink]]` links.
- Keep the operation small and reversible. Do not redesign unrelated wiki pages.

When you finish, report:
1. `Copied to raw`
2. `Updated wiki`
3. `Index/log`
4. `Next useful step`
