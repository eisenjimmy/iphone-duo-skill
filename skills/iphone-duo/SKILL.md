---
name: iphone-duo
description: >-
  Designs, audits, and adapts SwiftUI and UIKit apps for Apple iPhone Duo and
  continuously resizing iPhone interfaces. Use for foldable iPhone support,
  inner/outer display behavior, reserved regions, arrangement views, vertical
  toolbars and tab bars, hinge interactions, Split View multitasking, multiple
  scenes, scene accessories, camera direction coordination, or when removing
  UIScreen, UIDevice, orientation, fixed-width, or isDuo layout logic.
compatibility: >-
  Any Agent Skills-compatible coding agent (Codex, Cursor, or compatible harnesses).
  Duo-only APIs require the iOS 27.1 SDK; the skill degrades to Tier 1 work
  when the active SDK is older.
metadata:
  author: eisenjimmy
  version: "2.3.0"
  research-date: "2026-09-10"
  fact-source: "data/api-manifest.json"
---

# iPhone Duo

> **Layout reacts to available space. Physical interaction may react to the hinge.**
> Every rule below is a consequence of that one sentence.

iPhone Duo has an inner display and an outer display, each with a front camera, joined
by a hinge. It is still an iPhone. An app that genuinely resizes already works; an app
that encodes screen assumptions breaks in ways users notice immediately.

Build **one adaptive app**. There is real Duo-specific code — reserved regions,
arrangements, hinge, scenes — but every sanctioned branch is gated on a *capability*
(is there a hinge? is a region active? is the accessory available?), never on device
identity.

## Load only what the task needs

| File | Load when |
|---|---|
| `references/01-design-and-layout.md` | Sizing, size classes, grids, safe areas, state continuity |
| `references/02-bars-and-navigation.md` | Toolbars, tab bars, vertical bars, overflow, split navigation |
| `references/03-fold-arrangements.md` | Reserved regions, fold avoidance, `ArrangementView` |
| `references/04-hardware-scenes-hinge.md` | Hinge input, Split View, multiple scenes, scene accessories |
| `references/05-camera.md` | Any capture, preview, or camera-direction work |
| `references/06-testing-and-review.md` | Audit method, test matrix, report templates |
| `references/07-api-cookbook.md` | **The code index.** Every full call site and transformation |
| `references/08-sources.md` | Apple provenance, freshness, source precedence |

`data/api-manifest.json` is the **only** authority on whether an Apple API symbol named by
this skill is real. Its `status` field says `verified` (Apple doc page resolves),
`apple-sourced` (verbatim from Apple sample/chapter material, no dedicated DocC page yet),
or `conflicted` (Apple's own materials disagree). **Never invent or silently substitute a
Duo-relevant symbol.** If the manifest or active SDK cannot support it, report `SDK-blocked`.

---

## Invariants

Each rule states the violation that proves it.

1. **No device-identity branch for ordinary layout.**
   `if isDuo`, model checks, idiom checks, or inner/outer-display checks used to pick a
   normal layout. Branch on space, not identity.
2. **Hinge is interaction input, never a layout switch.** Apple is explicit. Layout
   belongs to reserved regions and arrangements.
   ✗ `if hinge.angle.degrees > 120 { showSidebar = true }`
3. **State survives resizing.** Folding must not reset navigation path, selection,
   scroll, focus, draft text, playback, filters, or unsaved edits. One state owner —
   never a parallel `compactViewModel` / `expandedViewModel`.
4. **Prefer system containers.** `NavigationStack`, `NavigationSplitView`, `TabView`,
   `List`, sheets, alerts, menus, and container-provided toolbars get fold-aware
   behavior free. Content in a hand-rolled `UIToolbar` is not considered at all.
5. **Treat every safe-area edge independently.** Duo insets are routinely asymmetric.
   ✗ `bounds.width - safeAreaInsets.left * 2`
6. **Nothing critical crosses a fold or an occlusion.** The test is not "can pixels
   cross?" but **"does interruption damage meaning or interaction?"** Backgrounds and
   continuously scrolling content may cross; a button, QR code, or drag handle may not.
7. **Occlusion covers; division splits.** Treating a division region as occlusion is the
   most common Duo layout bug.
8. **Keep navigation outside `ArrangementView`.** It is a layout container with no
   navigation infrastructure. Never nest `NavigationSplitView` inside one.
9. **Never put `ArrangementView` inside `List` or `ScrollView`.**
10. **Never target the two displays as independent canvases.** Use scenes and scene
    accessories. New windows cannot be created on the outer display.
11. **Duo-only capability is always additive.** The app stays whole when the hinge,
    accessory, or second display is absent. A nil hinge means the device has none.
12. **Never invent a dimension.** Apple publishes pixel sizes but **not** logical point
    sizes and **not** the native scale. Query the environment.
13. **Never invent an API.** If the manifest lacks a Duo-relevant symbol or the SDK cannot
    resolve it, report it `SDK-blocked` and stop rather than guessing.

### Reject on sight

```swift
if isDuo { DuoDashboard() } else { Dashboard() }     // 1
if isFolded { CompactRoot() } else { ExpandedRoot() } // 1, 3
let width = UIScreen.main.bounds.width                // 12 — and UIScreen.main is going away
if UIDevice.current.userInterfaceIdiom == .pad { }    // 1
if orientation == .landscape { }                      // inner display ignores orientation
if hinge.angle.degrees > 120 { showSidebar = true }   // 2
```

The full machine-readable catalog is `data/patterns.json`; `scripts/audit-duo.sh`
executes it. Do not re-type these patterns anywhere.

---

## Three concepts agents conflate

| Concept | What it describes | Drives |
|---|---|---|
| **Safe areas** | Where system UI sits | Insetting content — always |
| **Reserved regions** | Physical areas *inside* usable geometry: the two cameras, the fold | Displacing hand-laid-out content |
| **Hinge input** | How open the device physically is | Interaction and effects — never layout |

---

## Tiers

Classify every change before editing. Earn each tier before the next.

| Tier | Scope | Gate |
|---|---|---|
| **1** | Universal adaptive: size classes, container-relative layout, adaptive grids, safe areas, system navigation, state continuity | Do first. Needs no Duo API and improves every device. |
| **2** | Duo-aware presentation: reserved regions, displacement, `ArrangementView`, vertical bar tuning, overflow priority | Only after Tier 1 is sound. Needs iOS 27.1 SDK. |
| **3** | Duo-exclusive: hinge interaction, multiple scenes, scene accessories, camera direction coordination | Only when it creates real product value. |

Mentioning iPhone Duo is not a reason to reach Tier 2 or 3. Tier 3 novelty never
outranks Tier 1 correctness.

---

## Workflow

### 1. Establish context

UI framework, deployment target, active Xcode/SDK, navigation architecture, state
ownership, and whether custom bars, hand-built geometry, camera code, or multi-scene
support exist.

SDK reality, per Apple: apps run un-recompiled; the **iOS 27 SDK** extends the app left
of the status bar on the inner display; the **iOS 27.1 SDK** reaches the screen edge and
lays bars out vertically. Tier 2 and 3 need 27.1. Test in the iPhone Duo simulator via
**Device Hub** in Xcode 27.1, which can open, close, rotate, and fold the device.

### 2. Scan

Run `scripts/audit-duo.sh <project-root>` from the installed skill directory. It reads
`data/patterns.json` and ranks hits P0–P2. It is a grep: every hit needs judgment about
whether it actually controls layout.

### 3. Audit each screen

1. Usable from very narrow through intermediate to expansive width?
2. Does wider space improve hierarchy, or merely stretch?
3. Is navigation a semantic system container?
4. Is body text capped to a readable measure?
5. Do grids adapt by minimum item width — and land on an **even** column count, so
   content divides cleanly across the fold?
6. Is every action in a custom bar expressible as a `ToolbarItem`? List those that
   are not, with the reason.
7. Could any control, QR code, drag handle, or image focal point intersect a reserved
   region?
8. Are two related surfaces a real `ArrangementView` candidate?
9. Is any behavior genuinely *physical*, and therefore a hinge candidate?
10. Would a scene accessory add supplementary value without becoming required?

### 4. Plan before refactoring

Return a table: file/screen · observed problem · user impact · tier · recommended API ·
state-continuity risk · SDK dependency. Prefer the smallest coherent transformation.
Never redesign unrelated UX to demonstrate a Duo API.

### 5. Implement Tier 1 first

Decision order for ordinary responsive layout:

```text
system navigation/content container
→ adaptive grid or layout container
→ ViewThatFits / AnyLayout
→ size classes
→ local geometry
→ measured threshold, only when semantically justified
```

**A width threshold is allowed only if you can name the content that stops fitting
below it, and you write that derivation inline** — `// 2 × 220pt card + 16pt gutter = 456`.
No derivation, no threshold: use `ViewThatFits`.

### 6. Add fold awareness locally

If a fold affects one element, displace that element or its local container. Do not
rebuild the screen. Move the shortest distance that clears the region, and never
displace across the fold into the other half. Avoid dramatic rearrangement while
someone is folding — small tracked movement beats a replacement layout.

Query reserved regions only where **you** lay out content by hand. System containers
already adapt.

### 7. Arrangements for genuine two-part experiences

Good: player + queue, preview + controls, editor + inspector, canvas + properties,
camera preview + capture controls. Split when both surfaces deserve dedicated space;
overlay when one is clearly supplementary and partial obscuration is acceptable. An
existing `HStack`/`VStack` maps to split; a `ZStack` maps to overlay.

### 8. Hinge only for physical interaction

Good: instrument pitch bend, physical game input, tabletop controls, camera pose,
mechanical-feeling animation. Bad: anything that decides columns, sidebars, or
navigation. Always unwrap the optional hinge and reset transient interaction state when
the pose ends.

### 9. Bars

Controls move to the side on the outer display and on the inner display in landscape.
**The inner display in portrait keeps standard horizontal bars** — that is the exception.
In Split View each app puts its controls on its **outer** edge. Because the bar is
hardware-aligned it **stays on the same side in right-to-left languages** — do not flip it.

Reserve the top of the vertical axis for back/close, then prominent actions. Give every
non-text item both a title and a symbol — the title is what overflow menus show. Keep
text-only buttons rare; they stay horizontal. Group items instead of spacing them by
hand: flexible spacers are zero-size vertically. Let the system own the ellipsis.

### 10. Verify state continuity

Across compact ↔ regular, outer ↔ inner, fold, and Split View resizing, confirm:
navigation path, selection, scroll position, focused field, draft content, playback,
active filters, sheet intent, unsaved work, and scene-local state. Adaptive presentation
must never create a second source of truth.

### 11. Build and report honestly

Build after each coherent batch. Exercise intermediate widths, not just the two endpoint
poses. Label every claim with exactly one of:

| Label | Means |
|---|---|
| `verified` | Ran it and observed the result |
| `compile-verified only` | It builds; behavior unobserved |
| `design-verified` | Reasoned from code; nothing executed |
| `SDK-blocked` | Symbol unavailable in the active SDK |
| `deferred` | Deliberately out of scope |

If no Duo simulator is available, mark rows `design-verified` and stop. **Never describe
an unexecuted check as a test.**

For changes to this skill repository itself, run `scripts/verify-all.sh`. Use
`scripts/verify-all.sh --online` whenever Apple API evidence changes.

---

## Games

Lock to portrait or landscape if you must, but fill the screen in every pose. Prefer
changing aspect ratio over letterboxing or pillarboxing; if padding is unavoidable, fill
it with artwork. Keep text and control sizes consistent as the device resizes.

## Severity

**P0** functional breakage — content unreachable, action obscured, state lost, crash,
capture failure. **P1** architectural incompatibility — device-identity layout, hinge
driving layout, custom navigation that blocks adaptation, duplicated state trees.
**P2** degraded experience — stretched wide UI, weak vertical bar representation,
fold-adjacent critical content, poor overflow priority. **P3** enhancement — arrangement
opportunity, optional accessory, hinge-native interaction.

## Reporting

Use the report templates and full test matrix in `references/06-testing-and-review.md`.
Review output: verdict · evidence with file paths · tier · P0–P3 order · implementation
sequence · test plan · SDK caveats. Implementation output: the same structure, as a
completion summary with build evidence.

When Apple's current documentation disagrees with this skill, **Apple wins** — see the
source-precedence ladder in `references/08-sources.md`. Do not force code from here.
