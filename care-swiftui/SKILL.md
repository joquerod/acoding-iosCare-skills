---
name: care-swiftui
description: Care iOS-specific SwiftUI guidance - load before writing or modifying SwiftUI views in the Care codebase. Surfaces the Hoopla design system component catalog (HooplaText, HooplaCTAButton, attachedSheet, IconView, PillSelectorView, etc.), the Hoopla module layout, and Care-specific view-model conventions. For general SwiftUI best practices, pair this with a separate general-SwiftUI skill (e.g. swiftui-pro from twostraws/swiftui-agent-skill).
license: MIT
metadata:
  author: Jorge Quezada
  version: "2.0"
---

# Care SwiftUI

Care-specific SwiftUI guidance. **Always reach for a Hoopla component before building raw SwiftUI primitives.** This skill covers only what's specific to the Care codebase — pair it with a general-SwiftUI skill for non-Care best practices.

## Hoopla components catalog

| Category | Components | Notes |
|---|---|---|
| Icons | `IconView`, `IconButton` | Don't build raw `Button { Image(icon:)... }` wrappers |
| Selectors | `PillSelectorView`, `SmallRectangularButton`, `ActionSelector` | |
| Cards | `InfoActionDisplayView`, `ExpandableFeatureCard`, `PerksCardView` | |
| Layout | `FlowLayout`, `DottedLineView` | |
| Sheets | `.attachedSheet` | Prefer over `.sheet` / `.hooplaBottomSheet` |
| Transitions | `.overFullScreenTransition` | Prefer over `.alert()` / `.confirmationDialog()` |
| Errors | `HooplaErrorInfoView` | |
| Indicators | `HooplaPageIndicatorView` | |
| Modifiers | `.heightReader()`, `.widthReader()`, `.footer()`, `.bottomButton()`, `.safeSheet()` | |
| Typography | `HooplaText` + `.typography()` modifier | |
| Buttons | `HooplaCTAButton` | Drive disabled state via `.environment(\.isEnabled, ...)` |
| Toasts | `HooplaToast` + `.toast()` modifier with `HooplaBanner` | |
| Spacing | `.space4`, `.space8`, `.space12`, `.space16`, `.space24`, `.space32` | Tokens — don't hardcode padding |

## Where to find components

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

If you're unsure whether a Hoopla component exists, grep the matching subdirectory before building anything custom.

## Care-specific view-model conventions

- **`initialTask()` re-entry guard.** When a view model defines an `initialTask()` for first-load async work, guard with `guard loadingState == .idle` before kicking off fetches. Re-entry from navigation can otherwise double-fire.
- **Default to `.attachedSheet`** for sheet presentation. Only fall back to `.sheet` or `.hooplaBottomSheet` when there's a documented reason.
- **Use `.overFullScreenTransition`** instead of `.alert()` / `.confirmationDialog()` for blocking confirmations and error transitions.

## Workflow

Before writing or modifying a Care SwiftUI view:

1. Identify which Hoopla components in the catalog above already cover what you need.
2. If something looks missing, grep `Hoopla/Hoopla/` to confirm before building anything custom.
3. Briefly tell the user which Hoopla components you'll reuse and which (if any) genuinely new components are required.
4. Apply the Care-specific conventions above; defer general SwiftUI best practices to your general-SwiftUI skill.
