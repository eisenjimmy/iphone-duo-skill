# 01 — Design and adaptive layout

Use this reference for general iPhone Duo design, responsive SwiftUI/UIKit architecture, safe areas, readable widths, grids, and screen-assumption removal.

## Design model

Treat iPhone Duo as **iPhone with a wider range of available spaces and poses**, not as a separate platform. The same app may appear on the outer display, the inner display, beside another app, in a partially open pose, or in an intermediate resizable region.

The design hierarchy is:

1. preserve function and information architecture;
2. adapt to available space;
3. preserve continuity while the device changes pose;
4. use additional width to expose useful hierarchy;
5. introduce Duo-specific behavior only where the hardware changes the experience.

Avoid dramatic rearrangement while a person folds the device. Small, contextual displacement is easier to track than an unrelated replacement layout.

## Size classes over orientation

Prefer environment/trait information that describes **usable space**:

```swift
@Environment(\.horizontalSizeClass) private var horizontalSizeClass
@Environment(\.verticalSizeClass) private var verticalSizeClass
```

Do not make ordinary layout decisions from interface orientation. The HIG states the outer display is **compact width** and the inner display is **regular width**. Tech Talk 111461 goes further: the inner display is **regular in both dimensions** and **does not honor supported interface orientations**. Attribute accordingly — the vertical-dimension and orientation claims come from the talk, not the HIG.

Use size classes for broad information-architecture changes, and local container geometry for component-level decisions.

## Containers, not physical screens

A component should normally respond to the size offered by its parent. Avoid treating physical display dimensions as the layout contract.

Preferred techniques:

```text
NavigationSplitView
NavigationStack
TabView
Grid / LazyVGrid
GridItem(.adaptive(minimum: ...))
ViewThatFits
AnyLayout
containerRelativeFrame
onGeometryChange
GeometryReader when truly necessary
```

Avoid:

```swift
let screenWidth = UIScreen.main.bounds.width
```

On a device with multiple displays, “main screen” is ambiguous. When UIKit genuinely needs the current screen for a non-layout purpose, derive it from the active window scene rather than `UIScreen.main`.

## Adaptive decision order

For every responsive problem, attempt solutions in this order:

1. semantic system container;
2. adaptive grid/container;
3. `ViewThatFits` or `AnyLayout`;
4. size classes;
5. measured local geometry;
6. explicit threshold only when the content has a defensible minimum width.

A threshold like `width > 700` is acceptable only if 700 points represents a real usability constraint, not an encoded guess that “700 means Duo.”

## Wide layout quality

Do not simply stretch an outer-display design across the inner display.

Good expansive transformations:

```text
list                  → list + detail
editor                → editor + inspector
player                → player + queue/transcript
preview                → preview + controls
single card column     → adaptive multi-column cards
bottom tab navigation  → persistent sidebar where appropriate
```

Bad transformation:

```text
340-point form → same form stretched almost edge-to-edge
```

For text-heavy interfaces, constrain reading measure. A value such as `maxWidth: 650–750` can be a reasonable content-design choice when justified by the screen, typography, and localization, but should not be treated as a Duo device constant.

## Adaptive grids

For cards, thumbnails, dashboards, watchlists, or other repeated content, prefer minimum-item-width behavior:

```swift
private let columns = [
    GridItem(.adaptive(minimum: 220), spacing: 16)
]
```

This handles compact, intermediate, split-view, and expansive widths more gracefully than choosing a fixed column count from device state.

If fold-aware spacing is required, retain the adaptive grid but use reserved-region information to alter local spacing or grouping rather than replacing the entire grid.

### Even columns across the fold

The HIG is explicit: **"In a grid-style layout, prefer an even number of columns so content
divides cleanly."** An odd column count puts a column *on* the folding region.

`.adaptive(minimum:)` is the right default at narrow and intermediate widths, but it yields
whatever count fits — odd counts included — which is exactly wrong on the inner display, the
case this skill exists for. Size the minimum so the natural count lands even at Duo widths,
or pin an explicit even count once you are in expansive presentation:

```swift
GridItem(.adaptive(minimum: 220), spacing: 16)                        // narrow → intermediate
Array(repeating: GridItem(.flexible(), spacing: 16), count: 4)        // expansive: keep it even
```

Query `reservedRegions(kind: .division, options: .includeInactive)` if you need to know the
fold is there while the device is flat — the region has zero width when open, but its
existence is the reason the count matters.

## `ViewThatFits`

Use `ViewThatFits` when multiple semantically equivalent arrangements are acceptable:

```swift
ViewThatFits(in: .horizontal) {
    HStack { Summary(); Actions() }
    VStack { Summary(); Actions() }
}
```

This asks “which arrangement fits?” instead of “which device is this?”

## `AnyLayout`

Use `AnyLayout` when preserving child view identity is particularly important while rearranging the same views:

```swift
let layout: AnyLayout = prefersHorizontal
    ? AnyLayout(HStackLayout(spacing: 16))
    : AnyLayout(VStackLayout(spacing: 12))

layout {
    Preview()
    Controls()
}
```

The boolean must come from layout semantics such as available container space, not `isDuo`.

## Safe areas

Foreground controls and readable content belong inside safe areas unless the design explicitly requires otherwise. Background artwork may extend behind system regions.

SwiftUI example:

```swift
ZStack {
    Artwork()
        .ignoresSafeArea()

    Content()
}
```

Important Duo rule: **never assume opposite safe-area edges are equal**. Cameras, bars, the fold, and multitasking can produce asymmetric insets.

UIKit should use the full safe-area geometry rather than mirroring one edge:

```swift
let usable = view.bounds.inset(by: view.safeAreaInsets)
```

instead of manually subtracting `left * 2` or `top * 2`.

## Full-width visual content

Full-bleed to the physical width only when the view holds no readable text and no tap target under 44pt — media canvases, maps, game boards, camera previews. The HIG adds one hard constraint: **nothing may conflict with the Dynamic Island or the status bar.** Mixing is fine — a background or header may span full width while scrollable content stays inset.

A hybrid composition is often strongest:

```text
full-width image/background
+ safe-area-aligned text and controls
```

Do not center critical interactive content against the full physical display merely to make the composition geometrically symmetrical.

## State ownership

State should outlive presentation changes. Hoist shared state above layout switches where appropriate:

```text
navigation path
selection
scroll target
form/editor contents
playback
filter state
scene model
```

Do not instantiate one model for compact presentation and another model for expanded presentation if they represent the same user task.

## Screen review questions

For each screen, answer:

- What is the narrowest meaningful version?
- What additional hierarchy becomes useful as width grows?
- Which controls must remain spatially stable during resizing?
- Is any content excessively wide?
- Does a fixed frame represent content needs or historical device assumptions?
- Can a custom HStack/VStack switch become `ViewThatFits`, `AnyLayout`, a grid, or `ArrangementView`?
- Does the screen retain state while crossing size-class boundaries?
- Are safe-area assumptions valid on every edge independently?

## Anti-pattern transformations

### Device branch

Avoid:

```swift
if isDuo {
    DuoDashboard()
} else {
    Dashboard()
}
```

Prefer one dashboard whose layout adapts internally.

### Physical screen width

Avoid:

```swift
.frame(width: UIScreen.main.bounds.width * 0.8)
```

Prefer parent-relative sizing or a semantic maximum width.

### Fixed columns

Avoid:

```swift
let columns = isExpanded ? 3 : 1
```

Prefer:

```swift
GridItem(.adaptive(minimum: 220))
```

### Orientation branch

Avoid:

```swift
if orientation == .landscape { ... }
```

Prefer size class, aspect ratio, or local available space depending on what the design actually needs.

## Games

The HIG gives games their own best practice, and the skill would otherwise hand a
Unity/SpriteKit/Metal team nothing:

- You **may** lock to portrait or landscape — but **fill the screen in every pose**.
- **Prefer changing the aspect ratio** over letterboxing or pillarboxing.
- If padding is unavoidable, **fill it with artwork** so the experience still reads as
  full screen.
- Keep text and control sizes as consistent as you can while the device resizes.

## Acceptance criteria

A general layout passes this reference when:

- it remains coherent at narrow, compact, intermediate, and wide sizes;
- no ordinary layout depends on device identity or global screen dimensions;
- safe areas are handled independently;
- wide presentation reveals useful structure rather than only whitespace;
- readable content has a sensible measure;
- repeated content adapts without brittle fixed columns;
- application state survives layout transitions.
