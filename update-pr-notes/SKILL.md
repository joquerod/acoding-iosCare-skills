---
name: update-pr-notes
description: Updates the existing pull request description for the current branch based on all commits since branching from main, following the Care iOS PR template (Jira ticket, Description, Checklist, How to test, Proof of work). Use when the user asks to update the PR notes, refresh the PR description, or sync the PR body with the latest changes.
license: MIT
metadata:
  author: Jorge Quezada
  version: "1.0"
---

# Update PR Notes

Update the pull request description for the current branch based on latest changes:

1. Get the current PR for this branch using `gh pr view --json number,title,body,url`
2. Check git log to understand all commits since branching from main: `git log main..HEAD --oneline`
3. Review the changes using `git diff main...HEAD --stat` to understand scope
4. Update the PR description following this template structure:

```
Jira ticket: [TICKET-XXX](https://carecom.atlassian.net/browse/TICKET-XXX)

## Description
[Analyze ALL commits and changes to write comprehensive description covering:
- What is the feature/fix?
- What are the motivations behind these changes?
- How was the solution implemented?
- Current vs new behavior (if applicable)
- Impact on other areas]

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
[Provide clear testing instructions based on the changes]

## Proof of work
[Keep existing screenshots/videos if present, or note if needed]
```

5. Update the PR using gh command:
   ```
   gh pr edit --body "$(cat <<'EOF'
   [PR body here]
   EOF
   )"
   ```

6. Return the updated PR URL when done

Important notes:
- Preserve the Jira ticket from the existing PR if present
- Use HEREDOC format for multi-line PR bodies to preserve formatting
- Keep any existing "Proof of work" content (screenshots/videos)
- Make sure description reflects ALL changes, not just the latest commit
