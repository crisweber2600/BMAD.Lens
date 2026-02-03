---
name: 'step-03.5-multi-microservice-detection'
description: 'Detect and configure cross-microservice feature scope'
nextStepFile: './step-01-collect-metadata.md'
conditional: 'if lens_detected == "service"'
---

# Step 3.5: Multi-Microservice Scope Detection

## Goal
Detect if this is a cross-microservice feature and identify all affected microservices.

**Applies to:** Features running at **Service lens** only  
**Skipped for:** Features running at **Feature lens**

---

## Context

You're operating at **Service lens**, which means this feature could impact multiple microservices within the service. This step helps identify which microservices are affected and establishes coordination.

---

## Decision: Feature Scope

### Question: How Many Microservices Does This Feature Touch?

Display options:

```
What's the scope of this feature?

A) Single Microservice
   → Only affects one microservice within the service
   → Proceed as standard feature workflow
   
B) Multiple Microservices
   → Affects 2+ microservices
   → Requires cross-microservice coordination
   → Will collect affected microservices
   
C) Service-Wide / Infrastructure
   → Affects the entire service or infrastructure
   → Impacts all/most microservices
   → Will mark as service-level initiative

D) Not sure - Help me decide
   → Show decision tree
```

---

## Decision Tree: "Not Sure - Help Me Decide"

```
Does this feature change APIs or contracts?
  ├─ YES: Likely multi-microservice (affects consumers)
  │   └─ → Multiple Microservices
  └─ NO: Likely single-microservice
      └─ → Single Microservice

Does this feature require changes in 2+ microservices?
  ├─ YES: → Multiple Microservices
  └─ NO: 
      ├─ Does it affect infrastructure, deployment, or shared resources?
      │   ├─ YES: → Service-Wide / Infrastructure
      │   └─ NO: → Single Microservice
      └─ → Single Microservice

Does this feature involve data model changes?
  ├─ YES: Check if database is shared or separate
  │   ├─ SHARED: → Multiple Microservices (or Service-Wide)
  │   └─ SEPARATE: Could be single-microservice
  └─ NO: Continue evaluation
```

---

## Workflow: Single Microservice Selected

```
✓ This feature is single-microservice
  → Downgrade to Feature-level workflow
  → Ask which microservice?
  
  Options:
    - List all microservices in service
    - User selects one
    - Dynamically change parent context: parent_microservice = {selected}
    
✓ Continue to Step 4: Metadata Collection
  → Will use single-microservice branch pattern
  → Feature branch will be scoped to microservice
```

**Store:**
```
feature_scope: "single-microservice"
parent_microservice: {user-selected}
affected_microservices: [{user-selected}]
multi_microservice_mode: false
```

---

## Workflow: Multiple Microservices Selected

```
✓ This feature is cross-microservice
  → Collect all affected microservices
  → Will coordinate updates across multiple services
  
  Steps:
    1. List all microservices in service
    2. Ask user to select affected microservices
       (allow multi-select)
    3. Validate selections
    4. Store affected microservices list
```

**Collect affected microservices:**

```
Which microservices does this feature affect?

Available microservices in {service}:
  □ auth-service
  □ user-service  
  □ api-gateway
  □ notification-service
  □ billing-service
  
Selected:
  ✓ auth-service
  ✓ api-gateway
  ✓ user-service

Confirmed: 3 microservices affected
```

**Store:**
```
feature_scope: "cross-microservice"
parent_service: {service}
affected_microservices: [auth-service, user-service, api-gateway]
multi_microservice_mode: true
coordination_required: true
```

---

## Workflow: Service-Wide / Infrastructure Selected

```
✓ This feature is service-wide
  → Affects service infrastructure or all microservices
  → Will be flagged for service-level coordination
  
  Consider:
    - Should this be an Initiative instead of a Feature?
    - Requires approval from service architect/lead?
    - Should all microservices be in affected list?
```

**Prompt:**

```
⚠️  Service-Wide Feature Detected

This may be better tracked as an Initiative rather than a Feature.

Options:
  A) Proceed as service-wide feature (all microservices affected)
  B) Create as Initiative instead (for major changes)
  C) Narrow scope to specific microservices
  
Recommendation: Consult git-lens regarding initiative vs. feature
  Workflow: git-lens status
  Then: git-lens start-phase or return to narrow scope
```

**If proceed as service-wide feature:**

```
feature_scope: "service-wide"
parent_service: {service}
affected_microservices: [all microservices in service]
multi_microservice_mode: true
service_wide_flag: true
requires_coordination: true
```

---

## Casey Integration (git-lens)

### Casey Will Track

For cross-microservice features, Casey records:

```
Feature: {feature-name}
Scope: cross-microservice
Service: {service}
Affected Microservices:
  - auth-service
    Dependencies: [user-service, api-gateway]
    Estimated Impact: High (auth changes affect multiple services)
    
  - user-service
    Dependencies: [api-gateway]
    Estimated Impact: Medium
    
  - api-gateway
    Dependencies: [all]
    Estimated Impact: Critical (gateway changes affect all)
```

### Coordination Planning

When feature is later worked on:

- Casey will suggest **review coordination** across affected microservices
- Tracey will track **integration checkpoints** between microservices
- Teams will be notified of **cross-microservice testing requirements**

---

## Output Variables

After this step, store all of:

```
feature_scope: "single-microservice" | "cross-microservice" | "service-wide"
parent_service: {service}
parent_domain: {domain}
parent_microservice: {microservice} (single-microservice mode only)
affected_microservices: [{ms1}, {ms2}, ...] (multi-microservice mode)
multi_microservice_mode: true | false
coordination_required: true | false
service_wide_flag: false | true
```

---

## Next Step

→ Proceed to **Step 4: Collect Feature Metadata** (step-01-collect-metadata.md)

The metadata collection will adapt based on `feature_scope` and `affected_microservices`.
