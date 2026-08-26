# OpenCapability Map

Durable knowledge is useful only when it is connected to something agents can operationalize.

| Capability | Operational asset | Durable reference | Status |
|---|---|---|---|
| Deterministic task loop | `scripts/task.py`, `skills/agentic-task-loop/` | `docs/agentic-development.md` | active |
| Agentic TDD | `skills/agentic-tdd/`, `scripts/check.sh` | `docs/quality-gates.md` | active |
| QA artifact creation | `skills/android-qa-build/`, `scripts/qa-build.sh`, `scripts/verify-apk.sh` | ADR-0003, `docs/mobile-first-workflow.md` | active |
| Physical acceptance | `skills/android-device-acceptance/`, `scripts/task.py accept` | ADR-0002, ADR-0003 | active |
| Android architecture | `skills/android-architecture/` | `docs/architecture.md` | active |
| Official Android knowledge | `scripts/install-android-skills.sh` | Android CLI/skills upstream | external/updatable |

When a repeated development lesson materially changes how agents should work, promote it into a narrow skill and update this table.
