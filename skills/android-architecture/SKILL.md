# Skill: android-architecture

## Purpose

Preserve a testable Android architecture during feature work.

## Guardrails

- Keep product/business rules out of Composables and Android framework classes.
- Prefer immutable UI state and explicit events.
- Put pure behavior in `core/domain` or another justified Android-free module.
- Add repository/data modules only when a product boundary exists.
- Avoid speculative base classes, service locators and generic common modules.
- Every new architecture abstraction must reduce a demonstrated complexity/testability problem.
