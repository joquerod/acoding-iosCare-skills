# acoding-iosCare-skills

A collection of [Agent Skills](https://agentskills.io) for Care.com iOS development. Each skill is a self-contained directory with a `SKILL.md` that follows the [agentskills.io specification](https://agentskills.io/specification), so they work with Claude Code, Codex, Cursor, and any other agent that supports the format.

## Available skills

| Skill | Slash command | Purpose |
|---|---|---|
| [add-feature-flag](add-feature-flag/) | `/add-feature-flag` | Add a LaunchDarkly feature flag |
| [add-graphql-api](add-graphql-api/) | `/add-graphql-api` | Add a GraphQL query/mutation + Swift service method |
| [architecture](architecture/) | `/architecture` | Reference for the Care iOS module architecture |
| [build-and-run](build-and-run/) | `/build-and-run` | Build with Xcode MCP, check warnings, launch on simulator |
| [care-swiftui](care-swiftui/) | `/care-swiftui` | Hoopla component catalog + Care-specific SwiftUI conventions |
| [debug-logs](debug-logs/) | `/debug-logs` | Add/evaluate temporary `<<>>` debug logs |
| [mermaid](mermaid/) | `/mermaid` | Mermaid diagram styling reference |
| [review-pr](review-pr/) | `/review-pr` | Review a PR with structured feedback |
| [submit-pr](submit-pr/) | `/submit-pr` | Create a PR following Care iOS standards |
| [testing](testing/) | `/testing` | Deterministic unit-testing workflow |
| [update-apollo-schema](update-apollo-schema/) | `/update-apollo-schema` | Update Apollo schema + regenerate Swift |
| [update-pr-notes](update-pr-notes/) | `/update-pr-notes` | Refresh PR description from latest commits |
| [xcode-session](xcode-session/) | `/xcode-session` | Set up isolated Xcode + MCP for a worktree |
| [xcode-session-delete](xcode-session-delete/) | `/xcode-session-delete` | Remove the Xcode MCP config for a worktree |

## Installing

### Bulk install (all skills at once)

The fastest way — clones the repo into a temp dir and copies every skill folder into `.claude/skills/` of the current project:

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/joquerod/acoding-iosCare-skills/main/install.sh)
```

For a global install (`~/.claude/skills/`, available across all projects):

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/joquerod/acoding-iosCare-skills/main/install.sh) global
```

The script prints each installed skill and exits. Claude Code's live detection picks them up without restart.

### Single-skill install (via `npx skills add`)

If you only want one skill, use the [agentskills.io](https://agentskills.io) CLI:

```bash
npx skills add https://github.com/joquerod/acoding-iosCare-skills --skill <skill-name>
```

Examples:

```bash
npx skills add https://github.com/joquerod/acoding-iosCare-skills --skill care-swiftui
npx skills add https://github.com/joquerod/acoding-iosCare-skills --skill submit-pr
npx skills add https://github.com/joquerod/acoding-iosCare-skills --skill build-and-run
```

When prompted, choose:

- **Agent**: Claude Code (or any other agentskills.io-compatible tool)
- **Scope**: project (recommended for these iOS-Care skills) or global

To update a skill later, re-run the same command.

## Adding a new skill

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
4. Commit + push. Re-run the bulk-install script (or `npx skills add ...` for a single skill) to pick up changes in any project that uses it.

The skill name must be lowercase letters, numbers, and hyphens only — and must match the directory name.

## License

MIT.
