# CLAUDE.md

Use `skills/iphone-duo/SKILL.md` as the canonical iPhone Duo skill.

When a task involves iPhone Duo, foldable iPhone layout, hinge behavior, reserved regions, ArrangementView, vertical navigation/toolbars, multiple scenes, scene accessories, or Duo camera behavior:

- read `skills/iphone-duo/SKILL.md` first;
- load the smallest relevant reference files;
- audit before refactoring;
- prefer adaptive SwiftUI/UIKit system containers over device-specific branches;
- treat hinge data as interaction input, not normal layout input;
- preserve application state across fold/display/layout transitions;
- verify SDK availability for iOS 27.1 symbols before implementation;
- report any untestable Duo-only work explicitly instead of inventing hardware dimensions or behavior.

Use `bash skills/iphone-duo/scripts/audit-duo.sh <project-root>` for a first-pass heuristic scan when reviewing an existing codebase.
