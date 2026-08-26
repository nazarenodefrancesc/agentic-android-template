# Product Requirements — Agentic Android Template

## Status

`v0.1.0-candidate`

Structural repository validation: **PASS**.
Android compilation/device validation: **PENDING on the target Android build server** because the artifact-packaging environment has no Android SDK and no network-accessible Gradle dependency cache.

## Product hypothesis

A golden Android project can make small-to-medium Android applications developable primarily through remote coding agents while the human developer works from a phone, provided that the repository makes state, architecture, verification and APK provenance explicit and machine-operable.

## Primary user workflow

```text
Human request from phone
→ remote agent selects/implements task
→ automated verification
→ QA APK
→ human installs on physical Android device
→ acceptance/rejection feedback
→ task COMPLETE or fix iteration
```

## Goals

1. New apps can be created from the repository without retaining template Git history.
2. Derived apps start with a clean product PRD and task/progress/report structure.
3. Android business logic has an Android-free testable home.
4. User-visible changes can be built into a separately installable `.qa` application ID.
5. QA artifacts carry Git/build provenance.
6. Persistent QA signing is supported without committing secrets.
7. Agents have deterministic task routing and bounded persistent memory.
8. Automated test layers escalate from cheap JVM tests to headless managed devices.
9. Physical-device human acceptance is a formal quality gate when required.
10. Reusable agent knowledge can be promoted into narrow skills/capabilities.

## Non-goals

- being a runtime framework all apps depend on;
- solving every Android architecture up front;
- bundling authentication, networking, databases or analytics before an app needs them;
- replacing human acceptance for subjective UX/product judgments;
- requiring Android Studio or a desktop GUI for the normal human workflow;
- vendoring Google's Android skills, which should be installed/updateable from their official source.

## Technical baseline

See `docs/architecture.md` and `docs/decisions/ADR-0001-golden-template-not-common-library.md`.

## Acceptance criteria for v0.1

- [x] repository structure and agent contract exist;
- [x] Android app + pure Kotlin domain modules are scaffolded;
- [x] `debug`, `qa`, `release` build concepts are represented;
- [x] QA provenance is represented in `BuildConfig` and visible in-app;
- [x] deterministic task CLI exists;
- [x] PRD/task/progress/report templates exist;
- [x] fresh-app bootstrap script exists;
- [x] QA signing setup exists and secrets are ignored;
- [x] automated quality/build scripts exist;
- [x] build-managed headless device configuration exists;
- [x] CI reference workflow exists;
- [ ] target server successfully executes `./scripts/setup-server.sh`;
- [ ] target server successfully executes `./scripts/check.sh`;
- [ ] target server successfully creates an installable QA APK;
- [ ] first derived sample app completes physical acceptance on the target Pixel device.

The last four criteria are intentionally left open: they are the falsification test for the first derived app and server environment.
