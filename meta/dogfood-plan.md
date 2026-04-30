# Dogfood Plan

What real, lived dogfood looks like for atelier. The plan is **post-v1.0** — v1.0 GA shipped on automated guarantees + D1 (atelier-on-atelier) evidence; broader multi-domain dogfood is a v1.x hardening exercise that informs patch releases.

The automated portion (api-surface audit + migration end-to-end check) is wired into `tools/git-hooks/pre-push`. The **lived-experience** portion is what this plan covers — it cannot be faked by an LLM alone.

---

## Three projects, three domains, one milestone each

| Slot | Domain | Forge | Goal | Owner | Status |
|---|---|---|---|---|---|
| **D1** | atelier-itself | GitHub | Maintain atelier via atelier (every plugin change goes through `feature/<task-id>-*` → 3-tier change policy → atelier-validate gate → pre-push hook → merge). | maintainer | **Done as of v1.0** — plugin source git history IS the log. |
| **D2** | Web/SaaS app (small CRUD or content-publishing) | GitHub | Real `/atelier:init-project` STEP 0–6 → first milestone delivered → first retro. | needs human contributor | post-v1.0 |
| **D3** | Data pipeline OR CLI tool | GitHub or local-only | Same lifecycle. | needs human contributor | post-v1.0 |

D1 was the gate. D2 and D3 are recommended for v1.x stabilization; findings become v1.x.y patches.

---

## What "one milestone done" means per project

Each project must produce, end-to-end:

1. `/atelier:init-project` STEP 0–6 completed with `INIT-APPROVAL.md` user-signed.
2. ≥ 5 tasks decomposed via `/atelier:plan-milestone`, written as `docs/roadmap/tasks/t<NN>-*.md` files with valid frontmatter (atelier-validate user-project mode passes).
3. ≥ 5 PRs through the 3-reviewer cycle and merged. Solo-maintainer single-voice 3-lens template acceptable for solo projects per CONTRIBUTING.md.
4. `/atelier:milestone-checkpoint` produces `m<NN>-retro.md` with sections A–K filled.
5. ≥ 1 lessons-learned entry appended.

If atelier itself breaks during a project, that's a v1.x patch.

---

## Per-project log format

```markdown
# Dogfood log — <project> (D<N>)

- Init mode chosen (Quick / Standard / Thorough): _
- STEP 0.5 deviations from defaults: _
- STEP 1 (PM) — turns spent / surprises:
- STEP 2 (Architect) — surprises:
- STEP 3 (CAIO) — agent count / capabilities discovered:
- STEP 4 (PMO) — task count / scope-lock observed:
- STEP 5 (Tech Writer) — generated CLAUDE.md ergonomics:
- STEP 5.5 — approval friction:

# m01 (or m<NN>) execution

- Tasks: <count>
- PRs: <count merged>
- Time spent: <approx hours>
- atelier breakages found: <list with severity>
- "this should work but doesn't" findings: <list>
- atelier-on-the-fly improvements made: <list of patches>

# Retrospective (m<NN>-retro.md link)

(linked)

# Top 3 v1.x priorities surfaced by this dogfood

1. _
2. _
3. _
```

These logs feed v1.x patches. Aggregate findings reviewed at every minor release.

---

## Honest constraints

- D1 is achievable solo and was completed for v1.0.
- D2 / D3 require external contributors OR the maintainer running side projects with discipline.
- "Documentation pass by another author" requires a second human.
- Involvement-level coverage (1–4) requires diverse user behaviors.

These items are intentionally listed as not-achievable-autonomously. Post-v1.0 handoff (when external contributors arrive) inherits the unfinished items, not a false-positive "all done."

---

## See also

- `meta/v1-api-surface.md` — what's frozen at v1.0.
- `meta/version-history.md` — upgrade + breaking changes by version.
- `meta/ROADMAP.md` — overall v1.0 plan and v1.x outlook.
- `bin/atelier-api-audit` — automated surface check.
- `tests/verify-migration.sh` — migration path check.
- `tests/v1-acceptance.sh` — single-command GA-readiness gate.
