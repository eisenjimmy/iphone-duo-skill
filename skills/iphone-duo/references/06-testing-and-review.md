# 06 — Repository audit, testing, and acceptance

Use this reference for code review, implementation planning, simulator validation, regression checks, and handoff reports.

## Audit philosophy

A Duo audit is not a search for foldable-only code. It is a search for **assumptions that fail when available space, system bars, reserved regions, scene placement, or camera direction change dynamically**.

Start broad, then narrow:

```text
repository architecture
→ navigation/state ownership
→ screen-level responsiveness
→ bars/safe areas
→ fold/reserved regions
→ hinge/multidisplay/camera specializations
```

## Step 1 — Establish environment

Record:

```text
Xcode version
SDK version
deployment target
Swift version
SwiftUI/UIKit/mixed
scene model
navigation model
camera usage
custom rendering/layout frameworks
```

Do not report an iOS 27.1 API as “implemented and verified” if the current SDK cannot compile it.

Use these verification labels:

- **verified** — built/tested in current environment;
- **compile-verified only** — builds but Duo simulator behavior not exercised;
- **design-verified** — architecture reviewed against Apple guidance but not compiled;
- **SDK-blocked** — documented API not present in active SDK;
- **deferred** — intentionally not implemented.

## Step 2 — Run heuristic scan

Run:

```bash
bash skills/iphone-duo/scripts/audit-duo.sh <project-root>
```

The script looks for common risks. Every result requires manual interpretation.

False positives are expected. For example, `UIScreen.main` might be used in legacy analytics rather than layout. Severity depends on actual behavior.

## Step 3 — Repository-wide searches

Search manually for concepts the script cannot infer reliably:

```text
custom tab/navigation components
GeometryReader-heavy layout
fixed max/min widths
hardcoded sheet sizes
multiple screen roots for compact/regular
scene activation
camera session ownership
state object creation inside conditional view trees
scroll state ownership
custom popover/alert implementations
```

Also inspect localization because longer strings can change vertical toolbar viability.

## Step 4 — Screen inventory

Build a table:

| Screen | Narrow | Intermediate | Expansive | Fold risk | Bar risk | State risk | Tier |
|---|---|---|---|---|---|---|---|
| Example list | pass | weak | stretches | low | low | medium | 1 |
| Editor | pass | weak | missing inspector | medium | high | high | 1/2 |

Do not skip intermediate width. It is where endpoint-only designs usually break.

## Step 5 — Severity model

### P0 — Functional failure

Examples:

- required action unreachable;
- content hidden behind camera/fold/system bar;
- crash during resize/display transition;
- navigation resets and loses work;
- camera session becomes invalid;
- sheet traps the user.

### P1 — Architectural blocker

Examples:

- `isDuo` root branching;
- separate folded/unfolded state trees;
- device orientation drives information architecture;
- `UIScreen.main.bounds` controls major layout;
- custom navigation blocks standard resizing;
- global scene state prevents multiple-scene correctness.

### P2 — Significant quality defect

Examples:

- wide view only stretches;
- text line length becomes excessive;
- custom toolbar doesn't adapt vertically;
- important item overflows too early;
- controls jump dramatically around the fold;
- fixed grid columns waste or clip space.

### P3 — Enhancement opportunity

Examples:

- two-part surface could benefit from `ArrangementView`;
- optional outer-display accessory would add value;
- hinge interaction could create a distinctive physical affordance;
- camera preview could make better use of dynamic aspect ratio.

## Step 6 — Implementation batches

Prefer batches with clear regression boundaries:

### Batch A — Remove global assumptions

- remove layout use of `UIScreen.main`;
- replace orientation/idiom decisions;
- fix unsafe safe-area math;
- centralize state ownership.

### Batch B — Navigation and content adaptability

- adopt `NavigationSplitView`/adaptive `TabView`;
- convert fixed grids;
- add readable-width constraints;
- use `ViewThatFits`/`AnyLayout` locally.

### Batch C — Bars

- migrate fake bars to `.toolbar` where practical;
- provide symbols/titles;
- configure axis behavior;
- consolidate overflow;
- set visibility/compression priorities.

### Batch D — Fold-aware layout

- query reserved regions;
- displace only affected content;
- adopt arrangements where semantically justified.

### Batch E — Hardware-specific enhancements

- hinge interactions;
- multiple scenes;
- scene accessories;
- advanced camera switching.

Compile and exercise the affected flows after each batch.

## Duo test matrix

When Device Hub / Duo simulator is available, cover at least these states.

### Display/pose

```text
outer display — portrait
outer display — landscape
inner display — portrait-like/tall presentation where applicable
inner display — landscape/full expansive
partially folded — book-like
partially folded — tabletop-like
fully open/flat
closing transition
opening transition
```

### Window size

```text
very narrow
compact
intermediate ~ half-width behavior
regular
full inner display
```

Do not rely only on size-class endpoints. Drag/resize where supported to expose transition defects.

### System UI pressure

```text
keyboard visible
sheet presented
popover/menu/alert visible
large Dynamic Type
right-to-left localization
long localized toolbar titles
Live Activity / Dynamic Island interaction where relevant
```

### Navigation/state continuity

Before resizing/folding, create meaningful state:

```text
push 2–3 navigation levels
select an item
scroll into a long list
edit text without saving
start media playback
open inspector/filter state
focus a text field
```

Then change pose/width and verify no unintended reset.

### Bars

Verify:

```text
horizontal → vertical transition
back/close position
prominent action position
custom item representation
badge/status visibility
overflow menu content
visibility priority
toolbar vs tab compression
keyboard-induced overflow
```

### Fold/reserved regions

Verify:

```text
critical controls never land inside active division region
focal content isn't obscured by camera occlusion region
continuous scrolling content remains natural
local displacement doesn't cause unrelated jumps
fold transitions animate/relayout without overlap
```

### Scene tests

If multiple scenes are supported:

```text
create scene where supported
handle unavailable scene creation
keep state independent between scenes
close one scene without corrupting another
resize one scene while another remains active
```

### Scene accessory tests

If used:

```text
accessory available
accessory unavailable
availability changes mid-task
toggle enabled/disabled
main workflow remains complete without accessory
privacy-safe content on opposite display
```

### Camera tests

If camera features exist:

```text
virtual front camera across open/close
explicit physical camera direction change
preview mirroring
rotation
format/frame-rate fallback
capture while transitioning safely
second-display accessory availability
```

## Accessibility and localization

Duo adaptation isn't complete if it only works at default text size in English.

Check:

- Dynamic Type, especially toolbar custom views;
- VoiceOver order after layout rearrangement;
- Switch Control / keyboard focus where relevant;
- RTL layout;
- longer translated titles;
- minimum touch targets;
- contrast/readability on edge-to-edge content;
- reduce transparency if relying on system glass/bar backgrounds;
- reduce motion for fold-correlated decorative animation where appropriate.

## Performance checks

Watch for:

- view-model recreation during geometry changes;
- heavy work in `onGeometryChange`;
- excessive reserved-region state propagation;
- continuous hinge callbacks triggering network/storage work;
- camera session reconfiguration on irrelevant layout updates;
- repeated expensive grid computations during resize.

Use Instruments when behavior suggests layout thrash or main-thread stalls.

## Review report template

Use this structure:

```markdown
# iPhone Duo Readiness Review

## Verdict
Ready / Mostly adaptive / Material refactor needed

## Build context
- Xcode:
- SDK:
- Deployment target:
- UI framework:

## P0/P1 findings
| File | Finding | Evidence | Impact | Fix | Tier |

## P2/P3 findings
| File | Opportunity | Why it matters | Suggested API | Tier |

## Implementation sequence
1. ...
2. ...

## State continuity risks
- ...

## Test matrix for this app
- ...

## SDK-blocked or unverified items
- ...
```

## Implementation completion report

After changing code, report:

```markdown
## Implemented
- file/symbol — change — rationale

## Build verification
- command / target / result

## Behavioral verification
- widths/poses exercised

## Deferred
- reason and dependency

## Remaining risks
- concrete, evidence-based only
```

Never claim simulator validation if only static code review was performed.

## Definition of done

A repository is Duo-ready when:

- Tier 1 adaptability is structurally sound;
- no P0/P1 Duo/resizability defect remains knowingly unfixed;
- system navigation and bars adapt naturally;
- state continuity is verified across relevant width/pose changes;
- fold-aware custom UI uses queried regions rather than guesses;
- optional Tier 3 features degrade gracefully;
- test coverage includes intermediate widths, not only outer/full-inner endpoints;
- SDK-dependent work is accurately labeled.
