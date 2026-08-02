---
name: interact-with-sim
description: Drives the iOS Care apps on the simulator end to end — builds and launches via Xcode MCP, then navigates, taps, types, and gestures through the UI with the AXe accessibility CLI. Records each distinct user flow (login, enrollment, accessing a profile from a screen, etc.) to a reusable file the first time, then replays it fast on later runs, self-healing when the UI drifts. Use when the user asks to interact with / drive / automate the simulator, log in, enroll, navigate to a screen, reproduce a UI path, tap through a flow, or "have the app do X" on the sim.
license: MIT
metadata:
  author: Jorge Quezada
  version: "1.2"
---

# Interact With Sim

Drive the iOS Care apps on the simulator and get better at it over time. This skill owns
the whole loop — **build → install → launch → navigate → gesture → verify** — and keeps a
growing library of **recorded flows** so repeated journeys (login, enrollment, reaching a
profile) replay quickly instead of being re-derived tap by tap on every run.

This skill is **self-sufficient**: it builds and launches the app itself via Xcode MCP.
It never uses the `xcodebuild` CLI (broken on this workspace). If Xcode MCP is
unavailable, it **stops and asks the user to fix it** before continuing.

---

## The four roles

Every request exercises one or more of these. Be explicit in your narration about which
role you're in.

1. **Interacting** — driving the simulator with the AXe + `simctl` primitives below.
2. **Reading flows** — loading a recorded flow from the library and replaying it.
3. **Writing flows** — recording a new flow (or updating an existing one) after driving it.
4. **Deciding boundaries** — figuring out where a flow starts and ends. If it isn't
   obvious, **ask the user** before recording (see *Flow boundaries*).

---

## The flow library

Recorded flows live in:

```
/Users/jorgequezada/tools/bash_config/claude/ios-care/claude-tools/sim-interactions/
```

- One `<flow-name>.yaml` per flow, kebab-case (`login.yaml`, `enrollment.yaml`,
  `access-profile-from-home.yaml`).
- Flows are created **on demand** — nothing is pre-stubbed. No file yet → you record it.
- Flows compose via `requires:`. `access-profile-from-home` requires `login`; replay the
  prerequisite first, then the delta.
- `README.md` there is the index; keep it accurate when you add a flow.

---

## Main procedure (run this for every request)

### Step 1 — Ensure the app is built and running

This skill builds and launches on its own. Use **Xcode MCP** for building.

1. Confirm Xcode MCP is reachable (e.g. `mcp__xcode__XcodeListWindows` or
   `mcp__xcode__BuildProject`). **If Xcode MCP is NOT available: STOP. Tell the user Xcode
   MCP is down and ask them to fix it (e.g. relaunch Xcode / `/xcode-session`) before you
   continue. Do NOT fall back to `xcodebuild`.**
2. If source changed since the last build, build with `mcp__xcode__BuildProject`
   (Care scheme for Seeker, Caregiver scheme for Provider). For a full build+warnings
   pass you may load `/build-and-run`, but this skill can drive the build itself.
3. Discover the booted simulator UDID once, then **hardcode the literal** for the rest of
   the session (re-deriving `UDID=$(...)` mid-session is fragile):
   ```
   UDID=$(xcrun simctl list devices booted -j | python3 -c "import sys,json; devs=[d for r in json.loads(sys.stdin.read())['devices'].values() for d in r if d['state']=='Booted']; print(devs[0]['udid'])")
   ```
4. Install + launch the target app (terminate first if already running):
   ```
   xcrun simctl terminate $UDID <bundleId>
   xcrun simctl install   $UDID "<build-products-path>/<AppName>.app"
   xcrun simctl launch    $UDID <bundleId>
   ```
   Wait ~10s for the splash before the first `describe-ui`.

Bundle IDs: **Caregiver = `com.care.provider.enterprise`**. For the Seeker app, confirm
via `/build-and-run` or `xcrun simctl` rather than guessing. Record the bundle ID in each
flow file once known.

### Step 2 — Identify the flow and its boundaries

A flow is identified by **origin → destination**. Name the flow from the request
(`login-mhp`, `login-home`, `access-profile-from-home`, …). Decide its **origin** (start
state) and **destination** (end state). If the boundary is ambiguous, **ask** (see *Flow
boundaries*).

**Dispatch (which flow does a request map to):**
- A **bare "login"** resolves to the flow whose file declares `default_for: login`
  (currently `login-mhp`).
- An **explicit destination** ("log in to home", "…to the disclosure screen") → that
  `login-<destination>` flow.
- If the destination isn't stated, drive it and **identify the destination when you see
  it**, then match against recorded flows; if none matches, **record a new one** (Step 4B) —
  reusing the shared core via composition rather than re-recording it.

### Step 2.5 — Check the current app state first (ALWAYS)

**Before executing any flow, detect where the app actually is and never assume.** Launch
(or foreground) the app, `describe-ui` / screenshot, and reconcile against the flow's
`start_state` and `end_state`:

- **Already at the `end_state`?** The flow may be a no-op — say so and stop, or ask.
  For `login`: if the app is **already logged in** (Home / "Welcome, …"), do NOT re-run
  login. Report it, and only proceed if the user wants a *different* account (then log out
  first — for Caregiver that means `simctl uninstall` + reinstall, since there's no easy
  UI logout).
- **Not at the `start_state`?** Get there before running the steps (e.g. navigate back,
  or reset via reinstall).
- **A precondition differs from record time?** Adapt. The most common case: the flow was
  recorded on a **fresh install** but the app is now **installed-and-logged-out** — the
  fresh-install-only interruptions (ATT, notifications) will be **absent**, so skip
  whichever aren't on screen (verify by screenshot).

Every flow file should carry a `login_state:` / precondition note describing what
"already done" looks like so this check is unambiguous.

### Step 3 — Read the library

Check `sim-interactions/` for a matching `<flow>.yaml`.

- **Found → REPLAY mode** (Step 4A).
- **Not found → RECORD mode** (Step 4B).

### Step 4A — Replay a recorded flow

1. **Confirm the device matches.** Coordinate steps are device-specific — verify the booted
   simulator matches the flow's `device:` (see *Device pinning*). If it doesn't, stop and
   tell the user, or expect to re-derive every web coordinate.
2. **Expand composition.** If the flow has a `compose:` list (instead of its own `steps:`),
   execute each entry in order: an `include:` runs that referenced flow (substituting any
   `with:` params) — recursively, includes may nest — and an inline `steps:` block runs those
   steps. A leaf flow just has `steps:`.
3. Run the **Step 2.5** current-state check: bail if already at `end_state` (e.g. already
   logged in), get to the `start_state` if not there, and note which recorded steps to skip.
4. Execute each step in order. For each step:
   - Prefer the recorded `label`, then `id`, then coordinate `fallback`.
   - **`optional: true`** → do it only if the target is on screen (screenshot to check);
     skip silently if absent (e.g. fresh-install-only prompts, intermittent autofill sheets).
   - After actions that change the screen, `describe-ui`/screenshot again before the next tap.
   - Honor per-step `wait` and `verify`.
5. **Self-heal**: if a step's selector/coordinate no longer matches, re-`describe-ui` (or
   re-derive from a screenshot for web views), act, and **update the flow file** with the
   corrected value + a note. Bump `last_verified`. Fix a shared step in the *core* flow, not
   in each composing flow.

### Step 4B — Record a new flow

1. Drive it **manually** with the primitives: `describe-ui` → choose the most stable
   selector → act → `sleep` → `describe-ui`/`screenshot` → verify → repeat.
2. As you go, capture each successful step and every quirk you hit.
3. **Reuse, don't duplicate.** If part of the journey is an existing flow (e.g. login), make
   the new flow **composed** — `include:` the shared core + a `switch-environment` include if
   needed, then only record the steps unique to the new destination.
4. When you reach the `end_state`, **write** `sim-interactions/<flow>.yaml` using the schema
   below (include the `device:` field), and update `sim-interactions/README.md`.
5. Tell the user the flow was recorded and will replay faster next time.

### Step 5 — Learn

- Per-flow learning happened inline in 4A/4B (selector fixes, new gotchas).
- **Meta learning**: if you discovered a *general* interaction technique this session
  (not specific to one flow — e.g. a better way to clear a text field, a new AXe quirk),
  surface a short **"Skill improvement suggestion"** at the end and offer to fold it into
  this SKILL.md. Also offer this roughly every ~5th time the skill is used, so the skill
  keeps improving. Only edit the skill after the user agrees.

---

## Simulator interaction primitives (AXe + simctl)

All touch/type/gesture/inspection is **AXe CLI** (`brew install cameroncooke/axe/axe`),
which drives Apple's Accessibility APIs. All lifecycle is `xcrun simctl`.

**Always `describe-ui` before acting** — displayed text ≠ accessibility label.

| Need | Command |
|---|---|
| Dump accessibility tree (labels, `type`, `frame` x/y) | `axe describe-ui --udid $UDID` |
| Tap by label (preferred) | `axe tap --label "Text" --udid $UDID` |
| Tap by accessibility id | `axe tap --id "accessID" --udid $UDID` |
| Tap by coordinate (fallback only) | `axe tap -x N -y N --udid $UDID` |
| Type text (**positional — no `--text` flag**) | `axe type "hello" --udid $UDID` |
| Send HID keycode (42 = backspace) | `axe key 42 --udid $UDID` |
| Swipe (`--start-*` / `--end-*`, NOT `--from/--to`) | `axe swipe --start-x N --start-y N --end-x N --end-y N --duration 0.4 --udid $UDID` |
| Screenshot (visual verification only) | `axe screenshot --udid $UDID` |
| Terminate / install / launch / uninstall | `xcrun simctl {terminate\|install\|launch\|uninstall} $UDID <bundleId>` |

**Element-identity priority:** `--label` > `--id` > coordinates.

**Clearing a text field:** tap the field → `axe key 42` × N (backspace, no string alias)
→ `axe type "new value"`.

**Hard-won interaction gotchas (proven from prior automation):**
- Run `describe-ui` again after **any** scroll or screen change — stale frames cause
  silent no-ops.
- Coordinate taps in the top nav/status band (roughly **y < 80**) silently no-op — avoid.
- **Screenshot pixel coords ≠ AXe logical coords** (logical is ~402×874 on iPhone 17, not
  the rendered pixel size). For **native** elements derive coordinates from `describe-ui`
  frames; only for **web views** (where describe-ui is blind) derive from a screenshot via
  `logical = px / scale` — and those values are **device-specific** (see *Device pinning*).
- Labels with commas can break `--label` matching → fall back to a coordinate tap from the
  element's `describe-ui` frame center.
- **Duplicate matches** (e.g. a Button + StaticText sharing a frame, like "Log Out") make
  `--label` fail with "multiple matches" → coordinate-tap the Button's frame center.
- When `grep` on `describe-ui` misses an element, parse the full JSON tree with a small
  Python walker (write it to `$CLAUDE_JOB_DIR/tmp/parse_ui.py`) that prints every
  Button/StaticText with its frame; filter by `y` to target a region.
- Custom UIKit popups often expose non-obvious labels (e.g. `"ProviderProfile Pet Care"`
  for a visible "Pet care"). Trust `describe-ui`, not the on-screen text.

**Synchronization is unpolled:** fixed `sleep` + `describe-ui`/`screenshot`/`tail` verify.
Splash ≈ 10s; most transitions `sleep 2`–`3`.

**Runtime logs are file-based:** never OSLog/`--console-pty`. Use `/debug-logs` to write
to `/tmp/care_debug.txt` and read it back with `tail`/`grep`. Verify a silent action fired
nothing with a delta count (`grep -c`).

---

## WKWebView & opaque content (describe-ui is blind here)

Some screens are **not native** — most importantly the **web login/onboarding in a
WKWebView** (e.g. `*.carezen.net`). `axe describe-ui` **cannot see inside a WKWebView**: it
reports the *native scene behind* the web view (often the previous screen). Treat this as a
detection signal:

- **If `describe-ui` keeps returning content that clearly sits *behind* what's on screen
  (or is identical across taps that visibly changed the UI) → suspect a web view / opaque
  overlay.** Stop trusting `describe-ui` and **drive by screenshot coordinates** instead.
- Web views also load asynchronously behind a `HudView` loading overlay — wait (~5–7s) and
  screenshot before acting.
- The native scene resumes once the web view closes, so `describe-ui` becomes reliable
  again after the web step ends.

## Screenshot → logical coordinate conversion

Coordinate taps use **logical** coordinates (the screen is 402×874 on iPhone 17). When you
*can* use `describe-ui`, take coordinates from element `frame`s. When you **can't** (web
views), derive them from a screenshot:

```
logical = screenshot_pixel / device_scale        # ÷3 on @3x devices (iPhone 17)
```

The Read tool reports a screenshot's original pixel size and a scale factor to the
displayed image — combine them (`logical = displayed × displayed_scale ÷ device_scale`).
Re-derive from a fresh screenshot whenever the layout looks different; never reuse pixel
coordinates across a layout change.

## The screenshot-verify loop (standard for web/opaque screens)

When `describe-ui` isn't usable, the verification unit is:

```
axe screenshot --udid $UDID --output "$CLAUDE_JOB_DIR/tmp/<step>.png"
```

then **Read** that file to see the actual screen, choose coordinates, act, and screenshot
again. Do this for every web-view step — act-then-verify, never act blind.

## iOS system interruptions (handle across every flow)

The OS injects prompts that aren't part of the app UI and will block a flow if ignored.
Most appear only on a **fresh install** — verify by screenshot and skip whichever aren't
present:

- **In-app ATT explainer card** → tap `Continue` (native label works).
- **System ATT prompt** ("…track your activity…") → tap `Ask App Not to Track`.
- **Password autofill sheets** (iOS offers a saved keychain credential — "Sign In / Fill
  User Name", "Fill Password") → **dismiss via the sheet's X** and type manually, so the
  flow stays credential-agnostic.
- **Notification permission prompt** ("…Would Like to Send You Notifications") → tap
  `Don't Allow` (or `Allow`); it usually fires right after successful auth.

Record which interruptions a flow hits (and that they're fresh-install-only) in that flow's
`gotchas`.

---

## Flow file format

Structured YAML, one file per flow. Metadata is machine-readable; `notes`/`gotchas` are
where learning accumulates so replay survives UI drift.

A flow is **either a leaf** (has its own `steps:`) **or composed** (has a `compose:` list).
The shared `login` core is a leaf; destination flows compose it.

**Leaf flow** (own steps):
```yaml
flow: login                       # kebab-case, matches filename
role: core                        # optional: core | reusable — signals it's a building block
description: …
app: Caregiver                    # Caregiver | Care(Seeker)
bundleId: com.care.provider.enterprise
device: "iPhone 17 (logical 402x874 @3x)"   # coords are device-specific — see Device pinning
params:
  - name: username                # values the caller supplies at replay time
  - name: password
start_state: "Logged-out Get Started, intended env active."
end_state: "Authenticated; landed on the account's post-login screen."
reliability: medium               # high | medium | low — lower it when self-healing
last_verified: "2026-07-24"       # bump on every successful run/heal
steps:
  - n: 1
    action: tap                   # launch | relaunch | tap | type | clear | swipe | wait | verify
    label: "Log In"               # selector priority: label > id > fallback coordinate
    id: btnLogin
    fallback: { x: 201, y: 772 }  # LOGICAL coords, device-specific, starting point
    optional: true                # tap only if present; skip silently if absent
    wait: 7                        # seconds to wait AFTER this step
    verify: "web login visible"
    note: "why this selector / any quirk"
  - n: 2
    action: type
    value: "{username}"           # {param} substitution from params:
gotchas:
  - "Hard-won UI quirks that keep replay working…"
```

**Composed flow** (`compose:` instead of `steps:`):
```yaml
flow: login-mhp
default_for: login                # optional: a bare "login" request dispatches here
description: "origin → destination"
params: [ … ]
start_state: "…"
end_state: "…"
compose:
  - include: switch-environment   # run another flow…
    with: { environment: STG }    # …substituting its params
  - include: login
    with: { username: "{username}", password: "{password}" }
  - steps:                        # then this flow's own appended steps
      - { n: 1, action: tap, label: "Got it", note: "…" }
      - { n: 2, action: verify, detail: "destination reached" }
```

Field notes:
- `{param}` tokens (in `value:` and `with:`) are substituted at replay time.
- `include:` may nest — a composed flow can include another composed flow. **You may extend
  the structure at any level** (see *Extensibility*).
- `optional: true` = conditional step (interstitials, fresh-install prompts, autofill sheets).
- Keep `note` on any step whose selector was non-obvious or needed a fallback.
- Heal a shared step in the *core* flow, then bump `last_verified` on the files you touched.

---

## Composing flows (origin → destination)

A flow is identified by **origin → destination**. Same origin, different destination = a
**separate flow**. Don't duplicate — **compose**:

- Keep one **core** flow for the shared sub-procedure (e.g. `login` = credential entry,
  destination-neutral, ends "authenticated / landed on post-login screen").
- Each **destination flow** (`login-home`, `login-mhp`, `login-disclosure`, …) `compose:`s
  the core plus a `switch-environment` include if needed, then appends the steps unique to
  reaching and verifying its destination.
- The destination defines where the flow **ends**. `login-mhp` taps through the Safety-First
  disclosure to reach MHP; `login-disclosure` would **stop at** that disclosure screen.

**When the boundary is unclear, ask** (e.g. "does `enrollment` end at the confirmation or
back at Home?"). Record only after it's agreed. Keep flows single-purpose; compose rather
than build one giant script.

**Login dispatch:** bare "login" → the `default_for: login` flow (currently `login-mhp`);
explicit destination → that flow; unknown destination → drive, identify on arrival, match,
and record a new destination flow (composing the core) if none exists.

---

## Device pinning (coordinates are device-specific)

Web-view steps use **logical coordinates**, which depend on the simulator's screen size.
**On a different simulator (or a different screen size / scale) every web coordinate
shifts** and replay will mis-tap.

- Each flow records a **`device:`** field. Replay on that same simulator model.
- **Instruct the user to boot the pinned simulator** (recorded on **iPhone 17**, logical
  402×874 @3x) before running these flows. iPhone 17 Pro etc. have different dimensions.
- If only a different device is available: it can still work, but **treat every web
  coordinate as unverified** — screenshot and re-derive each one (`logical = px / scale`),
  then save a device-specific variant rather than overwriting the pinned values.
- Native (`describe-ui`) steps are resolution-independent (frames come back in logical
  coords); only the screenshot-derived web coordinates are device-sensitive.

---

## Extensibility (extend the flow model as you go)

This skill and its flow schema are meant to **grow with use, at any level**. You may add new
step `action`s, new step flags (like `optional`), new composition directives, new flow
fields, or new reusable building blocks whenever a flow needs something the current schema
can't express. Two rules:

1. **Prefer composition and reuse** over duplicating steps.
2. **Document any new convention here** (and in the affected flow files) so the format stays
   self-describing — a future session must be able to read a flow and this skill and know
   exactly how to replay it. Fold genuinely general additions in via the Step 5 meta-learning
   check-in.

---

## Bash safety & permissions

- **One line per Bash call.** Never separate commands with newlines — chain with `&&`/`;`.
- **Never chain `sleep`** with other commands (breaks the permission allowlist matcher);
  run `sleep` as its own call.
- Hardcode the UDID literal mid-session instead of re-deriving it.
- Use `$CLAUDE_JOB_DIR/tmp` for scratch files (e.g. `parse_ui.py`), not `/tmp` scratch.
- Needed allowlist entries (`.claude/settings.local.json`) for a fully unattended
  replay/record/self-heal loop:
  - Bash: `Bash(xcrun simctl*)`, `Bash(axe:*)` (or per-subcommand `axe tap:*`/`type:*`/…),
    `Bash(python3:*)`, `Bash(UDID=*)`, `Bash(sleep *)`, `Bash(echo:*)`.
  - `Skill(interact-with-sim)` — so invoking the skill doesn't prompt.
  - `Write(//Users/jorgequezada/tools/bash_config/claude/ios-care/claude-tools/sim-interactions/**)` and the
    matching `Edit(...)` — so recording and self-heal can write flow files unattended.
  - **Intentionally NOT allow-listed:** edits to this `SKILL.md`. Meta-learning changes stay
    gated so the skill asks before rewriting itself.
  - If a call is blocked, tell the user which entry to add.

---

## Related skills
- `/build-and-run` — full build + warnings pass + launch (this skill can build itself, but
  delegate here when the user wants the warnings check).
- `/debug-logs` — add/read `/tmp/care_debug.txt` runtime logs to verify code paths.
- `/xcode-session` — (re)establish the Xcode instance behind Xcode MCP if it's down.
