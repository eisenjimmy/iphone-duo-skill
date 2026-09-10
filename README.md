<div align="center">

<img src="assets/banner.svg" alt="iPhone Duo Agent Skill — design, audit, adapt" width="100%">

<br>

**A source-backed Agent Skill for designing one adaptive iPhone app that remains coherent across every iPhone Duo pose.**

<sub>English · [Español](docs/es/README.md) · [한국어](docs/ko/README.md)</sub>

<img src="assets/meta.svg" alt="MIT licensed · source-backed Apple API manifest · iOS 27.1 · Agent Skills format" width="100%">

</div>

<br>

<div align="center">
<img src="https://www.apple.com/newsroom/images/2026/09/apple-unveils-iphone-duo/tile/Apple-iPhone-Duo-opening-iPhone-Duo-260909-lp.jpg.landing-big_2x.jpg" alt="iPhone Duo being opened, revealing the 7.6-inch inner display" width="84%">
<br>
<sub>iPhone Duo · 7.6&Prime; inner display, 5.4&Prime; outer · images &copy; Apple Inc., served from apple.com &mdash; <a href="NOTICE.md">not redistributed here</a></sub>
</div>

<br>

## Why this exists

iPhone Duo introduces two displays, continuously changing window sizes, reserved regions,
vertical system bars, a hinge, multiple scenes, and camera behavior that ordinary fixed-screen
assumptions do not survive.

The wrong adaptation is a second app hidden behind a device check:

```swift
if isDuo {
    DuoDashboard()
} else {
    Dashboard()
}
```

This skill teaches the opposite model:

> **Layout reacts to available space. Physical interaction may react to the hinge.**

Build one adaptive hierarchy first. Add Duo-specific APIs only when a physical Duo capability
creates product value that ordinary adaptive layout cannot express.

<br>

<div align="center">
<img src="assets/poses.svg" alt="The five iPhone Duo poses and the layout pressures they create" width="100%">
</div>

<br>

<table>
<tr>
<td width="50%" valign="top" align="center">
<img src="https://www.apple.com/newsroom/images/2026/09/apple-unveils-iphone-duo/article/Apple-iPhone-Duo-display-sizes-260909_big.jpg.large_2x.jpg" alt="The inner and outer iPhone Duo displays side by side" width="100%">
<br><sub><b>Two displays, one app.</b> Compact width outside, regular width inside.<br>Your layout is the thing that has to travel between them.</sub>
</td>
<td width="50%" valign="top" align="center">
<img src="https://www.apple.com/newsroom/images/2026/09/apple-unveils-iphone-duo/article/Apple-iPhone-Duo-multitasking-Safari-and-Siri-app-260909_big.jpg.large_2x.jpg" alt="Two apps sharing the inner display in Split View" width="100%">
<br><sub><b>Split View on the inner display.</b> Each app puts its controls<br>on its <i>outer</i> edge &mdash; so "your" side is not always the left.</sub>
</td>
</tr>
</table>

<br>

## Quick start

```bash
git clone https://github.com/eisenjimmy/iphone-duo-skill.git

mkdir -p ~/.agents/skills
ln -sfn "$PWD/iphone-duo-skill/skills/iphone-duo" ~/.agents/skills/iphone-duo
```

Agent-specific locations:

| Harness | Path |
|---|---|
| Codex | `~/.codex/skills/iphone-duo` |
| Cursor / universal | `~/.agents/skills/iphone-duo` |

The skill itself is the directory `skills/iphone-duo/`. The canonical execution contract is
[`SKILL.md`](skills/iphone-duo/SKILL.md).

## Use it

```text
Use the iphone-duo skill to audit this repository. Do not change code yet.
Return file-level evidence, severity, tier, and the smallest coherent implementation plan.
```

```text
Use the iphone-duo skill to adapt this app for iPhone Duo.
Preserve navigation and view state during resizing. Complete Tier 1 before Duo-only APIs.
```

```text
Review this screen for partially-open iPhone Duo use.
Check fold interference, reachability, state continuity, and whether anything genuinely
needs hinge input rather than ordinary responsive layout.
```

<div align="center">
<table>
<tr>
<td width="25%" align="center"><img src="https://www.apple.com/newsroom/images/2026/09/apple-unveils-iphone-duo/article/Apple-iPhone-Duo-Slack-app-260909_big.jpg.large_2x.jpg" alt="Slack on iPhone Duo" width="100%"><br><sub>Slack</sub></td>
<td width="25%" align="center"><img src="https://www.apple.com/newsroom/images/2026/09/apple-unveils-iphone-duo/article/Apple-iPhone-Duo-Zoom-app-260909_big.jpg.large_2x.jpg" alt="Zoom on iPhone Duo" width="100%"><br><sub>Zoom</sub></td>
<td width="25%" align="center"><img src="https://www.apple.com/newsroom/images/2026/09/apple-unveils-iphone-duo/article/Apple-iPhone-Duo-Netflix-app-260909_big.jpg.large_2x.jpg" alt="Netflix on iPhone Duo" width="100%"><br><sub>Netflix</sub></td>
<td width="25%" align="center"><img src="https://www.apple.com/newsroom/images/2026/09/apple-unveils-iphone-duo/article/Apple-iPhone-Duo-Detail-app-260909_big.jpg.large_2x.jpg" alt="Detail on iPhone Duo" width="100%"><br><sub>Detail</sub></td>
</tr>
</table>
<sub>Shipping apps on the inner display. None of them is a separate &ldquo;Duo version.&rdquo;</sub>
</div>

<br>

## The execution model

Every change is classified before implementation:

| Tier | Purpose | Typical tools |
|---|---|---|
| **1 — universal adaptive** | Make the app correct at every available size | size classes, `NavigationSplitView`, adaptive grids, `ViewThatFits`, `AnyLayout`, safe areas, state continuity |
| **2 — Duo-aware presentation** | Handle Duo geometry and side controls | reserved regions, displacement, `ArrangementView`, vertical bar behavior, overflow priority |
| **3 — Duo-exclusive capability** | Use physical Duo hardware when it creates product value | hinge input, scene accessories, multiple scenes, camera direction coordination |

Tier 1 is mandatory groundwork. Mentioning iPhone Duo is not itself a reason to use Tier 2
or Tier 3 APIs.

<br>

<div align="center">
<img src="assets/tiers.svg" alt="Tier 1 universal adaptive, Tier 2 Duo-aware presentation, Tier 3 Duo-exclusive capability" width="100%">
</div>

<br>

## What the skill enforces

The high-value rules are intentionally strict:

- **No device-identity layout tree.** Never use `isDuo`, model identity, display identity, or idiom as an ordinary layout switch.
- **No hinge-driven layout.** Hinge input belongs to physical interaction and effects; columns, navigation, sidebars, and grid density belong to available space and reserved regions.
- **No duplicated application state.** Navigation, selection, drafts, playback, filters, and focus must survive resizing and display transitions.
- **No guessed hardware dimensions.** Apple does not publish a stable logical point-size contract for app layout. Query the environment.
- **No fold-obscured critical content.** Buttons, QR codes, drag handles, important labels, and image focal points must clear active reserved regions.
- **No invented SDK symbols.** If a symbol is absent from the manifest or unavailable in the active SDK, report `SDK-blocked` instead of improvising.
- **No independent inner/outer display canvases.** Use scenes and scene accessories for system-managed multi-display experiences.

## Reserved regions are not safe areas

<div align="center">
<img src="assets/reserved-regions.svg" alt="Camera occlusion regions and the folding division region" width="100%">
</div>

The skill keeps three concepts separate:

```text
safe areas       → system UI and edge protection
reserved regions → physical/system regions inside otherwise usable geometry
hinge input       → live physical motion for interaction/effects
```

The folding region is a **division** region. Camera regions are **occlusion** regions.
That distinction determines whether content should be split, displaced, or simply kept clear.

## Bars and navigation

Duo can move system controls to a vertical edge. The skill therefore prefers semantic
system navigation and toolbar APIs over hand-built bars. It also encodes less obvious Apple
guidance: the inner display in portrait retains horizontal bars, Split View puts each app's
controls on its outer edge, vertical bar placement is hardware-aligned rather than mirrored
for RTL, and overflow/visibility priority matters when vertical space is constrained.

## Arrangements

`ArrangementView` is for **two related surfaces**, not app navigation. Split arrangement is
appropriate when both surfaces deserve dedicated space. Overlay arrangement has a precise
semantic rule: **the primary view is the foreground view while overlaying**; when Duo is
partially open, the system may move the surfaces apart. The agent must choose primary and
secondary intentionally rather than inferring those roles from names like “player” or “queue.”

## Scenes, hinge, and camera

<div align="center">
<img src="https://www.apple.com/newsroom/images/2026/09/apple-unveils-iphone-duo/article/Apple-iPhone-Duo-Center-Stage-front-camera-260909_big.jpg.large_2x.jpg" alt="The Center Stage front camera on the outer display of iPhone Duo" width="62%">
<br><sub>Two front cameras &mdash; and <b>both report</b> <code>.front</code>. On a device whose displays can face<br>opposite directions, that is no longer enough to know a camera is looking at you.</sub>
</div>


Tier 3 guidance covers:

- side-by-side multitasking as a first-class layout state;
- multiple scene ownership and scene-local versus shared state;
- scene accessories as supplementary, availability-dependent UI;
- `onHingeChange` only for genuine physical interaction;
- virtual front-camera preference when it satisfies the product requirement;
- `AVCaptureDeviceDirectionCoordinator` for view-relative physical camera direction;
- rotation, mirroring, preview geometry, and camera-driven reserved-region changes.

## A factual layer agents cannot casually overstate

All Apple symbols named by the skill live in
[`data/api-manifest.json`](skills/iphone-duo/data/api-manifest.json). The manifest classifies
evidence as:

| Status | Meaning |
|---|---|
| `verified` | A current Apple DocC page resolves for the symbol |
| `apple-sourced` | The spelling comes from Apple sample/chapter material but the dedicated DocC page is not yet available |
| `conflicted` | Apple's own materials disagree; the agent must verify against the active SDK before emitting code |

The manifest is governed by
[`api-manifest.schema.json`](skills/iphone-duo/data/api-manifest.schema.json), and reference
files are not allowed to invent symbols outside that factual layer.

## Verify the repository locally

Run the deterministic suite before publishing changes:

```bash
# Offline: structure, schema contract, JSON, shell syntax, links, assets,
# audit self-test, manifest coverage and staleness.
bash skills/iphone-duo/scripts/verify-all.sh

# Also re-resolve documented Apple symbols against developer.apple.com.
bash skills/iphone-duo/scripts/verify-all.sh --online
```

For an app audit:

```bash
bash skills/iphone-duo/scripts/audit-duo.sh ~/code/MyApp
```

The audit is deliberately heuristic. It identifies candidates and severity; the agent still
has to inspect whether a match actually controls layout.

<br>

<div align="center">
<img src="assets/workflow.svg" alt="Scan, classify, plan, implement Tier 1 first, then verify across poses" width="100%">
</div>

<br>

## Repository structure

```text
skills/iphone-duo/
├── SKILL.md                         canonical agent contract
├── data/
│   ├── api-manifest.json            source-of-truth Apple symbol inventory
│   ├── api-manifest.schema.json     manifest structural contract
│   └── patterns.json                source-of-truth audit anti-patterns
├── scripts/
│   ├── audit-duo.sh                 repository readiness scanner
│   ├── verify-all.sh                deterministic local quality gate
│   └── verify-manifest.sh           Apple evidence/freshness verifier
└── references/
    ├── 01-design-and-layout.md
    ├── 02-bars-and-navigation.md
    ├── 03-fold-arrangements.md
    ├── 04-hardware-scenes-hinge.md
    ├── 05-camera.md
    ├── 06-testing-and-review.md
    ├── 07-api-cookbook.md
    └── 08-sources.md
```

## Source hierarchy

<div align="center">
<table>
<tr>
<td width="33%" align="center"><a href="https://developer.apple.com/videos/play/tech-talks/111466/"><img src="https://devimages-cdn.apple.com/wwdc-services/images/8/11309/11309_wide_250x141_2x.jpg" alt="Apple Tech Talk: Design for iPhone Duo" width="100%"><br><sub><b>Design for iPhone Duo</b></sub></a></td>
<td width="33%" align="center"><a href="https://developer.apple.com/videos/play/tech-talks/111461/"><img src="https://devimages-cdn.apple.com/wwdc-services/images/8/11312/11312_wide_250x141_2x.jpg" alt="Apple Tech Talk: Prepare your app" width="100%"><br><sub><b>Prepare your app</b></sub></a></td>
<td width="33%" align="center"><a href="https://developer.apple.com/videos/play/tech-talks/111462/"><img src="https://devimages-cdn.apple.com/wwdc-services/images/8/11313/11313_wide_250x141_2x.jpg" alt="Apple Tech Talk: Raise the bar" width="100%"><br><sub><b>Raise the bar</b></sub></a></td>
</tr>
<tr>
<td width="33%" align="center"><a href="https://developer.apple.com/videos/play/tech-talks/111463/"><img src="https://devimages-cdn.apple.com/wwdc-services/images/8/11314/11314_wide_250x141_2x.jpg" alt="Apple Tech Talk: Strike a pose" width="100%"><br><sub><b>Strike a pose</b></sub></a></td>
<td width="33%" align="center"><a href="https://developer.apple.com/videos/play/tech-talks/111464/"><img src="https://devimages-cdn.apple.com/wwdc-services/images/8/11315/11315_wide_250x141_2x.jpg" alt="Apple Tech Talk: Displays and scenes" width="100%"><br><sub><b>Displays and scenes</b></sub></a></td>
<td width="33%" align="center"><a href="https://developer.apple.com/videos/play/tech-talks/111465/"><img src="https://devimages-cdn.apple.com/wwdc-services/images/8/11316/11316_wide_250x141_2x.jpg" alt="Apple Tech Talk: Camera experience" width="100%"><br><sub><b>Camera experience</b></sub></a></td>
</tr>
</table>
<sub>The six launch Tech Talks this skill is built from. Click through to Apple.</sub>
</div>


When sources disagree, the skill uses this order:

1. active SDK/compiler reality;
2. current Apple API documentation;
3. current Apple Human Interface Guidelines;
4. current Apple Tech Talks and sample code;
5. this repository's synthesis;
6. third-party examples.

Primary Apple material is indexed in
[`references/08-sources.md`](skills/iphone-duo/references/08-sources.md), including the iPhone
Duo HIG and all six launch Tech Talks.

## Scope

This repository is a **reasoning and implementation skill**, not a Swift package. It does
not ship runtime code into your application. It teaches a coding agent how to audit, plan,
implement, and verify Duo adaptation without fragmenting the product into device-specific UI.

## Contributing

Corrections are more valuable than additional prose while the iOS 27.1 API surface is still
settling. See [CONTRIBUTING.md](CONTRIBUTING.md) for the evidence and verification contract.

[MIT](LICENSE) · [Security](SECURITY.md) · [Changelog](CHANGELOG.md) · [Trademark/image notice](NOTICE.md)

Prior art: [FloWritesCode/fwc-swiftui-skills](https://github.com/FloWritesCode/fwc-swiftui-skills)
