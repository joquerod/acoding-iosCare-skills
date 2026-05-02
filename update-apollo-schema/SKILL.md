---
name: update-apollo-schema
description: Updates the Apollo GraphQL schema and regenerates Swift code for a specified module (Care, CareAPI, IdentityVerification, EnterpriseBenefitAPI, MessagingAPI, BookingAPI, NotificationCenterAPI, etc.). Handles schema placement, codegen script discovery, regeneration, and file replacement. Use when the user asks to update the Apollo schema, regenerate GraphQL code, or refresh a `.generated.swift` file.
license: MIT
metadata:
  author: Jorge Quezada
  version: "1.0"
---

# Update Apollo Schema

Update the Apollo GraphQL schema and regenerate Swift code for a specified module.

## Usage

```
/update-apollo-schema [path-to-schema-json]
```

If no path is provided, check for `apolloschema.json` in the project root. If not found, prompt the user to download it from Apollo Studio.

## Steps

### 1. Place the Schema

If the user provides a file path as an argument:
- Copy the file to the project root, renaming it to `apolloschema.json` regardless of its original name (e.g., `schema.json`, `schema(1).json`, `dev-schema.json`, etc.)

If no argument is provided:
- Check if `apolloschema.json` already exists in the project root
- If not, instruct the user:
  1. Go to **Apollo GraphQL Studio** in Care Apps Dashboard
  2. Select the **dev** graph (use lifemart graph only for LifemartAPI)
  3. Hover over **Schema** on the left menu, choose **Schema definition**
  4. Download and change format to **JSON**
  5. Save as `apolloschema.json` in the project root

### 2. Ask Which Module to Regenerate

Present the available modules and ask the user to select one:

| # | Module | Namespace | .graphql Path | Output Path |
|---|--------|-----------|--------------|-------------|
| 1 | Entitlements | `EntitlementsAPI` | `Entitlements/Entitlements/Apollo/**/*.graphql` | `Entitlements/Entitlements/Apollo/EntitlementsAPI.generated.swift` |
| 2 | Care (Seeker) | `Care` | `ios-care-seeker/Care/Data/Webservices/**/*.graphql` | `ios-care-seeker/Care/Data/Webservices/Care.generated.swift` |
| 3 | IdentityVerification | `IdentityVerificationService` | `ios-care-seeker/Care/Data/IdentityVerificationService/**/*.graphql` | `ios-care-seeker/Care/Data/IdentityVerificationService/IdentityVerificationService.generated.swift` |
| 4 | EnterpriseBenefitAPI | `EnterpriseBenefitAPI` | `ios-care-seeker/Care/EnterpriseBenefits/CareModules/GraphQL/**/*.graphql` | `ios-care-seeker/Care/EnterpriseBenefits/CareModules/GraphQL/EnterpriseBenefitAPI.generated.swift` |
| 5 | ApolloServiceAPI (CareAPI) | `ApolloAPI` | `ios-careapi/CareAPI/CareModules/ApolloServices/**/*.graphql` | `ios-careapi/CareAPI/CareModules/ApolloServices/ApolloServiceAPI.generated.swift` |
| 6 | LifemartAPI (diff schema) | `LifemartAPI` | `ios-careapi/CareAPI/CareModules/LifemartServices/**/*.graphql` | `ios-careapi/CareAPI/CareModules/LifemartServices/LifemartAPI.generated.swift` |
| 7 | FreeGatedAPI | `FreeGatedAPI` | `ios-caregiver/Care/FreeGated/API/**/*.graphql` | `ios-caregiver/Care/FreeGated/API/Query/FreeGatedAPI.generated.swift` |
| 8 | PolygonGQL | `PolygonGQL` | `ios-caregiver/Care/Polygon/**/*.graphql` | `ios-caregiver/Care/Polygon/PolygonGQL.generated.swift` |
| 9 | NotificationCenterAPI | `NotificationCenterAPI` | `ios-caregiver/Care/NotificationCenter/API/**/*.graphql` | `ios-caregiver/Care/NotificationCenter/API/NotificationCenterAPI.generated.swift` |
| 10 | BookingAPI | `BookingAPI` | `ios-job-management/JobManagement/SchedulingUI/CareModules/BookingService/**/*.graphql` | `ios-job-management/JobManagement/SchedulingUI/CareModules/BookingService/BookingAPI.generated.swift` |
| 11 | JobMatches | `JobMatches` | `ios-job-management/JobManagement/PrematchUI/CareModules/JobMatchesKeeper/**/*.graphql` | `ios-job-management/JobManagement/PrematchUI/CareModules/JobMatchesKeeper/JobMatches.generated.swift` |
| 12 | MessagingAPI | `MessagingAPI` | `ios-messagingui/MessagingUI/CareModules/**/*.graphql` | `ios-messagingui/MessagingUI/CareModules/MessagingAPI.generated.swift` |
| 13 | ProfileManagement | `ProfileManagementAPI` | `ios-profile-management/ProfileManagement/GraphQL/**/*.graphql` | `ios-profile-management/ProfileManagement/GraphQL/ProfileManagementAPI.generated.swift` |

### 3. Find the Codegen Script

Search for `run-bundled-codegen.sh` in DerivedData:

```bash
find "$HOME/Library/Developer/Xcode/DerivedData" -name "run-bundled-codegen.sh" -path "*/apollo-ios/scripts/*" 2>/dev/null | head -1
```

If not found, tell the user to build the project in Xcode first (Apollo iOS SPM package must be resolved).

### 4. Run Code Generation

Run the codegen command from the project root:

```bash
<codegen-script-path> codegen:generate --target=swift --namespace="<namespace>" --includes="<graphql-path>" --localSchemaFile="apolloschema.json" <output-filename>
```

**Module-specific notes:**
- **IdentityVerification**: Add `--passthroughCustomScalars` flag
- **LifemartAPI**: Requires a separate schema downloaded from the lifemart graph
- **FreeGatedAPI**: After generation, compile and fix name conflicts: change `ApprovalStatus.self` to `FreeGatedAPI.ApprovalStatus.self`

### 5. Replace the Generated File

Move the generated `.generated.swift` file from the project root to its output path (shown in the table above), replacing the existing file.

### 6. Verify

- Run `git diff --stat` on the `.generated.swift` file to confirm it changed
- Tell the user to build the project to verify compilation

### 7. Clean Up

- Remove `apolloschema.json` from the project root (it's gitignored but keep things tidy)
- Do NOT commit the schema file

### 8. Next Steps

After regeneration, suggest to the user:
> If you need to add a new query/mutation and build the Swift service to consume it, run `/add-graphql-api`.

## Reference

- Full documentation: `ios-care-seeker/Documentation.docc/ApolloGraphQLCodeGeneration.md`
- Interactive helper script: `tools/apollo-codegen/apollo-codegen.sh`
- Context notes: `/Users/jorgequezada/tools/bash_config/claude/ios-care/apollo-graphql/README.md`
