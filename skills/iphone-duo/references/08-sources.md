# 08 — Sources and provenance

Research snapshot: **2026-09-10**.

This skill is a synthesis, not a mirror of Apple's documentation. Keep source material authoritative and re-check it when Xcode/iOS 27.1 changes.

## Apple — iPhone Duo landing page

**Get ready for iPhone Duo**  
https://developer.apple.com/iphone-duo/

Use this as the launch index for current Duo resources, workshops, tools, Xcode availability, and documentation links.

At the research snapshot, Apple's landing page listed Xcode 27.1 beta as upcoming later in September 2026. Because documentation and Tech Talks can precede local SDK availability, this skill requires agents to verify symbols against the installed SDK.

## Apple Human Interface Guidelines

**Designing for iPhone Duo**  
https://developer.apple.com/design/human-interface-guidelines/designing-for-iphone-duo

Primary design authority for:

- outer and inner display behavior;
- side-positioned bars;
- dynamic layouts and safe areas;
- reserved regions;
- fold avoidance;
- split views;
- arrangement views;
- limiting large layout changes while folding;
- making use of expansive inner-display space.

## Apple Tech Talk 111466

**Design for iPhone Duo**  
https://developer.apple.com/videos/play/tech-talks/111466/

Key topics:

- overall design principles;
- compact versus regular experience;
- controls placed along the side;
- outer-display composition;
- inner-display hierarchy and two-column opportunities;
- sheet behavior;
- fold avoidance.

## Apple Tech Talk 111461

**Prepare your app for iPhone Duo**  
https://developer.apple.com/videos/play/tech-talks/111461/

Key topics:

- rebuilding with iOS 27 / 27.1 SDKs;
- Xcode/Device Hub simulation;
- resizable layouts;
- size classes instead of orientation;
- avoiding `UIScreen.main` and display assumptions;
- `ConcentricRectangle` / concentric screen treatment;
- standard adaptive navigation;
- sidebar tab placement;
- asymmetric safe areas;
- reserved regions.

## Apple Tech Talk 111462

**Raise the bar with iPhone Duo**  
https://developer.apple.com/videos/play/tech-talks/111462/

Key topics and APIs:

- system navigation/toolbars for vertical bar participation;
- shared vertical bar region;
- semantic item ordering;
- `.topBarPinnedTrailing`;
- toolbar item `axisBehavior`;
- symbol-first vertical representations;
- badges;
- `toolbarVerticalEdge` environment context;
- toolbar compression behavior;
- `ToolbarOverflowMenu`;
- visibility priority;
- `.toolbarVerticalBehavior(.disabled)` for exceptional opt-out cases.

## Apple Tech Talk 111463

**Strike a pose with adaptive layouts on iPhone Duo**  
https://developer.apple.com/videos/play/tech-talks/111463/

Primary implementation source for:

- reserved regions;
- division versus occlusion regions;
- active/inactive reserved regions;
- displacement patterns;
- system containers adapting automatically;
- `ArrangementView`;
- split arrangement;
- axis restriction;
- overlay arrangement;
- `overlayArrangementZIndex`;
- when not to use arrangements;
- keeping navigation outside arrangements;
- avoiding arrangements inside scroll containers.

## Apple Tech Talk 111464

**Leverage multiple displays and scenes on iPhone Duo**  
https://developer.apple.com/videos/play/tech-talks/111464/

Primary source for:

- `onHingeChange`;
- closed / partially open / fully open hinge status;
- continuous hinge angle;
- hinge data for interaction rather than layout;
- split-view multitasking;
- multiple scenes on iPhone Duo;
- scene-creation availability constraints;
- scene accessories;
- `CameraCaptureAccessory`;
- `onAvailabilityChange`.

## Apple Tech Talk 111465

**Build a great camera experience for iPhone Duo**  
https://developer.apple.com/videos/play/tech-talks/111465/

Primary camera source for:

- outer and inner front cameras;
- virtual front camera;
- explicit physical front-camera capability differences;
- `AVCaptureDeviceDirectionCoordinator`;
- device descriptors and actor boundaries;
- direction-aware switching;
- mirroring;
- `AVCaptureVideoPreviewLayer.videoGravity`;
- dynamic aspect ratio;
- `AVCaptureDeviceRotationCoordinator`;
- camera sensor orientation compensation guidance;
- using both displays with scene accessories.

## Apple SwiftUI scene accessory documentation

**sceneAccessory(content:)**  
https://developer.apple.com/documentation/swiftui/view/sceneaccessory(content:)

Important semantic rule: accessory content is supplementary. The system determines when and where it becomes available, and the main app experience must remain functional without it.

## Agent Skills specification

**Agent Skills Specification**  
https://agentskills.io/specification

Repository structure follows the standard:

```text
skill-name/
├── SKILL.md
├── scripts/
├── references/
└── assets/
```

Important format constraints used here:

- `SKILL.md` YAML frontmatter contains `name` and `description`;
- directory name matches the `name` field;
- detailed content is split into references for progressive disclosure;
- the core skill stays substantially smaller than the full reference corpus.

## Comparative reference — FloWritesCode

**FWC SwiftUI Skills**  
https://github.com/FloWritesCode/fwc-swiftui-skills

Relevant skill:

https://github.com/FloWritesCode/fwc-swiftui-skills/tree/main/skills/swiftui-iphone-duo

Strengths carried forward conceptually:

- adaptive layout before Duo-specific behavior;
- semantic containers over device checks;
- `NavigationSplitView`, adaptive grids, `ViewThatFits`, and `AnyLayout`;
- state continuity;
- fold-safe content;
- progressive Tier 1 / Tier 2 / Tier 3 thinking.

This repository expands that model with a broader Apple-source index and deeper execution rules for vertical bars, overflow, scenes, scene accessories, camera behavior, audit automation, severity grading, and simulator acceptance criteria.

## Source precedence

When sources appear to disagree, agents should use this order:

1. current installed SDK/compiler reality;
2. current Apple API documentation;
3. current Apple HIG;
4. current Apple Tech Talks/sample code;
5. this skill's synthesized guidance;
6. third-party repositories or examples.

Do not force code from this skill when Apple's current documentation has changed.

## Maintenance protocol

When Apple publishes an updated iPhone Duo HIG, Xcode release, API rename, or replacement Tech Talk:

1. update this source index date;
2. update only the affected focused reference file;
3. keep `SKILL.md` stable unless the core workflow changes;
4. remove obsolete beta caveats after verifying the released SDK;
5. never retain an old API merely for consistency with this document.
