# Troubleshooting

## Common Issues

### "No active initiative"

**Symptom:** Commands fail with "no active initiative" error.
**Fix:** Create one with `/new` or switch to an existing one with `/switch`.

### State file missing

**Symptom:** State.yaml not found.
**Fix:** Run `/onboard` to initialize, or `/sync` if it was accidentally deleted.

### State corruption

**Symptom:** State shows incorrect phase or initiative data.
**Fix:**
1. Try `/sync` first — reconciles with git reality
2. If that doesn't work, try `/fix` — rebuilds from event log
3. Last resort: `/override` — manual edit (use carefully)

### Branch doesn't exist

**Symptom:** Git checkout fails for expected branch.
**Fix:**
1. Run `/sync` to detect drift
2. Check if branches were manually deleted
3. Use `/fix` if state references non-existent branches

### Constitution violations blocking progress

**Symptom:** Can't advance to next phase due to governance checks.
**Fix:**
1. Read the cited rule and remediation path
2. Produce the missing artifacts
3. Use `/Review` to see all blockers
4. If in advisory mode, violations warn but don't block

### Background errors

**Symptom:** `/status` shows background errors.
**Fix:**
1. Read the error details in state.yaml `background_errors` array
2. Address the root cause
3. Run `/sync` to clear resolved errors
4. Errors are also in event-log.jsonl for history

### Old lens-work state

**Symptom:** State references old lens-work paths or agents.
**Fix:** See [Migration from lens-work](migration-from-lens-work.md) for migration steps.

## Recovery Commands

| Command | When to Use |
|---------|-------------|
| `/sync` | State seems wrong, branches missing |
| `/fix` | State is corrupted, /sync didn't help |
| `/override` | Need manual state edit (advanced) |
| `/resume` | Workflow was interrupted |

## Diagnostic Commands

| Command | What It Shows |
|---------|---------------|
| `/status` | Compact initiative state |
| `/lens` | Full context with all details |
