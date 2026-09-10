# Changelog

All notable changes to this project are documented here.
Format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/);
the skill itself is versioned in `SKILL.md` frontmatter.

## [Unreleased]

## [2.3.0] — 2026-09-10

The release that turns the repository into a source-backed, locally verifiable iPhone Duo
agent skill with a polished public reference surface.

### Added

- **`data/api-manifest.json`** as the Apple-symbol evidence layer, with `verified`,
  `apple-sourced`, and `conflicted` states instead of treating beta-era API spellings as
  equally certain.
- **`data/api-manifest.schema.json`** as the structural contract for that manifest.
- **`data/patterns.json`** as the single source of truth for Duo-hostile audit patterns.
- **`scripts/verify-all.sh`** as one deterministic local quality gate covering Agent Skills
  structure, JSON/schema integrity, shell syntax, links, reference ownership, SVG validity,
  raster policy, audit fixtures, manifest freshness, and optional live Apple-doc checks.
- Apple-hosted iPhone Duo hardware, app, camera, and Tech Talk screenshots in the README.
  They remain remote Apple assets and are not vendored into this repository.
- Manifest coverage for `NavigationStack` and `ToolbarItem`, which are foundational to the
  system-bar guidance agents are expected to follow.
- A dedicated `builtInDuoCamera` false-friend rule so a deprecated rear-camera alias cannot
  be mistaken for an iPhone Duo camera API.
- Open-source scaffolding: MIT license, contribution guide, code of conduct, security policy,
  notice, issue templates, pull-request template, editor config, original SVG diagrams, and
  Korean/Spanish human-facing documentation.

### Changed

- `SKILL.md` advanced to **2.3.0** and remains the canonical execution contract.
- Repository verification is intentionally **local and reproducible** rather than dependent
  on a hosted workflow service.
- Tier 1 adaptive-layout correctness is required before Tier 2 Duo-aware presentation or
  Tier 3 Duo-exclusive capability.
- Audit semantics distinguish heuristic review candidates from confirmed defects and use
  P0–P3 severity consistently.
- Full API call sites live in `references/07-api-cookbook.md`; domain references stay focused
  on reasoning and implementation decisions.
- Hinge input is explicitly restricted to physical interaction/effects, never ordinary
  layout switching.
- Width thresholds require a content-based derivation instead of device dimensions.
- Terminology standardized around **Tier 1/2/3**, **pose**, **partially open**, and
  **hinge input**.

### Fixed

- Corrected the Swift spelling from nonexistent `AVCaptureDeviceRotationCoordinator` to
  `AVCaptureDevice.RotationCoordinator`.
- Corrected `.builtInDualWideCamera`: it is a rear virtual camera, not a Duo front camera.
- Documented `builtInDuoCamera` as a deprecated false friend unrelated to iPhone Duo.
- Corrected stale reference filenames after the fold/hinge documentation was reorganized.
- Tightened overlay-arrangement semantics so the primary view is treated as the foreground
  view while overlaying rather than inferred from product naming.
- Corrected **Device Hub** naming in the canonical skill.
- Removed harness-specific placeholders and installation guidance so the repository remains
  agent-neutral while still documenting Codex and universal Agent Skills locations.

### Apple guidance captured

- Inner display portrait keeps horizontal bars; Duo vertical bars are not universal.
- In Split View, each app places controls on its **outer** edge.
- Vertical bars are hardware-aligned and do **not** mirror for RTL.
- Grids should prefer an even column count when that produces a cleaner fold division.
- Overlay arrangements may stop overlaying when the device is partially open.
- `HStack`/`VStack` are natural split-arrangement candidates; `ZStack` is an overlay candidate.
- The outer and inner front cameras have different capabilities and both report `.front`, so
  view-relative camera direction may require `AVCaptureDeviceDirectionCoordinator`.
- Camera/session changes can alter reserved-region geometry.
- Games may lock orientation but must still fill the screen coherently across Duo poses.
- The iOS 27 versus 27.1 adaptation boundary and iPhone Duo simulator testing via Device Hub.

## [1.0.0] — 2026-09-10

Initial release: `SKILL.md`, eight focused references, and a heuristic repository audit
script synthesized from Apple's iPhone Duo HIG and the six launch Tech Talks.
