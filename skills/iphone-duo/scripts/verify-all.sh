#!/usr/bin/env bash
# Run every repository-level check without requiring a hosted CI service.
#
# Usage:
#   bash skills/iphone-duo/scripts/verify-all.sh
#   bash skills/iphone-duo/scripts/verify-all.sh --online
#
# Default mode is deterministic and offline. --online additionally re-resolves
# Apple documentation URLs through verify-manifest.sh.
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL="$(dirname "$HERE")"
ROOT="$(cd "$SKILL/../.." && pwd)"
ONLINE=0

for arg in "$@"; do
  case "$arg" in
    --online) ONLINE=1 ;;
    -h|--help)
      sed -n '1,12p' "$0"
      exit 0
      ;;
    *) echo "unknown argument: $arg" >&2; exit 2 ;;
  esac
done

command -v python3 >/dev/null || { echo "python3 required" >&2; exit 2; }

MANIFEST="$SKILL/data/api-manifest.json"
SCHEMA="$SKILL/data/api-manifest.schema.json"
PATTERNS="$SKILL/data/patterns.json"
AUDIT="$HERE/audit-duo.sh"
VERIFY_MANIFEST="$HERE/verify-manifest.sh"

echo "iPhone Duo skill — full verification"
echo "===================================="

echo
echo "[structure]"
test -f "$SKILL/SKILL.md"
test -f "$MANIFEST"
test -f "$SCHEMA"
test -f "$PATTERNS"
test -f "$AUDIT"
test -f "$VERIFY_MANIFEST"
name="$(awk '/^name:/{print $2; exit}' "$SKILL/SKILL.md")"
[ "$name" = "iphone-duo" ] || { echo "SKILL.md name '$name' != directory 'iphone-duo'"; exit 1; }
line_count="$(wc -l < "$SKILL/SKILL.md" | tr -d ' ')"
[ "$line_count" -lt 500 ] || { echo "SKILL.md is $line_count lines; Agent Skills recommends keeping it under 500"; exit 1; }
if command -v skills-ref >/dev/null 2>&1; then
  skills-ref validate "$SKILL"
  echo "  skills-ref validation ok"
else
  echo "  skills-ref not installed — structural validation completed locally"
fi
echo "  ok"

echo
echo "[shell syntax]"
for f in "$HERE"/*.sh; do
  bash -n "$f"
  printf '  ok  %s\n' "$(basename "$f")"
done
if command -v shellcheck >/dev/null; then
  shellcheck -S warning "$HERE"/*.sh
  echo "  shellcheck ok"
else
  echo "  shellcheck not installed — syntax checks completed"
fi

echo
echo "[json + manifest + audit contracts]"
python3 - "$MANIFEST" "$SCHEMA" "$PATTERNS" "$SKILL/references" <<'PY'
import datetime, json, pathlib, re, sys

manifest_path, schema_path, patterns_path, refs_path = map(pathlib.Path, sys.argv[1:])
manifest = json.loads(manifest_path.read_text())
schema = json.loads(schema_path.read_text())
patterns = json.loads(patterns_path.read_text())

# The schema is dependency-free at verification time. Enforce the operational
# contract here; editors and external validators can consume the JSON Schema.
required_top = {
    "manifestVersion", "researchDate", "staleAfterDays", "note",
    "statusLegend", "sdkTimeline", "symbols"
}
missing = sorted(required_top - manifest.keys())
if missing:
    raise SystemExit(f"manifest missing top-level fields: {missing}")

if manifest.get("$schema") != "./api-manifest.schema.json":
    raise SystemExit("manifest $schema must point to ./api-manifest.schema.json")
if schema.get("$schema") != "https://json-schema.org/draft/2020-12/schema":
    raise SystemExit("schema must declare JSON Schema draft 2020-12")
if not re.fullmatch(r"\d+\.\d+\.\d+", manifest["manifestVersion"]):
    raise SystemExit("manifestVersion must be semver")
datetime.date.fromisoformat(manifest["researchDate"])
if not isinstance(manifest["staleAfterDays"], int) or manifest["staleAfterDays"] < 1:
    raise SystemExit("staleAfterDays must be a positive integer")

statuses = {"verified", "apple-sourced", "conflicted"}
if set(manifest["statusLegend"]) != statuses:
    raise SystemExit("statusLegend must define exactly verified/apple-sourced/conflicted")

refs = {p.name for p in refs_path.glob("*.md")}
ids = set()
for i, symbol in enumerate(manifest["symbols"]):
    where = f"symbols[{i}]"
    for key in ("id", "name", "framework", "kind", "status", "availability", "duoExclusive", "usedIn"):
        if key not in symbol:
            raise SystemExit(f"{where} missing {key}")
    if symbol["id"] in ids:
        raise SystemExit(f"duplicate symbol id: {symbol['id']}")
    ids.add(symbol["id"])
    if symbol["status"] not in statuses:
        raise SystemExit(f"{where} invalid status: {symbol['status']}")
    if not isinstance(symbol["duoExclusive"], bool):
        raise SystemExit(f"{where}.duoExclusive must be boolean")
    if not symbol["usedIn"] or len(symbol["usedIn"]) != len(set(symbol["usedIn"])):
        raise SystemExit(f"{where}.usedIn must be non-empty and unique")
    stale = sorted(set(symbol["usedIn"]) - refs)
    if stale:
        raise SystemExit(f"{where} has stale usedIn entries: {stale}")
    if symbol["status"] == "verified" and not symbol.get("docUrl"):
        raise SystemExit(f"{where} verified symbols require docUrl")
    if symbol["status"] == "apple-sourced" and not symbol.get("sourceUrl"):
        raise SystemExit(f"{where} apple-sourced symbols require sourceUrl")
    if symbol["status"] == "conflicted" and not symbol.get("conflict"):
        raise SystemExit(f"{where} conflicted symbols require conflict")

if not re.fullmatch(r"\d+\.\d+\.\d+", patterns.get("patternsVersion", "")):
    raise SystemExit("patternsVersion must be semver")
categories = patterns.get("categories")
if not isinstance(categories, list) or not categories:
    raise SystemExit("patterns.json must contain a non-empty categories array")
pattern_ids = []
required_category = {"id", "title", "severity", "tier", "why", "fix", "expectZeroInDuoReadyApp", "patterns"}
allowed_severity = {"P0", "P1", "P2", "P3", "info"}
for i, category in enumerate(categories):
    where = f"categories[{i}]"
    missing = sorted(required_category - category.keys())
    if missing:
        raise SystemExit(f"{where} missing fields: {missing}")
    if category["severity"] not in allowed_severity:
        raise SystemExit(f"{where}.severity invalid: {category['severity']}")
    if category["tier"] not in (1, 2, 3):
        raise SystemExit(f"{where}.tier must be 1, 2, or 3")
    if not isinstance(category["expectZeroInDuoReadyApp"], bool):
        raise SystemExit(f"{where}.expectZeroInDuoReadyApp must be boolean")
    if not isinstance(category["patterns"], list) or not category["patterns"]:
        raise SystemExit(f"{where}.patterns must be a non-empty array")
    if len(category["patterns"]) != len(set(category["patterns"])):
        raise SystemExit(f"{where}.patterns contains duplicates")
    for expression in category["patterns"]:
        try:
            re.compile(expression)
        except re.error as exc:
            raise SystemExit(f"{where} invalid regex {expression!r}: {exc}")
    pattern_ids.append(category["id"])
if len(pattern_ids) != len(set(pattern_ids)):
    raise SystemExit("pattern category ids must be unique")

print(f"  manifest: {len(manifest['symbols'])} symbols, {len(ids)} unique ids")
print(f"  patterns: {len(pattern_ids)} valid categories")
print("  contracts ok")
PY

echo
echo "[links + prose references + asset policy]"
python3 - "$ROOT" "$SKILL/references" <<'PY'
import pathlib, re, sys, xml.dom.minidom
root = pathlib.Path(sys.argv[1])
refs_dir = pathlib.Path(sys.argv[2])
md_link = re.compile(r'\[[^\]]*\]\(([^)#]+?)(?:#[^)]*)?\)')
html_link = re.compile(r'(?:src|href)="([^"#]+?)(?:#[^"]*)?"')
# Reference filenames often appear as prose code spans rather than Markdown
# links. Those must be checked too or renames can silently leave stale advice.
ref_literal = re.compile(r'`((?:\.{0,2}/)?[0-9]{2}-[a-z0-9-]+\.md)`')
broken = []
markdown = list(root.rglob("*.md"))
for f in markdown:
    if ".git" in f.parts:
        continue
    text = f.read_text(errors="replace")
    for rx in (md_link, html_link):
        for m in rx.finditer(text):
            target = m.group(1).strip()
            if target.startswith(("http://", "https://", "mailto:", "data:")):
                continue
            if not (f.parent / target).exists():
                broken.append(f"{f.relative_to(root)} -> {target}")
    for target in ref_literal.findall(text):
        name = pathlib.Path(target).name
        if not (refs_dir / name).exists():
            broken.append(f"{f.relative_to(root)} -> stale reference literal {target}")
if broken:
    print("broken/stale references:")
    for item in sorted(set(broken)):
        print("  ", item)
    raise SystemExit(1)

for svg in sorted((root / "assets").glob("*.svg")):
    xml.dom.minidom.parse(str(svg))

raster_ext = {".jpg", ".jpeg", ".png", ".heic"}
raster = [p for p in root.rglob("*") if p.is_file() and p.suffix.lower() in raster_ext and ".git" not in p.parts]
if raster:
    raise SystemExit("raster assets are not permitted: " + ", ".join(str(p.relative_to(root)) for p in raster))

print(f"  {len(markdown)} markdown files: links and reference literals ok")
print("  SVG well-formed; no vendored raster imagery")
PY

echo
echo "[audit self-test]"
fixture="$(mktemp -d)"
trap 'rm -rf "$fixture"' EXIT
mkdir -p "$fixture/Sources"
cat > "$fixture/Sources/Bad.swift" <<'EOF'
import SwiftUI
struct RootView: View {
    var body: some View {
        let width = UIScreen.main.bounds.width
        if isDuo { Text("A") } else { Text("B") }
    }
}
final class compactViewModel {}
EOF
cat > "$fixture/Sources/Good.swift" <<'EOF'
import SwiftUI
struct DetailView: View {
    @Environment(\.horizontalSizeClass) private var sizeClass
    var body: some View { Text("hello") }
}
EOF
if "$AUDIT" "$fixture" --quiet >/dev/null 2>&1; then
  echo "  audit failed to reject bad fixture" >&2
  exit 1
fi
rm "$fixture/Sources/Bad.swift"
"$AUDIT" "$fixture" --quiet >/dev/null
echo "  bad fixture rejected; clean fixture accepted"

echo
echo "[manifest evidence]"
if [ "$ONLINE" -eq 1 ]; then
  "$VERIFY_MANIFEST"
else
  OFFLINE=1 "$VERIFY_MANIFEST"
fi

echo
echo "RESULT: repository verification passed."
