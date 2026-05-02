---
name: architecture
description: Reference guide for the Care iOS codebase module-based architecture - covers Hub (DI), Analytics, Storage, Hoopla design system, FeatureFlags, MessagingUI, FlowController, and CareAPI. Use when exploring unfamiliar code, understanding module boundaries, or working across modules.
license: MIT
metadata:
  author: Jorge Quezada
  version: "1.0"
---

# Architecture Reference

Use this command when exploring unfamiliar code, understanding module boundaries, or working across modules.

## Module-Based Architecture

The codebase is organized into domain-specific modules, each in its own Xcode project:

- **Hub**: Core dependency injection system. All modules extend `Module` class and implement `fulfillDependencies()`
- **Analytics**: Analytics abstraction layer with providers
- **Storage**: Persistence layer with Keychain, disk, and in-memory storage
- **Hoopla**: Design system and UI components library
- **FeatureFlags**: Feature flag management with LaunchDarkly integration
- **MessagingUI**: Chat/messaging interface components
- **FlowController**: Navigation and flow coordination
- **CareAPI**: GraphQL API client and data models

## Key Patterns

### Dependency Injection (Hub)
Every module registers its dependencies via `Module.fulfillDependencies()`. To resolve a dependency:
```swift
let service = resolver.resolve(SomeProtocol.self)
```

### Navigation
- UIKit: `FlowController` pattern — coordinators manage navigation stacks
- SwiftUI: Mixed — some screens use `NavigationStack`, others bridge through UIKit via `UIHostingController`

### API Layer (CareAPI)
- GraphQL-based via Apollo
- DTOs are generated from `.graphql` files
- Services wrap Apollo calls and return domain models

### UI Layer
- **UIKit**: Storyboards + programmatic views (legacy)
- **SwiftUI**: Newer screens, often wrapped in `UIHostingController` for UIKit integration
- **Hoopla**: Shared design system components used by both apps
