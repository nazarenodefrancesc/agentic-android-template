# Skill: android-qa-build

## Purpose

Produce a human-installable, traceable QA APK from an agent change.

## Signing invariant

- Every QA APK for a project must use the same persistent QA keystore across builds.
- Never use `debug-fallback` or a newly generated container/debug key for a deliverable.
- Before delivery, require `signing_mode=persistent-qa` and compare the certificate fingerprint with the previously accepted APK. A mismatch is a hard failure for an update build.

## Procedure

1. Ensure the repository is clean and the task change is committed. `qa-build.sh` rejects dirty trees by default.
2. Require `qa-signing.properties` and its ignored keystore; run `scripts/setup-qa-keystore.sh` if missing, then run `./scripts/check.sh`.
3. Run managed-device tests when the task requires them.
4. Run `./scripts/qa-build.sh` (or set `SKIP_CHECK=1` only if the same gates just passed in the current run).
5. Confirm packaging verified the APK signature; read `dist/*.metadata.txt`, require persistent QA signing, compare the certificate fingerprint, and report app/version/build/Git SHA/test mode/signing-certificate SHA-256.
6. Deliver only the generated `dist/*.apk`, never a raw intermediate build path.
7. Never deliver when metadata says `debug-fallback` or when the certificate differs from the expected update key.
