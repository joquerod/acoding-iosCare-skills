---
name: create-skill
description: Creates a new Claude skill in the shared acoding-iosCare-skills repo and symlinks it into all ios-care-app* worktrees. Use when the user asks to create a skill, add a new slash command, or extend Claude with project-specific knowledge.
license: MIT
metadata:
  author: Jorge Quezada
  version: "1.0"
---

# Create a New Claude Skill

When the user asks to create a new skill, follow these steps:

## 1. Create the skill directory and SKILL.md

Create a new directory with a `SKILL.md` file in the shared skills repo:
```
/Users/jorgequezada/tools/acoding-iosCare-skills/<skill-name>/SKILL.md
```

If the skill needs supporting files (templates, examples, checklists), add them in the same directory:
```
/Users/jorgequezada/tools/acoding-iosCare-skills/<skill-name>/
├── SKILL.md              # Main prompt (must include YAML frontmatter with name + description)
├── checklist.md          # Optional supporting files
└── examples/             # Optional examples
```

The skill name must be lowercase letters, numbers, and hyphens only — and must match the directory name.

## 2. Symlink to all repos

Find all repos with the `ios-care-app` prefix and symlink the **skill directory** into each one:

```bash
for repo in /Users/jorgequezada/Development/care/ios-care-app*; do
  mkdir -p "$repo/.claude/skills"
  ln -sfn /Users/jorgequezada/tools/acoding-iosCare-skills/<skill-name> "$repo/.claude/skills/<skill-name>"
done
```

Note: Use `ln -sfn` (not `ln -sf`) to properly symlink directories.

## 3. Verify

List the symlinks created to confirm they point to the shared location:
```bash
ls -la /Users/jorgequezada/Development/care/ios-care-app*/.claude/skills/<skill-name>
```

## Important Notes

- **Shared location**: `/Users/jorgequezada/tools/acoding-iosCare-skills/` (the `joquerod/acoding-iosCare-skills` repo) — version-controlled.
- **Never** create skills directly in a repo's `.claude/skills/` directory. Always create in the shared location and symlink.
- If a repo doesn't have a `.claude/skills/` directory yet, create it before adding the symlink.
- Skills are invoked with `/<skill-name>` (e.g., `/review-pr`).
