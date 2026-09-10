# Changelog

All notable changes to this project are documented here.
Format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/);
the skill itself is versioned in `SKILL.md` frontmatter.

## [Unreleased]

## [2.2.0] — 2026-09-10

The release that turns repository verification into a self-contained local contract and
tightens the boundary between adaptive-layout guidance and Duo-specific API evidence.

### Added

- **`data/api-manifest.schema.json`** — a JSON Schema contract for the manifest's top-level
  structure, symbol evidence states, URL provenance, and reference ownership.
- **`scripts/verify-all.sh`** — one deterministic local quality gate covering Agent Skills
  structure, shell syntax, JSON/manifest invariants, schema presence, duplicate IDs, stale
  `usedIn` entries, relative links, backticked reference filenames, SVG validity, raster
  policy, audit self-tests, freshness, and optional live Apple documentation verification.
- Validation of the always-loaded `SKILL.md` alongside focused reference files for tracked
  Apple API claims.
- A dedicated `builtInDuoCamera` false-friend audit rule so a deprecated rear-camera alias
  cannot be mistaken for an iPhone Duo camera API.

### Changed

- The API manifest is explicitly a **focused evidence inventory**, not an attempted mirror of
  the complete SwiftUI/UIKit SDK. Duo-specific, newly introduced, conflicted, false-friend,
  and otherwise evidence-sensitive symbols belong there; established platform primitives do
  not need duplicate catalog entries merely because prose names them.
- `SKILL.md` advanced to **2.2.0** and now states that evidence boundary directly.
- Repository quality verification is intentionally **local and reproducible**; no hosted CI
  workflow is required.
- Audit semantics were tightened: fixed-grid issues are Tier 1 adaptability concerns,
  hinge-driven layout is a must-be-zero P1 defect, and orientation-lock APIs are not treated
  as proof of a layout bug because games may legitimately lock orientation.
- English, Korean, and Spanish entry documentation use the same canonical skill, tier model,
  schema-backed factual layer, and local verification path.

### Fixed

- Corrected a stale camera reference from the retired `04-scenes-and-multidisplay.md` name
  to `04-hardware-scenes-hinge.md`.
- Tightened overlay-arrangement semantics: the **primary view is the foreground view while
  overlaying**. Product labels such as player/queue no longer imply primary/secondary role;
  ownership follows the intended foreground relationship and Apple's published example.
- Removed hardcoded verification counts from the repository presentation layer so README
  metadata cannot silently drift from the manifest inventory.
- Corrected **Device Hub** naming in the core skill.

## [2.1.0] — 2026-09-10

The release that made the skill's factual layer machine-checkable.

### Added

- **`data/api-manifest.json`** — a focused source of truth for Apple symbols whose identity,
  availability, or semantics materially affect Duo implementation. Entries are graded
  `verified` (Apple's doc page resolves), `apple-sourced` (verbatim from Apple material,
  no dedicated doc page yet), or `conflicted` (Apple's own materials disagree).
- **`data/patterns.json`** — the single source of truth for Duo-hostile code patterns,
  with severity, tier, cause and fix.
- **`scripts/verify-manifest.sh`** — re-resolves documented symbols against
  developer.apple.com, detects untracked evidence-sensitive symbols and stale `usedIn` paths,
  and expires the research date after 45 days so staleness is visible.
- Structure, JSON, SVG, shell, audit-fixture, internal-link, and Apple-image policy checks
  around the factual layer.
- **Apple code samples**, cited by Tech Talk and timestamp, replacing paraphrased snippets
  throughout `references/07-api-cookbook.md`.
- Open-source scaffolding: `LICENSE` (MIT), `CONTRIBUTING.md`, `CODE_OF_CONDUCT.md`,
  `SECURITY.md`, `NOTICE.md`, issue and PR templates, `.editorconfig`.
- Original SVG diagram set in `assets/`.
- Spanish and Korean translations of the human-facing documentation.

### Fixed

- **`AVCaptureDeviceRotationCoordinator` does not exist in Swift.** It is the
  Objective-C name; the Swift type is the nested `AVCaptureDevice.RotationCoordinator`.
- **`.builtInDualWideCamera` was presented as a Duo front camera.** It is a *rear*
  virtual device. It belongs in the direction coordinator's `deviceTypes:` because the
  coordinator reports direction for every monitored camera — not because it faces you.
- Added a warning about `builtInDuoCamera` — a real, deprecated iOS 10 alias for
  `builtInDualCamera` with no relationship to iPhone Duo.
- Recorded that `ToolbarItemVisibilityPriority`, `ToolbarOverflowMenu`,
  `UIBarButtonItemVisibilityPriority` and `UISceneAccessory` predate the Duo-specific 27.1
  surface, and `UINavigationItem.additionalOverflowItems` predates it substantially.

### Added — Apple guidance that was missing

- The inner display **in portrait keeps horizontal bars** — the exception to side controls.
- Vertical bars are hardware-aligned and **do not flip in right-to-left languages**.
- In Split View each app places controls on its **outer** edge.
- Grids should **prefer an even column count** so content divides across the fold.
- **Games** may lock orientation, must fill the screen, and should prefer changing aspect
  ratio over letterboxing; fill unavoidable padding with artwork.
- Overlay arrangements stop overlaying when partially open, with the primary surface as the
  foreground surface while overlaying.
- The `HStack`/`VStack` → split, `ZStack` → overlay adoption heuristic.
- The outer camera region is always present; the inner one exists only while the camera is
  active, so starting a session can change usable geometry.
- The iOS 27 versus 27.1 SDK behavior difference and **Device Hub** simulator testing.

### Changed

- `SKILL.md` was substantially compressed while preserving the execution contract; detailed
  examples remain in progressive-disclosure references.
- `references/07-api-cookbook.md` became the **code index** for full call sites.
- Hinge guidance moved from `03` to `04`, so reference files map directly onto the tier/domain
  structure.
- `scripts/audit-duo.sh` was rewritten to execute `patterns.json` rather than carry a second
  regex catalog.
- Terminology standardized around **Tier 1/2/3**, **pose**, **partially open**, and **hinge
  input**.
- Width thresholds require an inline derivation naming the content that stops fitting.

## [1.0.0] — 2026-09-10

Initial release: `SKILL.md`, eight references, and a heuristic audit script, synthesized
from Apple's iPhone Duo HIG and the six launch Tech Talks.
