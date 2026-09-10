# iPhone Duo Agent Skill

A source-backed Agent Skill for designing, reviewing, and adapting iOS apps for **iPhone Duo** with SwiftUI and UIKit.

The repository is intended for coding agents such as **Codex**, **Claude Code**, Cursor, and any harness that supports the [Agent Skills](https://agentskills.io) format.

This skill synthesizes Apple's iPhone Duo Human Interface Guidelines and the full 2026 iPhone Duo Tech Talk set into an implementation-oriented rulebook. It also builds on the strong adaptive-layout philosophy demonstrated by FloWritesCode's `fwc-swiftui-skills`, while expanding the scope into vertical bars, reserved regions, arrangements, hinge interactions, multi-scene behavior, second-display scene accessories, camera direction coordination, and a concrete audit/test workflow.

> Research snapshot: 2026-09-10. iPhone Duo APIs discussed by Apple target the iOS 27 / 27.1 generation. Some APIs may still depend on Xcode 27.1 availability. Agents must verify SDK symbol availability before compiling or shipping code.

## Core principle

**Do not build a separate “Duo app.” Build one adaptive iPhone app that remains coherent across continuously changing sizes, then use Duo-specific hardware only when it adds product value.**

The skill treats iPhone Duo adaptation as three layers:

1. **Universal adaptability** — sizing, navigation, grids, safe areas, state continuity, resizing.
2. **Duo-aware layout** — reserved regions, displacement, ArrangementView, vertical bars.
3. **Duo-exclusive capability** — hinge-driven interaction, scene accessories, multiple scenes, dual-camera behavior.

Agents must complete layer 1 before adding layers 2 or 3.

## Repository layout

```text
iphone-duo-skill/
├── README.md
├── AGENTS.md
├── CLAUDE.md
└── skills/
    └── iphone-duo/
        ├── SKILL.md
        ├── scripts/
        │   └── audit-duo.sh
        └── references/
            ├── 01-design-and-layout.md
            ├── 02-bars-and-navigation.md
            ├── 03-fold-arrangements-and-hinge.md
            ├── 04-scenes-and-multidisplay.md
            ├── 05-camera.md
            ├── 06-testing-and-review.md
            ├── 07-api-cookbook.md
            └── 08-sources.md
```

`SKILL.md` is intentionally compact. Detailed material is split into focused references so agents load only the context required for the current task.

## Install

### Codex

```bash
git clone https://github.com/eisenjimmy/iphone-duo-skill.git
mkdir -p ~/.codex/skills
cp -R iphone-duo-skill/skills/iphone-duo ~/.codex/skills/
```

### Claude Code

```bash
git clone https://github.com/eisenjimmy/iphone-duo-skill.git
mkdir -p ~/.claude/skills
cp -R iphone-duo-skill/skills/iphone-duo ~/.claude/skills/
```

### Universal Agent Skills location

```bash
mkdir -p ~/.agents/skills
cp -R iphone-duo-skill/skills/iphone-duo ~/.agents/skills/
```

The directory name and `name:` field are both `iphone-duo`, as required by the Agent Skills specification.

## What the skill can do

Use it to ask an agent to:

- audit an existing SwiftUI or UIKit repository for iPhone Duo readiness;
- redesign a screen for compact, intermediate, and expansive sizes;
- remove `UIScreen.main`, orientation, idiom, and device-model layout assumptions;
- convert list/detail flows to adaptive system navigation;
- make TabView/sidebar behavior resilient across outer and inner displays;
- migrate custom bars to system toolbars that can become vertical;
- audit overflow priority and toolbar item axis behavior;
- keep important controls away from fold and camera reserved regions;
- implement displacement patterns and `ArrangementView` where appropriate;
- add hinge-driven interactions without abusing hinge angle as a layout breakpoint;
- add multi-scene and scene-accessory experiences;
- design camera flows around the virtual front camera or explicit camera direction coordination;
- create a test matrix for outer display, inner display, partial fold, portrait/landscape, split view, keyboard, sheets, and scene transitions.

## Suggested prompts

```text
Use the iphone-duo skill to audit this repository. Do not change code yet.
Return evidence by file, classify each issue as universal adaptive,
Duo-aware, or Duo-exclusive, then propose the smallest implementation plan.
```

```text
Use the iphone-duo skill and adapt this SwiftUI app for iPhone Duo.
Preserve navigation and view state during resizing. Prefer system containers,
reserved regions, and adaptive bars before introducing hinge-specific logic.
Compile after each coherent batch and report unverified beta APIs separately.
```

```text
Review this screen specifically for partially folded iPhone Duo use.
Check fold interference, safe areas, control reachability, displacement,
ArrangementView suitability, and whether any interaction should use hinge state.
```

## Design stance

The skill deliberately rejects common foldable-app anti-patterns:

- no `if isDuo` layout tree;
- no `if isFolded { wideLayout }` logic;
- no screen-width constants copied from hardware dimensions;
- no navigation decisions driven by hinge angle;
- no duplicated compact/expanded state;
- no custom fake toolbar when a system toolbar can express the interaction;
- no assumption that the two physical displays are independent canvases;
- no critical content centered across the fold;
- no speculative iOS 27.1 code when the active SDK cannot verify it.

## Primary sources

The source index in `references/08-sources.md` covers Apple's iPhone Duo landing page, Human Interface Guidelines, and all six launch Tech Talks:

- Design for iPhone Duo
- Prepare your app for iPhone Duo
- Raise the bar with iPhone Duo
- Strike a pose with adaptive layouts on iPhone Duo
- Leverage multiple displays and scenes on iPhone Duo
- Build a great camera experience for iPhone Duo

It also records the Agent Skills specification and the comparative `fwc-swiftui-skills` repository.
