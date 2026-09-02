# Agentic Android Template

Golden repository for building Android applications with an agent-first, mobile-first development workflow.

The human developer is assumed to work primarily from an Android phone. Agents run builds, tests, static checks and headless device tests on a server; the human receives an installable QA APK for physical acceptance testing.

## What this repository is

This is a **project skeleton**, not a runtime common library. Create a new independent app from it with `scripts/new-app.sh`. Each derived app receives its own Git repository, PRD, task state, reports and Android codebase.

If genuinely reusable runtime code emerges after multiple apps, extract it later into explicit versioned libraries rather than coupling apps to this template.

## Baseline

- Android Gradle Plugin: 9.3.2
- Gradle: 9.5.0
- compileSdk / targetSdk: 37
- minSdk: 26
- Kotlin: 2.3.21
- Jetpack Compose BOM: 2026.08.00
- Java: 17
- UI: Jetpack Compose + Material 3
- Architecture: unidirectional state flow, Android-thin UI, pure Kotlin domain module
- Build channels: `debug`, `qa`, `release`

## Repository map

```text
.
├── AGENTS.md                  # mandatory operating contract for coding agents
├── PRD.md                     # PRD of this golden template repository
├── app/                       # Android UI/application shell
├── core/domain/               # pure Kotlin, Android-free business/domain logic
├── prd/                       # task specifications for the current repository
├── progress/                  # bounded hot working memory per task
├── reports/                   # cold evidence, audits and test reports
├── docs/                      # architecture, workflow and ADRs
├── capabilities/              # durable capability map
├── skills/                    # local operational agent skills
├── templates/                 # PRD/task/progress templates used by derived apps
├── scripts/                   # deterministic agent/build/bootstrap tooling
└── dist/                      # generated QA artifacts (ignored by Git)
```

## Create a new app

From the template repository:

```bash
./scripts/new-app.sh "Calculator" com.example.calculator ../calculator-app
```

The script:

1. copies the golden skeleton without its `.git` history;
2. rewrites app name, package, namespace and source paths;
3. replaces the template PRD with a product PRD starter;
4. clears template-specific progress/reports;
5. records the originating template Git commit;
6. creates a fresh Git repository and initial commit.

Then enter the new project and complete `PRD.md` before implementation.

## Server bootstrap

The packaging environment used to create this ZIP does not contain an Android SDK or Gradle installation, so the repository includes a self-bootstrapping `gradlew`. On a connected Linux server:

```bash
./scripts/setup-server.sh
```

It verifies JDK 17+, installs/generates the Gradle wrapper when necessary, checks Android tooling, and prints missing SDK packages. If Android CLI is installed, it can also install Google's official Android agent skills.

## QA flow

```bash
./scripts/qa-build.sh
```

Default behavior:

1. static repository checks;
2. JVM/domain tests;
3. Android unit tests;
4. lint for QA;
5. QA APK build;
6. verify the APK signature with Android `apksigner`;
7. copy/rename APK into `dist/`;
8. write artifact SHA-256, signing-certificate fingerprint and gate metadata next to the APK.

To include headless managed-device tests:

```bash
RUN_DEVICE_TESTS=1 ./scripts/qa-build.sh
```

By default the QA pipeline refuses a dirty Git working tree, so the installed artifact is reproducible from its recorded commit. The produced artifact is intended to be sent to the human tester's Android phone. A task with `human_acceptance: required` remains `IN_REVIEW` until that APK is accepted on a physical device.

Optional Telegram delivery:

```bash
TELEGRAM_BOT_TOKEN=... TELEGRAM_CHAT_ID=... PUBLISH_TELEGRAM=1 ./scripts/qa-build.sh
```

Keep these values in server secrets, never in Git.

## Stable QA signing

Generate a persistent QA keystore once on the build server:

```bash
./scripts/setup-qa-keystore.sh
```

Secrets are written under `.secrets/`, which is Git-ignored. Persistent QA signing is mandatory: the build fails when the keystore is missing and never falls back to a debug key. Keep the same keystore for every update build and compare the recorded certificate fingerprint before delivery.

## Deterministic task routing

Task specifications live in `prd/Txxx.md` and contain machine-readable front matter. Use:

```bash
python3 scripts/task.py next
python3 scripts/task.py list
python3 scripts/task.py set T001 IN_PROGRESS
python3 scripts/task.py check T001
# after explicit physical acceptance of a human-required task:
python3 scripts/task.py accept T001 dist/<accepted-build>.apk
```

Agents must not choose work by scanning the repository and improvising priority. See `AGENTS.md`.

## Template regression self-test

The golden repository can test its own derivation logic without Android SDK/network dependencies:

```bash
./scripts/template-self-test.sh
```

It creates a temporary derived app, verifies package/name rewriting and independent Git initialization, exercises dependency routing and lifecycle transitions, checks cycle detection, and verifies the physical-acceptance completion guard.

## License

The Agentic Android Template is licensed under the Apache License 2.0. An application
derived from this template may use a separate license for its original code, including
a proprietary license. Apache-licensed template material copied into a derived app
remains subject to the applicable Apache-2.0 conditions; using the template does not
require the entire derived application to be open source.

## First intended validation

The first derived app should intentionally be small. Its purpose is to validate the whole factory:

`idea → PRD → tasks → agent implementation → automated gates → QA APK → physical Pixel acceptance → COMPLETE`

Do not add product complexity until this loop works end-to-end.
