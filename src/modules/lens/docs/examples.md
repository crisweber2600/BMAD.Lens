# Examples & Use Cases

This section provides practical examples for using LENS.

---

## Example Workflows

- **Daily navigation:** Run `navigator` to see your current lens and context summary.
- **Context switching:** Use `switch lens` to move from Feature to Service view.
- **Deep dive:** Run `context load` to view dependencies and structure.
- **Restore session:** Use `restore session` to resume work after a break.

---

## Common Scenarios

- You are on a feature branch and need to understand the parent microservice.
- You are investigating a bug and need to see cross-service dependencies.
- You are onboarding to a new domain and need a high-level map.

---

## Tips & Tricks

- Keep branch names aligned with the 6-segment schema for best detection.
- Use `lens-configure` to adjust patterns for legacy repositories.
- Store domain maps in `.lens/` for consistent discovery.

---

## Troubleshooting

For detailed troubleshooting steps, see [Troubleshooting](troubleshooting.md).

---

## Getting More Help

- Review the main BMAD documentation
- Check module configuration in module.yaml
- Verify all agents and workflows are properly installed
