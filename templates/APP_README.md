# __APP_NAME__

Android application derived from `agentic-android-template`.

## Development model

This project is designed for remote, agent-driven development. Agents build/test on the server; human acceptance happens by installing a traceable QA APK on a physical Android phone.

## Start here

1. Complete `PRD.md`.
2. Create bounded tasks under `prd/` from `templates/TASK.md`.
3. Run `python3 scripts/task.py next` for deterministic routing.
4. Run `./scripts/check.sh` before review.
5. Run `./scripts/qa-build.sh` to produce the installable artifact in `dist/`.

See `AGENTS.md`, `docs/architecture.md`, and `docs/mobile-first-workflow.md`.

## Build channels

- `debug`: agent/developer iteration (`.debug`).
- `qa`: physical human acceptance (`.qa`).
- `release`: store/release candidate.

## Template provenance

See `TEMPLATE_ORIGIN.md`.
