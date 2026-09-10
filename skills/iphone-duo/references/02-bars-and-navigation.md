# 02 — Bars and navigation

Use this reference when a screen has navigation stacks/split views, tab bars, toolbars, custom bars, overflow behavior, or actions that must adapt between horizontal and vertical presentation.

## Why Duo bars matter

On iPhone Duo, system navigation, toolbar, and tab controls can share a **vertical bar region** along the side of the display. This preserves vertical content space and improves reachability on the wider form factor. When the device opens in landscape, the side placement can remain stable so controls don't jump unnecessarily during display transitions.

This behavior is a strong reason to prefer system containers over custom bars.

## System containers first

SwiftUI preference:

```text
NavigationStack
NavigationSplitView
TabView
.toolbar { ... }
ToolbarItem
ToolbarItemGroup
ToolbarOverflowMenu
```

UIKit preference:

```text
UINavigationController
UISplitViewController
UITabBarController
navigationItem
UIBarButtonItemGroup
```

A custom `UIToolbar`, custom SwiftUI `HStack` pretending to be a toolbar, or bespoke bottom tab implementation won't automatically participate in the system's vertical bar behavior.

## Navigation hierarchy

If the app has a collection → selection → detail structure, prefer `NavigationSplitView`.

Expected behavior:

```text
compact:     list → detail
expansive:   list | detail
```

Keep the selection source of truth stable so moving between compact and regular presentation doesn't reset the selected item.

For tab-driven products, evaluate sidebar presentation at expansive sizes. Apple documents `defaultTabBarPlacement(.sidebar)` for using a sidebar presentation where appropriate.

Do not manually invent a sidebar solely because a device is open.

## Shared vertical bar mental model

Navigation, toolbar, and tab content compete for one constrained vertical region. Design as if horizontal bar content has been reorganized into a vertical stack with limited space.

Important consequences:

- navigation and prominent actions should remain easy to find;
- text-heavy items consume scarce bar space;
- keyboard or other transient UI may force additional compression;
- overflow prioritization becomes part of functional design, not polish;
- the detail column in a split view is generally the participant in the shared bar region;
- inspectors don't need their own independent bar architecture.

## Action ordering

Use semantic placements instead of fixed visual ordering.

Back/close/cancel actions should use system semantics such as:

```swift
ToolbarItem(placement: .cancellationAction) {
    Button("Close") { dismiss() }
}
```

Prominent trailing actions can use the current SDK's dedicated placement when available, including Apple's documented `.topBarPinnedTrailing` behavior.

Do not hardcode a `VStack` to mimic Apple's bar item order.

## Titles and symbols

Vertical bars favor symbols because width is constrained while height is flexible.

Guidelines:

- provide a clear symbol when one exists;
- still provide a meaningful title because the system can use it in overflow/expanded representations;
- avoid long title-only toolbar actions when a conventional symbol works;
- use badges for count/status where appropriate instead of embedding verbose inline text;
- keep standalone information as text if converting it to a symbol would destroy meaning.

A dollar amount, account balance, selected mode name, or other meaningful textual status may legitimately remain horizontal.

## Axis behavior

When a custom toolbar item can adapt to a side bar, use the SDK's axis behavior APIs rather than maintaining a second toolbar implementation.

Apple examples include concepts such as:

```swift
ToolbarItem {
    ProfileView()
}
.axisBehavior(.verticalPreferred)
```

and:

```swift
ToolbarItem {
    SelectOrDoneButton()
}
.axisBehavior(.horizontalOnly)
```

Decision rule:

- `.verticalPreferred` when the custom view has a deliberate compact vertical representation;
- `.horizontalOnly` when rotating/reflowing the control would damage its meaning;
- default behavior when the system representation is already sufficient.

Verify exact API availability against the active SDK.

## Detecting vertical bar context

For custom views that genuinely need a different internal composition in a vertical bar, Apple documents the SwiftUI environment value conceptually as:

```swift
@Environment(\.toolbarVerticalEdge) private var toolbarVerticalEdge
```

Use it to tailor the custom view, not to rebuild the entire screen.

This is a local rendering concern.

## Grouping

Prefer `ToolbarItemGroup` and semantic groups. System groups provide adaptive spacing and remain coherent when the bar's axis changes.

Avoid:

```text
Spacer().frame(width: 12)
Spacer().frame(height: 8)
manual offsets to separate action clusters
```

inside system bar content unless there is a narrowly justified visual requirement.

## Overflow

Overflow is expected, especially on the outer display in landscape or when the keyboard reduces available vertical space.

Use the system overflow mechanism:

```swift
ToolbarOverflowMenu {
    Button("Scan") { ... }
    Button("Connect") { ... }
}
```

Do not create a parallel custom ellipsis menu when the system bar already manages overflow.

Reserve the ellipsis symbol for overflow semantics so users don't confuse unrelated commands with hidden toolbar actions.

## Visibility priority

Items can overflow from the lower end of the bar first, but importance should not be left to incidental ordering.

Prioritize:

1. navigation and destructive escape routes;
2. the primary action for the current screen;
3. frequent task actions;
4. status-bearing actions that need glanceability;
5. infrequent secondary commands.

Use current SDK visibility-priority APIs when available:

```swift
ToolbarItem {
    Button("Compose", systemImage: "square.and.pencil") { ... }
}
.visibilityPriority(.high)
```

Prefer assigning priority to semantic groups first, then individual items if necessary.

## Toolbar versus tab compression

When the shared bar gets crowded, decide which class of controls should remain visible longer.

Navigation-centric app:

```text
prefer tabs / primary navigation persistence
allow task toolbar items to overflow sooner
```

Task-centric app:

```text
preserve critical creation/editing controls
allow less critical navigation chrome to compress where system APIs permit
```

Apple documents `toolbarVerticalCompressionBehavior` for controlling this relationship. Verify exact enum cases in the active SDK before using them.

## When to opt out of vertical bars

Opt-out should be exceptional and product-driven.

Potential candidates:

- a single-page immersive interface where side chrome consumes meaningful space;
- a sheet whose only action is a close control and where the vertical bar worsens composition;
- a custom full-screen tool whose controls cannot meaningfully fit the vertical model.

SwiftUI documentation shown by Apple includes:

```swift
.toolbarVerticalBehavior(.disabled)
```

Do not disable vertical bars merely because the existing custom design was authored horizontally.

## RTL behavior

Do not assume the side bar mirrors like an arbitrary leading/trailing stack. Apple's system bar placement is tied to hardware and interaction behavior, so validate right-to-left localization rather than manually mirroring based on language.

## Sheets and presentations

System sheets, popovers, context menus, alerts, and action sheets gain Duo adaptation automatically. Prefer them over custom full-screen overlays.

Sheets can change control orientation and can move away from the fold depending on pose. Do not fight this behavior with hardcoded offsets.

## Audit checklist

For every bar-heavy screen:

- Is the bar system-provided?
- Are back/close/cancel actions semantic?
- Is the primary action marked/promoted appropriately?
- Does every icon-based action still have a title?
- Are custom views viable at side-bar width?
- Should any custom item be vertical-preferred or horizontal-only?
- Can secondary actions move into system overflow?
- Is the ellipsis reserved for overflow?
- Are high-value/status items prioritized?
- Does the UI remain usable with the keyboard visible?
- Does the UI remain usable in outer-display landscape?
- Does the navigation state survive compact/regular transitions?

## Acceptance criteria

A navigation/bar implementation passes when:

- system containers own ordinary navigation and bar placement;
- vertical presentation doesn't require a duplicate toolbar;
- primary actions remain discoverable;
- overflow is intentional and system-managed;
- custom toolbar views have a deliberate axis policy;
- tab/sidebar navigation adapts without state loss;
- sheets and system presentations aren't manually offset around predicted fold geometry.
