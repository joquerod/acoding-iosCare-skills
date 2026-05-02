---
name: swiftui
description: SwiftUI review checklist for the Care iOS codebase - load before writing or modifying any SwiftUI view. Reads the SwiftUI reference guide, surfaces existing Hoopla components (HooplaText, HooplaCTAButton, attachedSheet, IconView, PillSelectorView, etc.), and lists conventions for state management, async work, and animations. Use whenever modifying SwiftUI views, building new screens, or writing Hoopla components.
license: MIT
metadata:
  author: Jorge Quezada
  version: "1.0"
---

# SwiftUI — Review Before Writing

Before writing or modifying SwiftUI code, load the reference guide and review existing components.

## Instructions

1. **Read the SwiftUI reference guide:**
   - Read `/Users/jorgequezada/tools/bash_config/claude/ios-care/ios/swiftUI.md` in full
   - This covers: state management, view composition, navigation, async patterns, Hoopla components, layout, and conventions

2. **Check existing Hoopla components before building custom UI:**
   - Icons: `IconView`, `IconButton` — don't build raw `Button { Image(icon:)... }` wrappers
   - Selectors: `PillSelectorView`, `SmallRectangularButton`, `ActionSelector`
   - Cards: `InfoActionDisplayView`, `ExpandableFeatureCard`, `PerksCardView`
   - Layout: `FlowLayout`, `DottedLineView`
   - Sheets: `.attachedSheet` (preferred over `.sheet` / `.hooplaBottomSheet`)
   - Transitions: `.overFullScreenTransition` (preferred over `.alert()` / `.confirmationDialog()`)
   - Errors: `HooplaErrorInfoView`
   - Indicators: `HooplaPageIndicatorView`
   - Modifiers: `.heightReader()`, `.widthReader()`, `.footer()`, `.bottomButton()`, `.safeSheet()`
   - Typography: `HooplaText` with `.typography()` modifier
   - Buttons: `HooplaCTAButton` with `.environment(\.isEnabled)` for disabled state
   - Toasts: `HooplaToast` + `.toast()` modifier with `HooplaBanner`
   - Spacing: `.space4`, `.space8`, `.space12`, `.space16`, `.space24`, `.space32` tokens

3. **If unsure whether a component exists**, search the Hoopla module:
   ```
   Hoopla/Hoopla/
   ├── Buttons/SwiftUI/       # Button components
   ├── Iconography/SwiftUI/   # Icon components
   ├── Selectors/SwiftUI/     # Selection components
   ├── Banners/SwiftUI/       # Banner & card components
   ├── UIComponents/          # Calendar, PillSelector, InfoActionDisplay, etc.
   ├── Divider/SwiftUI/       # Dividers and lines
   ├── Indicator/SwiftUI/     # Page indicators
   ├── Errors/SwiftUI/        # Error state views
   ├── Color/SwiftUI/         # Color palette tokens
   └── Utils/                 # FlowLayout, View+Extensions, CGFloat+Spacing
   ```

4. **Follow these conventions:**
   - `@MainActor` on all ViewModels
   - `@StateObject` for owned VMs, `@ObservedObject` for passed-in VMs
   - `.task` for async work, `.onAppear` for sync-only (analytics, flags)
   - Guard against re-entry in `initialTask()` with `guard loadingState == .idle`
   - `@ViewBuilder` over `AnyView`
   - Custom bindings use `[weak self]`
   - Animations use `.animation(.smooth, value:)`, not `withAnimation`

5. **Report what you found** — before writing code, briefly confirm which existing components you'll reuse and which new components are needed.
