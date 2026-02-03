---
name: onboarding
description: Create profile + run bootstrap
agent: scout
trigger: "@scout onboard" or "@lens-work onboard"
category: utility
first_run: true
---

# Onboarding Workflow

**Purpose:** Create user profile and bootstrap TargetProjects for new team members.

---

## Execution Sequence

### 1. Welcome

```
🔭 Welcome to LENS Workbench!

I'm Scout, your setup guide. I'll help you:
1. Create your profile
2. Set up your TargetProjects
3. Generate initial documentation

This takes about 3-5 minutes. Ready? [Y]es / [L]ater
```

### 2. Create Profile

```yaml
output: |
  📝 Let's create your profile
  
  What's your name?
name = prompt_user()

output: "What's your role?"
output: "[1] Developer"
output: "[2] Tech Lead"
output: "[3] Architect"
output: "[4] Product Owner"
output: "[5] Scrum Master"
role = prompt_user()

output: "What domain/team do you work on? (or 'all' for full access)"
scope = prompt_user()

profile = {
  name: name,
  role: roles[role],
  scope: scope,
  created_at: now()
}

save(profile, "_bmad/lens-work/profiles/${sanitize(name)}.yaml")
```

### 3. Determine Bootstrap Scope

```yaml
if scope == "all":
  bootstrap_scope = "full"
  output: "Will bootstrap all repos from service map"
else:
  bootstrap_scope = scope
  output: "Will bootstrap repos for ${scope}"
```

### 4. Run Discovery

```yaml
invoke: scout.repo-discover
params:
  scope: bootstrap_scope

output: |
  🔍 Discovery complete
  ├── Found: ${matched} repos
  ├── Missing: ${missing} repos
  └── Extra: ${extra} repos
```

### 5. Run Reconcile (Clone Missing)

```yaml
if missing > 0:
  output: |
    📥 Cloning ${missing} missing repos...
    This may take a few minutes.
  
  invoke: scout.repo-reconcile
```

### 6. Run Documentation

```yaml
output: |
  📄 Generating initial documentation...

invoke: scout.repo-document
params:
  mode: "full"  # First run = full documentation
```

### 7. Completion

```
🎉 Onboarding Complete!

Profile: ${profile.name} (${profile.role})
Scope: ${profile.scope}

What's ready:
├── ✅ Profile created
├── ✅ ${cloned_count} repos cloned
├── ✅ ${documented_count} repos documented
└── ✅ Canonical docs in Docs/

Next steps:
├── Run #new-feature "your-feature" to start an initiative
├── Run @tracey ST to see status anytime
└── Run @compass H for help

Welcome to the team! 🚀
```

---

## Profile Storage

Profiles are stored in `_bmad/lens-work/profiles/`:

```yaml
# _bmad/lens-work/profiles/jane-smith.yaml
name: Jane Smith
role: Developer
scope: payment-service
created_at: 2026-02-03T10:00:00Z
preferences:
  communication_style: concise
  auto_fetch: true
```
