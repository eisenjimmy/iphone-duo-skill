---
name: iphone-duo
description: >-
  Designs, audits, and adapts SwiftUI and UIKit apps for Apple iPhone Duo and
  continuously resizing iPhone interfaces. Use for foldable iPhone support,
  inner/outer display behavior, iOS 27.1 ReservedRegion, ArrangementView,
  vertical toolbars and tab bars, hinge interactions, split-view multitasking,
  multiple scenes, scene accessories, camera direction coordination, or when
  removing UIScreen, UIDevice, orientation, fixed-width, or isDuo layout logic.
compatibility: >-
  Intended for Codex, Claude Code, Cursor, and Agent Skills-compatible coding
  agents. Some Duo APIs require the iOS 27.1 SDK; verify the active Xcode SDK.
metadata:
  author: eisenjimmy
  version: "1.0.0"
  research-date: "2026-09-10"
---

# iPhone Duo

Build **one excellent adaptive iPhone experience**, not a parallel “Duo version.”

A correct Duo implementation reacts primarily to **available container space, safe areas, system navigation behavior, and reserved regions**. Use physical hinge state or multi-display APIs only when the feature itself depends on those physical capabilities.

## Mandatory reading policy

Read this file completely before changing code. Then load only the references needed for the task:

- General design, safe areas, sizing, grids: `references/01-design-and-layout.md`
- Toolbars, tab bars, split navigation, overflow: `references/02-bars-and-navigation.md`
- Fold avoidance, reserved regions, arrangements, hinge: `references/03-fold-arrangements-and-hinge.md`
- Split-view multitasking, multiple scenes, scene accessories: `references/04-scenes-and-multidisplay.md`
- Camera apps: `references/05-camera.md`
- Repository audit, test matrix, acceptance criteria: `references/06-testing-and-review.md`
- API patterns and transformation examples: `references/07-api-cookbook.md`
- Apple source provenance and freshness: `references/08-sources.md`

For an existing codebase, run `bash scripts/audit-duo.sh <project-root>` as a heuristic first pass, then validate every result manually.

---

## Non-negotiable invariants

1. **Never create a device-identity layout branch as the primary architecture.** Reject `if isDuo`, model-name checks, idiom checks, or outer/inner-display checks used merely to choose ordinary layout.
2. **Layout reacts to available space; physical interaction may react to the hinge.** Do not use hinge angle to decide sidebar visibility, column count, navigation collapse, or routine responsive layout.
3. **Preserve semantic view identity and app state across resizing.** Folding must not reset navigation path, selection, scroll state, draft text, playback, form data, or unsaved edits.
4. **Prefer system containers.** `NavigationStack`, `NavigationSplitView`, `TabView`, `List`, `ScrollView`, sheets, alerts, menus, popovers, and standard toolbars gain fold-aware behavior automatically.
5. **Respect each safe-area edge independently.** Duo layouts can be asymmetric.
6. **Do not put critical content across a fold or occlusion region.** Backgrounds and continuous scrolling content may cross when interruption is acceptable.
7. **Keep navigation outside `ArrangementView`.** An arrangement is a layout container, not a navigation architecture.
8. **Do not place `ArrangementView` inside a `List` or `ScrollView` unless current Apple documentation explicitly changes this guidance.**
9. **Prefer system bars to custom bars.** System navigation/toolbars can become vertical and manage overflow; hand-built bars usually cannot.
10. **Do not manually target two physical displays as independent app canvases.** Use scenes and scene accessories according to system availability.
11. **Duo-specific functionality is additive.** The app must remain fully functional when hinge data, a second display accessory, or another Duo-only capability is unavailable.
12. **Do not invent dimensions, hinge coordinates, bar widths, or camera geometry.** Query the environment or use system APIs.
13. **Verify the active SDK before emitting iOS 27.1 code.** If a symbol is unavailable, prepare an isolation boundary or conditional implementation instead of fabricating an API.

---

## Three implementation tiers

Classify every proposed change before editing code.

### Tier 1 — Universal adaptive foundation

Implement first. Typical work:

```text
size classes
container-relative layout
NavigationSplitView / NavigationStack
adaptive TabView and sidebar placement
adaptive grids
ViewThatFits / AnyLayout
safe areas and layout margins
system sheets / alerts / popovers
system toolbar adoption
state continuity during resizing
removing UIScreen.main and orientation assumptions
```

Tier 1 should improve ordinary iPhones, iPhone Mirroring, split view, and other resizable environments too.

### Tier 2 — Duo-aware presentation

Add only after Tier 1 is sound:

```text
reserved division/occlusion regions
displacement around the fold
ArrangementView split/overlay layouts
vertical bar representations
vertical toolbar compression / overflow behavior
fold-sensitive placement of manually laid out controls
```

### Tier 3 — Duo-exclusive capability

Add only when it creates genuine product value:

```text
onHingeChange physical interactions
multi-scene workflows
scene accessories
camera capture accessories
explicit Duo camera direction coordination
```

Do not escalate to Tier 2 or Tier 3 merely because the user mentioned iPhone Duo.

---

## Required workflow

### 1. Establish the build context

Before proposing Duo-only code, inspect:

- UI framework: SwiftUI, UIKit, or mixed;
- deployment target;
- active Xcode and SDK version if available;
- navigation architecture;
- state ownership model;
- presence of custom bars, custom geometry, camera code, or multi-scene support.

If the SDK cannot verify a documented Duo API, clearly mark that work **SDK-blocked** rather than guessing.

### 2. Audit the repository

Search for these high-risk patterns:

```text
UIScreen.main
UIScreen.main.bounds
UIDevice.current.userInterfaceIdiom
userInterfaceIdiom
interfaceOrientation
orientation ==
isLandscape / isPortrait
isDuo / isFolded / isUnfolded
fixed large .frame(width: ...)
manual screen-width breakpoints
custom bottom bars / fake navigation bars
fixed grid column counts
safe-area mirroring assumptions
separate compact/expanded state stores
```

Do not mechanically replace every match. Determine whether each use actually controls layout.

### 3. Audit each screen in this order

Ask:

1. Does it remain usable from very narrow through intermediate to expansive widths?
2. Is the information hierarchy appropriate at wider sizes, or merely stretched?
3. Is navigation using a semantic system container?
4. Are text and forms capped to a readable width?
5. Can grids adapt by minimum item width rather than fixed column count?
6. Do system bars replace custom controls where possible?
7. Could any important control, text, image focal point, QR code, handle, or editor affordance intersect a fold/occlusion region?
8. Are two related content surfaces a legitimate `ArrangementView` candidate?
9. Is any behavior genuinely physical and therefore a hinge candidate?
10. Would a second-display accessory create useful supplementary value without becoming required for the main workflow?

### 4. Produce a change plan before broad refactors

For non-trivial repositories, return a compact table containing:

```text
file / screen
observed problem
user impact
Tier 1/2/3
recommended system API or pattern
state-continuity risk
SDK/test dependency
```

Prefer the smallest coherent transformation. Do not redesign unrelated product UX simply to demonstrate Duo APIs.

### 5. Implement Tier 1 first

Preferred decision order for ordinary responsive layout:

```text
system navigation/content container
→ adaptive grid/layout container
→ ViewThatFits / AnyLayout
→ size classes
→ local geometry
→ exact measured threshold only when semantically justified
```

Use width thresholds only when they represent a real minimum usable content width, not guessed device categories.

### 6. Add fold awareness locally

If a fold affects one critical element, displace that element or its local container. Do not rebuild the whole screen.

Use reserved regions only where manually laid-out content needs knowledge of the fold/camera. Standard containers should be allowed to adapt on their own.

### 7. Add arrangements only for two-part experiences

Good candidates:

```text
player + queue
preview + controls
editor + inspector
canvas + properties
content + supplementary metadata
camera preview + capture controls
```

Use split when both surfaces deserve dedicated space; use overlay when one surface is clearly foreground/supplementary and partial obscuration is acceptable.

### 8. Add hinge behavior only for physical interaction

Good candidates:

```text
instrument pitch/effect
physical game input
tabletop controls
camera posture behavior
mechanical-feeling animation tied to device pose
```

Bad candidates:

```text
show sidebar when angle > X
use 3 columns when flat
collapse navigation when partly folded
select compact UI from hinge status
```

Always handle a missing hinge and reset transient interaction state when the relevant hinge state ends.

### 9. Validate bars and navigation

When system bars are present, inspect:

- back/close placement;
- prominent actions;
- symbol and title availability;
- custom-view ability to represent vertically;
- item `axisBehavior` where needed;
- toolbar/tab compression priority;
- overflow menu composition;
- item visibility priority;
- keyboard-induced compression;
- outer-display landscape;
- right-to-left layout assumptions.

Do not reserve the ellipsis symbol for an unrelated action when system overflow is in use.

### 10. Validate state continuity

During compact ↔ regular, outer ↔ inner, fold/unfold, and split-view resizing, explicitly verify:

```text
navigation path
selected item
scroll position
focused field
editor/draft content
playback state
active filters
sheet/popover intent
unsaved work
scene-specific state
```

Adaptive presentation must not create a second source of truth.

### 11. Compile and test in coherent batches

After each structural batch:

- build the affected target;
- fix compile errors before moving on;
- exercise multiple widths, not only “closed” and “open”;
- run the matrix in `references/06-testing-and-review.md` when simulator support is available;
- distinguish **verified**, **not testable in current environment**, and **deferred** findings.

---

## Review severity

Use these levels when auditing:

- **P0 — functional breakage:** content inaccessible, action obscured, state loss, crash, camera/session failure.
- **P1 — architectural incompatibility:** device-identity layout, custom navigation that blocks adaptation, hard screen assumptions, duplicated state trees.
- **P2 — degraded Duo experience:** stretched wide UI, poor vertical bar representation, fold-adjacent critical content, weak overflow prioritization.
- **P3 — enhancement:** ArrangementView opportunity, optional scene accessory, hinge-native interaction, camera polish.

Do not present Tier 3 novelty as more important than Tier 1 correctness.

---

## Output contract for repository reviews

When asked to review but not modify code, return:

1. **Readiness verdict** — Ready / Mostly adaptive / Material refactor needed.
2. **Evidence-backed findings** — file paths and relevant symbols/lines.
3. **Tier classification** — universal, Duo-aware, or Duo-exclusive.
4. **Priority order** — P0 through P3.
5. **Implementation sequence** — smallest safe batches.
6. **Test plan** — widths/poses/scenes that matter for this app.
7. **SDK caveats** — any iOS 27.1 API that was not verifiable.

When asked to implement, make the changes and then report the same structure as a completion summary with build/test evidence.

---

## Red flags to reject during code review

```swift
if isDuo { DuoDashboard() } else { Dashboard() }
if isFolded { CompactRoot() } else { ExpandedRoot() }
let width = UIScreen.main.bounds.width
if UIDevice.current.userInterfaceIdiom == .pad { ... }
if orientation == .landscape { ... }
if hinge.angle.degrees > 120 { showSidebar = true }
```

Also flag:

- global screen geometry for local container layout;
- mirrored safe-area assumptions;
- fixed sidebar widths without content rationale;
- custom tab bars that cannot reorient or overflow;
- long toolbar text that has no symbol representation;
- fixed spacer tricks inside system bars;
- critical content centered on the fold;
- layouts tested only at two endpoint sizes;
- multiple independent view models for compact and expanded versions of the same feature;
- manual attempts to move the primary app UI to a second physical display;
- exact camera selection logic that ignores device direction changes.

---

## Completion definition

A Duo adaptation is complete only when:

- ordinary responsive layout works across a continuum of widths;
- information hierarchy improves appropriately on expansive space;
- navigation and state survive resizing;
- system bars are allowed to adapt unless there is a documented reason to opt out;
- important content avoids safe areas and active reserved regions;
- fold-specific displacement is minimal and contextual;
- `ArrangementView` is used only where semantically appropriate;
- hinge APIs drive physical interactions rather than routine layout;
- second-display content is supplementary and availability-aware;
- camera behavior remains directionally correct if camera features exist;
- all implemented SDK symbols compile in the target environment, or unavailable work is explicitly isolated and deferred;
- the test report includes intermediate widths and split-view conditions, not only fully closed/open states.

The objective is not to make the code “Duo-aware” everywhere. The objective is to remove assumptions so the product feels native everywhere, then exploit Duo hardware only where the experience becomes materially better.
