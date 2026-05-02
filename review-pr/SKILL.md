---
name: review-pr
description: Reads and reviews a pull request, analyzing the description completeness, code quality, Swift/iOS best practices, and potential bugs. Produces a structured review with Issues / Suggestions / Nitpicks / Positive Notes sections and an overall verdict. Use when the user asks to review a PR, do a code review, or get feedback on a pull request.
license: MIT
metadata:
  author: Jorge Quezada
  version: "1.0"
---

# Review PR

Read and review a pull request, analyzing the description and code changes.

## Arguments
- `$ARGUMENTS` - PR number or URL (optional, will use current branch's PR if not provided)

## Instructions

Follow these steps to review a PR:

1. **Identify the PR:**
   - If PR number/URL provided in `$ARGUMENTS`, use that
   - Otherwise, ask user: "Please provide the PR URL or number you'd like me to review."

2. **Fetch PR details using gh CLI:**
   ```bash
   gh pr view <PR_NUMBER> --json title,body,author,baseRefName,headRefName,state,additions,deletions,changedFiles,comments,reviews
   ```

3. **Fetch the code diff:**
   ```bash
   gh pr diff <PR_NUMBER>
   ```

4. **Analyze and Review:**

   **PR Description Review:**
   - Is the description clear and complete?
   - Does it explain what was changed and why?
   - Is there a linked Jira ticket?
   - Are testing instructions provided?
   - Is the checklist filled out appropriately?

   **Code Review:**
   - Check for code quality and adherence to Swift/iOS best practices
   - Look for potential bugs, edge cases, or error handling issues
   - Check for proper memory management (retain cycles, weak references)
   - Verify async/await and concurrency patterns are correct
   - Check for proper error handling
   - Look for hardcoded values that should be constants
   - Check naming conventions and code readability
   - Identify any security concerns
   - Check for proper separation of concerns
   - Look for missing unit tests if applicable

5. **Provide Structured Feedback:**

   Present your review in this format:

   ```
   ## PR Summary
   - **Title:** [PR title]
   - **Author:** [Author]
   - **Branch:** [head] → [base]
   - **Changes:** +[additions] -[deletions] across [X] files

   ## Description Assessment
   [Evaluate the PR description completeness and clarity]

   ## Code Review Findings

   ### Issues (Must Fix)
   - [Critical issues that should be addressed]

   ### Suggestions (Should Consider)
   - [Improvements that would enhance the code]

   ### Nitpicks (Optional)
   - [Minor style or preference items]

   ### Positive Notes
   - [Things done well worth highlighting]

   ## Overall Assessment
   [Summary verdict: Approve / Request Changes / Needs Discussion]
   ```

6. **Offer to add review comments:**
   - Ask if user wants you to submit review comments via `gh pr review`

## Example Commands

```bash
# View PR details
gh pr view 123 --json title,body,author,baseRefName,headRefName,state,additions,deletions,changedFiles

# View PR diff
gh pr diff 123

# View specific file changes
gh pr diff 123 -- path/to/file.swift

# Submit a review
gh pr review 123 --comment --body "Review comments here"
gh pr review 123 --approve --body "LGTM!"
gh pr review 123 --request-changes --body "Please address the following..."
```

## Notes

- Focus on substantive issues over style nitpicks
- Consider the context and scope of the PR
- Be constructive and specific in feedback
- Reference specific line numbers when pointing out issues
- Consider both the immediate changes and their broader impact
