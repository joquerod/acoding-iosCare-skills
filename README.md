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
| [create-skill](create-skill/) | `/create-skill` | Create a new skill in this repo |
| [debug-logs](debug-logs/) | `/debug-logs` | Add/evaluate temporary `<<>>` debug logs |
| [delete-skill](delete-skill/) | `/delete-skill` | Remove a skill from this repo |
| [mermaid](mermaid/) | `/mermaid` | Mermaid diagram styling reference |
| [review-pr](review-pr/) | `/review-pr` | Review a PR with structured feedback |
| [submit-pr](submit-pr/) | `/submit-pr` | Create a PR following Care iOS standards |
| [swiftui](swiftui/) | `/swiftui` | SwiftUI review checklist + Hoopla components |
| [testing](testing/) | `/testing` | Deterministic unit-testing workflow |
| [update-apollo-schema](update-apollo-schema/) | `/update-apollo-schema` | Update Apollo schema + regenerate Swift |
| [update-pr-notes](update-pr-notes/) | `/update-pr-notes` | Refresh PR description from latest commits |
| [xcode-session](xcode-session/) | `/xcode-session` | Set up isolated Xcode + MCP for a worktree |
| [xcode-session-delete](xcode-session-delete/) | `/xcode-session-delete` | Remove the Xcode MCP config for a worktree |

## Installing

Use the [agentskills.io](https://agentskills.io) CLI to install individual skills. Run from any project directory (or `~` for a global install):

```bash
npx skills add https://github.com/joquerod/acoding-iosCare-skills --skill <skill-name>
```

Examples:

```bash
npx skills add https://github.com/joquerod/acoding-iosCare-skills --skill swiftui
npx skills add https://github.com/joquerod/acoding-iosCare-skills --skill submit-pr
npx skills add https://github.com/joquerod/acoding-iosCare-skills --skill build-and-run
```

When prompted, choose:

- **Agent**: Claude Code (or any other agentskills.io-compatible tool)
- **Scope**: project (recommended for these iOS-Care skills) or global

The CLI copies the skill into `<scope>/.claude/skills/<skill-name>/`, so the slash command (e.g. `/swiftui`) becomes available to that agent.

To update a skill later, re-run `npx skills add ...` with the same arguments.

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
4. Commit + push. Reinstall with `npx skills add ...` to pick up changes in any project that uses the skill.

The skill name must be lowercase letters, numbers, and hyphens only — and must match the directory name.

## License

MIT.
