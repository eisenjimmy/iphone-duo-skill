# Security policy

## What this repository is

Markdown, JSON, and two shell scripts. It ships no compiled artifact, no dependency, and no
network service. The realistic risk surface is small but not zero.

## What counts as a vulnerability here

- **Prompt injection** — content crafted so that an agent loading the skill takes an
  instruction from the skill that the maintainers did not intend.
- **Malicious guidance** — a rule that would lead an agent to write insecure code (disabling
  ATS, weakening a keychain policy, leaking data to an outer-display accessory).
- **Script defects** — command injection or destructive behavior in `audit-duo.sh` or
  `verify-manifest.sh`. Both are read-only by design: they must never write to, or execute
  anything from, the audited project.

## Reporting

Use **GitHub Security Advisories** (Security → Report a vulnerability) for anything
sensitive. For everything else, open a normal issue.

Please include the file, the exact content, and the behavior you observed. Expect a first
response within 7 days.

## Notes for users

- `audit-duo.sh` **reads** the path you give it and writes nothing. Review it before running
  it against a private codebase — it is ~90 lines.
- `verify-manifest.sh` makes outbound HTTPS requests to `developer.apple.com` only. Run it
  with `OFFLINE=1` to skip all network access.
- Installing a skill grants an agent instructions, not permissions. It still operates under
  whatever tool permissions your harness enforces.
