# Agentic Development Model

## Memory model

```text
PRD.md                 product-level truth + task index
prd/Txxx.md             stable task specification
progress/PROGRESS...    bounded hot state
reports/...             durable cold evidence/history
docs/ + ADRs            durable decisions/knowledge
skills/...               reusable operational behavior
Git                      code and provenance history
```

## Progressive disclosure

An agent starts with the smallest context that can resolve the task. It must not read every document by default.

## Completion model

`COMPLETE` is evidence-based.

Typical code feature:

```text
acceptance criteria PASS
+ relevant unit tests PASS
+ relevant UI/integration tests PASS
+ lint/build PASS
+ regression PASS
+ human acceptance PASS (when required)
= COMPLETE
```

If a required gate cannot run, the evidence is missing; do not convert uncertainty into completion.
