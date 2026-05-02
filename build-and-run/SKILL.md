---
name: build-and-run
description: Builds the iOS Care project with Xcode MCP, checks for new warnings introduced by current changes, and launches the app on the booted simulator for runtime verification. Use after making code changes that need runtime testing, or whenever the user asks to build and run, deploy to the simulator, or verify a UI change.
license: MIT
metadata:
  author: Jorge Quezada
  version: "1.0"
---

# Build and Run

Build the project with Xcode MCP, check for warnings, and launch the app on the simulator so the user can verify the change immediately.

## Instructions

1. **Build** using Xcode MCP `BuildProject` (use `XcodeListWindows` first if you don't have the tab identifier).
2. **If the build succeeds**, check for warnings using `XcodeListNavigatorIssues`. Report any new warnings introduced by the current changes — these must be fixed before the PR.
3. **Launch** the app on the booted simulator:
   ```bash
   xcrun simctl launch booted <bundle-id>
   ```
4. **If the build fails**, report the errors. Do not attempt to launch or check warnings.

## Bundle IDs

| App | Bundle ID |
|-----|-----------|
| Caregiver | `com.care.provider.enterprise` |
| Seeker | `com.care.enterprise` |

## Which app to launch

- Default to the app matching the current scheme/branch context (e.g., Caregiver for provider work, Seeker for seeker work).
- If unclear, ask.

## Notes

- `BuildProject` only compiles — it does **not** launch the app. Always follow up with `simctl launch`.
- The simulator must already be booted. If `simctl launch` fails with a device error, tell the user to open Simulator.app first.
- The debugger will not be attached. If the user needs the debugger, they should run from Xcode manually (Cmd+R).
- When reporting warnings, only flag warnings in files that were changed in the current branch. Pre-existing warnings in other files are not our concern.
