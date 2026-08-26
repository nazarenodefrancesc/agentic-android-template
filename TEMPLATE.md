# Template Usage Contract

`agentic-android-template` is a golden source repository.

## Derivation model

A new application **copies** this skeleton and becomes independent. It does not inherit runtime behavior from the template.

```text
agentic-android-template@<commit>
        ├── snapshot → calculator-app (own Git)
        ├── snapshot → ping-pong-app (own Git)
        └── snapshot → another-app (own Git)
```

Each derived project records `TEMPLATE_ORIGIN.md` with the source template commit.

## Updates after derivation

Template improvements are not automatically pulled into existing apps. Apply them deliberately when useful, preferably as small reviewed patches.

If the same runtime code is independently needed by multiple mature apps, consider extracting a separate versioned library. Do not make the golden template itself that library.
