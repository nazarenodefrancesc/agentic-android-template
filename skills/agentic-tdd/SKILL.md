# Skill: agentic-tdd

## Purpose

Make agent changes falsifiable through the cheapest reliable automated test.

## Rules

- Prefer pure Kotlin/JVM tests for business rules.
- Test ViewModel/state transitions without launching Android when possible.
- Use Compose component tests for rendering/event contracts.
- Use instrumented tests only for Android/framework integration.
- Use managed-device journeys for high-value cross-layer flows.
- Do not make a feature `COMPLETE` when a required regression test is red or unexecuted.

## Loop

`criterion → failing/updated test → implementation → narrow test → regression gate → evidence`.
