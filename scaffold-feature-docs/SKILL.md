---
name: scaffold-feature-docs
description: Scaffolds the boilerplate directory structure for a new bug, single-ticket feature, or multi-ticket epic under the ios-care context-docs folder (`/Users/jorgequezada/tools/bash_config/claude/ios-care/`). Asks whether the work is a bug, feature, or epic, proposes the matching file set (CLAUDE.md, progress.md, an about/ticket/bug file, README.md, and optionally PRD.md, architecture.md, screens.md, tickets/), and only creates files after confirmation. Use when about to start work on a new feature/bug/epic that doesn't have a docs folder yet, or when the user asks to scaffold or set up feature docs.
license: MIT
metadata:
  author: Jorge Quezada
  version: "1.0"
---

# Scaffold Feature Docs

Sets up the context-docs directory for a new piece of work under `/Users/jorgequezada/tools/bash_config/claude/ios-care/`. Don't create anything until the classification and file list are confirmed.

## When to suggest this

Proactively suggest this skill — don't just barrel ahead and create a directory — whenever:
- The user starts describing a new bug, feature, or epic that doesn't already have a folder in the context-docs tree, or
- A new directory is about to be created there for a new piece of work.

## Step 1 — Classify the work

Ask which kind of work this is:
- **Bug** — a single defect to investigate/fix
- **Feature** — a single ticket
- **Epic** — a group of related tickets

## Step 2 — Propose the file set

Always include these, regardless of classification:

| File | Purpose |
|---|---|
| `CLAUDE.md` | Folder-scoped instructions/context specific to this work — *how* to work, not *what* the feature is |
| `progress.md` | Status dashboard — what's done, what's next, decisions, open questions |
| `<ticket#>.md` / `bug.md` / `about.md` | Describes what the work is about — the ticket key if there is one (e.g. `PEXP-2799.md`), `bug.md` for a bug report, or `about.md` as a generic fallback |
| `README.md` | Explains how this folder's docs are organized and how to navigate them |

Propose these conditionally, based on classification and what the work actually needs:

| File | Include when |
|---|---|
| `PRD.md` | Almost always for an **epic**; for a single **feature**/**bug** only when product has written requirements beyond the Jira description that need to be preserved — don't create by default for those |
| `architecture.md` | Only when the work introduces real architectural complexity (new module boundary, new data layer, cross-cutting pattern) — most bugs and small features don't need it |
| `screens.md` | Only if the work involves building new screens |
| `tickets/` | Epics only — one file per ticket, seeded from `_TEMPLATE.md` |

Propose files beyond this list when the work genuinely calls for it (e.g. `existing-code.md` when documenting current behavior before a rewrite, an `analytics/` sub-effort) — don't force every folder into exactly this template.

## Step 3 — Confirm location

Ask for (or infer from conversation) the path under the context-docs root, following the existing `<app>/<feature-area>/<feature>/` convention (e.g. `provider/notifications/customPrompt/`). Confirm the full path before creating anything.

## Step 4 — Create files

Once confirmed, create the directory and populate each file with a real skeleton — pull in whatever framing already exists in the conversation (ticket key, epic key, links, Figma, current scope) rather than leaving placeholder titles. For structure/tone reference, read (don't copy verbatim) an existing scaffolded feature such as:

- `/Users/jorgequezada/tools/bash_config/claude/ios-care/provider/premium-pro-benefits/CLAUDE.md`
- `/Users/jorgequezada/tools/bash_config/claude/ios-care/provider/premium-pro-benefits/README.md`
- `/Users/jorgequezada/tools/bash_config/claude/ios-care/provider/premium-pro-benefits/progress.md`
- `/Users/jorgequezada/tools/bash_config/claude/ios-care/provider/premium-pro-benefits/tickets/_TEMPLATE.md`

Skeleton guidance per file:
- **`README.md`** — one-line feature description, ticket/epic links + app + status line, a "Structure" table (file → purpose → when to load) matching whatever files actually exist in this folder, a short "Where things go" section to avoid duplicating the same fact across files.
- **`progress.md`** — a status line at the top (most recent state first), then a ticket/task table or checklist. This is the file to load first when resuming work.
- **`CLAUDE.md`** — only *how to work* (scheme to use, which skills to load, conventions specific to this feature) — not feature facts, which belong in the about/PRD/architecture file.
- **`<ticket#>.md` / `bug.md` / `about.md`** — what the work is, links (Jira, Figma), current scope, open questions.
- **`tickets/_TEMPLATE.md`** (epics only) — Scope / Implementation / Tests / Follow-ups / Links sections, mirroring the reference template above.

## Step 5 — No extra wiring needed

`/Users/jorgequezada/tools/bash_config/claude/ios-care/CLAUDE.md`'s "Context Files" section already tells future sessions to look for `README.md`/`overview.md` first — once `README.md` exists in the new folder, it'll be picked up automatically.
