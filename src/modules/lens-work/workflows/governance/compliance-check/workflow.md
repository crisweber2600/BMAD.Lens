---
name: compliance-check
description: Validate artifacts against resolved constitutional rules
agent: scribe
trigger: /compliance command
category: governance
phase: N/A
---

# Compliance Check Workflow — Governance

Evaluate an artifact against accumulated constitutional rules from the LENS inheritance chain.

## Role

You are **Scribe (Cornelius)**, the Constitutional Guardian, evaluating artifact compliance.

---

## Step 0: Git Discipline — Verify Clean State

Invoke Casey to verify clean git state.

```
casey.verify-clean-state
```

---

## Step 1: Get Artifact

Ask user for the artifact to evaluate:

```
📜 Constitutional Compliance Check

Which artifact should I evaluate?

1. Enter a file path (e.g., _bmad-output/planning-artifacts/archive-migration/prd.md)
2. Select artifact type:
   - [P] PRD
   - [A] Architecture document
   - [S] Story/Epic
   - [C] Code file

[Enter path or type]
```

Validate artifact exists and is readable. Load its content.

---

## Step 2: Resolve Constitution

Call resolve-constitution logic to get accumulated rules for current context:

1. Determine hierarchy from active initiative
2. Walk chain parent-first: Domain → Service → Microservice → Feature
3. Collect all applicable articles

```
Resolving constitution for current context...

Found {constitution_count} constitution(s):
{list constitutions}

Total articles to check: {article_count}
```

**If no constitutions found:**
```
📜 No rules defined. Compliance check not applicable.

There are no constitutions governing this context.
This is expected if governance has not been configured for this scope.
```

Exit gracefully — this is not an error.

---

## Step 3: Evaluate Each Article

For each article in the resolved constitution, evaluate the artifact:

1. Read the article's rule and evidence requirements
2. Search the artifact for:
   - Direct mention of the requirement
   - Section addressing the topic
   - Evidence matching the required evidence type
   - Implicit compliance through design/content

3. Classify each article:
   - **PASS** — Clear evidence of compliance found in artifact
   - **WARN** — Topic not addressed, may need attention (not verified)
   - **FAIL** — Direct contradiction or explicit non-compliance found

```
Evaluating Article {id}: {title}...
```

---

## Step 4: Generate Report

### Report Header

```
📜 Constitutional Compliance Review

Artifact: {artifact_path}
Type: {artifact_type}
Context: {layer} — {name}

Checking against: {constitution_count} constitution(s), {article_count} articles
Date: {today_date}

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### Verdict

Determine overall verdict:
- Any FAIL → **NON-COMPLIANT**
- All PASS → **COMPLIANT**
- Mix of PASS and WARN → **CONDITIONAL PASS**

```
{if COMPLIANT:}
✅ VERDICT: COMPLIANT
All {article_count} articles satisfied.

{if CONDITIONAL PASS:}
⚠️ VERDICT: CONDITIONAL PASS
{pass_count} satisfied, {warn_count} not verified, 0 violations.

{if NON-COMPLIANT:}
❌ VERDICT: NON-COMPLIANT
{fail_count} violation(s) detected.
```

### Detailed Results

```
## Results by Article

{for each article:}

{PASS|WARN|FAIL} Article {id}: {title} — {status}

  {if PASS:}
  Evidence: {evidence_quote_or_section}
  Location: {section_reference}

  {if WARN:}
  Expected: {expected_evidence}
  Found: No mention of {topic}
  Recommendation: Add section addressing {requirement}

  {if FAIL:}
  Issue: {violation_description}
  Location: {section_reference}
  Required Action: {remediation}

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### Summary

```
## Summary

N/total PASS | N/total WARN | N/total FAIL

{if recommendations:}
## Recommendations
{numbered list of items to address}
```

---

## Step 5: Event Logging

Log compliance evaluation through Tracey:

```yaml
type: compliance-evaluated
timestamp: {now}
artifact_path: {artifact_path}
artifact_type: {artifact_type}
constitution_resolved: {list of constitutions checked}
pass_count: {pass_count}
warn_count: {warn_count}
fail_count: {fail_count}
initiative_id: {active_initiative_id}  # REQUIRED for compliance events
```

Note: `initiative_id` is **required** for compliance events (compliance always runs in initiative context).

---

## Completion

```
Compliance check complete.

{if violations:}
- Fix violations and re-check → /compliance
{endif}
- View full constitution → /resolve
- Show ancestry → /ancestry
- Return to Compass → exit
```
