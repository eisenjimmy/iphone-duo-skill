# 07 — API cookbook

**Load when:** you need a call site, or you are transforming an anti-pattern into a fix.
**Source:** Apple Tech Talks 111461–111465. Samples marked ⓐ are reproduced **verbatim**
from Apple's own code listings; the talk and timestamp are cited.

This is the **code index**. References 01–05 carry short illustrative snippets inline, but
every full call site lives here — when you need something you can paste, come to this file.

## Availability convention

A symbol tagged `(27.1)` requires the iOS 27.1 SDK. Every symbol below appears in
`data/api-manifest.json`, which records whether Apple's documentation page resolves
(`verified`) or the name comes only from a talk (`apple-sourced`). If a symbol is absent
from the manifest, it does not exist as far as this skill is concerned — report
`SDK-blocked` rather than improvising a spelling.

---

## Tier 1 — universal adaptive

### 1. Size classes ⓐ *(111461, 2:59)*

```swift
// SwiftUI
@Environment(\.horizontalSizeClass) private var horizontalSizeClass
@Environment(\.verticalSizeClass) private var verticalSizeClass

// UIKit
traitCollection.horizontalSizeClass
traitCollection.verticalSizeClass
```

The outer display is **compact width**. The inner display is **regular in both
dimensions**, and it **does not honor supported interface orientations** — so orientation
is never a substitute for a size class here.

### 2. Never reach for the main screen ⓐ *(111461, 4:16 and 9:25)*

```swift
// Avoid referencing the main screen on a two-display device.
// Access the screen dynamically from the window scene instead.
let screen = window?.windowScene?.screen

func updateThumbnail(from image: UIImage) {
    let screenScale = traitCollection.displayScale   // was UIScreen.main.scale
}
```

`UIScreen.main` is ambiguous on a two-display device and Apple states it **will be
deprecated**.

### 3. Handle asymmetric safe areas ⓐ *(111461, 7:07 and 7:30)*

```swift
// Avoid assuming insets on opposite sides are equal
let width = view.bounds.width - view.safeAreaInsets.left * 2

// Handle each side independently
let width = view.bounds.inset(by: view.safeAreaInsets).width

// Foreground aligns to the safe area; background may extend past it
foreground.frame = view.bounds.inset(by: view.safeAreaInsets)
backgroundView.frame = view.bounds        // SwiftUI: .ignoresSafeArea()
```

### 4. Match the screen corners ⓐ *(111461, 4:30)*

```swift
// SwiftUI
ConcentricRectangle()
    .fill(Color.green)
    .padding(8.0)
    .ignoresSafeArea()

// UIKit: UICornerConfiguration
```

### 5. Adaptive grid — prefer an even column count

```swift
LazyVGrid(columns: [GridItem(.adaptive(minimum: 220), spacing: 16)], spacing: 16) {
    ForEach(items) { ItemCell(item: $0) }
}
```

Size the minimum so the natural count stays **even** at Duo widths: an even grid divides
cleanly across the folding region. Never `GridItem(.fixed)` or a hardcoded count.

### 6. Local fit-based rearrangement

```swift
ViewThatFits(in: .horizontal) {
    HStack(spacing: 24) { Summary(); Detail() }   // preferred
    VStack(spacing: 16) { Summary(); Detail() }   // fallback
}
```

`ViewThatFits` measures the *offered* space, so it needs no threshold at all. Reach for
it before reaching for a number.

### 7. Preserve identity while changing axis

```swift
let layout = isWide ? AnyLayout(HStackLayout(spacing: 24))
                    : AnyLayout(VStackLayout(spacing: 16))
layout {
    Summary().id("summary")
    Detail().id("detail")
}
```

`AnyLayout` keeps child identity across the change, so scroll position, focus, and
animation state survive. Swapping between two different container views does not.

### 8. Sidebar-capable tabs ⓐ *(111461, 5:44)*

```swift
// SwiftUI
TabView { … }
    .defaultTabBarPlacement(.sidebar)

// UIKit
tabBarController.sidebar.preferredPlacement = .sidebar
```

---

## Tier 2 — bars

### 9. Use a container-provided toolbar ⓐ *(111462, 2:24 and 2:39)*

```swift
// SwiftUI
NavigationStack {
    ContentView()
        .toolbar { ToolbarItem(placement: .bottomBar) { … } }
}

// UIKit — content from a custom UIToolbar won't be considered.
// Prefer UINavigationController and UITabBarController, which manage their own bars.
```

Only container-provided bars participate in the vertical bar region. This is the single
highest-leverage bar change in the skill.

### 10. Back / close, and pinned prominent actions ⓐ *(111462, 5:00 and 5:24)*

```swift
// SwiftUI
.toolbar {
    ToolbarItem(placement: .cancellationAction) { … }
    ToolbarItem(placement: .topBarPinnedTrailing) { … }
}

// UIKit
navigationItem.leftItemsSupplementBackButton = false
navigationItem.leadingItemGroups = [UIBarButtonItemGroup(...)]
navigationItem.pinnedTrailingGroup = UIBarButtonItemGroup(...)
```

Reserve the top of the vertical axis for navigation, then prominent actions.

### 11. Axis behavior for custom views `(27.1)` ⓐ *(111462, 8:08–8:52)*

```swift
// SwiftUI
.toolbar { ToolbarItem { ProfileView() } .axisBehavior(.verticalPreferred) }
.toolbar { ToolbarItem { SelectOrDoneButton() } .axisBehavior(.horizontalOnly) }

// UIKit
item.axisBehavior = .verticalPreferred
item.axisBehavior = .horizontalOnly
```

Choose mechanically: **`.horizontalOnly`** if the view renders text that must be read as
a run — a balance, a timestamp, a mode name. **`.verticalPreferred`** if it is a symbol,
avatar, or badge that fits a 44pt square. Otherwise omit the modifier and let the system
decide.

### 12. Badge instead of inline text ⓐ *(111462, 9:27)*

```swift
// SwiftUI
ToolbarItem(...) { InboxButton().badge(7) }

// UIKit
item.badge = .count(7)
```

A badge converts a text-plus-symbol item into a symbol-only one, which suits the fixed
width of a vertical bar.

### 13. Read the vertical bar edge `(27.1)` ⓐ *(111462, 10:36)*

```swift
// SwiftUI
@Environment(\.toolbarVerticalEdge) var edge

// UIKit
switch traitCollection.verticalBarEdge { … }
```

Only needed for custom views that must know which side they are on. Note: vertical bars
have **no scroll edge effect** by default, and **flexible spacers are zero-size
vertically** — group items instead of spacing them.

### 14. Compression behavior `(27.1)` ⓐ *(111462, 12:23)*

```swift
// SwiftUI
.toolbarVerticalCompressionBehavior(.prefersToolbarItems)

// UIKit
navigationItem.verticalBarCompressionBehavior = .prefersBarItems
```

Toolbars compress **first** by default, preserving the tab bar — right for
navigation-focused apps. Invert it for task-focused apps where the toolbar *is* the task.

### 15. Overflow and visibility priority ⓐ *(111462, 12:43 and 13:21)*

```swift
// SwiftUI
.toolbar {
    ToolbarOverflowMenu {
        Button("Scan") { … }
        Button("Connect") { … }
    }
    ToolbarItem { Button(...) { … } }.visibilityPriority(.high)
}

// UIKit
navigationItem.additionalOverflowItems = UIDeferredMenuElement({ provider in
    provider(self.persistentOverflowItems())
})
item.visibilityPriority = .high
```

Items overflow **bottom to top** by default. Raise priority for frequently used actions
(Compose, New Note) and for anything carrying status, like a badge. Move your own
overflow menu into the system one and leave the ellipsis to the system.

### 16. Opt out of vertical bars `(27.1)` ⓐ *(111462, 14:47)*

```swift
// SwiftUI
NavigationStack { ContentView().toolbarVerticalBehavior(.disabled) }

// UIKit
override var preferredVerticalBarBehavior: UIVerticalBarBehavior { .disabled }
```

Rare and deliberate: a Calculator-style single-page app, or a sheet whose only control is
Close. Side placement is a core Duo pattern — do not opt out to preserve a habit.

---

## Tier 2 — reserved regions and arrangements

### 17. Query reserved regions `(27.1)` ⓐ *(111463, 6:46–8:07)*

```swift
// SwiftUI
GeometryReader { proxy in
  let divisions = proxy.reservedRegions(kind: .division)
  let occlusions = proxy.reservedRegions(kind: .occlusion)
  let all = proxy.reservedRegions(kind: .division, options: .includeInactive)
  let frames = all.map(\.frame)
}

// UIKit
let regions = view.reservedRegions(kind: .division)
let frames = regions.map(\.frame)
```

Only **active** regions return by default. `.includeInactive` matters because the fold's
division region has **zero width when flat** — yet knowing it exists is exactly why you
choose an even column count.

### 18. Split arrangement `(27.1)` ⓐ *(111463, 11:23–13:07)*

```swift
// SwiftUI
NavigationStack {                      // navigation stays OUTSIDE
  ArrangementView {
    PlayerView()
  } secondary: {
    UpNextView()
  }
  .arrangementViewStyle(.split.axes(.horizontal))
}

// UIKit
let arrangementVC = UIArrangementViewController()
let navController = UINavigationController(rootViewController: arrangementVC)
arrangementVC.setViewController(PlayerViewController(), for: .primary)
arrangementVC.setViewController(UpNextViewController(), for: .secondary)
arrangementVC.updateArrangement(.split.axes(.horizontal))
```

Split divides the bounds: horizontally when wider than tall, vertically when taller.
Restrict with `.axes(…)`. When it cannot split along its permitted axis it shows a single
view.

### 19. Overlay arrangement and z-index `(27.1)` ⓐ *(111463, 13:26–14:21)*

```swift
// SwiftUI
ArrangementView {
  UpNextView()
} secondary: {
  PlayerView()
}
.arrangementViewStyle(.overlay)

enum UpNextMinimization { case collapsed; case expanded }

struct UpNextView: View {
    @Environment(\.overlayArrangementZIndex) private var zIndex: Int
    var minimization: UpNextMinimization { zIndex > 0 ? .collapsed : .expanded }
    var body: some View { UpNextList(minimization: minimization) }
}

// UIKit
let primaryState = arrangementVC.state(for: .primary)
myModel.minimization = (primaryState?.zIndex ?? 0) > 0 ? .collapsed : .expanded
```

Overlay stacks the views, moving them side by side when partially open. Read the z-index
to switch between a collapsed and expanded representation.

**Map from what you already have:** `HStack`/`VStack` → split. `ZStack` → overlay.

---

## Tier 3 — hardware capability

### 20. Hinge as interaction input `(27.1)` ⓐ *(111464, 1:33–2:17)*

```swift
struct InstrumentView: View {
    /// Normalized bend, 0 is no bend, 1 is deepest bend
    @State private var pitchBend: Double = 0

    var body: some View {
        GuitarView(pitchBend: pitchBend)
            .onHingeChange { _, context in
                // A null hinge means the device doesn't have one
                if let hinge = context.hinge, hinge.status == .partiallyOpen {
                    pitchBend = calculatePitchBend(angle: hinge.angle)
                } else {
                    pitchBend = 0          // reset transient state when the pose ends
                }
            }
    }

    private func calculatePitchBend(angle: Angle) -> Double { … }
}
```

UIKit counterpart: `UIHingeInteraction`. Status is `.closed` / `.partiallyOpen` /
`.fullyOpen`, plus a continuous angle. **Always unwrap** — and note the `else` branch
resetting `pitchBend`: leaving transient state behind when the pose ends is the classic
hinge bug. This is an *effect*, not a layout switch.

### 21. Scene accessory with availability `(27.1)` ⓐ *(111464, 5:43–6:25)*

```swift
struct CameraRootView: View {
    @State private var model = TeleprompterModel()

    var body: some View {
        CameraView(model: model)
            .sceneAccessory {
                CameraCaptureAccessory(isEnabled: $model.isEnabled) {
                    TeleprompterView(model: model)
                }
                .onAvailabilityChange { newValue in
                    model.isAvailable = newValue
                }
            }
            .toolbar {
                TeleprompterToggle(isEnabled: $model.isEnabled)
                    .disabled(!model.isAvailable)
            }
    }
}
```

Availability is **system-controlled and dynamic**. `CameraCaptureAccessory` is available
only while the app is full screen on the inner display with an active camera session, and
puts supplementary UI on the **outer** display. Register it on the same view as the camera
UI. The main workflow must never depend on it.

### 22. Camera direction coordination `(27.1)` ⓐ *(111465, 4:06)*

```swift
directionCoordinator = AVCaptureDeviceDirectionCoordinator(
    view: view,
    deviceTypes: [
        .builtInOuterUltraWideCamera,
        .builtInInnerUltraWideCamera,
        .builtInDualWideCamera,
    ],
    changeHandler: { [weak self] map in
        self?.updateCameraSession(map)   // main actor — hand off, don't touch AVFoundation here
    }
)
```

Lives in **AVKit**, not AVFoundation. Positions are reported **relative to that view**, so
one coordinator per view — two if you drive both displays. Because it is view-tied it is
main-actor isolated: it vends a `AVCaptureDeviceDescriptor` (Sendable, main-actor-safe)
to pass to your camera actor. Both front cameras report `.front`, so `.front` alone can no
longer tell you a camera faces the user.

### 23. Preview and rotation ⓐ *(111465, 7:30–8:34)*

```swift
var videoGravity: AVLayerVideoGravity { get set }              // AVCaptureVideoPreviewLayer
var dynamicAspectRatio: AVCaptureDevice.AspectRatio? { get }   // pick a landscape ratio
var isCameraSensorOrientationCompensationEnabled: Bool { get set }
```

Adopt `AVCaptureDevice.RotationCoordinator` — it updates as the app moves between
displays. **After adopting it, disable sensor orientation compensation** (on by default
for all iPhone Duo front cameras) for better performance. Mirror the preview when a rear
camera is forward-facing, so a selfie looks natural.

---

## Anti-pattern → replacement

| Anti-pattern | Replace with | Tier | Why |
|---|---|---|---|
| `if isDuo { A() } else { B() }` | One view; `ViewThatFits` or size classes | 1 | Two trees diverge and drift |
| `if isFolded { Compact() } else { Expanded() }` | One view + one state owner | 1 | Folding must not reset state |
| `UIScreen.main.bounds.width` | `GeometryReader` / scene bounds | 1 | Ambiguous on two displays; being deprecated |
| `UIScreen.main.scale` | `traitCollection.displayScale` | 1 | Same |
| `orientation == .landscape` | `horizontalSizeClass` | 1 | Inner display ignores orientation |
| `.frame(width: 428)` | Container-relative sizing | 1 | Apple publishes no Duo point sizes |
| `GridItem(.fixed)` × N | `GridItem(.adaptive(minimum:))`, even count | 2 | Even columns divide across the fold |
| Custom `UIToolbar` | `UINavigationController` + toolbar items | 2 | Custom bar content isn't considered |
| `flexibleSpace` in a bar | `ToolbarItemGroup` / `UIBarButtonItemGroup` | 2 | Flexible spacers are zero-size vertically |
| Own overflow menu | `ToolbarOverflowMenu` / `additionalOverflowItems` | 2 | One place to find everything |
| Centered button over the fold | Displace the button only | 2 | Interruption breaks interaction |
| `if hinge.angle > X { columns = 3 }` | `reservedRegions` / `ArrangementView` | 3 | Hinge is not layout input |
| `NavigationSplitView` inside `ArrangementView` | Navigation wraps the arrangement | 2 | Arrangements carry no navigation |
| `compactViewModel` + `expandedViewModel` | One model, adaptive presentation | 1 | Two sources of truth lose state |

### Worked transformation

```swift
// Before — device identity, global geometry, fixed columns, duplicated state
struct Dashboard: View {
    @StateObject private var compactVM = CompactDashboardViewModel()
    @StateObject private var wideVM = WideDashboardViewModel()
    var body: some View {
        if isDuo && !isFolded {
            LazyVGrid(columns: Array(repeating: GridItem(.fixed(200)), count: 3)) { … }
                .environmentObject(wideVM)
        } else {
            List { … }.environmentObject(compactVM)
                .frame(width: UIScreen.main.bounds.width)
        }
    }
}

// After — one model, one tree, space-driven, even columns
struct Dashboard: View {
    @State private var model = DashboardModel()
    var body: some View {
        NavigationSplitView {
            SidebarList(model: model)
        } detail: {
            // 220 = the card's minimum readable width. Verify the resulting column
            // count is even at your target widths — Apple publishes no Duo point sizes.
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 220), spacing: 16)], spacing: 16) {
                ForEach(model.items) { ItemCell(item: $0) }
            }
        }
    }
}
```

The rewrite uses no Duo API at all. That is the point: most Duo readiness is Tier 1.
