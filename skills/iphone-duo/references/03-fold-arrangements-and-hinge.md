# 03 — Fold, reserved regions, arrangements, and hinge

Use this reference when content can intersect the physical fold or camera, when two related surfaces need reorganization, or when a product feature genuinely responds to hinge posture.

## Distinguish three concepts

Do not conflate these APIs:

```text
safe areas       → system UI / edge protection
reserved regions → physical or system areas inside usable geometry
hinge data       → live physical posture / interaction input
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

SwiftUI pattern documented by Apple:

```swift
GeometryReader { proxy in
    let regions = proxy.reservedRegions(kind: .division)
    // incorporate region frames into local layout
}
```

Do not assume one permanent hinge rectangle. Query the current region.

### Occlusion regions

An occlusion region covers content without dividing the entire container. The camera is an example.

```swift
GeometryReader { proxy in
    let regions = proxy.reservedRegions(kind: .occlusion)
}
```

Use this for manually positioned focal content or controls that cannot be obscured.

## Active versus inactive regions

By default, queries return active regions. Apple also documents querying inactive regions:

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

When displacement is necessary, choose the destination based on task semantics and physical posture rather than arbitrary geometry.

Examples:

- book-like partial fold: keep transient actions where users can continue tracking them as the device closes;
- tabletop posture: viewing content may fit the upper region while interactive controls belong closer to the lower region;
- two equally valid regions: preserve spatial continuity with the control's previous location.

Minimize movement distance and surprise.

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

Use overlay when one view is foreground/supplementary to another and partial obscuration is acceptable:

```swift
NavigationStack {
    ArrangementView {
        UpNextView()
    } secondary: {
        PlayerView()
    }
    .arrangementViewStyle(.overlay)
}
```

Apple documents `overlayArrangementZIndex` as an environment value that can help a child adapt its internal representation when it is in front versus behind:

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

## Hinge API

SwiftUI provides `onHingeChange` for live hinge context. Apple describes high-level status values including closed, partially open, and fully open, plus continuous angle updates.

Pattern:

```swift
struct InstrumentView: View {
    @State private var effectAmount = 0.0

    var body: some View {
        InstrumentSurface(effectAmount: effectAmount)
            .onHingeChange { _, context in
                if let hinge = context.hinge,
                   hinge.status == .partiallyOpen {
                    effectAmount = mapAngle(hinge.angle)
                } else {
                    effectAmount = 0
                }
            }
    }
}
```

Always handle `context.hinge == nil`, because the code may run on devices without a hinge.

## Good hinge use cases

Use hinge data when the **physical bend itself** is part of the product interaction:

- musical pitch/modulation;
- game steering or mechanical input;
- tabletop controller effects;
- camera posture behavior;
- a physical-book effect whose state is directly tied to device motion;
- a deliberate tactile animation synchronized with folding.

## Bad hinge use cases

Never write ordinary layout logic such as:

```swift
if hinge.angle.degrees > 120 {
    showSidebar = true
}
```

or:

```swift
columns = hinge.status == .fullyOpen ? 3 : 1
```

Use available space, size classes, arrangement rules, or reserved regions for those decisions.

## Hinge-state lifecycle

When a continuous hinge effect applies only while partially open:

1. enter relevant posture;
2. update interaction state continuously;
3. clamp/normalize values if necessary;
4. reset state when the posture ends;
5. ensure no stale value remains after closing/opening fully;
6. make the feature harmless on devices without a hinge.

Do not persist transient hinge angle as long-lived application state unless the product explicitly requires it.

## Performance

Hinge callbacks can update frequently. Keep work lightweight:

- map angles with pure math;
- avoid network/database work;
- avoid rebuilding unrelated view models;
- throttle only when a genuinely expensive downstream effect requires it;
- drive animations/effects from a compact state value.

## Audit checklist

- Are critical elements ever centered across the fold?
- Is fold geometry queried rather than guessed?
- Are inactive regions being used semantically rather than as a device detector?
- Can displacement solve the issue locally?
- Is an `ArrangementView` truly a two-part content experience?
- Is navigation outside the arrangement?
- Is the arrangement outside scroll containers?
- Is hinge data used only because the physical hinge matters?
- Is missing-hinge behavior safe?
- Does transient hinge interaction reset correctly?
- Does state remain stable as layout placement changes?

## Acceptance criteria

This area passes when fold interference is handled with queried geometry and minimal displacement, arrangements are semantically justified, hinge data never substitutes for responsive layout, and the app remains fully functional without Duo-specific hardware signals.
