# Skill: agentic-tdd

## Purpose

Make agent changes falsifiable through the cheapest reliable automated test.

## Rules

- Prefer pure Kotlin/JVM tests for business rules.
- Test ViewModel/state transitions without launching Android when possible.
- Use Compose component tests for rendering/event contracts.
- Treat Compose semantics assertions as evidence of semantic presence/accessibility and
  interaction, not proof of pixel-level visual correctness.
- Use instrumented tests only for Android/framework integration.
- Use managed-device journeys for high-value cross-layer flows.
- Do not make a feature `COMPLETE` when a required regression test is red or unexecuted.

## Loop

`criterion → failing/updated test → implementation → narrow test → regression gate → evidence`.

When a criterion is visual (icons, colors, typography, spacing, clipping, imagery or
contrast), record separate rendered evidence. Use an explicitly adopted visual test when
it is justified; otherwise keep physical-device human acceptance as the visual gate. Do
not add screenshot/golden infrastructure automatically for a single visual requirement.
