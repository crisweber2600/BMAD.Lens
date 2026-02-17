# Lens Configuration

## Install-Time Configuration

These are set during module installation:

| Setting | Default | Description |
|---------|---------|-------------|
| `target_projects_path` | `../TargetProjects` | Where target repos live |
| `docs_output_path` | `Docs` | Documentation output path |
| `enable_telemetry` | `false` | Dashboard data collection |
| `discovery_depth` | `shallow` | Repo scan depth |
| `enable_jira_integration` | `false` | JIRA integration |
| `default_audiences` | `small,medium,large` | Default audiences for new initiatives |
| `default_git_remote` | `origin` | Git remote name |

## Config File Location

`_bmad/lens/config.yaml`

## Per-Initiative Configuration

Each initiative has its own config at:
`_bmad-output/lens/initiatives/{id}.yaml`

This includes audiences, governance mode, and initiative-specific settings.

## Governance Modes

| Mode | Behavior |
|------|----------|
| `advisory` | Warn on violations, don't block |
| `enforced` | Block progress on critical violations |

Set per-initiative in `initiative.yaml`.

## State File Locations

| File | Path | Purpose |
|------|------|---------|
| State | `_bmad-output/lens/state.yaml` | Current initiative state |
| Event Log | `_bmad-output/lens/event-log.jsonl` | Immutable audit trail |
| Config | `_bmad/lens/config.yaml` | Global config |
