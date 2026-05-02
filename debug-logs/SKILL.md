---
name: debug-logs
description: Adds temporary file-based debug logs to source files using the `<<>>` prefix, then builds, runs on simulator, and evaluates log output. Two modes - "Add Logs" injects debug prints, "Evaluate Logs" reads /tmp/care_debug.txt and analyzes which code paths executed. Use when the user asks to add debug logs, trace runtime execution, evaluate logs, or debug code paths.
license: MIT
metadata:
  author: Jorge Quezada
  version: "1.0"
---

# Debug Logs

Add temporary debug logs to source files, build, run on simulator, capture and evaluate log output. Uses file-based logging for reliability.

## Arguments

The user specifies:
- **What to log**: Code paths, variable values, decision branches, method calls
- **Where to log**: Source files and approximate locations (methods, conditions, lines)
- If not specified, ask.

## Two Modes

### Mode 1: Add Logs
Add `<<>>` debug prints to the specified locations. Use the file-based logger below.

### Mode 2: Evaluate Logs
Build, install, launch the app, then read and analyze the captured log output.

---

## File-Based Logger

**This is the only reliable log capture method.** Console-pty and log stream are unreliable.

Add this helper to any file that needs logging (or to a shared utility if multiple files need it):

```swift
private func debugLog(_ message: String) {
    let url = URL(fileURLWithPath: "/tmp/care_debug.txt")
    let line = "<<>> \(Date()) \(message)\n"
    guard let data = line.data(using: .utf8) else { return }
    if let handle = try? FileHandle(forWritingTo: url) {
        handle.seekToEndOfFile(); handle.write(data); handle.closeFile()
    } else {
        try? line.write(to: url, atomically: false, encoding: .utf8)
    }
}
```

**Scope rules:**
- If logging inside a class/struct, add as a `private func` or `private static func`
- If logging across multiple files, add to each file independently (avoid creating shared utilities for temporary debug code)
- The `<<>>` prefix is mandatory — it marks these as temporary debug logs per CLAUDE.md

### Log Placement Pattern

```swift
// At method entry
debugLog("methodName called")

// At decision branches
if someCondition {
    debugLog("methodName: took branch A, value=\(someValue)")
} else {
    debugLog("methodName: took branch B, value=\(otherValue)")
}

// Before/after async calls
debugLog("methodName: calling API")
api.fetch { result in
    debugLog("methodName: API returned \(result)")
}
```

---

## Build & Run (Evaluate Mode)

Requires Xcode MCP connected and simulator booted.

### 1. Get Xcode Tab
```
mcp__xcode__XcodeListWindows()
```

### 2. Build
```
mcp__xcode__BuildProject(tabIdentifier: "<tab>")
```
On failure: `mcp__xcode__GetBuildLog(tabIdentifier: "<tab>", severity: "error")`

### 3. Get Simulator UDID
```bash
UDID=$(xcrun simctl list devices booted -j | python3 -c "import sys,json; devs=[d for r in json.loads(sys.stdin.read())['devices'].values() for d in r if d['state']=='Booted']; print(devs[0]['udid'])")
```

### 4. Install & Launch
Determine app from scheme:
- **Care scheme** → `BUNDLE_ID="com.care.enterprise"`, `APP_NAME="Care.app"`
- **Caregiver scheme** → `BUNDLE_ID="com.care.provider.enterprise"`, `APP_NAME="Caregiver.app"`

Build products path: `<project-root>/Build/Products/Debug-iphonesimulator/`

```bash
xcrun simctl terminate booted $BUNDLE_ID 2>/dev/null ; rm -f /tmp/care_debug.txt ; xcrun simctl install booted "<project-root>/Build/Products/Debug-iphonesimulator/$APP_NAME" && xcrun simctl launch booted $BUNDLE_ID
```

### 5. Wait & Let User Interact
Tell the user: **"App launched. Reproduce the scenario, then tell me to evaluate logs."**

If the user asks you to navigate, use AXe CLI:
```bash
sleep 6  # wait for splash
axe describe-ui --udid $UDID | grep -i "keyword"
axe tap --label "Label" --udid $UDID
```

### 6. Read & Evaluate Logs
```bash
cat /tmp/care_debug.txt
```

Analyze the output:
- Which code paths executed?
- What were the variable values at decision points?
- Did execution order match expectations?
- Any unexpected branches taken or skipped?

Report findings clearly: what happened, what was expected, what the discrepancy is.

---

## Cleanup Rules

**CRITICAL — from CLAUDE.md:**
- NEVER commit `<<>>` prints — they are for local debugging only
- Remove ALL `debugLog` calls and the helper function before any commit
- Fully revert any code changes made solely to support debug logging (e.g., extracting local variables for logging)
- Don't leave behind artifacts

## Cleanup Command
When the user says "clean up logs" or "remove debug logs":
1. Search for `<<>>` and `debugLog` in modified files
2. Remove all debug log statements and the helper function
3. Revert any code that was only added to support logging
4. Verify with `XcodeRefreshCodeIssuesInFile` that files still compile
5. Run `rm -f /tmp/care_debug.txt`
