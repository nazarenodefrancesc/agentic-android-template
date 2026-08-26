# Skill: agentic-task-loop

## Purpose

Execute one project task without losing state or scanning unnecessary context.

## Procedure

1. Read `AGENTS.md` and root `PRD.md`.
2. If no task is specified, run `python3 scripts/task.py next`.
3. Read only that `prd/Txxx.md` and matching progress file.
4. Set task to `IN_PROGRESS` if starting work.
5. Implement the smallest coherent slice that satisfies acceptance criteria.
6. Run relevant checks.
7. Put verbose evidence in `reports/`; keep hot state concise in `progress/`.
8. Move to `IN_REVIEW` only with required automated evidence.
9. Move to `COMPLETE` only if all task gates, including human acceptance when required, are satisfied.
