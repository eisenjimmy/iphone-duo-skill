# 03 — Fold, reserved regions, and arrangements

Use this reference when content can intersect the physical fold or camera, when two related surfaces need reorganization, or when a product feature genuinely responds to the device pose.

## Distinguish three concepts

Do not conflate these APIs:

```text
safe areas       → system UI / edge protection
reserved regions → physical or system areas inside usable geometry
hinge data       → live physical pose / interaction input
```

Layout normally uses safe areas and reserved regions. Hinge state is primarily an interaction signal.

## Reserved regions

Apple describes hardware- or system-shaped areas as reserved regions. On iPhone Duo, important examples include:

- the central fold/hinge area on the inner display;
- the front-facing camera region;
- other system-defined regions that content should avoid or adapt around.

There are two useful semantic categories:

### Division regions

A division region splits a larger usable area into smaller regions. The fold is represented this way.

SwiftUI pattern from Apple's Tech Talk 111463:

```swift
GeometryReader { proxy in
    let regions = proxy.reservedRegions(kind: .division)
    // incorporate region frames into local layout
}
```

Do not assume one permanent hinge rectangle. Query the current region.

### Occlusion regions

The two camera regions are **not** equivalent, and the difference decides whether you can
treat the region as static:

- **Outer front camera — always present.** It expands into the Dynamic Island for Live
  Activities and is vertically aligned with the side controls.
- **Inner front camera — only while the camera is active.** Invisible otherwise; when a
  capture session starts, the UI moves aside to reveal it.

An occlusion region covers content without dividing the entire container. The camera is an example.

```swift
GeometryReader { proxy in
    let regions = proxy.reservedRegions(kind: .occlusion)
}
```

Use this for manually positioned focal content or controls that cannot be obscured.

## Active versus inactive regions

By default, queries return active regions. Apple's Tech Talk 111463 also shows querying inactive ones:

```swift
proxy.reservedRegions(
    kind: .division,
    options: .includeInactive
)
```

An inactive fold can still provide structural information even when flat; for example, an adaptive grid may prefer symmetry around where the division would occur. However, do not turn inactive geometry into a fake device breakpoint.

## Fold-avoidance policy

Critical content should avoid the fold:

```text
buttons
small text
input controls
faces / image focal points
QR codes
precise charts or labels
drag handles
scrubbers
small icons with semantic meaning
```

Content that can often cross the fold:

```text
background gradients
textures
noncritical photography
continuous scrolling feeds/articles
large ambient visualizations
```

The question is not “can pixels cross the fold?” The question is “does interruption damage meaning or interaction?”

## Displacement before redesign

Apple's recommended pattern is often **displacement**: move or resize the smallest affected unit while preserving the rest of the composition.

Examples:

```text
one floating action button intersects fold
→ move only that button

player controls intersect fold
→ move the control group as one semantic unit

continuous article crosses fold
→ usually keep scrolling naturally; don't split every paragraph
```

Avoid changing the entire screen architecture merely because a region became active.

## Choosing a destination

When displacement is necessary, choose the destination based on task semantics and physical pose rather than arbitrary geometry.

Examples:

- book-like partial fold: keep transient actions where users can continue tracking them as the device closes;
- tabletop pose: viewing content may fit the upper region while interactive controls belong closer to the lower region;
- two equally valid regions: preserve spatial continuity with the control's previous location.

Minimize movement distance and surprise.

## Which arrangement? Read your existing layout

The HIG gives the most actionable refactoring heuristic in the whole guide:

| You already have | Use |
|---|---|
| `HStack` — two views side by side | **split** |
| `VStack` — one above the other | **split** |
| `ZStack` — one layered over another | **overlay** |

A **split** arrangement divides its bounds: **horizontally when it is wider than tall,
vertically when taller than wide**. Restrict that with `.axes(…)`. When it cannot split along
a permitted axis it shows a single view.

## `ArrangementView`

`ArrangementView` is a Duo-era adaptive layout container for **two related views**. It is not a replacement for navigation.

Appropriate structures:

```text
player + queue
video + transcript
preview + controls
editor + inspector
canvas + properties
content + supplementary metadata
```

Poor uses:

```text
app-wide tab navigation
master navigation list + arbitrary unrelated page
entire app root merely because Duo is open
```

### Split arrangement

Use a split arrangement when both surfaces deserve dedicated visible space and neither should obscure the other.

Apple's SwiftUI pattern:

```swift
NavigationStack {
    ArrangementView {
        PlayerView()
    } secondary: {
        UpNextView()
    }
    .arrangementViewStyle(.split)
}
```

The system can choose a horizontal or vertical split based on available geometry. Restrict axes only when content semantics require it:

```swift
.arrangementViewStyle(.split.axes(.horizontal))
```

Do not encode device-specific layout logic around the arrangement.

### Overlay arrangement

Overlay has a precise structural rule: **the primary view is the foreground view when the
arrangement is overlaying**. Apple's HIG describes the primary view as moving atop the
secondary view. When the display becomes partially open, the views stop overlaying and move
to occupy separate sides.

Do not infer primary/secondary ownership from generic product labels such as “player,”
“controls,” or “queue.” Decide which surface should own the foreground role in the overlay
state, make that surface primary, and keep those semantic roles stable across transitions.
Apple's published example uses `UpNextView` as primary and `PlayerView` as secondary:

```swift
NavigationStack {
    ArrangementView {
        UpNextView()      // primary: foreground while overlaying
    } secondary: {
        PlayerView()      // secondary: behind while overlaying
    }
    .arrangementViewStyle(.overlay)
}
```

The important rule is not that a particular product surface must always be primary; it is
that **primary means foreground in overlay**, and the agent must choose that relationship
intentionally.

Apple's Tech Talk 111463 shows `overlayArrangementZIndex` as an environment value that lets a child adapt its internal representation when it is in front versus behind:

```swift
@Environment(\.overlayArrangementZIndex) private var zIndex
```

Use that to collapse/expand local content, not to mutate global app state.

## Arrangement placement rules

Strict rules:

- place navigation containers **around** an `ArrangementView`, not inside it;
- avoid putting `ArrangementView` inside `List` or `ScrollView` under current Apple guidance;
- keep the primary/secondary semantic roles stable;
- preserve state outside layout placement where possible;
- don't use an arrangement if a standard split view or ordinary adaptive stack already solves the problem better.

## When not to use `ArrangementView`

Prefer ordinary adaptive layout when:

- there are more than two peer surfaces;
- the change is merely grid density;
- navigation hierarchy is the real problem;
- only one button needs fold avoidance;
- a standard `NavigationSplitView` already expresses list/detail semantics;
- the existing design is a scrolling page with independent sections.

## Audit checklist

- Are critical elements ever centered across the fold?
- Is fold geometry queried rather than guessed?
- Are inactive regions being used semantically rather than as a device detector?
- Can displacement solve the issue locally?
- Is an `ArrangementView` truly a two-part content experience?
- Is primary/secondary ownership correct for the intended overlay foreground?
- Is navigation outside the arrangement?
- Is the arrangement outside scroll containers?
- Is hinge data used only because the physical hinge matters?
- Is missing-hinge behavior safe?
- Does transient hinge interaction reset correctly?
- Does state remain stable as layout placement changes?

## Acceptance criteria

This area passes when fold interference is handled with queried geometry and minimal displacement, arrangements are semantically justified, overlay primary/secondary ownership is deliberate, hinge data never substitutes for responsive layout, and the app remains fully functional without Duo-specific hardware signals.
