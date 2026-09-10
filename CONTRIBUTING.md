# Contributing

Apple's iPhone Duo documentation is still shipping. **Corrections are the most valuable
contribution to this repository** — more valuable than new prose.

## The one rule

> **Never add an API symbol to a reference file without adding it to
> `skills/iphone-duo/data/api-manifest.json` first.**

CI enforces this. A reference file that names a symbol the manifest doesn't carry fails the
build. This is deliberate: the whole promise of the skill is that an agent reading it will
not be handed an invented API.

## Where things live

There is exactly one home for each kind of fact. If you find yourself typing something twice,
you are editing the wrong file.

| Kind of change | File |
|---|---|
| An Apple symbol — name, availability, status | `data/api-manifest.json` |
| An anti-pattern the audit should catch | `data/patterns.json` |
| A full, pasteable call site | `references/07-api-cookbook.md` |
| Judgment, rules, guidance | `references/01`–`06` |
| Where a claim came from | `references/08-sources.md` |
| A core rule every task needs | `SKILL.md` |

`SKILL.md` always loads into the agent's context. Adding to it costs every user tokens on
every invocation — argue for it, don't assume it.

## Symbol status

`status` in the manifest is a claim about evidence, not about confidence:

- **`verified`** — the DocC page resolves. Include the `docUrl`; CI re-fetches it.
- **`apple-sourced`** — the spelling comes verbatim from an Apple code sample or chapter
  text, but no doc page exists yet. Include `sourceUrl` and, where possible, `appleSample`.
- **`conflicted`** — Apple's own materials disagree. Record both spellings in `conflict` and
  say which is better attested. **Do not pick a winner** on the skill's own authority.

Never upgrade `apple-sourced` to `verified` without a resolving URL. When the 27.1 docs land,
that upgrade is the single most useful PR anyone can send.

## Before you open a PR

```bash
bash skills/iphone-duo/scripts/verify-manifest.sh     # network; re-resolves every docUrl
bash skills/iphone-duo/scripts/audit-duo.sh <a-swift-project>
python3 -m json.tool skills/iphone-duo/data/api-manifest.json > /dev/null
```

CI runs the same checks plus `shellcheck`, and re-runs the manifest verification **weekly**
so rot surfaces without anyone remembering to look.

## Reporting an Apple change

Open an issue with the **API change** template. Include the symbol, what changed, and the
Apple URL. If `verify-manifest.sh` already fails for you, paste its output — that is the
whole report.

## Style

Reference files open with a one-line "Use this reference when…" trigger and close with
`## Acceptance criteria` (or, in 03 and 05, a one-sentence "passes when" paragraph).
Mid-file, the recurring sections are `## Audit checklist` and topic headings. Follow the
file you are editing rather than inventing a new shape.

The reader is a language model under context pressure. Prefer a decidable test to a
preference — "prefer X where appropriate" is not a rule an agent can act on. If you write a
threshold, name the content that stops fitting below it.

Terminology is fixed: **Tier 1/2/3**, **pose** (not posture), **partially open** (not
partially folded), **hinge input** (not hinge state — "state" is reserved for app state).

## Translations

`docs/es/` and `docs/ko/` mirror the human-facing docs only. The skill itself stays English:
it is consumed by agents and cites English Apple documentation, and a translated rule that
drifts from the original is worse than no translation. When you change `README.md`
substantively, note it in the PR so translations can follow.

## Licensing

Contributions are accepted under the [MIT License](LICENSE). Do not paste Apple
documentation prose or commit Apple images — see [NOTICE.md](NOTICE.md).
