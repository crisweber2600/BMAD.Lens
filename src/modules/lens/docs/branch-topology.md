# Branch Topology

## Naming Convention

Lens uses **flat hyphen-separated** branch naming. No slashes.

## Patterns

```
{domain_prefix}                                    # Domain layer
{domain_prefix}-{service_prefix}                   # Service layer
{featureBranchRoot}                                # Feature root (= base)
{featureBranchRoot}-{audience}                     # Audience branch
{featureBranchRoot}-{audience}-p{N}                # Phase branch
{featureBranchRoot}-{audience}-p{N}-{workflow}     # Workflow branch
```

## Example

For a feature "auth-flow" under service "user-mgmt" in domain "platform":

```
platform                                # Domain
platform-user-mgmt                      # Service
platform-user-mgmt-auth-flow            # Feature root (base)
platform-user-mgmt-auth-flow-small      # Small audience
platform-user-mgmt-auth-flow-medium     # Medium audience
platform-user-mgmt-auth-flow-large      # Large audience
platform-user-mgmt-auth-flow-small-p1   # Phase 1 on small
platform-user-mgmt-auth-flow-small-p1-dev  # Dev workflow
```

## Audience Configuration

Per-initiative (not global):
- **Minimum:** 1 audience
- **Default:** 3 (small, medium, large)
- **Custom:** Define your own labels

## Lifecycle

1. `/new` → Creates root + audience branches (pushed immediately)
2. `/pre-plan` → Creates `-p1` branch on first audience
3. Phase commands → Create `-p{N}` as needed
4. Phase end → PR → merge → delete phase branch → checkout next
5. `/archive` → Clean up when done

## featureBranchRoot

Stored in initiative config. Built from hierarchy:
- Domain: `{domain_prefix}`
- Service: `{domain_prefix}-{service_prefix}`
- Feature: `{domain_prefix}-{service_prefix}-{feature_id}`
