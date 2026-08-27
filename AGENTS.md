# AGENTS.md — Agent Operating Contract

This file is authoritative for any coding agent operating in this repository or in a project derived from it.

## 1. Core operating principle

Work is evidence-driven, not narration-driven. A task is not complete because code was written or because an agent says it is complete.

Required loop:

```text
READ STATE → SELECT TASK DETERMINISTICALLY → IMPLEMENT → VERIFY → RECORD EVIDENCE → UPDATE STATE → STOP/CONTINUE
```

## 2. Source-of-truth hierarchy

Read only what is needed, in this order:

1. `AGENTS.md`
2. root `PRD.md`
3. selected task `prd/Txxx.md`
4. matching hot memory `progress/PROGRESS-Txxx.md`, if present
5. architecture/ADR documents explicitly referenced by the task
6. reports only when evidence/history is needed
7. Git history only when provenance is needed

Do not context-dump the whole repository.

## 3. Deterministic task selection

Use `python3 scripts/task.py next` unless the human explicitly names a task. Use `task.py set` only through valid lifecycle transitions; the CLI rejects state skipping.

Valid states:

- `PLANNED`
- `IN_PROGRESS`
- `IN_REVIEW`
- `COMPLETE`
- `BLOCKED`
- `DEFERRED`
- `CANCELLED`

Never use `DEFERRED` to hide unfinished work.

## 4. Specification vs state

- `prd/Txxx.md` = stable task specification and acceptance criteria.
- `progress/PROGRESS-Txxx.md` = bounded working memory: current approach, next action, blockers, temporary discoveries.
- `reports/...` = durable evidence, deep analysis, test output and audit material.
- Git = historical provenance.

Do not turn progress files into permanent diaries. Promote durable knowledge into docs/ADRs/skills and prune the progress file.

## 5. Android architecture constraints

Default architecture is:

```text
Compose UI
  ↓ user events
ViewModel / UiState
  ↓
Domain use cases (pure Kotlin)
  ↓
Repositories/interfaces
  ↓
Android/data implementations
```

Rules:

- business rules must not live in Composables;
- domain code must remain Android-free unless a task explicitly justifies otherwise;
- UI should be a deterministic function of explicit state as far as practical;
- side effects must be isolated;
- avoid new abstractions until there is a demonstrated need;
- do not create a generic shared runtime library merely because code might someday be shared.

## 6. Test-first / test-with implementation

For behavior changes:

1. identify acceptance criteria;
2. add or update the narrowest useful automated test;
3. implement the behavior;
4. run the relevant local gate;
5. run regression gates before review.

Prefer the cheapest reliable level:

1. pure JVM/domain test;
2. ViewModel/state test;
3. Compose component test;
4. instrumented integration test;
5. managed-device journey/smoke test;
6. physical human acceptance.

For UI criteria, distinguish semantic evidence from rendered visual evidence. Compose
semantics assertions validate node presence, accessibility and interaction; they do not
prove that pixels, colors, shapes, icons, spacing, clipping or contrast render correctly.
Mark visual criteria explicitly and require a separate screenshot-based or physical-device
evidence path. Do not claim visual correctness solely because `assertIsDisplayed()` passes.

Do not push logic upward into UI merely to make it easier to implement.

## 7. Quality gates

Before moving a code task to `IN_REVIEW`, run the relevant automated gates. Before `COMPLETE`, all required acceptance evidence must exist.

Standard automated gate:

```bash
./scripts/check.sh
```

Full QA candidate:

```bash
./scripts/qa-build.sh
```

Full QA including headless device tests:

```bash
RUN_DEVICE_TESTS=1 ./scripts/qa-build.sh
```

A user-visible task marked `human_acceptance: required` cannot move from `IN_REVIEW` to `COMPLETE` until the human accepts an identified QA artifact on a physical Android device. After explicit human acceptance, record it with `python3 scripts/task.py accept Txxx dist/<accepted>.apk`; only then may the task become `COMPLETE`.

## 8. Mobile-first human workflow

Assume the human is not using Android Studio or a desktop GUI.

Therefore every reviewable user-visible increment must be distributable as an installable QA APK. Do not ask the human to open an emulator, inspect a desktop window, or execute IDE-only steps unless explicitly requested.

Every QA artifact must be built from a clean Git tree by default and be traceable to:

- app/version;
- build number;
- Git SHA;
- dirty/clean state;
- build UTC time;
- signing mode and signing-certificate SHA-256 fingerprint;
- test/gate result.

## 9. Commits

Use focused commits. Include the task ID when work belongs to a task, e.g.:

```text
T014: add deterministic score calculation
```

Do not commit secrets, APKs, local SDK paths, generated build output or keystores.

## 10. Agent self-maintenance / OpenCapability

When repeated work reveals durable knowledge:

1. decide whether it is project-specific documentation, an ADR, or a reusable operational capability;
2. promote it out of progress memory;
3. if operational and reusable, update/create a skill under `skills/`;
4. update `capabilities/README.md` to link the capability to its executable/operational asset;
5. keep the skill narrow and testable.

Documentation that changes how agents should operate must be connected to an operational capability or explicitly marked as informational-only.

## 11. Stop conditions

Stop and mark `BLOCKED` only when the missing dependency cannot be resolved from repository state, tools or deterministic checks. Record exactly what is missing and the smallest human decision required.

Never fabricate a successful build/test. If the environment cannot execute a gate, report that gate as unverified.
