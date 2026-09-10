#!/usr/bin/env bash
# iPhone Duo readiness — heuristic first-pass scan.
#
#   bash audit-duo.sh <project-root> [--json] [--quiet]
#
# Patterns come from data/patterns.json — the single source of truth. This
# script owns NO pattern strings of its own; add patterns there.
#
# This is a grep. It finds candidates, not defects. Every hit needs a human or
# an agent to decide whether the match actually controls layout. Exit code is
# 0 unless a category marked `expectZeroInDuoReadyApp` has hits.
set -uo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PATTERNS="$(dirname "$HERE")/data/patterns.json"
ROOT="${1:-}"; shift || true
JSON=0; QUIET=0
for a in "$@"; do case "$a" in --json) JSON=1;; --quiet) QUIET=1;; esac; done

[ -z "$ROOT" ] && { echo "usage: audit-duo.sh <project-root> [--json] [--quiet]"; exit 2; }
[ -d "$ROOT" ] || { echo "not a directory: $ROOT"; exit 2; }
[ -f "$PATTERNS" ] || { echo "missing $PATTERNS"; exit 2; }
command -v python3 >/dev/null || { echo "python3 required"; exit 2; }

python3 - "$ROOT" "$PATTERNS" "$JSON" "$QUIET" <<'PY'
import json,sys,re,pathlib

root,patterns_path,as_json,quiet = sys.argv[1],sys.argv[2],sys.argv[3]=="1",sys.argv[4]=="1"
cfg=json.load(open(patterns_path))

EXT={".swift",".m",".mm",".h"}
SKIP={".build","DerivedData","Pods","Carthage","node_modules",".git","vendor",".swiftpm"}
files=[p for p in pathlib.Path(root).rglob("*")
       if p.suffix in EXT and not any(s in p.parts for s in SKIP)]

if not files:
    print(f"No Swift/ObjC sources found under {root}"); sys.exit(2)

results=[]; swift_files=sum(1 for f in files if f.suffix==".swift")

# Read and pre-filter each file ONCE, not once per category.
docs=[]
for f in files:
    try: text=f.read_text(errors="replace")
    except Exception: continue
    lines=[]; in_block=False
    for n,line in enumerate(text.splitlines(),1):
        st=line.strip()
        if in_block:
            if "*/" in st: in_block=False
            continue
        if st.startswith("/*"):
            if "*/" not in st: in_block=True
            continue
        if st.startswith("//"): continue
        lines.append((n,line,st))
    docs.append((str(f.relative_to(root)),lines))

for cat in cfg["categories"]:
    rx=re.compile("|".join(f"(?:{p})" for p in cat["patterns"]))
    hits=[]
    for rel,lines in docs:
        for n,line,st in lines:
            if rx.search(line):
                hits.append({"file":rel,"line":n,"text":st[:160]})
    results.append({**{k:cat[k] for k in ("id","title","severity","tier","why","fix")},
                    "expectZero":cat.get("expectZeroInDuoReadyApp",False),
                    "count":len(hits),"hits":hits})

blocking=[r for r in results if r["expectZero"] and r["count"]>0]

if as_json:
    print(json.dumps({"root":root,"patternsVersion":cfg["patternsVersion"],
                      "filesScanned":len(files),"swiftFiles":swift_files,
                      "categories":results},indent=2))
    sys.exit(1 if blocking else 0)

W=76
print("="*W)
print("iPhone Duo readiness scan".center(W))
print("="*W)
print(f"root            {root}")
print(f"files scanned   {len(files)}  ({swift_files} Swift)")
print(f"patterns        v{cfg['patternsVersion']}\n")

order={"P0":0,"P1":1,"P2":2,"info":3}
for r in sorted(results,key=lambda r:(order.get(r["severity"],9),-r["count"])):
    if r["count"]==0 and quiet: continue
    flag = "  <-- must be zero" if (r["expectZero"] and r["count"]) else ""
    print(f"[{r['severity']:<4}] tier {r['tier']}  {r['title']}  ({r['count']} hits){flag}")
    if r["count"]:
        print(f"         why  {r['why']}")
        print(f"         fix  {r['fix']}")
        for h in r["hits"][:6]:
            print(f"           {h['file']}:{h['line']}  {h['text'][:90]}")
        if r["count"]>6: print(f"           ... {r['count']-6} more")
    print()

adopt=next((r for r in results if r["id"]=="duo-api-surface"),None)
if adopt is not None and adopt["count"]==0 and swift_files>20:
    print("note: zero Duo API adoption across a non-trivial codebase.")
    print("      Expected if you are starting Tier 1. Suspicious if you believe\n"
          "      this app already ships Duo-aware layout.\n")

print("-"*W)
if blocking:
    print("VERDICT: material refactor needed — "
          + ", ".join(f"{b['title']} ({b['count']})" for b in blocking))
else:
    print("VERDICT: no blocking patterns. Grep cannot judge layout quality —\n"
          "         continue with the screen-by-screen audit in references/06.")
print("-"*W)
print("\nThis is a heuristic. Confirm every hit before acting on it.")
sys.exit(1 if blocking else 0)
PY
