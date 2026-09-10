# 05 — Camera experiences on iPhone Duo

Use this reference when the app captures photos/video, presents a live camera preview, lets users choose a front camera, or shows camera-related content on both displays.

## Camera model

Apple's iPhone Duo launch guidance introduces two front-facing cameras:

- an outer ultrawide front camera;
- an inner ultrawide front camera.

For most camera apps, start with the **virtual front camera** rather than hardcoding a physical front-camera choice. The virtual front camera lets AVFoundation select the relevant front camera as the device opens and closes.

## Default recommendation: virtual front camera

If the product only needs “the front camera facing the user,” prefer discovery using ordinary front-camera semantics and allow the system's virtual front camera to manage the physical transition.

This produces simpler behavior and avoids unnecessary camera-session churn.

Use explicit physical camera selection only when the app needs features unavailable through the virtual camera or requires direct control over the inner/outer camera.

## Capability differences

Apple's launch Tech Talk states that the individual front cameras have different maximum capabilities, while the virtual camera exposes the feature set common to both.

Therefore, never assume that a mode configured on one physical camera remains valid after switching to another.

When manually selecting devices:

- query supported formats and frame rates;
- revalidate depth support;
- revalidate stabilization and other capture capabilities;
- choose a compatible fallback before switching the active input;
- never encode device-specific capability assumptions as constants.

## Direction is not equivalent to `.front`

On a folding device, the traditional `AVCaptureDevice.Position.front` label does not fully describe which way a camera is physically facing relative to the active UI.

When directly managing physical cameras, Apple provides `AVCaptureDeviceDirectionCoordinator` to determine camera direction relative to a particular view/display context.

Conceptual setup shown by Apple:

```swift
directionCoordinator = AVCaptureDeviceDirectionCoordinator(
    view: view,
    deviceTypes: [
        .builtInOuterUltraWideCamera,
        .builtInInnerUltraWideCamera,
        .builtInDualWideCamera,
    ],
    changeHandler: { [weak self] map in
        self?.handleDirectionChange(map)
    }
)
```

Verify exact types and initializer signatures against the active SDK.

## Coordinator ownership

A direction coordinator is tied to a view. Direction is interpreted relative to that view's display/context.

Therefore:

- one camera UI view → one appropriate coordinator;
- camera UI on two displays → separate coordinators for each displayed view;
- do not cache one coordinator globally and assume it describes every scene/display.

## Main-actor boundary

Apple's guidance notes that the direction coordinator is associated with UI/view context and therefore with main-actor work. Its change callback should not directly perform heavy AVFoundation session mutation if your capture pipeline runs on a dedicated actor/queue.

Use the provided/sendable device descriptor information to bridge from UI direction changes into the camera session layer.

Architecture:

```text
Main actor
  direction coordinator callback
  → convert/select descriptor intent

Camera actor / session queue
  → resolve AVCaptureDevice
  → reconfigure AVCaptureSession
  → publish resulting state
```

Avoid blocking the main actor while restarting capture.

## Direction-change handling

When device posture changes and a different camera should become forward-facing:

1. receive the direction update;
2. identify the desired device descriptor;
3. validate that the current capture mode exists on the new device;
4. begin capture-session configuration;
5. switch inputs atomically where possible;
6. update mirroring/orientation policy;
7. commit configuration;
8. update UI state after the session is valid;
9. recover gracefully if the preferred device cannot be opened.

Do not leave a black preview while waiting for an impossible mode.

## Mirroring

Do not decide preview mirroring solely from `.front`/`.back` labels. The physical camera that is forward-facing relative to the user can change as the device moves between displays.

Evaluate mirroring after direction changes so a selfie-oriented preview remains visually natural.

## Preview layout

Camera previews are strong candidates for edge-to-edge presentation, but controls still need safe-area and fold awareness.

Preferred structure:

```text
edge-to-edge preview/background
+ safe-area-aligned controls
+ reserved-region-aware focal UI
```

Use `AVCaptureVideoPreviewLayer.videoGravity` to decide how the preview fills its layer bounds.

Avoid hardcoded preview frames based on screen dimensions.

## Dynamic aspect ratio

Apple documents a dynamic aspect-ratio capability on relevant cameras. When available, use the camera's supported dynamic aspect ratio to choose a landscape-friendly preview/capture presentation rather than cropping from a guessed fixed ratio.

Always verify the current camera supports the requested behavior.

## Rotation

Adopt `AVCaptureDeviceRotationCoordinator` to keep the preview and captured media upright as the app moves between display contexts.

Apple's Duo camera guidance also advises disabling camera sensor orientation compensation after adopting the rotation coordinator where the relevant output/API supports doing so, for better performance.

Agents must verify exact property availability before applying this optimization.

## Both displays at once

A camera app may use a scene accessory to show supplementary content on the other display while the main camera UI remains active.

Examples:

```text
subject-facing preview
teleprompter
countdown
recording state
visual prompt for child/group photo
```

See `04-scenes-and-multidisplay.md` for scene-accessory rules.

## Camera capture accessory

Apple demonstrates a SwiftUI scene accessory pattern similar to:

```swift
CameraView(model: model)
    .sceneAccessory {
        CameraCaptureAccessory(isEnabled: $model.isEnabled) {
            TeleprompterView(model: model)
        }
        .onAvailabilityChange { available in
            model.isAvailable = available
        }
    }
```

The related main-screen toggle should be disabled when the accessory is unavailable.

Treat this API as optional enhancement. The capture workflow must remain usable without it.

## Privacy and disclosure

If content appears on the opposite display, assume another person may see it.

Do not expose by default:

- private messages;
- account information;
- hidden camera settings with sensitive metadata;
- location details;
- internal debugging overlays.

Accessory content should be intentionally designed for its audience.

## Camera audit checklist

- Is the virtual front camera sufficient?
- If using physical cameras, is direction coordinated relative to the correct view?
- Are capabilities revalidated on every camera switch?
- Is session mutation isolated from the UI actor/queue?
- Does preview mirroring update with direction?
- Does rotation remain correct across display transitions?
- Is preview sizing container-based rather than `UIScreen`-based?
- Are controls safe-area and fold aware?
- Does camera switching preserve capture state safely?
- Does a scene accessory remain optional and availability-aware?
- Is opposite-display content privacy-safe?

## Acceptance criteria

Camera support passes when ordinary front-camera use prefers system virtualization, explicit camera control uses direction coordination correctly, session state remains valid while posture changes, preview layout adapts without screen assumptions, and all second-display camera UI is supplementary and availability-aware.
