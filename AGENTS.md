# AGENTS.md

When working in this repository, treat `skills/iphone-duo/SKILL.md` as the canonical execution contract.

For an iPhone Duo task:

1. Read `skills/iphone-duo/SKILL.md` first.
2. Load only the relevant files from `skills/iphone-duo/references/`.
3. Prefer evidence from Apple sources indexed in `references/08-sources.md` over assumptions.
4. Verify the project's active Xcode/SDK version before using iOS 27.1-only APIs.
5. Never use device identity, orientation, or hinge angle as the primary ordinary-layout switch.
6. Preserve navigation, selection, scroll, editing, playback, and unsaved state across layout transitions.
7. Compile and test after coherent changes; clearly separate verified changes from speculative or SDK-blocked work.

For repository audits, run `bash skills/iphone-duo/scripts/audit-duo.sh <project-root>` as an initial heuristic scan, then inspect each finding manually. The script is not a substitute for code review.
