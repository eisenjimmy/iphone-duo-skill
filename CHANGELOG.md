# Changelog

All notable changes to this project are documented here.
Format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/);
the skill itself is versioned in `SKILL.md` frontmatter.

## [2.1.0] — 2026-09-10

The release that made the skill's factual layer machine-checkable.

### Added

- **`data/api-manifest.json`** — the single source of truth for every Apple symbol the
  skill names. 50 symbols, each graded `verified` (Apple's doc page resolves),
  `apple-sourced` (verbatim from an Apple sample, no doc page yet), or `conflicted`
  (Apple's own materials disagree). Prose is no longer allowed to assert a symbol the
  manifest doesn't carry.
- **`data/patterns.json`** — the single source of truth for Duo-hostile code patterns,
  with severity, tier, cause and fix. Ten categories, 76 patterns.
- **`scripts/verify-manifest.sh`** — re-resolves every documented symbol against
  developer.apple.com, fails if a reference file names an unmanifested symbol, and
  **expires the research date after 45 days** so staleness becomes a red build.
- **CI** — structure, JSON, SVG well-formedness, shellcheck, an `audit-duo.sh` self-test
  against good and bad fixtures, internal link checking, and a guard that no Apple raster
  image is ever committed. The manifest check also runs weekly on a schedule.
- **Apple's verbatim code samples**, cited by Tech Talk and timestamp, replacing
  paraphrased snippets throughout `references/07-api-cookbook.md`.
- Open-source scaffolding: `LICENSE` (MIT), `CONTRIBUTING.md`, `CODE_OF_CONDUCT.md`,
  `SECURITY.md`, `NOTICE.md`, issue and PR templates, `.editorconfig`.
- Original SVG diagram set in `assets/`, drawn to the `diagram-design` editorial system.
- Spanish and Korean translations of the human-facing documentation.

### Fixed

- **`AVCaptureDeviceRotationCoordinator` does not exist in Swift.** It is the
  Objective-C name; the Swift type is the nested `AVCaptureDevice.RotationCoordinator`.
  The old spelling would not have compiled.
- **`.builtInDualWideCamera` was presented as a Duo front camera.** It is a *rear*
  virtual device. It belongs in the direction coordinator's `deviceTypes:` because the
  coordinator reports direction for every monitored camera — not because it faces you.
- **Added a warning about `builtInDuoCamera`** — a real, deprecated iOS 10 alias for
  `builtInDualCamera` with no relationship to iPhone Duo. It is the first thing an agent
  grepping the SDK for "Duo" will find.
- Recorded that `ToolbarItemVisibilityPriority`, `ToolbarOverflowMenu`,
  `UIBarButtonItemVisibilityPriority` and `UISceneAccessory` are **iOS 27.0**, not Duo
  APIs, and `UINavigationItem.additionalOverflowItems` is **iOS 16.0**.

### Added — Apple guidance that was missing

- The inner display **in portrait keeps horizontal bars** — the exception to side controls.
- Vertical bars are hardware-aligned and **do not flip in right-to-left languages**.
- In Split View each app places controls on its **outer** edge.
- Grids should **prefer an even column count** so content divides across the fold.
- **Games**: may lock orientation, must fill the screen, prefer changing aspect ratio over
  letterboxing; fill unavoidable padding with artwork.
- Overlay arrangements **stop overlaying when partially open**, and primary sits on top.
- The `HStack`/`VStack` → split, `ZStack` → overlay adoption heuristic.
- The outer camera region is **always present**; the inner one exists **only while the
  camera is active** — so starting a session changes your own safe geometry.
- The iOS 27 vs 27.1 SDK behavior difference, and DeviceHub simulator testing.

### Changed

- `SKILL.md` rewritten: 363 → 273 lines with more content. Invariants now carry their own
  counter-examples; the tier catalog is a table; report templates and pattern lists are
  referenced rather than restated.
- `references/07-api-cookbook.md` is now the **code index**: every full call site lives
  there, and 01–05 keep only short illustrative snippets.
- Hinge guidance moved from `03` to `04`, so reference files map 1:1 onto the tiers.
  `03-fold-arrangements-and-hinge.md` → `03-fold-arrangements.md`;
  `04-scenes-and-multidisplay.md` → `04-hardware-scenes-hinge.md`.
- `scripts/audit-duo.sh` rewritten to execute `patterns.json` rather than carry its own
  regexes. Now reports severity, cause and fix, and exits non-zero on must-be-zero
  categories.
- Terminology fixed throughout: **Tier 1/2/3**, **pose** (not posture), **partially open**
  (not partially folded), **hinge input** (not hinge state).
- Width thresholds now require an inline derivation naming the content that stops fitting.

## [1.0.0] — 2026-09-10

Initial release: `SKILL.md`, eight references, and a heuristic audit script, synthesized
from Apple's iPhone Duo HIG and the six launch Tech Talks.
