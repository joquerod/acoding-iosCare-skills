---
name: add-graphql-api
description: Adds a new GraphQL query or mutation to the iOS Care codebase and generates the matching async/await Swift service method, including DTO structs and ApolloCompatible mappings. Use when the user asks to add a GraphQL API, wire up a new query or mutation, or build an Apollo service method. Requires the Apollo schema to be up to date (run /update-apollo-schema first if needed).
license: MIT
metadata:
  author: Jorge Quezada
  version: "1.0"
---

# Add GraphQL API

Add a new GraphQL query or mutation to the iOS codebase and generate an async/await Swift service method to consume it.

**Prerequisite:** The Apollo schema must already be up to date. If the query/mutation is new and not yet in the generated file, run `/update-apollo-schema` first.

## Usage

```
/add-graphql-api <query-or-mutation-name>
```

Example: `/add-graphql-api getSomethingNew`

## Steps

### 1. Check if the Schema Has the API

Search the `apolloschema.json` in the project root (or the `.generated.swift` file for the target module) for the query/mutation name.

- If found in the generated file already, skip to Step 3.
- If found only in `apolloschema.json`, the `.graphql` file is missing — proceed to Step 2.
- If not found anywhere, tell the user: *"This API is not in the current schema. Run `/update-apollo-schema` with a fresh schema download first."*

### 2. Extract the Query Shape from the Schema

Parse `apolloschema.json` to extract:
- **Arguments** (name, type, nullability)
- **Return type** (union, object, or scalar)
- **Nested types** — recursively resolve all object fields, unions, and enums needed

Build the complete type tree so the `.graphql` file includes all fields.

### 3. Ask the User Where to Add This API

List the existing service directories under `ios-careapi/CareAPI/CareModules/ApolloServices/` and ask the user to pick one or create a new one.

```bash
ls -d ios-careapi/CareAPI/CareModules/ApolloServices/*/
```

Present the options like:
> Where should this API live?
> 1. `ApolloServices/ProviderProfile/` (existing — ProviderProfileService)
> 2. `ApolloServices/SafetyStatus/` (existing — SafetyStatusService)
> 3. ... (other existing directories)
> 4. Create a new service directory

If the user picks an existing directory, add the `.graphql` file and service method to the existing service files there.

If the user picks "new", create a new directory under `ios-careapi/CareAPI/CareModules/ApolloServices/<NewServiceName>/` with:
- `GraphQL/Query/` and/or `GraphQL/Mutation/` subdirectories for `.graphql` files
- `<ServiceName>Service.swift` (protocol)
- `Default<ServiceName>Service.swift` (implementation)

### 4. Write the `.graphql` File

Create the file in the appropriate `GraphQL/` directory next to the service's other `.graphql` files.

**Directory structure:** Place `.graphql` files under `GraphQL/Query/` or `GraphQL/Mutation/` subdirectories based on the operation type:

```
<ServiceName>/
├── GraphQL/
│   ├── Query/
│   │   └── GetSomething.graphql
│   └── Mutation/
│       └── UpdateSomething.graphql
├── <ServiceName>Service.swift
└── Default<ServiceName>Service.swift
```

If the chosen directory only has a flat `GraphQL/` folder (no `Query/`/`Mutation/` subdirectories), follow the existing structure — don't restructure it.

**Naming convention:** Match the query/mutation operation name in PascalCase (e.g., `GetPetCareServiceLevelPricing.graphql`).

**Guidelines:**
- Include all non-deprecated fields by default
- For union return types, add `... on SuccessType` and `... on FailureType` fragments
- Both args optional? Keep them optional. Required args? Mark with `!`.
- Omit deprecated fields unless the user explicitly asks for them

Example (union return type with nested objects):
```graphql
query GetSomething($id: ID!, $filter: [SomeEnum!]) {
  getSomething(id: $id, filter: $filter) {
    ... on GetSomethingSuccess {
      items {
        label
        type
        nested {
          value
          status
        }
      }
    }
    ... on GetSomethingFailure {
      message
    }
  }
}
```

### 5. Run Code Generation

Find the codegen script and regenerate:

```bash
CODEGEN_SCRIPT=$(find "$HOME/Library/Developer/Xcode/DerivedData" -name "run-bundled-codegen.sh" -path "*/apollo-ios/scripts/*" 2>/dev/null | head -1)
```

If `apolloschema.json` is not in the project root, tell the user to run `/update-apollo-schema` first.

Run the codegen command for the appropriate module (refer to the module table in `/update-apollo-schema` skill for namespace, includes path, and output path).

Move the generated file from the project root to its correct location, replacing the existing one.

### 6. Add the Swift Service Method

Follow the established pattern in the codebase:

#### a. Add a typealias (in the protocol file)

```swift
public typealias <ShortName>Data = ApolloAPI.<QueryName>Query.Data.<RootField>
```

#### b. Add the protocol method

```swift
func fetchSomething(args...) async throws -> <ReturnType>
```

#### c. Add the implementation

Follow this exact pattern used by the existing service methods:

```swift
public func fetchSomething(args...) async throws -> <ReturnType> {
    guard let apolloClient = careApolloClient() else { throw IntegrationError.missingApolloClient }

    let query = ApolloAPI.<QueryName>Query(arg1: value1, arg2: value2)

    return try await withCheckedThrowingContinuation { continuation in
        apolloClient.fetch(query: query, cachePolicy: .fetchIgnoringCacheData, contextIdentifier: nil, queue: .main) { result in
            switch result {
            case let .success(data):
                guard data.errors?.isEmpty ?? true else {
                    let message = data.errors?.first?.description ?? "Unable to fetch <description>"
                    continuation.resume(throwing: APIError(domain: .commonServices, description: message))
                    return
                }
                // Handle union type: check success/failure variants
                let response = data.data?.<rootField>
                if let success = response?.as<SuccessType> {
                    continuation.resume(returning: success.<field>)
                } else if let failure = response?.as<FailureType> {
                    continuation.resume(throwing: APIError(domain: .commonServices, description: failure.message))
                } else {
                    continuation.resume(throwing: APIError(domain: .commonServices, description: "Unexpected response"))
                }
            case let .failure(error):
                continuation.resume(throwing: error)
            }
        }
    }
}
```

**For mutations**, use `apolloClient.perform(mutation:)` instead of `apolloClient.fetch(query:)`.

**Key patterns to follow:**
- Always guard `careApolloClient()` first
- Use `withCheckedThrowingContinuation` for async/await bridge
- Use `.fetchIgnoringCacheData` cache policy for queries (or `.fetchIgnoringCacheCompletely` for volatile data)
- Use `publishResultToStore: true` for mutations
- Run on `.main` queue
- Handle GraphQL errors via `data.errors`
- Handle union success/failure types explicitly

### 7. Create DTOs (for queries)

For query return types, create DTO structs that map from the Apollo generated types. This decouples the rest of the app from Apollo's generated code. Mutations that return `Void` or simple success/failure don't need DTOs.

#### Directory structure

Add a `DTO/` folder inside the service directory:

```
<ServiceName>/
├── DTO/
│   ├── SomethingDTO.swift                      # Plain struct
│   └── SomethingDTO+ApolloCompatible.swift     # Mapping extension
├── GraphQL/
│   └── ...
└── ...
```

#### a. Define the DTO struct

Plain structs with `Equatable` conformance. Keep them simple — no Apollo imports.

```swift
import Foundation

public struct SomethingDTO: Equatable {
    public let label: String
    public let type: String
    public let items: [ChildDTO]
}
```

#### b. Add the ApolloCompatible mapping

In a separate `+ApolloCompatible.swift` file, conform to the `ApolloCompatible` protocol (defined in `ios-careapi/CareAPI/CareModules/ApolloCompatible/`):

```swift
import Foundation

extension SomethingDTO: ApolloCompatible {

    public init?(apolloModel: <ApolloGeneratedType>) {
        label = apolloModel.label
        type = apolloModel.type
        items = apolloModel.items.compactMap { ChildDTO(apolloModel: $0) }
    }
}
```

**Guidelines:**
- One DTO per response object level (create DTOs for each nested type)
- Use `compactMap` when mapping arrays of nested DTOs (since `init?` is failable)
- Flatten trivial nested types (e.g., `Money` with just `amount` + `currencyCode` can be flattened into the parent DTO)
- Map enums to `String` via `.rawValue` unless a dedicated enum DTO is needed

#### For Apollo enum input parameters

When a query/mutation takes an Apollo enum as input (e.g., `ApolloAPI.PetCareAnimalType`), also create a DTO enum so callers never import Apollo types. Add an `apolloType` computed property for converting back:

```swift
// DTO definition
public enum SomeEnumDTO: String, CaseIterable {
    case optionA
    case optionB
}

// ApolloCompatible extension
extension SomeEnumDTO: ApolloCompatible {

    public init?(apolloModel: ApolloAPI.SomeEnum) {
        switch apolloModel {
        case .optionA: self = .optionA
        case .optionB: self = .optionB
        case .__unknown: return nil
        }
    }

    public var apolloType: ApolloAPI.SomeEnum {
        switch self {
        case .optionA: return .optionA
        case .optionB: return .optionB
        }
    }
}
```

The service implementation converts DTO inputs to Apollo types internally:
```swift
petTypes: petTypes?.map { $0.apolloType }
```

#### c. Update the service to return DTOs

The protocol method should return the DTO type, and the implementation maps from Apollo types using the `ApolloCompatible` initializer:

```swift
// Protocol
func fetchSomething(...) async throws -> [SomethingDTO]

// Implementation — in the success handler:
let items = success.items.compactMap { SomethingDTO(apolloModel: $0) }
continuation.resume(returning: items)
```

### 8. Clean Up

- Remove `apolloschema.json` from the project root if it's still there
- Run `git diff --stat` to show the user what changed
- Tell the user to build in Xcode to verify compilation

## Reference

- Apollo codegen docs: `ios-care-seeker/Documentation.docc/ApolloGraphQLCodeGeneration.md`
- Context notes: `/Users/jorgequezada/tools/bash_config/claude/ios-care/apollo-graphql/README.md`
- For examples of existing service patterns, read any service under `ios-careapi/CareAPI/CareModules/ApolloServices/` (protocol + Default implementation)
