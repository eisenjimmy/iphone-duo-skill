#!/usr/bin/env bash
# Verifies that this skill's factual layer has not rotted.
#
#   1. the research snapshot is inside its staleness budget
#   2. every `docUrl` in data/api-manifest.json still resolves at Apple
#   3. every Apple-shaped API symbol named in SKILL.md or references exists in the manifest
#   4. every `usedIn` filename still exists
#
# The watchlist for (3) is DERIVED FROM THE MANIFEST — this script owns no
# symbol names of its own. Exit 0 clean, 1 on drift, 2 on a broken setup.
#
#   OFFLINE=1   skip all network access
set -uo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL="$(dirname "$HERE")"
MANIFEST="$SKILL/data/api-manifest.json"
REFS="$SKILL/references"
CORE="$SKILL/SKILL.md"
OFFLINE="${OFFLINE:-0}"
fail=0

command -v python3 >/dev/null || { echo "python3 required"; exit 2; }
[ -f "$MANIFEST" ] || { echo "missing manifest: $MANIFEST"; exit 2; }
[ -d "$REFS" ]     || { echo "missing references: $REFS"; exit 2; }
[ -f "$CORE" ]     || { echo "missing core skill: $CORE"; exit 2; }

echo "iPhone Duo skill — manifest verification"
echo "========================================"

# Any non-zero exit from a check (including an unhandled Python traceback)
# must fail the run. Never gate on a sentinel code.
run_check() {
  if ! python3 - "$@"; then fail=1; fi
}

# ---------------------------------------------------------------- staleness
echo
echo "[freshness]"
run_check "$MANIFEST" <<'PY'
import json, sys, datetime
m = json.load(open(sys.argv[1]))
d = datetime.date.fromisoformat(m["researchDate"])
age = (datetime.date.today() - d).days
budget = m.get("staleAfterDays", 45)
print(f"  researchDate={m['researchDate']}  age={age}d  budget={budget}d")
if age > budget:
    print(f"  STALE by {age - budget} days. Re-verify against Apple and bump researchDate.")
    sys.exit(1)
print("  fresh")
PY

# ------------------------------------------------------------ doc url check
echo
if [ "$OFFLINE" = "1" ]; then
  echo "[docUrls] skipped (OFFLINE=1)"
else
  echo "[docUrls] re-resolving documented symbols against developer.apple.com"
  urls="$(python3 - "$MANIFEST" <<'PY'
import json, sys
m = json.load(open(sys.argv[1]))
for s in m["symbols"]:
    if s.get("docUrl"):
        print(s["id"] + "\t" + s["docUrl"])
PY
)" || { echo "  could not read manifest"; exit 2; }

  while IFS=$'\t' read -r id url; do
    [ -z "${url:-}" ] && continue
    json_url="$(printf '%s' "$url" | sed 's|developer.apple.com/documentation|developer.apple.com/tutorials/data/documentation|').json"
    code=$(curl -sIL -o /dev/null -w '%{http_code}' -A 'Mozilla/5.0' --max-time 20 "$json_url")
    if [ "$code" = "200" ]; then
      printf '  ok    %s\n' "$id"
    else
      printf '  DRIFT %s  (HTTP %s)\n         %s\n' "$id" "$code" "$json_url"
      fail=1
    fi
  done <<< "$urls"
fi

# ------------------------------------------- prose symbols exist in manifest
echo
echo "[coverage] Apple-shaped symbols in SKILL.md and references/ must exist in the manifest"
run_check "$MANIFEST" "$CORE" "$REFS" <<'PY'
import json, sys, re, pathlib

m = json.load(open(sys.argv[1]))
core = pathlib.Path(sys.argv[2])
refs = pathlib.Path(sys.argv[3])

# The watchlist is derived from the manifest, not hand-maintained here.
known = set()
for s in m["symbols"]:
    name = s["name"]
    known.add(name)
    known.add(name.split("(")[0])
    for part in name.replace("(", ".").split("."):
        if part:
            known.add(part)
    for mem in s.get("members", []):
        mem = mem.strip(".")
        known.add(mem)
        known.add(mem.split("(")[0])

# Any identifier shaped like a Duo/Apple API that prose asserts must be known.
# Heuristic: UpperCamel types with an Apple prefix, or camelCase members that
# look like framework API rather than English.
CANDIDATE = re.compile(
    r"`([A-Za-z_][A-Za-z0-9_]*(?:\.[A-Za-z_][A-Za-z0-9_]*)*(?:\([^`]*\))?)`"
)
APPLEISH = re.compile(
    r"^(UI[A-Z]|AV[A-Z]|NS[A-Z])"
    r"|^(Toolbar|Scene|Arrangement|Reserved|Camera|Hinge|Concentric|Navigation|Tab)[A-Z]"
    r"|^(on|toolbar|scene|arrangement|reserved|camera|hinge|axis|vertical|visibility|default|overlay|dynamic)[A-Z]"
)
# Named deliberately as things NOT to adopt; they are documented as traps.
ALLOWED_ANTIPATTERNS = {
    "UIScreen.main", "UIScreen", "UIScreen.main.bounds", "UIScreen.main.scale",
    "UIScreen.screens", "UIDevice.current.userInterfaceIdiom", "UIDevice",
    "UIToolbar", "UINavigationBar", "UITabBar",
    "AVCaptureDeviceRotationCoordinator",
}

files = [core, *sorted(refs.glob("*.md"))]
missing = {}
for f in files:
    for n, line in enumerate(f.read_text().splitlines(), 1):
        for sym in CANDIDATE.findall(line):
            base = sym.split("(")[0]
            if any(base == a or base.startswith(a + ".") for a in ALLOWED_ANTIPATTERNS):
                continue
            if not APPLEISH.search(base.split(".")[-1]) and not APPLEISH.search(base):
                continue
            if sym in known or base in known or base.split(".")[-1] in known:
                continue
            missing.setdefault(sym, []).append(f"{f.name}:{n}")

if missing:
    print("  UNMANIFESTED symbols asserted in prose:")
    for s, locs in sorted(missing.items()):
        extra = " (+%d more)" % (len(locs) - 1) if len(locs) > 1 else ""
        print(f"    {s}  ->  {locs[0]}{extra}")
    print("\n  Add them to data/api-manifest.json, or stop naming them.")
    sys.exit(1)
print(f"  ok — every Apple-shaped symbol in SKILL.md + references/ is manifested ({len(known)} known names)")
PY

# ------------------------------------------- usedIn points at real files
echo
echo "[usedIn] every referenced filename exists"
run_check "$MANIFEST" "$REFS" <<'PY'
import json, sys, pathlib
m = json.load(open(sys.argv[1]))
have = {p.name for p in pathlib.Path(sys.argv[2]).glob("*.md")}
bad = {}
for s in m["symbols"]:
    for u in s.get("usedIn", []):
        if u not in have:
            bad.setdefault(u, []).append(s["id"])
if bad:
    print("  STALE usedIn filenames (files renamed or removed):")
    for f, ids in sorted(bad.items()):
        extra = " (+%d more)" % (len(ids) - 1) if len(ids) > 1 else ""
        print(f"    {f}  <- {ids[0]}{extra}")
    sys.exit(1)
print(f"  ok — all usedIn filenames resolve ({len(have)} reference files)")
PY

# --------------------------------------------------------------- inventory
echo
echo "[inventory]"
run_check "$MANIFEST" <<'PY'
import json, sys, collections
m = json.load(open(sys.argv[1]))
c = collections.Counter(s["status"] for s in m["symbols"])
for k, v in sorted(c.items()):
    print(f"  {k:<14} {v}")
print(f"  {'TOTAL':<14} {len(m['symbols'])}")
conf = [s["id"] for s in m["symbols"] if s["status"] == "conflicted"]
if conf:
    print("  conflicted: " + ", ".join(conf))
PY

echo
if [ "$fail" -ne 0 ]; then
  echo "RESULT: drift detected — the factual layer needs a human pass."
  exit 1
fi
echo "RESULT: manifest verified."
