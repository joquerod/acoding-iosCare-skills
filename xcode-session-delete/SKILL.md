---
name: xcode-session-delete
description: Removes the Xcode MCP server configuration for the current repo directory from ~/.claude.json. Use when the user asks to delete an Xcode session, remove an Xcode MCP config, or clean up after switching worktrees.
license: MIT
metadata:
  author: Jorge Quezada
  version: "1.0"
---

# Xcode Session Delete

Remove the Xcode MCP server configuration for the current repo directory.

## Steps

### 1. Determine the current repo path

```bash
REPO_ROOT=$(git rev-parse --show-toplevel)
```

### 2. Remove the xcode MCP entry from ~/.claude.json

Read `~/.claude.json`, find and remove the `xcode` MCP server entry scoped to the current repo path (`$REPO_ROOT`), then write the file back.

Use Python to parse and update the JSON:

```bash
python3 -c "
import json, os

config_path = os.path.expanduser('~/.claude.json')
with open(config_path) as f:
    config = json.load(f)

repo_root = os.popen('git rev-parse --show-toplevel').read().strip()

projects = config.get('projects', {})
project_key = repo_root
project = projects.get(project_key, {})
mcp_servers = project.get('mcpServers', {})

if 'xcode' in mcp_servers:
    del mcp_servers['xcode']
    # Clean up empty nested dicts
    if not mcp_servers:
        del project['mcpServers']
    if not project:
        del projects[project_key]
    with open(config_path, 'w') as f:
        json.dump(config, f, indent=2)
        f.write('\n')
    print(f'Removed xcode MCP config for {repo_root}')
else:
    print(f'No xcode MCP config found for {repo_root}')
"
```

### 3. Confirm

Tell the user the xcode MCP config has been removed for this repo. Remind them to restart the Claude Code session for the change to take effect.
