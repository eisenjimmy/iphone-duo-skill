# 04 — Split-view multitasking, scenes, and multiple displays

Use this reference when the app can run beside another app, supports multiple windows/scenes, or wants supplementary content on another display.

## Multitasking is part of the baseline

On iPhone Duo, applications participate in side-by-side multitasking. Therefore, “inner display” does not imply that the application receives the entire inner display width.

Design and test along a continuum:

```text
very narrow
→ compact
→ intermediate
→ regular
→ expansive/full inner display
```

The app should respond to size classes and scene/container geometry just as it would in other resizable environments.

Do not write:

```swift
if isInnerDisplay {
    ExpansiveRoot()
}
```

because an app on the inner display may still occupy a constrained region.

## Multiple scenes

Apple describes iPhone Duo as the first iPhone capable of presenting multiple instances of an app's UI. Applications that already support multiple scenes/windows on iPad are well positioned.

Important Duo constraint from Apple's launch guidance:

- requesting a new app window/scene is associated with the inner display experience;
- the outer display may not allow creation of a new window;
- scene creation can therefore fail or be unavailable depending on the current context.

Agents must treat scene creation as a capability, not an entitlement.

### Scene request policy

When adding a “New Window” or scene-creation action:

1. use Apple's system scene activation/request mechanism;
2. allow system-provided actions to hide or disable themselves when unavailable where supported;
3. handle request errors rather than assuming success;
4. keep the current scene fully functional if a second scene can't be created;
5. keep scene-specific state separate from global shared data.

Do not create an outer-display-specific workaround that bypasses system restrictions.

## State architecture for multiple scenes

Separate:

```text
shared domain state
    documents / records / account data / media library

scene-local state
    selected item
    navigation path
    inspector visibility
    window-specific draft context
    scroll/focus state
```

If every scene binds to one global navigation model, opening another scene may unexpectedly move or reset the first scene. Conversely, duplicating shared domain state creates consistency problems.

The correct boundary depends on the product, but the agent must explicitly evaluate it.

## Scene transitions and resizing

When the device opens/closes or a scene changes available space:

- don't recreate expensive models solely because the layout changed;
- preserve user task continuity;
- allow sheets/popovers to adapt to the new region;
- avoid storing “folded/unfolded” as durable navigation state;
- handle focus and keyboard transitions gracefully.

## Scene accessories

Scene accessories are the system mechanism for presenting **supplementary app content** when an associated system capability/display becomes available.

SwiftUI's model is declarative: the application provides accessory content, and the system determines when and where that content can appear.

Core rule:

**The main application workflow must not depend on accessory availability.**

Good accessory use cases:

```text
camera subject preview
teleprompter
countdown / timer
presenter notes/status
game companion information
recording indicator / supplementary controls
nonessential external-display preview
```

Bad accessory use cases:

```text
the only Save button
the only navigation UI
required form fields
a primary workflow that disappears when the accessory is unavailable
manual mirroring of the entire app root
```

## Availability is dynamic

The system can change whether an accessory is available. Code must observe and respond to availability rather than caching an assumption.

A good UI pattern:

```text
accessory becomes available
→ enable its optional toggle/action

accessory becomes unavailable
→ disable optional action
→ preserve the main workflow
→ clear or pause accessory-only state if appropriate
```

For camera capture accessories, Apple demonstrates `onAvailabilityChange` to synchronize the enabling state of a related control.

## Do not manually manage physical displays

Avoid application architecture that treats:

```text
innerDisplay
outerDisplay
```

as two permanently addressable custom rendering surfaces.

Instead:

- keep the primary experience in the current main scene;
- use the scene/window model for independent UI instances;
- use scene accessories for intentionally supplementary cross-display content;
- let the system control placement and availability.

This prevents brittle assumptions about which display is active, folded, hidden, or available.

## Accessory ownership

Attach accessory declarations near the feature that owns them. For example, a camera accessory should be associated with the camera UI rather than a global application root if it should only exist while that feature is active.

Benefits:

- lifecycle matches feature visibility;
- state ownership is clearer;
- unavailable contexts degrade naturally;
- unrelated screens don't keep accessory models alive unnecessarily.

## Multiple displays and camera features

Camera applications may legitimately use both displays at once. In that case, each displayed camera UI can have its own view-relative camera direction context. See `05-camera.md`.

Do not reuse a camera direction coordinator created for one view/display as if its interpretation necessarily applies to another view on the other display.

## Product-design questions

Before adding a second-display feature, answer:

1. What new value appears because someone else can see the other display?
2. Is the content truly supplementary?
3. What happens when the accessory disappears mid-task?
4. Which state is shared with the main scene?
5. Which controls belong only to the accessory?
6. Does the accessory expose private/sensitive information unexpectedly to someone facing the other side?
7. Does the app remain complete when running on a non-Duo device?

The privacy question is particularly important for outer-display content: supplementary information may be visible to another person by design.

## Multitasking audit

For each major screen, test conceptually and in simulator where possible:

- very narrow side-by-side width;
- intermediate width;
- full inner width;
- keyboard open;
- sheet presented;
- another app beside it;
- scene created/closed;
- main scene resized while secondary scene exists.

Check for:

- clipped fixed-width content;
- invisible actions;
- duplicate or shared navigation mistakes;
- state reset;
- excessive recomputation;
- assumptions that regular size class means full physical display.

## Acceptance criteria

Scene/multidisplay work passes when:

- split-view multitasking behaves like a first-class layout;
- scene creation is capability/error-aware;
- scene-local and shared state are deliberately separated;
- second-display content is implemented as supplementary system-managed content;
- accessory availability can change without breaking the task;
- no code manually targets physical displays merely to create responsive layout.
