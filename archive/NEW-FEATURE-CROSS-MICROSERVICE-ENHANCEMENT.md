# new-feature Workflow: Cross-Microservice Enhancement

**Date:** 2026-02-02  
**Enhancement:** Support for features spanning multiple microservices

---

## Changes Made

### 1. ✅ Expanded Lens Support

**Before:** Feature lens only (single microservice)  
**After:** Feature lens OR Service lens

- **Feature lens** → Single-microservice feature (traditional)
- **Service lens** → Cross-microservice feature (new capability)

### 2. ✅ Added Multi-Microservice Detection

**New Step: 3.5 - Multi-Microservice Scope Detection** (conditional)

- Runs when at **Service lens**
- Helps user determine scope:
  - Single microservice (convert to feature lens)
  - Multiple microservices (cross-microservice feature)
  - Service-wide / Infrastructure (all microservices)
- Collects affected microservices list
- Establishes coordination requirements

### 3. ✅ Updated git-lens Integration

Workflow tracking now includes:

```yaml
Workflow Instance:
  scope: "single-microservice" | "cross-microservice" | "service-wide"
  affected_microservices: [{ms1}, {ms2}, ...] (if cross-microservice)
```

**Casey (git-lens agent) will track:**
- All affected microservices
- Dependencies between microservices
- Coordination requirements
- Cross-service integration points

### 4. ✅ Enhanced Branch Naming

**Single-Microservice (Feature lens):**
```
feature/{phase}/{microservice}/{feature-name}
feature/implementation/auth-service/add-oauth-2fa
```

**Multi-Microservice (Service lens):**
```
feature/{phase}/{service}/{feature-name}
feature/planning/customer-api/unified-auth-system
```

**Service-Wide:**
```
feature/{phase}/{service}/initiative-{feature-name}
feature/implementation/customer-api/initiative-service-modernization
```

### 5. ✅ Expanded Metadata Collection

**Single-Microservice:**
- Feature name, description
- Feature type, effort estimate

**Multi-Microservice (adds):**
- Coordination notes
- Affected microservices confirmation
- Testing strategy (cross-service)
- Risk assessment

**Service-Wide (adds):**
- Initiative sequencing
- Approval notes
- Service-wide approval tracking

### 6. ✅ State File Enhancements

New file for cross-microservice features:
```
.git-lens/features/{feature-id}/affected-microservices.yaml
  - auth-service
  - user-service
  - api-gateway
```

---

## Workflow Flow (Updated)

```
workflow.md
  → step-01-lens-check
     (accepts: Feature lens OR Service lens)
    → step-02-phase-loading
    → step-03-git-lens-integration
    → step-03.5-multi-microservice-detection
       (conditional: only if Service lens)
       └─ Determines scope (single/multi/service-wide)
    → step-01-collect-metadata
       (adapts to scope)
    → step-02-generate-branch
       (generates appropriate branch pattern)
    → step-03-initialize-context
```

---

## Usage Scenarios

### Scenario 1: Single-Microservice Feature (Feature lens)

**User at:** Feature branch level in auth-service  
**Workflow:** Runs as before  
**Result:** Single-microservice feature branch created

```
feature/implementation/auth-service/add-oauth-2fa
```

---

### Scenario 2: Cross-Microservice Feature (Service lens)

**User at:** Service level (customer-api service root)  
**Workflow:** Detects Service lens → Prompts for scope  
**User selects:** Multiple microservices affected  
**Result:** Service-level feature branch tracking all microservices

```
feature/planning/customer-api/unified-auth-system

Affected microservices:
  - auth-service
  - api-gateway
  - user-service
```

Casey tracks dependencies and integration points between services.

---

### Scenario 3: Service-Wide Infrastructure Change (Service lens)

**User at:** Service level  
**Workflow:** Detects Service lens → Prompts for scope  
**User selects:** Service-wide infrastructure change  
**Result:** Initiative-style feature affecting all microservices

```
feature/planning/customer-api/initiative-service-modernization

Affected: All 5 microservices in customer-api service
Requires: Service-level approval and sequencing
```

---

## Git-Lens Integration

### Casey (Agent) Tracking

For cross-microservice features, Casey automatically:

1. **Records affected microservices**
   ```yaml
   Feature: unified-auth-system
   Affected:
     - auth-service (owns APIs)
     - api-gateway (routes traffic)
     - user-service (consumes auth APIs)
   ```

2. **Tracks dependencies**
   ```
   auth-service → api-gateway (must sync first)
   auth-service → user-service
   ```

3. **Detects integration points**
   - API contracts
   - Event flows
   - Shared resources

4. **Suggests coordination**
   - Code review strategy
   - Testing checkpoints
   - Integration verification

### Tracey (Workflow Orchestrator)

- Tracks workflow instances with scope metadata
- Manages lifecycle events (start, during, finish)
- Links affected microservices for coordination

---

## Testing Recommendations

1. ✅ Feature lens flow (single-microservice) - existing tests
2. ⏳ Service lens detection at service root
3. ⏳ Multi-microservice selection and confirmation
4. ⏳ Branch naming for each scope type
5. ⏳ State file generation for cross-microservice features
6. ⏳ Casey tracking of affected microservices
7. ⏳ Downgrade flow (Service lens → single microservice selection)
8. ⏳ Service-wide feature handling

---

## Documentation References

- **Workflow Map:** https://docs.bmad-method.org/reference/workflow-map/
- **Git-Lens:** src/modules/lens/extensions/git-lens/
- **New Feature Workflows:** src/modules/lens/workflows/new-feature/

---

## Future Enhancements

1. **Automatic microservice discovery**
   - Scan for impacted microservices based on code dependencies
   - Suggest affected services to user

2. **Risk assessment automation**
   - Higher risk scoring for service-wide changes
   - Integration risk based on microservice dependencies

3. **Testing coordination**
   - Auto-generate integration test checkpoints
   - Coordinate testing across microservices

4. **Review workflow**
   - Route reviews to appropriate microservice teams
   - Require approval from each affected team for cross-service features

---

## Summary

The new-feature workflow now fully supports:
- ✅ Single-microservice features (traditional)
- ✅ Cross-microservice features (coordinated)
- ✅ Service-wide initiatives (all microservices)
- ✅ Automatic git-lens tracking of affected services
- ✅ Intelligent branch naming by scope
- ✅ Scope-aware metadata collection
