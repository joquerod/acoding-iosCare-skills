---
name: automate-app-enrollment
description: Automates the Caregiver app enrollment flow on the iOS Simulator using the AXe CLI - navigates the UI, fills enrollment forms, and completes enrollment for Pet care, Tutoring, Senior care, or Housekeeping. Use when the user asks to automate enrollment, run an end-to-end enrollment test, or simulate the enrollment flow on simulator.
license: MIT
metadata:
  author: Jorge Quezada
  version: "1.0"
---

# Automate App Enrollment

Automate the Caregiver app enrollment flow on the iOS Simulator. This command navigates the app UI, fills out enrollment forms, and completes the service enrollment process.

## Arguments

The user will specify which service to enroll in. If not specified, ask them.

Available services and their accessibility labels:
- **Pet care** → `"ProviderProfile Pet Care"`
- **Tutoring** → `"ProviderProfile Tutoring"`
- **Adult & Senior care** → `"ProviderProfile Senior Care"`
- **Housekeeping** → `"ProviderProfile Housekeeping"`

## Prerequisites

- Simulator must be booted (iPhone 17, UDID: check with `xcrun simctl list devices booted`)
- Caregiver app must be installed and user must be logged in
- AXe CLI must be installed (`axe` command available)

## Environment

```
BUNDLE_ID="com.care.provider.enterprise"
```

## Execution Steps

### 1. Get Simulator UDID
```bash
UDID=$(xcrun simctl list devices booted -j | python3 -c "import sys,json; devs=[d for r in json.loads(sys.stdin.read())['devices'].values() for d in r if d['state']=='Booted']; print(devs[0]['udid'])")
```

### 2. Launch App with Log Capture
```bash
xcrun simctl terminate booted $BUNDLE_ID 2>/dev/null
rm -f /tmp/care_stdout.txt
xcrun simctl launch --console-pty booted $BUNDLE_ID > /tmp/care_stdout.txt 2>&1 &
```

### 3. Navigate to My Profiles → Add Service
Wait for the app to fully load (splash screen → home screen), then:
```bash
sleep 6
axe tap --id "ProfileButton" --udid $UDID        # Profile avatar top-right
sleep 2
axe tap --label "View/edit profile" --udid $UDID  # Opens My Profiles
sleep 2
axe tap --label "Add service" --udid $UDID         # Opens service picker popup
sleep 2
axe tap --label "<SERVICE_LABEL>" --udid $UDID     # Select the target service
```

### 4. Fill Enrollment Forms
After tapping the service, the enrollment flow begins with multi-page attribute forms.

**For each enrollment page:**
1. Take a screenshot to see what's on the page
2. Use `axe describe-ui --udid $UDID | grep -i "keyword"` to find tappable elements
3. Tap required fields (select at least one option per required section)
4. Tap "Next" to advance to the next page
5. Repeat until enrollment is complete

**Important patterns:**
- Chip/pill selectors: tap the label text (e.g., `axe tap --label "Dogs"`)
- Sliders: leave at default unless user specifies otherwise
- Text fields: use `axe type --text "..." --udid $UDID`
- "Next" button: `axe tap --label "Next" --udid $UDID`
- Always `sleep 2` between page transitions

### 5. Verify & Report
After completing enrollment:
1. Take a final screenshot to confirm success
2. Check logs: `grep "<<>>" /tmp/care_stdout.txt`
3. Report what was enrolled and any errors encountered

## Key Rules

- **Always `axe describe-ui` before tapping** — accessibility labels often differ from displayed text
- **Look for `type: Button`** not `type: StaticText` — StaticText elements are not tappable
- **Screenshot after each page transition** to verify navigation succeeded
- **Wait 2 seconds** between taps and page transitions for animations
- If a tap fails or the screen doesn't change, retry with `describe-ui` to find the correct label
- If stuck, take a screenshot and report to the user what's on screen
