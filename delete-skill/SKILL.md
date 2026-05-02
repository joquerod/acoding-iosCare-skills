---
name: delete-skill
description: Removes a Claude skill - deletes symlinks from all ios-care-app* worktrees first, then removes the source directory from the shared acoding-iosCare-skills repo. Use when the user asks to delete a skill, remove a slash command, or clean up an unused skill.
license: MIT
metadata:
  author: Jorge Quezada
  version: "1.0"
---

# Delete a Claude Skill

When the user asks to delete/remove a skill, follow these steps:

## 1. Remove symlinks from all repos

Find all repos with the `ios-care-app` prefix and remove the symlink from each one:

```bash
for repo in /Users/jorgequezada/Development/care/ios-care-app*; do
  rm -f "$repo/.claude/skills/<skill-name>"
done
```

## 2. Delete the source directory

Remove the skill directory from the shared skills repo:
```bash
rm -rf /Users/jorgequezada/tools/acoding-iosCare-skills/<skill-name>
```

## 3. Verify

Confirm the source and all symlinks are gone:
```bash
ls -la /Users/jorgequezada/tools/acoding-iosCare-skills/<skill-name> 2>/dev/null && echo "Source still exists!" || echo "Source removed"
ls -la /Users/jorgequezada/Development/care/ios-care-app*/.claude/skills/<skill-name> 2>/dev/null && echo "Symlinks still exist!" || echo "All symlinks removed"
```

## Important Notes

- **Always remove symlinks first**, then the source directory. Removing source first leaves broken symlinks.
- **Shared location**: `/Users/jorgequezada/tools/acoding-iosCare-skills/`
- This skill cannot delete itself.
