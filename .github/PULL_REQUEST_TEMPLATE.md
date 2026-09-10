## What changed

<!-- One or two sentences. -->

## Type

- [ ] Apple API correction (a symbol was renamed, removed, or is now documented)
- [ ] Guidance change (a rule is wrong or incomplete)
- [ ] New coverage (a Duo behavior the skill doesn't address)
- [ ] Tooling / verification
- [ ] Docs, README, or translation

## If this touches an Apple symbol

- [ ] `skills/iphone-duo/data/api-manifest.json` updated **first**
- [ ] `status` is honest: `verified` only with a resolving `docUrl`
- [ ] Source evidence points to Apple documentation, sample code, or the active SDK

## Source

<!-- Apple URL, Tech Talk + timestamp, or the SDK you verified against. -->

## Required checks

- [ ] `bash skills/iphone-duo/scripts/verify-all.sh` passes
- [ ] `bash skills/iphone-duo/scripts/verify-all.sh --online` was run when Apple API evidence changed
- [ ] No fact is maintained manually in multiple canonical locations
- [ ] Full pasteable API examples live in `references/07-api-cookbook.md`
- [ ] Terminology is consistent: Tier 1/2/3 · pose · partially open · hinge input
- [ ] Any behavior described as verified was actually executed or observed
