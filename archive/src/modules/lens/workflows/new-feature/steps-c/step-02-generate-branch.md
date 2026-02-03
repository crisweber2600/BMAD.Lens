---
name: 'step-02-generate-branch'
description: 'Generate branch name for single or cross-microservice feature'
nextStepFile: './step-03-initialize-context.md'
---

# Step 2: Generate Feature Branch Name

## Goal
Generate a branch name using appropriate schema based on feature scope.

---

## Input Variables

```
feature_scope: "single-microservice" | "cross-microservice" | "service-wide"
feature_name: {name}
parent_microservice: {microservice} (single-microservice only)
parent_service: {service}
parent_domain: {domain}
current_phase: {phase}
affected_microservices: [{ms1}, {ms2}, ...] (multi-microservice only)
```

---

## Branch Naming: Single-Microservice Feature

**Pattern:**
```
feature/{phase}/{microservice}/{feature-name}
```

**Example:**
```
feature/implementation/auth-service/add-oauth-2fa
feature/planning/billing-service/invoice-redesign
```

**Process:**
1. Use `parent_microservice` from context
2. Append `feature_name`
3. Prepend `current_phase`
4. Format: kebab-case for all segments

---

## Branch Naming: Cross-Microservice Feature

**Pattern:**
```
feature/{phase}/{service}/{feature-name}
```

**Example:**
```
feature/planning/customer-api/unified-auth-system
feature/implementation/order-service/multi-service-refactor
```

**Process:**
1. Use `parent_service` (NOT individual microservice)
2. Append `feature_name`
3. Prepend `current_phase`
4. Format: kebab-case for all segments

**Note:** Service-level branch allows operations across all affected microservices

**Store affected microservices in state:**
```
.git-lens/branches/{branch-name}/affected-microservices.yaml
  - auth-service
  - user-service
  - api-gateway
```

---

## Branch Naming: Service-Wide Feature

**Pattern:**
```
feature/{phase}/{service}/initiative-{feature-name}
```

**Example:**
```
feature/planning/customer-api/initiative-service-modernization
feature/implementation/payment-service/initiative-migration-to-events
```

**Process:**
1. Use `parent_service`
2. Prepend `initiative-` to feature name (distinguishes from standard features)
3. Prepend `current_phase`
4. Format: kebab-case for all segments

---

## Validate Branch Name

Before proceeding:

```
✓ Does branch name follow correct pattern?
✓ All segments are kebab-case?
✓ Does it include service/microservice context?
✓ Is it unique (doesn't already exist)?
  Check: git branch -a | grep {branch-name}
```

If branch already exists:

```
⚠️  Branch {branch-name} already exists

Options:
  A) Use existing branch
     git checkout {branch-name}
     
  B) Create new with different feature name
     Return to Step 1 and choose different name
     
  C) Append timestamp or counter
     {branch-name}-{timestamp}
```

---

## Output

```
branch_name: {generated}
branch_pattern: {pattern-used}
feature_scope: {scope}
```

---

## Next Step

→ Proceed to **Step 3: Initialize Context**
