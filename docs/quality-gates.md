# Quality Gates

## Gate A — repository/static

`scripts/repo-check.sh`

Checks expected structure, task metadata consistency, secret-risk paths and script syntax assumptions that do not require Android dependencies.

## Gate B — fast code gate

`scripts/check.sh`

Expected to run:

- `:core:domain:test`
- `:app:testDebugUnitTest`
- `:app:lintQa`

## Gate C — managed-device

`scripts/device-check.sh`

Runs QA instrumented tests on the lightweight API 30 ATD by default. Set `DEVICE_TASK=ciApi37QaAndroidTest` when latest-platform behavior matters.

## Gate D — QA artifact

`scripts/qa-build.sh`

Requires a clean Git tree by default, produces a signed traceable APK, verifies it with `apksigner`, and records both artifact SHA-256 and signing-certificate SHA-256 metadata under `dist/` only after previous required automated gates succeed.

## Gate E — physical acceptance

Performed on the human's real Android phone for tasks that explicitly require it. The accepted artifact must be identified by build number + Git SHA. Record explicit acceptance with `python3 scripts/task.py accept Txxx dist/<apk>` before moving the task to `COMPLETE`.

## Template self-test — generator regression

`scripts/template-self-test.sh` validates new-app derivation, independent Git bootstrap, deterministic dependency routing, lifecycle transition guards, cycle detection and required physical-acceptance recording. It is intentionally Android-SDK-independent.
