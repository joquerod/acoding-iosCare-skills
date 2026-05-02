# acoding-iosCare-skills

A collection of [Agent Skills](https://agentskills.io) for Care.com iOS development. Each skill is a self-contained directory with a `SKILL.md` that follows the [agentskills.io specification](https://agentskills.io/specification), so they work with Claude Code, Codex, Cursor, and any other agent that supports the format.

## Available skills

| Skill | Slash command | Purpose |
|---|---|---|
| [add-feature-flag](add-feature-flag/) | `/add-feature-flag` | Add a LaunchDarkly feature flag |
| [add-graphql-api](add-graphql-api/) | `/add-graphql-api` | Add a GraphQL query/mutation + Swift service method |
| [architecture](architecture/) | `/architecture` | Reference for the Care iOS module architecture |
| [automate-app-enrollment](automate-app-enrollment/) | `/automate-app-enrollment` | Automate Caregiver enrollment on the simulator |
| [build-and-run](build-and-run/) | `/build-and-run` | Build with Xcode MCP, check warnings, launch on simulator |
| [create-skill](create-skill/) | `/create-skill` | Create a new skill in this repo + symlink it |
| [debug-logs](debug-logs/) | `/debug-logs` | Add/evaluate temporary `<<>>` debug logs |
| [delete-skill](delete-skill/) | `/delete-skill` | Remove a skill from this repo + all symlinks |
| [mermaid](mermaid/) | `/mermaid` | Mermaid diagram styling reference |
| [review-pr](review-pr/) | `/review-pr` | Review a PR with structured feedback |
| [submit-pr](submit-pr/) | `/submit-pr` | Create a PR following Care iOS standards |
| [swiftui](swiftui/) | `/swiftui` | SwiftUI review checklist + Hoopla components |
| [testing](testing/) | `/testing` | Deterministic unit-testing workflow |
| [update-apollo-schema](update-apollo-schema/) | `/update-apollo-schema` | Update Apollo schema + regenerate Swift |
| [update-pr-notes](update-pr-notes/) | `/update-pr-notes` | Refresh PR description from latest commits |
| [xcode-session](xcode-session/) | `/xcode-session` | Set up isolated Xcode + MCP for a worktree |
| [xcode-session-delete](xcode-session-delete/) | `/xcode-session-delete` | Remove the Xcode MCP config for a worktree |

Stubs (not yet written): `pull`, `push`.

## Installing into a Care iOS worktree

Skills are loaded by symlinking each one into the project's `.claude/skills/` directory. Run this from the worktree root:

```bash
SKILLS_REPO=/Users/jorgequezada/tools/acoding-iosCare-skills
mkdir -p .claude/skills
for skill in "$SKILLS_REPO"/*/; do
  name=$(basename "$skill")
  ln -sfn "$skill" ".claude/skills/$name"
done
```

This makes every skill in this repo available as `/<skill-name>` inside Claude Code in that worktree.

## Adding a new skill

Use the `/create-skill` slash command, or manually:

1. Create `<skill-name>/SKILL.md` in this repo.
2. Add YAML frontmatter at the top:
   ```yaml
   ---
   name: skill-name
   description: One or two sentences on what this does and when to use it. Include trigger keywords agents would naturally hear.
   license: MIT
   metadata:
     author: Jorge Quezada
     version: "1.0"
   ---
   ```
3. Write the skill instructions as Markdown below the frontmatter.
4. Symlink into each `ios-care-app*` worktree (the snippet above does the whole repo at once).

The skill name must be lowercase letters, numbers, and hyphens only — and must match the directory name.

## License

MIT.
