---
name: add-feature-flag
description: Adds a new LaunchDarkly feature flag to the iOS Care codebase, wiring up FeatureFlagKey enum case, logging configuration, and the Caregiver debug-menu override list. Use when the user asks to add a feature flag, create a LaunchDarkly toggle, or wire up a new flag key (prv-, pro-, skr-, ent- prefixes).
license: MIT
metadata:
  author: Jorge Quezada
  version: "1.0"
---

# Add Feature Flag

Add a new LaunchDarkly feature flag to the iOS codebase.

## Instructions

1. **Ask for the flag details (if not already provided):**
   - Flag key name (e.g., "prv-consolidate-secondary-profile-creation")
   - The enum case name will be derived from the key (e.g., `proConsolidatedSecondaryProfileCreation`)
   - **Flag value type** — ask the user which type of flag this is:
     - **String with HoldoutVariant** (control/holdout/test) — most common, used for A/B experiments
     - **Boolean** — simple on/off toggle
     - **Integer** — numeric values
     - **JSON** — dictionary/object values
   - **Test exposure tracking** (`shouldLogTestExposures`) — ask the user:
     - **Yes (default)** — fires a "Test Exposure" analytics event every time the flag is evaluated. Use for A/B experiments where you need to track which variant a user saw.
     - **No** — no exposure event. Use for simple feature rollout gates where exposure tracking is unnecessary/noisy.

2. **Determine flag type from prefix:**
   - `prv-` or `pro-` = Provider flag (add to FeatureFlagItems.swift)
   - `skr-` = Seeker flag
   - `ent-` = Enterprise flag
   - Other = Shared flag

3. **Add the flag to these files:**

   ### Required for ALL flags:

   **a) Hub/Hub/Protocols/CommonServices/FeatureFlags/FeatureFlagKey.swift**
   - Add enum case with raw value (the flag key)
   - Add to the `characteristics` switch statement
   - Default: Use `.stringFeatureKey` with `holdoutVariantTestValues` and `HoldoutVariant.control` default
   - Set `shouldLogTestExposures` based on user's answer (default is `true` if omitted)

   **b) ios-caregiver/Care/Application/ApplicationDelegate/ApplicationDelegate+LoggingConfiguration.swift**
   - Add to the exhaustive switch in `shouldLogTag` (return false section)

   **c) ios-care-seeker/Care/Application/AppDelegate/AppDelegate+LoggingConfiguration.swift**
   - Add to the exhaustive switch in `shouldLogTag` (return false section)

   ### For flags to appear in the DEBUG feature flag override menu:

   **d) ios-caregiver/Care/Data/Model/LaunchDarkly/FeatureFlagItems.swift**
   - Add `FeatureFlagItem(flagKey: .yourFlagName)` to the `providerFeatureFlagItems` array
   - **This is required for ANY flag you want to override in the Caregiver app's debug menu**, not just provider flags
   - Without this, the flag won't appear in Settings > Feature Flags override list

4. **Build verification:**
   - Build both Caregiver and Care schemes to verify no compilation errors
   - Use Xcode MCP `BuildProject` + `XcodeListNavigatorIssues`

5. **Flag configuration options:**
   - Default type: String with HoldoutVariant (control, holdout, test)
   - Alternative types available:
     - `.boolFeatureKey(keyName:)` for boolean flags
     - `.intFeatureKey(keyName:possibleFlagValues:defaultValue:)` for integer flags
     - `.jsonFeatureKey(keyName:defaultValue:)` for JSON/dictionary flags

## Example

For flag key `prv-my-new-feature`:

```swift
// FeatureFlagKey.swift - enum case
case proMyNewFeature = "prv-my-new-feature"

// FeatureFlagKey.swift - characteristics switch
// Option A: with test exposure tracking (A/B experiment) — add to existing group that returns .stringFeatureKey with holdoutVariantTestValues
.proMyNewFeature,
.messageSelfReminders:
    return .stringFeatureKey(
        keyName: rawValue,
        possibleFlagValues: holdoutVariantTestValues,
        defaultValue: HoldoutVariant.control.rawValue
    )

// Option B: without test exposure tracking (feature gate) — add to existing group with shouldLogTestExposures: false
.proMyNewFeature,
.seekerSearchHorizontalFilters:
    return .stringFeatureKey(
        keyName: rawValue,
        possibleFlagValues: holdoutVariantTestValues,
        defaultValue: HoldoutVariant.control.rawValue,
        shouldLogTestExposures: false
    )

// LoggingConfiguration files - add to return false section
.proMyNewFeature,

// FeatureFlagItems.swift - for provider flags
FeatureFlagItem(flagKey: .proMyNewFeature),
```

## Notes

- Always place new cases near similar flags (e.g., near `proConsolidatedWebEnrollmentAttributes` for provider flags)
- The exhaustive switch errors will guide you if you miss a file
- Build both apps to ensure all switches are updated
