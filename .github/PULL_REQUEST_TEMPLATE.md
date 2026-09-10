## What changed

<!-- One or two sentences. -->

## Type

- [ ] Apple API correction (a symbol was renamed, removed, or is now documented)
- [ ] Guidance change (a rule is wrong or incomplete)
- [ ] New coverage (a Duo behavior the skill doesn't address)
- [ ] Tooling / CI
- [ ] Docs, README, or translation

## If this touches an Apple symbol

- [ ] `skills/iphone-duo/data/api-manifest.json` updated **first**
- [ ] `status` is honest: `verified` only with a resolving `docUrl`
- [ ] `bash skills/iphone-duo/scripts/verify-manifest.sh` passes

## Source

<!-- Apple URL, Tech Talk + timestamp, or the SDK you verified against. -->

## Checks

- [ ] No fact is stated in two files (see the table in CONTRIBUTING.md)
- [ ] Any new code lives in `references/07-api-cookbook.md`
- [ ] Terminology: Tier 1/2/3 · pose · partially open · hinge input
