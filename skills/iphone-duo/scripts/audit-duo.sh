#!/usr/bin/env bash
set -euo pipefail

ROOT="${1:-.}"

if [[ ! -d "$ROOT" ]]; then
  echo "error: project root does not exist: $ROOT" >&2
  exit 2
fi

if command -v rg >/dev/null 2>&1; then
  SEARCH="rg"
else
  SEARCH="grep"
fi

echo "iPhone Duo heuristic audit"
echo "root: $ROOT"
echo "search: $SEARCH"
echo

echo "This scan reports candidates, not confirmed defects."
echo "Review every match in context before changing code."
echo

run_rg() {
  local title="$1"
  local pattern="$2"
  echo "== $title =="
  rg -n --glob '*.swift' \
    --glob '!**/.build/**' \
    --glob '!**/DerivedData/**' \
    --glob '!**/Pods/**' \
    --glob '!**/Carthage/**' \
    --glob '!**/SourcePackages/**' \
    "$pattern" "$ROOT" || true
  echo
}

run_grep() {
  local title="$1"
  local pattern="$2"
  echo "== $title =="
  find "$ROOT" \
    -type d \( -name .build -o -name DerivedData -o -name Pods -o -name Carthage -o -name SourcePackages \) -prune -o \
    -type f -name '*.swift' -print0 \
    | xargs -0 grep -nE "$pattern" 2>/dev/null || true
  echo
}

scan() {
  if [[ "$SEARCH" == "rg" ]]; then
    run_rg "$1" "$2"
  else
    run_grep "$1" "$2"
  fi
}

scan "P1 candidate: global screen assumptions" \
  'UIScreen\.main|UIScreen\.main\.bounds|main\.bounds'

scan "P1 candidate: device idiom/model layout assumptions" \
  'UIDevice\.current\.userInterfaceIdiom|userInterfaceIdiom|isDuo|isIPhoneDuo|isFolded|isUnfolded'

scan "P1 candidate: orientation-driven layout" \
  'interfaceOrientation|deviceOrientation|isLandscape|isPortrait|orientation[[:space:]]*=='

scan "P1/P2 candidate: explicit screen-width breakpoints" \
  '(geometry|proxy|size|width|bounds\.width)[^\n]{0,80}[<>]=?[[:space:]]*[0-9]{3,4}'

scan "P2 candidate: large fixed frames" \
  '\.frame\([[:space:]]*(width|height):[[:space:]]*[0-9]{3,4}'

scan "P2 candidate: fixed grid columns" \
  'GridItem\(\.fixed|Array\(repeating:[[:space:]]*GridItem|columns[[:space:]]*=[[:space:]]*[0-9]'

scan "Review: custom navigation/tab/toolbar components" \
  '(Custom|Floating|Bottom|Top)(Tab|TabBar|Toolbar|Nav|Navigation|NavigationBar)|struct[[:space:]]+[A-Za-z0-9_]*(TabBar|Toolbar|NavigationBar)'

scan "Review: safe-area overrides" \
  'ignoresSafeArea|safeAreaInset|safeAreaInsets|edgesIgnoringSafeArea'

scan "Review: geometry-heavy layout" \
  'GeometryReader|onGeometryChange|containerRelativeFrame'

scan "Review: Duo-era APIs" \
  'reservedRegions|ReservedRegion|ArrangementView|arrangementViewStyle|overlayArrangementZIndex|onHingeChange|sceneAccessory|CameraCaptureAccessory|toolbarVertical|axisBehavior|visibilityPriority|ToolbarOverflowMenu'

scan "Review: camera direction/rotation" \
  'AVCaptureDeviceDirectionCoordinator|AVCaptureDeviceRotationCoordinator|builtInOuterUltraWideCamera|builtInInnerUltraWideCamera|dynamicAspectRatio|isCameraSensorOrientationCompensationEnabled'

scan "Review: scene/window activation" \
  'WindowGroup|openWindow|requestSceneSessionActivation|UIWindowScene|scenePhase|SceneStorage'

echo "Suggested next steps:"
echo "1. Inspect P1 candidates first."
echo "2. Classify findings as Tier 1, Tier 2, or Tier 3 using SKILL.md."
echo "3. Confirm whether each match actually controls layout or state."
echo "4. Build a screen inventory and test narrow/intermediate/expansive widths."
echo "5. Verify iOS 27.1 symbols against the active Xcode SDK before implementation."
