# Contributing

Apple's iPhone Duo documentation is still settling. **Corrections are more valuable than
additional prose** until the iOS 27.1 surface is fully stable.

## The non-negotiable rule

> **Never add an Apple API symbol to a reference file before adding it to
> `skills/iphone-duo/data/api-manifest.json`.**

The skill's value depends on separating evidence from prose. A symbol may be discussed only
when the manifest records its spelling, framework, evidence status, availability, and the
reference files that use it.

## One home for each kind of fact

| Kind of change | Canonical file |
|---|---|
| Apple symbol name, availability, evidence status | `skills/iphone-duo/data/api-manifest.json` |
| Manifest structural rules | `skills/iphone-duo/data/api-manifest.schema.json` |
| Audit anti-pattern | `skills/iphone-duo/data/patterns.json` |
| Full pasteable API example | `skills/iphone-duo/references/07-api-cookbook.md` |
| Design/implementation judgment | `skills/iphone-duo/references/01`–`06` |
| Source provenance | `skills/iphone-duo/references/08-sources.md` |
| Rule every invocation must know | `skills/iphone-duo/SKILL.md` |

If the same fact is being maintained manually in several places, the design is wrong.

`SKILL.md` is expensive context: every invocation loads it. Keep detailed examples and
secondary explanation in the focused references.

## Symbol evidence status

`status` describes evidence, not confidence:

- **`verified`** — a current Apple DocC page resolves. Include `docUrl`.
- **`apple-sourced`** — the spelling comes directly from Apple sample/chapter material but a
  dedicated DocC page is not yet available. Include `sourceUrl` and supporting evidence.
- **`conflicted`** — Apple's own material disagrees. Record the conflict and require active
  SDK verification before an agent emits the symbol.

Never promote `apple-sourced` to `verified` unless the documentation URL actually resolves.
Never collapse a `conflicted` entry by preference.

## Required local verification

Before opening a pull request or publishing a change, run:

```bash
bash skills/iphone-duo/scripts/verify-all.sh
```

That deterministic offline suite validates:

- Agent Skills structure and skill-directory identity;
- shell syntax;
- JSON parsing and manifest invariants;
- the local manifest schema contract;
- duplicate/stale symbol metadata;
- Markdown/HTML relative links;
- backticked reference filenames after renames;
- SVG well-formedness and the no-vendored-raster policy;
- `audit-duo.sh` against known-good and known-bad fixtures;
- manifest coverage and research-date freshness.

When changing Apple API evidence, also run:

```bash
bash skills/iphone-duo/scripts/verify-all.sh --online
```

The online pass re-resolves documented Apple symbols against developer.apple.com. Network
failure is not evidence that a symbol is wrong; investigate before changing status.

## Repository audit changes

`data/patterns.json` is the only anti-pattern catalog. `audit-duo.sh` must not grow a second
hardcoded list of regexes.

A new pattern must specify:

- stable category id;
- title;
- severity;
- tier;
- why it is risky;
- recommended fix;
- whether a Duo-ready application is expected to have zero hits.

Remember that the scanner is heuristic. A grep match is a review candidate, not proof of a
defect.

## API examples

`references/07-api-cookbook.md` is the code index. Keep full call sites there and use only
short excerpts elsewhere. For beta or newly published APIs:

1. verify spelling against the active SDK when available;
2. record the evidence in the manifest;
3. cite the Apple source and relevant timestamp/chapter;
4. mark provisional signatures honestly;
5. never invent a plausible replacement when compilation cannot confirm it.

## Terminology

Use these terms consistently:

- **Tier 1 / Tier 2 / Tier 3**
- **pose**, not posture
- **partially open**, not partially folded
- **hinge input**, not hinge state when referring to physical interaction
- **application state** for navigation, selection, drafts, playback, filters, and other
  durable user-task state

The distinction matters because one of the core rules is that layout changes must not become
application-state changes.

## Writing style

Write for an agent under context pressure. Prefer a decidable condition over a vague
preference.

Weak:

```text
Use a breakpoint when appropriate.
```

Better:

```text
Use a measured width threshold only when you can name the content that stops fitting below
it and derive the threshold from that content.
```

Do not add hardware point-size constants merely because they appear to work on one simulator
pose.

## Translations

`docs/es/` and `docs/ko/` are human-facing summaries. The executable skill remains English so
its API names and Apple-source citations remain canonical. When the English README changes
materially, update the localized summaries in the same change.

## Licensing and Apple material

Contributions are accepted under the [MIT License](LICENSE). Do not paste substantial Apple
documentation text or vendor Apple imagery into the repository. See [NOTICE.md](NOTICE.md).
