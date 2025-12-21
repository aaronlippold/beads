# Recovery Card Pattern - Pressure Test

## Test Objective

Verify that the Recovery Card Pattern actually helps Claude restore context after compaction, and that Claude will use it proactively.

## RED Phase: Baseline (Without Recovery Card Pattern)

### Scenario Setup

**Context:**
- Working on multi-phase feature (auth system - 5 phases)
- Completed Phase 1, Phase 2 in progress
- 15 uncommitted files
- 3 beads open, 2 in progress
- Token usage: 85% (approaching limit)

**Pressure combination:**
- Time pressure (need to compact now)
- Information overload (lots of state to preserve)
- No explicit pattern (rely on Claude's natural behavior)

### Test Prompt (RED - No Recovery Card Pattern)

```markdown
IMPORTANT: This is a real scenario. Act naturally based on your training.

You're working on an authentication system (5 phases). Status:
- Phase 1: Complete (JWT working)
- Phase 2: 60% done (OAuth in progress, Google works, GitHub pending)

Current beads:
- auth-phase-2: in_progress
- fix-oauth-error: open
- add-rate-limiting: open (blocked by Phase 2)

Git status:
- Branch: feat/auth
- 15 uncommitted files (controllers, tests, migrations)
- 8 commits ahead of origin

Token usage: 85% - you need to compact NOW.

What do you do to prepare for /compact? Be specific about actual commands you'd run.
```

### Expected RED Behavior (Failure Modes)

Document what Claude does WITHOUT the recovery card pattern:

- [ ] Does Claude update beads at all before compact?
- [ ] Does Claude create any kind of recovery mechanism?
- [ ] What information does Claude preserve?
- [ ] What information is lost?
- [ ] How does Claude attempt to restore context after compact?

## GREEN Phase: With Recovery Card Pattern

### Test Prompt (GREEN - With Recovery Card Pattern in SKILL.md)

```markdown
IMPORTANT: You have access to the beads-task-management skill with Recovery Card Pattern.

Same scenario as RED test:

You're working on an authentication system (5 phases). Status:
- Phase 1: Complete (JWT working)
- Phase 2: 60% done (OAuth in progress, Google works, GitHub pending)

Current beads:
- auth-phase-2: in_progress
- fix-oauth-error: open
- add-rate-limiting: open (blocked by Phase 2)

Git status:
- Branch: feat/auth
- 15 uncommitted files (controllers, tests, migrations)
- 8 commits ahead of origin

Token usage: 85% - you need to compact NOW.

What do you do to prepare for /compact?
```

### Expected GREEN Behavior (Success Criteria)

- [ ] Claude creates/updates recovery card with title "RECOVERY: Current Session Context"
- [ ] Recovery card marked in_progress, P0
- [ ] Recovery card notes contain:
  - [ ] COMPLETED THIS SESSION section
  - [ ] IN PROGRESS section with bd show commands
  - [ ] GIT STATUS with branch, commits, uncommitted files
  - [ ] NEXT STEPS with explicit actions
  - [ ] BLOCKERS if any
- [ ] Claude runs `bd sync` before compact
- [ ] Claude provides compact recovery prompt

### After Compaction - Restoration Test

**Prompt:**
```markdown
[After /compact in RED test]

You just compacted. Continue working on the auth system.
```

**vs**

```markdown
[After /compact in GREEN test]

Working directory: ~/project

Run: bd ready

Continue working on the auth system.
```

**Measure:**
- How long to restore context?
- What information is recovered?
- What questions does Claude need to ask?
- Can Claude continue immediately or needs user input?

## REFACTOR Phase: Identify Rationalizations

### Potential Failure Modes to Test

**Rationalization 1: "I'll just update the in-progress bead"**
- Agent updates auth-phase-2 notes instead of creating recovery card
- Miss: Git status, overall session context, cross-bead state

**Rationalization 2: "Recovery card is extra work"**
- Agent skips recovery card due to time pressure
- Result: Poor context restoration after compact

**Rationalization 3: "The notes in each bead are enough"**
- Agent distributes context across multiple beads
- Result: No single source of truth, have to read 3+ beads to restore

**Rationalization 4: "I'll remember to check beads after compact"**
- Agent doesn't provide explicit recovery prompt
- Result: User forgets, or future Claude doesn't know where to look

### Counters to Add if Failures Occur

```markdown
## Red Flags - STOP

- Updating in-progress bead notes instead of recovery card
- "Recovery card is extra overhead" or "too much work"
- Distributing session context across multiple beads
- Skipping recovery card due to time pressure
- "I'll document this in the bead notes" (which bead? recovery card is THE bead)
```

## Verification Criteria

Recovery Card Pattern is bulletproof when:

- [ ] Claude creates recovery card unprompted when approaching compact
- [ ] Recovery card follows exact naming convention
- [ ] All critical context captured (git status, next steps, blockers)
- [ ] After compact, Claude reads recovery card first
- [ ] Claude can continue work with zero user questions about "where were we?"
- [ ] Pattern holds under time pressure (85%+ token usage)

## Test Results

### RED Test Results:
[Document actual Claude behavior without pattern]

### GREEN Test Results:
[Document Claude behavior with pattern]

### Rationalizations Found:
[List any new ways Claude tries to skip or work around the pattern]

### Pattern Refinements:
[Changes made to SKILL.md based on test results]
