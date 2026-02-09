```prompt
---
mode: 'agent'
agent: 'bmad-agent-lens-work-compass'
description: 'Check compliance of current initiative against lens-work rules'
---

Check compliance for my current initiative.

$ARGUMENTS

## Instructions
1. Load current initiative config from initiatives/{active_initiative}.yaml
2. Validate: required fields present, gates properly configured, branch topology correct
3. Check artifact completeness for current phase
4. Report compliance status with pass/warn/fail indicators

```
