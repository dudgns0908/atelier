# Maintainer Documentation (`meta/`)

This top-level `meta/` directory holds **plugin-development documents only** — for maintainers and prospective contributors of `atelier` itself.

End-users who install atelier in their projects do **not** need to read anything here. The agents, skills, and hooks loaded into a user session never reference `meta/*` files. Plugin user-facing documentation lives entirely under [`../docs/`](../docs/).

> **Why a separate `meta/` directory?** The two audiences (atelier users vs atelier maintainers) read disjoint sets of docs. Mixing them in one tree (the previous `docs/maintainers/` location) created cognitive overhead and bloated user installs. `meta/` is a clear "you are now in plugin-development territory" signal — moved in v0.9.

> **No `CHANGELOG.md` by design** — release history lives on the forge (GitHub Releases), per-version migration recipes live in [`version-history.md`](version-history.md). User projects MAY maintain their own CHANGELOG (the `/atelier:release` skill writes one); the plugin source itself does not.

## Contents

| File | Purpose |
|---|---|
| [`ROADMAP.md`](ROADMAP.md) | Versioned plan from current pre-GA to v1.0 GA. Updated each minor release. |
| [`GOVERNANCE.md`](GOVERNANCE.md) | How decisions are made: roles, RFC process, compatibility commitments. |
| [`version-history.md`](version-history.md) | Combined upgrade guide + breaking-changes catalog since v0.1. |
| [`v1-api-surface.md`](v1-api-surface.md) | Frozen surfaces at v1.0 GA (skills / agents / bin/* / hook contracts / file paths / frontmatter / status JSON). |
| [`dogfood-plan.md`](dogfood-plan.md) | What the lived-experience portion of v0.9 RC looks like (D1 / D2 / D3 slot definitions). |

## Related top-level files (also maintainer-facing)

These remain outside `meta/` either because OSS convention expects them at root, or because tooling reads them from a fixed path:

- [`../CONTRIBUTING.md`](../CONTRIBUTING.md) — contribution flow (3-tier change policy, dev setup, PR process).
- [`../CODE_OF_CONDUCT.md`](../CODE_OF_CONDUCT.md) — community standards.
- [`../SECURITY.md`](../SECURITY.md) — vulnerability disclosure.
- [`../CLAUDE.md`](../CLAUDE.md) — maintainer-mode runtime manual (loaded when working ON atelier itself; user projects load their own generated CLAUDE.md instead).
- [`../tools/git-hooks/`](../tools/git-hooks/) — pre-push hook + setup for maintainers.
- [`../tools/dev-setup.sh`](../tools/dev-setup.sh) — one-time dev environment bootstrap.

## User-facing files (NOT maintainer-only) — for context

These are what the plugin actually ships to users:

- `../README.md` / `../README.ko.md` — entry point + quickstart.
- `../LICENSE` / `../NOTICE.md` — legal.
- `../agents/*.md` — 8 default agents.
- `../skills/*/SKILL.md` — 11 user skills + bundled skill-creator.
- `../hooks/hooks.json` — 12 hook handlers.
- `../bin/*` — 11 helpers.
- `../docs/process/`, `../docs/templates/`, `../docs/flows/`, `../docs/README.md` — process rules / templates / flow diagrams referenced by agents.
- `../.claude-plugin/plugin.json` — manifest.

If you're a user, ignore `meta/` and read [`../README.md`](../README.md) instead.
