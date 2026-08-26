# Skill: android-qa-build

## Purpose

Produce a human-installable, traceable QA APK from an agent change.

## Procedure

1. Ensure repository is not in an unexplained dirty state.
2. Run `./scripts/check.sh`.
3. Run managed-device tests when the task requires them.
4. Run `./scripts/qa-build.sh` (or set `SKIP_CHECK=1` only if the same gates just passed in the current run).
5. Read `dist/*.metadata.txt` and report app/version/build/Git SHA/test mode.
6. Deliver only the generated `dist/*.apk`, never a raw intermediate build path.
7. Do not claim persistent QA signing unless metadata says `persistent-qa`.
