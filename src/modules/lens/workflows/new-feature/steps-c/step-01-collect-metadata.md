---
name: 'step-01-collect-metadata'
description: 'Collect feature metadata (single or multi-microservice)'
nextStepFile: './step-02-generate-branch.md'
---

# Step 1: Collect Feature Metadata

## Goal
Capture feature scope and metadata for branch creation.

---

## Input Variables

Check context from previous steps:

```
feature_scope: "single-microservice" | "cross-microservice" | "service-wide"
parent_microservice: {microservice} (if single-microservice)
affected_microservices: [{ms1}, {ms2}, ...] (if cross-microservice)
parent_service: {service}
parent_domain: {domain}
current_phase: {phase}
```

---

## Metadata Collection: Single-Microservice Feature

**If `feature_scope` = "single-microservice":**

```
Collect:
  - Feature name (required)
    Example: "add-oauth-2fa"
    Validate: kebab-case
    
  - Feature description (optional)
    Focus: What problem does it solve?
    
  - Feature type (optional)
    Options: enhancement | bugfix | refactor | performance | security
    
  - Estimated effort (optional)
    Options: small | medium | large
```

**Output:**
```
feature_name: {name}
feature_description: {description}
feature_type: {type}
feature_effort: {effort}
parent_microservice: {confirmed}
parent_service: {confirmed}
parent_domain: {confirmed}
```

---

## Metadata Collection: Multi-Microservice Feature

**If `feature_scope` = "cross-microservice":**

```
Collect:
  - Feature name (required)
    Example: "unified-auth-system"
    Validate: kebab-case
    
  - Feature description (required)
    Focus: How does this impact multiple microservices?
    
  - Feature type (required)
    Options: enhancement | bugfix | refactor | performance | security | infrastructure
    
  - Estimated effort (required)
    Options: small | medium | large | epic
    
  - Coordination notes (optional)
    Focus: Key integration points between microservices
    Example: "Auth service updates APIs, User service consumes, Gateway routes traffic"
    
  - Affected microservices confirmation (required)
    Reconfirm: Is [auth-service, user-service, api-gateway] still correct?
    Allow: Add/remove as needed
    
  - Testing strategy (optional)
    Focus: How will cross-microservice testing be done?
    Example: "Integration tests in api-gateway, contract tests in each service"
    
  - Risk assessment (optional)
    Options: low | medium | high | critical
    Note: Higher risk for features touching multiple services
```

**Output:**
```
feature_name: {name}
feature_description: {description}
feature_type: {type}
feature_effort: {effort}
affected_microservices: [{ms1}, {ms2}, ...] (confirmed)
coordination_notes: {notes}
testing_strategy: {strategy}
risk_level: {risk}
parent_service: {confirmed}
parent_domain: {confirmed}
multi_microservice_mode: true
```

---

## Metadata Collection: Service-Wide Feature

**If `feature_scope` = "service-wide":**

```
Collect:
  - Feature/Initiative name (required)
    Example: "service-modernization-2026"
    Validate: kebab-case
    
  - Initiative description (required)
    Focus: Comprehensive impact across service
    
  - Type (required)
    Options: initiative | modernization | migration | refactor | infrastructure
    
  - Estimated effort (required)
    Options: large | epic | multi-phase
    
  - Affected microservices (automatic)
    Set to: All microservices in {service}
    Display: "This affects all {N} microservices in {service}"
    
  - Sequencing (optional)
    Focus: Phasing across microservices
    Example: "Gateway first, then auth, then user services, finally billing"
    
  - Approval notes (optional)
    Focus: Who approved this service-wide change?
```

**Output:**
```
feature_name: {name}
feature_description: {description}
feature_type: {type}
feature_effort: {effort}
affected_microservices: [{all microservices}]
sequencing: {sequence}
approval_notes: {notes}
parent_service: {confirmed}
parent_domain: {confirmed}
service_wide_flag: true
multi_microservice_mode: true
```

---

## Instructions

1. **Validate** that correct `feature_scope` is set from previous steps
2. **Collect** only the fields relevant to this scope
3. **Validate** all required fields have values
4. **Confirm** affected microservices (for multi-microservice features)
5. **Proceed** to Step 2: Generate Branch Name

---

## Output
- `feature_metadata` (merged with scope-specific fields)
