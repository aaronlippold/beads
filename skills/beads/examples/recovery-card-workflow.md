# Recovery Card Workflow Example

## Scenario

You're working on Vulcan v2.3.0 stabilization. You need to compact due to low context. A week later, you return to the project.

## Session End (Before Compact)

```bash
# Check for existing recovery card
bd list --status in_progress | grep -i recovery

# Update the recovery card (vulcan-clean-4rp exists)
bd update vulcan-clean-4rp --description "$(cat <<'EOF'
Context from Dec 20, 2025:

COMPLETED THIS SESSION:
- Fixed MCP Docker → binary/npx for VPN compatibility
- Setup YubiKey + age encryption for chezmoi
- Centralized all certs to ~/.certs/
- Closed e21 (Admin Panel) - all 7 phases implemented

IN PROGRESS:
- ze9 Stabilization (P0) - Run: bd show vulcan-clean-ze9
  - ze9.1: Command Palette 404 fix
  - ze9.2: Commit 15 uncommitted files
  - ze9.5: STIGs page intermittent 404

GIT STATUS:
- Branch: v2.3.0
- Commits ahead: 54
- Uncommitted changes: Yes, 15 files

NEXT STEPS:
1. Run git status to review changes
2. Start with ze9.1 (Command Palette 404)
3. Run foreman start -f Procfile.dev (Vulcan on port 3000)

BLOCKERS/NOTES:
- bdui running on port 4001 (not 3000)
- aga (Performance) still needs frontend work
- xzy (Find/Replace) modal refactor pending
EOF
)"

# Sync beads
bd sync

# Verify
bd show vulcan-clean-4rp
```

## User Runs Compact

```
/compact
```

## Session Start (After Compact)

**Recovery prompt (from prepare-compact):**
```
Working directory: /Users/alippold/github/mitre/vulcan-clean

Run: bd ready

The "RECOVERY: Current Session Context" card contains full context.
Read it, follow its instructions, then close it when ready to continue.
```

**Claude executes:**

```bash
# 1. Check for recovery card
bd ready
# Output shows: vulcan-clean-4rp: RECOVERY: Current Session Context [P0 - in_progress]

# 2. Read the card
bd show vulcan-clean-4rp
# Reads full context from description

# 3. Restore TodoWrite
TodoWrite: [
  "Verify git status (15 uncommitted files)",
  "Fix Command Palette 404 (ze9.1)",
  "Commit uncommitted changes (ze9.2)"
]

# 4. Close recovery card
bd close vulcan-clean-4rp --reason "Context restored, continuing with ze9 stabilization"

# 5. Continue with next task
bd show vulcan-clean-ze9
# Reads epic details

# 6. Start work
bd update vulcan-clean-ze9.1 --status=in_progress
# Begin implementation
```

## Key Benefits

- ✅ No context lost after compact
- ✅ Full state preserved in beads
- ✅ Recovery card provides explicit next steps
- ✅ Git status documented
- ✅ Blockers and notes preserved

## Anti-Pattern

**DON'T:**
```bash
# Compact without updating recovery card
/compact

# Week later...
"What was I working on?" ❌
```

**DO:**
```bash
# Update recovery card first
bd update recovery-card --description "..."
bd sync

# Then compact
/compact

# Week later...
bd ready  # Recovery card tells you everything ✅
```
