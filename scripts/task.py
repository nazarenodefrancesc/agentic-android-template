#!/usr/bin/env python3
from __future__ import annotations

import hashlib
import re
import sys
from datetime import datetime, timezone
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
PRD = ROOT / "prd"
VALID = ["PLANNED", "IN_PROGRESS", "IN_REVIEW", "COMPLETE", "BLOCKED", "DEFERRED", "CANCELLED"]
ACTIVE_PRIORITY = {"P0": 0, "P1": 1, "P2": 2, "P3": 3}
ALLOWED_TRANSITIONS = {
    "PLANNED": {"IN_PROGRESS", "BLOCKED", "DEFERRED", "CANCELLED"},
    "IN_PROGRESS": {"IN_REVIEW", "BLOCKED", "DEFERRED", "CANCELLED"},
    "IN_REVIEW": {"COMPLETE", "IN_PROGRESS", "BLOCKED", "DEFERRED", "CANCELLED"},
    "BLOCKED": {"PLANNED", "IN_PROGRESS", "DEFERRED", "CANCELLED"},
    "DEFERRED": {"PLANNED", "CANCELLED"},
    "COMPLETE": {"IN_PROGRESS"},  # explicit reopen
    "CANCELLED": {"PLANNED"},
}


def parse(path: Path):
    text = path.read_text(encoding="utf-8")
    match = re.match(r"\A---\s*\n(.*?)\n---(?:\s*\n|\Z)", text, re.S)
    if not match:
        return None
    data = {}
    for line in match.group(1).splitlines():
        if ":" not in line:
            continue
        key, value = line.split(":", 1)
        data[key.strip()] = value.strip().strip('"')
    data["path"] = path
    return data


def tasks():
    out = []
    for path in sorted(PRD.glob("T[0-9][0-9][0-9]*.md")):
        data = parse(path)
        if data:
            out.append(data)
    return out


def deps(value: str):
    value = value.strip()
    if value in ("", "[]"):
        return []
    return [x.strip().strip('"\'') for x in value.strip("[]").split(",") if x.strip()]


def eligible(task, by_id):
    if task.get("status") != "PLANNED":
        return False
    return all(by_id.get(dep, {}).get("status") == "COMPLETE" for dep in deps(task.get("depends_on", "[]")))


def acceptance_path(task_id: str) -> Path:
    return ROOT / "reports" / "acceptance" / f"{task_id}.md"


def has_passed_human_acceptance(task_id: str) -> bool:
    path = acceptance_path(task_id)
    if not path.is_file():
        return False
    text = path.read_text(encoding="utf-8")
    return bool(re.search(r"(?m)^result:\s*PASS\s*$", text))


def _dependency_cycle(by_id):
    visiting = set()
    visited = set()

    def visit(task_id, stack):
        if task_id in visiting:
            start = stack.index(task_id) if task_id in stack else 0
            return stack[start:] + [task_id]
        if task_id in visited:
            return None
        visiting.add(task_id)
        stack.append(task_id)
        for dep in deps(by_id[task_id].get("depends_on", "[]")):
            if dep in by_id:
                cycle = visit(dep, stack)
                if cycle:
                    return cycle
        stack.pop()
        visiting.remove(task_id)
        visited.add(task_id)
        return None

    for task_id in by_id:
        cycle = visit(task_id, [])
        if cycle:
            return cycle
    return None


def validate():
    errors = []
    seen = set()
    parsed_tasks = tasks()
    for task in parsed_tasks:
        task_id = task.get("id")
        filename_id = task["path"].stem
        if not task_id or not re.fullmatch(r"T\d{3,}", task_id):
            errors.append(f"{task['path']}: invalid id")
        if task_id and task_id != filename_id:
            errors.append(f"{task['path']}: front-matter id {task_id} does not match filename {filename_id}")
        if task_id in seen:
            errors.append(f"duplicate id {task_id}")
        seen.add(task_id)
        if task.get("status") not in VALID:
            errors.append(f"{task_id}: invalid status {task.get('status')}")
        if task.get("priority", "P1") not in ACTIVE_PRIORITY:
            errors.append(f"{task_id}: invalid priority")
        if task.get("human_acceptance", "not_required") not in ("required", "not_required"):
            errors.append(f"{task_id}: invalid human_acceptance")

    by_id = {task.get("id"): task for task in parsed_tasks if task.get("id")}
    for task in parsed_tasks:
        task_id = task.get("id")
        for dep in deps(task.get("depends_on", "[]")):
            if dep not in by_id:
                errors.append(f"{task_id}: unknown dependency {dep}")
            if dep == task_id:
                errors.append(f"{task_id}: task cannot depend on itself")

    cycle = _dependency_cycle(by_id) if by_id else None
    if cycle:
        errors.append("dependency cycle: " + " -> ".join(cycle))

    if errors:
        print("\n".join(errors), file=sys.stderr)
        return 1
    print(f"Task metadata: PASS ({len(parsed_tasks)} tasks)")
    return 0


def next_task():
    task_list = tasks()
    by_id = {task.get("id"): task for task in task_list}
    in_progress = [task for task in task_list if task.get("status") == "IN_PROGRESS"]
    if in_progress:
        chosen = sorted(
            in_progress,
            key=lambda task: (ACTIVE_PRIORITY.get(task.get("priority", "P1"), 9), task.get("id")),
        )[0]
    else:
        candidates = [task for task in task_list if eligible(task, by_id)]
        if not candidates:
            print("NONE")
            return
        chosen = sorted(
            candidates,
            key=lambda task: (ACTIVE_PRIORITY.get(task.get("priority", "P1"), 9), task.get("id")),
        )[0]
    print(
        f"{chosen.get('id')}\t{chosen.get('status')}\t{chosen.get('priority', 'P1')}\t"
        f"{chosen.get('title', '')}\t{chosen['path'].relative_to(ROOT)}"
    )


def list_tasks():
    for task in tasks():
        print(f"{task.get('id')}\t{task.get('status')}\t{task.get('priority', 'P1')}\t{task.get('title', '')}")


def set_status(task_id, status):
    if status not in VALID:
        raise SystemExit(f"invalid status: {status}")
    matches = [task for task in tasks() if task.get("id") == task_id]
    if not matches:
        raise SystemExit(f"unknown task: {task_id}")
    task = matches[0]
    current = task.get("status")
    if status == current:
        print(f"{task_id} already {status}")
        return
    if status not in ALLOWED_TRANSITIONS.get(current, set()):
        raise SystemExit(f"invalid transition: {task_id} {current} -> {status}")
    if status == "COMPLETE" and task.get("human_acceptance", "not_required") == "required":
        if not has_passed_human_acceptance(task_id):
            raise SystemExit(
                f"{task_id}: human acceptance is required; record it first with "
                f"task.py accept {task_id} path/to/accepted.apk"
            )

    path = task["path"]
    text = path.read_text(encoding="utf-8")
    text, count = re.subn(r"(?m)^status:\s*\S+\s*$", f"status: {status}", text, count=1)
    if count != 1:
        raise SystemExit("status field not found")
    path.write_text(text, encoding="utf-8")
    print(f"{task_id}: {current} -> {status}")


def check_task(task_id):
    matches = [task for task in tasks() if task.get("id") == task_id]
    if not matches:
        raise SystemExit(f"unknown task: {task_id}")
    task = matches[0]
    by_id = {item.get("id"): item for item in tasks()}
    unresolved = [
        dep for dep in deps(task.get("depends_on", "[]")) if by_id.get(dep, {}).get("status") != "COMPLETE"
    ]
    print(f"id={task_id}")
    print(f"status={task.get('status')}")
    print(f"human_acceptance={task.get('human_acceptance', 'not_required')}")
    print(f"human_acceptance_recorded={'yes' if has_passed_human_acceptance(task_id) else 'no'}")
    print(f"unresolved_dependencies={','.join(unresolved) if unresolved else 'none'}")


def accept_task(task_id: str, artifact_arg: str):
    matches = [task for task in tasks() if task.get("id") == task_id]
    if not matches:
        raise SystemExit(f"unknown task: {task_id}")
    task = matches[0]
    if task.get("human_acceptance", "not_required") != "required":
        raise SystemExit(f"{task_id}: human_acceptance is not required")
    if task.get("status") != "IN_REVIEW":
        raise SystemExit(f"{task_id}: acceptance can only be recorded while IN_REVIEW")

    artifact = Path(artifact_arg)
    if not artifact.is_absolute():
        artifact = (ROOT / artifact).resolve()
    if not artifact.is_file():
        raise SystemExit(f"accepted artifact not found: {artifact}")

    digest = hashlib.sha256(artifact.read_bytes()).hexdigest()
    metadata_path = Path(str(artifact) + ".metadata.txt")
    metadata = {}
    if metadata_path.is_file():
        for line in metadata_path.read_text(encoding="utf-8").splitlines():
            if "=" in line:
                key, value = line.split("=", 1)
                metadata[key] = value

    out = acceptance_path(task_id)
    out.parent.mkdir(parents=True, exist_ok=True)
    relative_artifact = artifact
    try:
        relative_artifact = artifact.relative_to(ROOT)
    except ValueError:
        pass
    now = datetime.now(timezone.utc).replace(microsecond=0).isoformat().replace("+00:00", "Z")
    content = [
        "---",
        f"task: {task_id}",
        "result: PASS",
        f"accepted_utc: {now}",
        "---",
        "",
        f"# Physical acceptance — {task_id}",
        "",
        f"- Artifact: `{relative_artifact}`",
        f"- SHA-256: `{digest}`",
    ]
    for key in ("version", "build_number", "git_sha", "git_state", "signing_mode", "signing_cert_sha256"):
        if key in metadata:
            content.append(f"- {key}: `{metadata[key]}`")
    content += ["", "Human acceptance was explicitly reported for this QA artifact.", ""]
    out.write_text("\n".join(content), encoding="utf-8")
    print(f"Recorded human acceptance: {out.relative_to(ROOT)}")


if __name__ == "__main__":
    command = sys.argv[1] if len(sys.argv) > 1 else "next"
    if command == "next":
        next_task()
    elif command == "list":
        list_tasks()
    elif command == "validate":
        raise SystemExit(validate())
    elif command == "set" and len(sys.argv) == 4:
        set_status(sys.argv[2], sys.argv[3])
    elif command == "check" and len(sys.argv) == 3:
        check_task(sys.argv[2])
    elif command == "accept" and len(sys.argv) == 4:
        accept_task(sys.argv[2], sys.argv[3])
    else:
        raise SystemExit(
            "usage: task.py [next|list|validate|set T001 STATUS|check T001|accept T001 path/to/accepted.apk]"
        )
