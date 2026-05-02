---
name: xcode-session
description: Sets up an isolated Xcode instance for the current worktree and configures the MCP bridge with a session ID, so multiple worktrees can each have their own Xcode + MCP connection. Use when the user asks to start an Xcode session, set up Xcode MCP for a worktree, or switch between Xcode instances per worktree.
license: MIT
metadata:
  author: Jorge Quezada
  version: "1.0"
---

# Xcode Session

Set up an isolated Xcode instance for the current worktree and configure the MCP bridge.

## Arguments

- **Session ID** (required): A number or name to identify this Xcode session (e.g., `1`, `2`, `profiles`)

## Steps

### 1. Detect workspace

Find `Universal.xcworkspace` relative to the current repo root:

```bash
REPO_ROOT=$(git rev-parse --show-toplevel)
WORKSPACE="$REPO_ROOT/Universal.xcworkspace"
```

Verify it exists. If not, tell the user they need to be in a repo copy that has the workspace.

### 2. Launch Xcode with session ID

```bash
/Users/jorgequezada/tools/bash_config/claude/ios-care/claude-tools/xcode/xcode-session <SESSION_ID> "$WORKSPACE"
```

This launches a new Xcode instance, registers the PID, and kills any previous instance for this session ID.

### 3. Configure MCP bridge

Remove any existing xcode MCP config first, then add with the session ID:

```bash
claude mcp remove xcode 2>/dev/null; claude mcp add xcode --transport stdio -e XCODE_SESSION=<SESSION_ID> -- /Users/jorgequezada/tools/bash_config/claude/ios-care/claude-tools/xcode/xcode-mcp-bridge
```

### 4. Instruct user

Tell the user:

1. **Enable MCP in the new Xcode instance**: Settings > Intelligence > Model Context Protocol > Xcode Tools **on** (if not already enabled)
2. **Restart this Claude Code session** to pick up the MCP bridge
3. After restart, Xcode MCP tools will connect to session `<SESSION_ID>`'s Xcode instance

Remind them: if Xcode crashes or needs relaunching, they can run from any terminal:
```
xcode-session <SESSION_ID>
```
This relaunches Xcode with the same workspace and updates the PID. No need to reconfigure Claude — just restart the Claude session.
