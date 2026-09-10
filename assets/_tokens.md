# Diagram tokens

These SVGs follow the `diagram-design` skill's default editorial skin.

| Role | Hex |
|---|---|
| paper | `#f5f5f5` |
| paper-2 | `#ececec` |
| ink | `#2d3142` |
| muted | `#4f5d75` |
| soft | `#7a8399` |
| rule | `rgba(45,49,66,0.12)` |
| rule-solid | `#bfc0c0` |
| accent | `#eb6c36` |
| accent-tint | `rgba(235,108,54,0.08)` |
| link | `#2e5aa8` |

**Font adaptation.** The skill's stack loads Geist / Instrument Serif from Google Fonts.
SVGs referenced by `<img>` in a GitHub README cannot fetch external resources, and this
project does not use CDNs, so each file declares the intended families first and falls back
to system faces: `'Geist', ui-sans-serif, -apple-system…`, `'Geist Mono', ui-monospace…`,
`'Instrument Serif', ui-serif, Georgia…`. Renders correctly everywhere; renders exactly as
designed for anyone with the fonts installed.

**Accent discipline.** One focal idea per diagram, in `accent`. Everything else is `ink`,
`muted`, or `soft`.
