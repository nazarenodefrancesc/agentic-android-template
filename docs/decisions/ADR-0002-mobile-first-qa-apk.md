# ADR-0002 — QA APK is the human review boundary

## Status

Accepted.

## Context

The primary human developer works from a phone and normally does not inspect Android Studio or a graphical emulator.

## Decision

Agents own server-side automated verification. A user-visible increment reaches the human only as a QA candidate APK after the required automated gates pass.

The QA application ID has a `.qa` suffix and the artifact carries build/Git provenance.

## Consequence

The physical Android device becomes the formal human-acceptance environment, while emulators remain an agent/CI implementation detail.
