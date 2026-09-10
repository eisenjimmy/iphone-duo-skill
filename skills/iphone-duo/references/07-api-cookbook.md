# 07 — API cookbook and transformation patterns

This file is a fast implementation reference. Always verify exact symbol availability in the active SDK, especially iOS 27.1 APIs.

## 1. Read size classes

```swift
@Environment(\.horizontalSizeClass) private var horizontalSizeClass
@Environment(\.verticalSizeClass) private var verticalSizeClass
```

Use for broad compact/regular experience decisions. Do not infer pose from size class.

## 2. Adaptive list/detail

```swift
struct RootView: View {
    @State private var selection: Item.ID?

    var body: some View {
        NavigationSplitView {
            ItemList(selection: $selection)
        } detail: {
            if let selection {
                ItemDetail(id: selection)
            } else {
                ContentUnavailableView("Select an item", systemImage: "list.bullet")
            }
        }
    }
}
```

Keep selection above presentation changes.

## 3. Adaptive grid

```swift
let columns = [GridItem(.adaptive(minimum: 220), spacing: 16)]

LazyVGrid(columns: columns, spacing: 16) {
    ForEach(items) { item in
        Card(item: item)
    }
}
```

Prefer minimum usable card width over fixed “phone/tablet/Duo” counts.

## 4. Local fit-based rearrangement

```swift
ViewThatFits(in: .horizontal) {
    HStack(spacing: 16) {
        Preview()
        Controls()
    }

    VStack(spacing: 12) {
        Preview()
        Controls()
    }
}
```

## 5. Preserve child identity with `AnyLayout`

```swift
let layout: AnyLayout = horizontalSizeClass == .regular
    ? AnyLayout(HStackLayout(spacing: 16))
    : AnyLayout(VStackLayout(spacing: 12))

layout {
    Preview()
    Inspector()
}
```

Size class is acceptable here because it represents available-space semantics, not device identity.

## 6. Safe-area background split

```swift
ZStack {
    HeroBackground()
        .ignoresSafeArea()

    VStack {
        Header()
        Content()
    }
}
```

Never mirror one safe-area edge manually.

## 7. UIKit current screen

Avoid:

```swift
let scale = UIScreen.main.scale
```

For display-specific UIKit work, Apple recommends deriving screen context from the window scene when needed:

```swift
let screen = window?.windowScene?.screen
```

For traits such as display scale, prefer trait/environment values where suitable.

## 8. Sidebar-capable tabs

Apple demonstrates:

```swift
TabView {
    // tabs
}
.defaultTabBarPlacement(.sidebar)
```

Use when persistent sidebar navigation materially improves the regular-width experience. Verify API availability and whether a more adaptive policy is appropriate for the app.

## 9. System toolbar

```swift
NavigationStack {
    ContentView()
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Close", systemImage: "xmark") { dismiss() }
            }

            ToolbarItem {
                Button("Share", systemImage: "square.and.arrow.up") {
                    share()
                }
            }
        }
}
```

Prefer this over a hand-built horizontal bar.

## 10. Pin/promote an important action

Apple's Duo bar Tech Talk shows a placement named:

```swift
ToolbarItem(placement: .topBarPinnedTrailing) {
    Button("Done") { save() }
}
```

Verify availability before use.

## 11. Toolbar axis behavior

```swift
ToolbarItem {
    ProfileControl()
}
.axisBehavior(.verticalPreferred)
```

or:

```swift
ToolbarItem {
    ModeControl()
}
.axisBehavior(.horizontalOnly)
```

Use only for the toolbar item's own representation.

## 12. Read vertical bar edge

Apple documents an environment value conceptually as:

```swift
@Environment(\.toolbarVerticalEdge) private var toolbarVerticalEdge
```

Use to adapt a custom toolbar item's internal layout. Do not use it as a global device detector.

## 13. Overflow menu

```swift
.toolbar {
    ToolbarOverflowMenu {
        Button("Scan") { scan() }
        Button("Connect") { connect() }
    }
}
```

Keep rare actions here instead of making a second custom menu.

## 14. Visibility priority

```swift
ToolbarItem {
    Button("Compose", systemImage: "square.and.pencil") { compose() }
}
.visibilityPriority(.high)
```

Prioritize the task, not visual order.

## 15. Disable vertical bar exceptionally

Apple demonstrates:

```swift
NavigationStack {
    ImmersiveSinglePageView()
        .toolbarVerticalBehavior(.disabled)
}
```

Opt out only when the vertical bar is genuinely harmful to the design.

## 16. Query fold division regions

```swift
GeometryReader { proxy in
    let regions = proxy.reservedRegions(kind: .division)
    FoldAwareContent(regions: regions)
}
```

Treat the returned frames as local geometry. Never hardcode the fold coordinate.

## 17. Include inactive division regions

```swift
let regions = proxy.reservedRegions(
    kind: .division,
    options: .includeInactive
)
```

Useful for high-level symmetry or preparation decisions. Do not use as `isDuo` detection.

## 18. Query occlusion regions

```swift
let regions = proxy.reservedRegions(kind: .occlusion)
```

Use for manually positioned content that must avoid camera/system occlusion.

## 19. Split arrangement

```swift
NavigationStack {
    ArrangementView {
        PrimaryView()
    } secondary: {
        SecondaryView()
    }
    .arrangementViewStyle(.split)
}
```

When semantics require horizontal splitting only:

```swift
.arrangementViewStyle(.split.axes(.horizontal))
```

## 20. Overlay arrangement

```swift
NavigationStack {
    ArrangementView {
        ForegroundView()
    } secondary: {
        BackgroundView()
    }
    .arrangementViewStyle(.overlay)
}
```

A child may inspect overlay placement:

```swift
@Environment(\.overlayArrangementZIndex) private var zIndex
```

Use this to change local density/minimization only.

## 21. Hinge interaction

```swift
.onHingeChange { _, context in
    if let hinge = context.hinge,
       hinge.status == .partiallyOpen {
        interactionAmount = transform(hinge.angle)
    } else {
        interactionAmount = 0
    }
}
```

Never use the angle to choose routine responsive layout.

## 22. Scene accessory

Apple's SwiftUI scene-accessory model resembles:

```swift
MainFeatureView(model: model)
    .sceneAccessory {
        CameraCaptureAccessory(isEnabled: $model.accessoryEnabled) {
            AccessoryContent(model: model)
        }
        .onAvailabilityChange { available in
            model.accessoryAvailable = available
        }
    }
```

Main functionality must survive when availability becomes false.

## 23. Camera direction coordinator

When explicit physical camera choice is necessary, Apple's example uses:

```swift
AVCaptureDeviceDirectionCoordinator(
    view: view,
    deviceTypes: [
        .builtInOuterUltraWideCamera,
        .builtInInnerUltraWideCamera,
        .builtInDualWideCamera,
    ],
    changeHandler: { map in
        // pass descriptor intent to camera session layer
    }
)
```

Create one coordinator per relevant displayed camera view.

## 24. Preview behavior

```swift
previewLayer.videoGravity = .resizeAspectFill
```

Choose aspect-fill/aspect-fit based on product intent and cropping tolerance. Keep overlay controls fold/safe-area aware.

## Transformation recipes

### Recipe A — `UIScreen.main` responsive layout

Before:

```swift
if UIScreen.main.bounds.width > 700 {
    HStack { list; detail }
} else {
    VStack { list; detail }
}
```

After, choose the semantic tool:

```text
list/detail navigation → NavigationSplitView
same two local views → ViewThatFits or AnyLayout
repeated cards → adaptive grid
true two-part fold-aware content → ArrangementView
```

### Recipe B — Custom bottom bar

Before:

```text
ZStack(alignment: .bottom) {
  content
  custom HStack of buttons
}
```

After:

```text
TabView for primary sections
system .toolbar for contextual actions
ToolbarOverflowMenu for secondary actions
axis/visibility priorities for Duo vertical presentation
```

### Recipe C — Folded root switch

Before:

```swift
if isFolded {
    CompactScreen(model: model)
} else {
    WideScreen(model: model)
}
```

After:

```text
one semantic screen
+ adaptive navigation/layout
+ local fold displacement only where needed
+ shared state above presentation
```

### Recipe D — Hinge-driven columns

Before:

```swift
let columns = hinge.angle.degrees > 150 ? 3 : 1
```

After:

```swift
GridItem(.adaptive(minimum: 220))
```

Use hinge angle only if the physical folding motion directly controls an effect.

### Recipe E — Critical center button

Before:

```text
full-width canvas
button fixed at geometric center
```

After:

```text
query active division regions
if intersection occurs, displace button to nearest semantically suitable region
keep canvas/background spanning continuously when safe
```

## API uncertainty policy

If code completion suggests an API that isn't present in the active SDK:

1. search local SDK documentation/symbols;
2. check Apple's current documentation;
3. do not invent a similarly named API;
4. isolate planned Duo functionality behind a small boundary;
5. mark the implementation SDK-blocked in the handoff.
