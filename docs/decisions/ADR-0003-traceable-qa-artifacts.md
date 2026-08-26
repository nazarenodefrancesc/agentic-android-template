# ADR-0003 — Human QA artifacts must be commit-traceable

## Status

Accepted — 2026-08-26.

## Context

The human developer tests primarily by installing APKs delivered remotely to a physical Android phone. A Git SHA is useful provenance only when the APK can be mapped back to the exact committed source tree. A dirty working tree breaks that guarantee, and a signing-mode label alone does not prove that consecutive APKs use the same certificate.

## Decision

Human-testable QA artifacts are produced from a clean Git tree by default. `scripts/qa-build.sh` rejects a dirty tree unless `ALLOW_DIRTY_QA=1` is explicitly used for a non-authoritative local build.

Every packaged QA APK is verified with Android `apksigner` and stores:

- artifact SHA-256;
- Git SHA and clean/dirty state;
- build number and UTC build time;
- signing mode;
- signing-certificate SHA-256 fingerprint;
- fast-gate result;
- managed-device test result when run.

For tasks declaring `human_acceptance: required`, `COMPLETE` is blocked until `scripts/task.py accept` records explicit acceptance of a packaged QA APK whose checksum/metadata are internally consistent, whose Git state is clean, and whose fast gates passed.

## Consequences

- Agents normally commit before producing the APK sent to the human.
- Phone feedback can be tied to exact source and signing provenance.
- Dirty QA builds remain possible for troubleshooting, but cannot serve as formal physical-acceptance evidence.
- `apksigner` / Android SDK Build-Tools is a required part of the QA packaging environment.
