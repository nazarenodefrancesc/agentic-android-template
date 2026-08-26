# ADR-0001 — Golden template, not common runtime library

## Status

Accepted.

## Decision

`agentic-android-template` is copied to create a new independent app repository. Derived apps do not depend on the template at runtime and do not inherit future changes automatically.

## Rationale

- apps can diverge safely;
- template mistakes do not couple all products;
- no speculative abstraction tax;
- agent instructions, QA tooling and repository conventions are reusable without forcing runtime code reuse;
- truly common runtime code can later become explicit versioned libraries with their own contracts/tests.

## Consequence

Template upgrades to existing apps are deliberate patches, not implicit inheritance.
