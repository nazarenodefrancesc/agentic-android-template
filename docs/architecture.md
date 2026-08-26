# Architecture

## Principle

The UI is Android-specific; product rules should be Android-independent wherever practical.

```text
Compose
  ↓ events
ViewModel + immutable UiState
  ↓
Domain use cases / models (pure Kotlin)
  ↓
Repository interfaces
  ↓
Data implementations (add only when required)
```

## Why the template starts with only `app` + `core/domain`

The skeleton deliberately avoids pre-creating networking, database, analytics, authentication and elaborate clean-architecture layers. Empty architecture is maintenance cost. Add modules when a real product requirement creates a boundary worth enforcing.

The domain module exists from day one because it creates an important agentic property: core behavior can be compiled and tested cheaply without Android or an emulator.

## UI rules

- model meaningful states explicitly (`Loading`, `Empty`, `Content`, `Error`, etc. when the product needs them);
- keep Composables focused on rendering state and emitting events;
- keep navigation state explicit;
- do not hide business state in UI-local mutable variables;
- attach semantics/test tags when stable automated interaction needs them;
- test the smallest useful Composable rather than launching the whole app for every assertion.

## Build variants

### debug

Agent/developer iteration. Package suffix `.debug`.

### qa

Human-testable artifact. Package suffix `.qa`, allowing production and QA builds to coexist on the physical device. Includes Git/build provenance. Prefer persistent QA signing.

### release

Store/release build. Template intentionally does not ship release credentials.
