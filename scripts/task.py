#!/usr/bin/env python3
from __future__ import annotations
import re, sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
PRD = ROOT / "prd"
VALID = ["PLANNED", "IN_PROGRESS", "IN_REVIEW", "COMPLETE", "BLOCKED", "DEFERRED", "CANCELLED"]
ACTIVE_PRIORITY = {"P0": 0, "P1": 1, "P2": 2, "P3": 3}

def parse(path: Path):
    text = path.read_text(encoding="utf-8")
    if not text.startswith("---\n"):
        return None
    try:
        _, front, _ = text.split("---", 2)
    except ValueError:
        return None
    data = {}
    for line in front.strip().splitlines():
        if ":" not in line:
            continue
        k, v = line.split(":", 1)
        data[k.strip()] = v.strip().strip('"')
    data["path"] = path
    return data

def tasks():
    out=[]
    for p in sorted(PRD.glob("T[0-9][0-9][0-9]*.md")):
        d=parse(p)
        if d: out.append(d)
    return out

def deps(value: str):
    value=value.strip()
    if value in ("", "[]"): return []
    return [x.strip().strip('"\'') for x in value.strip("[]").split(",") if x.strip()]

def eligible(t, by_id):
    if t.get("status") != "PLANNED": return False
    return all(by_id.get(d, {}).get("status") == "COMPLETE" for d in deps(t.get("depends_on", "[]")))

def validate():
    errors=[]; seen=set()
    for t in tasks():
        tid=t.get("id")
        if not tid or not re.fullmatch(r"T\d{3,}", tid): errors.append(f"{t['path']}: invalid id")
        if tid in seen: errors.append(f"duplicate id {tid}")
        seen.add(tid)
        if t.get("status") not in VALID: errors.append(f"{tid}: invalid status {t.get('status')}")
        if t.get("priority", "P1") not in ACTIVE_PRIORITY: errors.append(f"{tid}: invalid priority")
        if t.get("human_acceptance", "not_required") not in ("required", "not_required"):
            errors.append(f"{tid}: invalid human_acceptance")
    known={t.get("id") for t in tasks()}
    for t in tasks():
        for d in deps(t.get("depends_on", "[]")):
            if d not in known: errors.append(f"{t.get('id')}: unknown dependency {d}")
    if errors:
        print("\n".join(errors), file=sys.stderr); return 1
    print(f"Task metadata: PASS ({len(tasks())} tasks)")
    return 0

def next_task():
    ts=tasks(); by={t.get("id"):t for t in ts}
    inprog=[t for t in ts if t.get("status")=="IN_PROGRESS"]
    if inprog:
        chosen=sorted(inprog, key=lambda t:(ACTIVE_PRIORITY.get(t.get("priority","P1"),9), t.get("id")))[0]
    else:
        cand=[t for t in ts if eligible(t,by)]
        if not cand:
            print("NONE"); return
        chosen=sorted(cand, key=lambda t:(ACTIVE_PRIORITY.get(t.get("priority","P1"),9), t.get("id")))[0]
    print(f"{chosen.get('id')}\t{chosen.get('status')}\t{chosen.get('priority','P1')}\t{chosen.get('title','')}\t{chosen['path'].relative_to(ROOT)}")

def list_tasks():
    for t in tasks():
        print(f"{t.get('id')}\t{t.get('status')}\t{t.get('priority','P1')}\t{t.get('title','')}")

def set_status(tid,status):
    if status not in VALID: raise SystemExit(f"invalid status: {status}")
    matches=[t for t in tasks() if t.get("id")==tid]
    if not matches: raise SystemExit(f"unknown task: {tid}")
    p=matches[0]["path"]; text=p.read_text(encoding="utf-8")
    text,n=re.subn(r"(?m)^status:\s*\S+\s*$", f"status: {status}", text, count=1)
    if n!=1: raise SystemExit("status field not found")
    p.write_text(text,encoding="utf-8")
    print(f"{tid} -> {status}")

def check_task(tid):
    matches=[t for t in tasks() if t.get("id")==tid]
    if not matches: raise SystemExit(f"unknown task: {tid}")
    t=matches[0]; by={x.get("id"):x for x in tasks()}
    unresolved=[d for d in deps(t.get("depends_on","[]")) if by.get(d,{}).get("status")!="COMPLETE"]
    print(f"id={tid}")
    print(f"status={t.get('status')}")
    print(f"human_acceptance={t.get('human_acceptance','not_required')}")
    print(f"unresolved_dependencies={','.join(unresolved) if unresolved else 'none'}")

if __name__=="__main__":
    cmd=sys.argv[1] if len(sys.argv)>1 else "next"
    if cmd=="next": next_task()
    elif cmd=="list": list_tasks()
    elif cmd=="validate": raise SystemExit(validate())
    elif cmd=="set" and len(sys.argv)==4: set_status(sys.argv[2],sys.argv[3])
    elif cmd=="check" and len(sys.argv)==3: check_task(sys.argv[2])
    else:
        raise SystemExit("usage: task.py [next|list|validate|set T001 STATUS|check T001]")
