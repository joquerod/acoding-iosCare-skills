---
name: submit-pr
description: Creates a GitHub pull request for the current branch following the Care iOS repository standards - extracts the Jira ticket from the branch name, fills the PR template (Description, Checklist, How to test, Proof of work), and submits via the gh CLI. Use when the user asks to create a PR, submit a pull request, or open a PR. Required by CLAUDE.md - do not create PRs manually.
license: MIT
metadata:
  author: Jorge Quezada
  version: "1.0"
---

# Submit PR

Create a pull request for the current branch following the Care iOS repository standards.

## Instructions

Follow these steps to create a PR:

1. **Check current branch and git status:**
   - Verify you're on the correct branch
   - Ensure all changes are committed
   - Check if branch is pushed to remote

2. **Gather information:**
   - Ask user for Jira ticket number if not obvious from branch name
     - Extract from branch name if possible (e.g., "jorge.quezada/APPHEALTH-885-feature" → "APPHEALTH-885")
   - If no Jira ticket, ask user to provide it or confirm none exists
   - Ask for target base branch (default: `main`)

3. **Analyze changes:**
   - Review git log to understand commits since branch diverged from base
   - Review git diff to understand code changes
   - Prepare a clear description of what was changed and why

4. **Ask user for additional context:**
   - How to test the changes (if not obvious from the code)
   - Any screenshots/videos for proof of work (provide instructions if needed)
   - Confirm which checklist items apply

5. **Create PR using gh CLI:**
   - Ensure branch is pushed: `git push -u origin <branch-name>`
   - Use the PR template below with HEREDOC format
   - Title format: `TICKET-XXX: Brief description` (or just brief description if no ticket)
   - Fill in all template sections based on your analysis and user input

6. **Return the PR URL** to the user

## PR Template

```markdown
Jira ticket: [TICKET-XXX](https://carecom.atlassian.net/browse/TICKET-XXX)

## Description
<!-- What is the feature? -->
<!-- What are the motivations behind these changes? -->
<!-- How you implemented the solution? -->
<!-- What is the current behavior, and the new behavior (if this is a feature change)? -->
<!-- Does it impact any other area of the project? -->

## Checklist
Documentation (check at least one):
- [ ] My code is appropriately commented, particularly in hard-to-understand areas.
- [ ] I have made corresponding changes to the documentation.
- [ ] No code changes

Testing (check at least one):
- [ ] Unit tests are written to cover my changes.
- [ ] The code I changed is currently impossible to unit test.
- [ ] I have manually tested my changes to verify my fix is effective or that my feature works.
- [ ] No code changes

General:
- [ ] My changes generate no new warnings.

## How to test?
<!--- Please describe the tests that you ran to verify your changes. Provide instructions so we can reproduce. Please also list any relevant details for your test configuration -->
* ...
* ...
  * ...

## Proof of work
<!-- Show us the implementation: screenshots, videos, GIFs, etc. -->

| Before | After |
|--------|-------|
| <!-- Add screenshots if applicable --> | <!-- Add screenshots if applicable --> |
```

## Example gh Command

```bash
gh pr create --base main --title "APPHEALTH-XXX: Brief description" --body "$(cat <<'EOF'
Jira ticket: [APPHEALTH-XXX](https://carecom.atlassian.net/browse/APPHEALTH-XXX)

## Description
[Detailed description based on code analysis]

## Checklist
Documentation (check at least one):
- [x] My code is appropriately commented, particularly in hard-to-understand areas.
- [ ] I have made corresponding changes to the documentation.
- [ ] No code changes

Testing (check at least one):
- [x] I have manually tested my changes to verify my fix is effective or that my feature works.
- [ ] Unit tests are written to cover my changes.
- [ ] The code I changed is currently impossible to unit test.
- [ ] No code changes

General:
- [x] My changes generate no new warnings.

## How to test?
[Testing instructions]

## Proof of work
[Description or note about screenshots]
EOF
)"
```

## Multiple PRs with Different Base Branches

When submitting to both a release branch and `main`, **each PR must have its own branch**:

1. **Create the release PR first** from the feature branch (e.g., `jorge.quezada/TICKET-123`)
   - Base: `core-provider-app/release/XX.XX`
2. **Create a separate branch for main:**
   ```bash
   git fetch origin main
   git checkout -b jorge.quezada/TICKET-123-main origin/main
   git cherry-pick <commit-hash>
   git push -u origin jorge.quezada/TICKET-123-main
   ```
3. **Create the main PR** from the new branch
   - Base: `main`
   - Reference the release PR in the description (e.g., "Release cherry-pick: #XXXX")

**Never reuse the same branch for both PRs.** The branches have different base commits — reusing causes merge conflicts or incorrect diffs.

## Important Notes

- Always verify branch is pushed before creating PR
- Use HEREDOC format for proper multi-line formatting
- Default base branch is `main` unless specified otherwise
- Pre-check appropriate checklist items based on the changes (check at least one in each section)
- For release branches, follow the cherry-pick workflow from /Users/jorgequezada/tools/bash_config/claude/ios-care/pr.md
- Don't commit or push code unless user explicitly asks - only create the PR

## Error Handling

- If branch is not pushed, push it first
- If no commits exist, inform user they need to commit changes first
- If gh CLI is not installed or authenticated, provide instructions
