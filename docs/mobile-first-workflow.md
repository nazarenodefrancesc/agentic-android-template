# Mobile-first Agentic Development Workflow

## Assumption

The human developer works primarily from an Android phone and may interact with agents through ChatGPT, Telegram or another conversational frontend.

The server is the workstation. The physical phone is the final acceptance device.

## Flow

```text
Human describes change
→ agent resolves task/spec
→ agent implements
→ cheap automated tests
→ lint/static gate
→ instrumented/headless device gate where relevant
→ clean-tree QA APK built, signature verified and fingerprinted
→ artifact delivered via Telegram/link/storage
→ human installs on phone
→ human reports ACCEPT or defect + build diagnostics
```

## Human acceptance

Use human acceptance only for things automation cannot fully prove: subjective UX, feel, physical-device integration, visual/product intent, or an explicitly requested product checkpoint.

Do not make the human repeat low-level checks the server can automate.

## Defect feedback format

Ideal minimal feedback from phone:

```text
Build 173 / git abc123
Action: tap Save after editing title
Observed: app returns to home and title is unchanged
Expected: edited title persists
```

The app's diagnostic screen exists to make build provenance copyable from the device. When the human explicitly accepts a task that requires physical acceptance, the agent records the exact packaged APK with `python3 scripts/task.py accept Txxx dist/<apk>` before marking the task `COMPLETE`.

## Telegram delivery

`scripts/publish-telegram.sh` can send the final `dist/*.apk` directly to a configured Telegram chat using secret environment variables. It is an optional delivery adapter; the build/test pipeline does not depend on Telegram.
