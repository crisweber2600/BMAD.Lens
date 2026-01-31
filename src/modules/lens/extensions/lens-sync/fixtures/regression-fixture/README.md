# Regression Fixture (Lens Sync)

This fixture provides a minimal target project for validating lens-sync workflows without external dependencies.

## Structure

- `_lens/domain-map.yaml` defines one domain (`platform`).
- `_lens/domains/platform/service.yaml` defines two services (`auth`, `billing`).
- Each service includes a tiny code sample for analysis and doc generation.

## Notes

- `git_repo` values use `.invalid` domains to avoid accidental network access.
- This fixture is intended for local workflow validation only.
