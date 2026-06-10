# Notes for Claude (Harvester Example app)

Before doing any non-trivial work in this app — and **especially before refactoring** — read [`SPEC.md`](./SPEC.md). It is the authoritative description of the app's features, behaviors, and invariants. If a change you propose would alter anything described there, that's a behavior change and must be flagged to the user.

Particularly load-bearing sections to re-read before a refactor:

- **§4b** — single-project client fallback (commit `3720d43`).
- **§7d** — date-change stop rule for time entries (commits `da6176c` and `e4b6cd4`).
- **§8** — the four mutation invariants that must hold across every refactor.
- **§11** — modal-selection race-condition fix (commit `9f3ea32`).

If you intentionally change a behavior described in `SPEC.md`, update the spec in the same commit.
