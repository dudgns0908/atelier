# Agent Team Sizing Rules

Authoritative rules Chief AI Officer must follow when designing the Phase 2 execution team. Violations are grounds for PR rejection at review time.

## Principle: Minimum Viable Team

Start from a baseline appropriate to the **project type**. Only specialize when justified.

## STEP 0 — Project Type Recognition (mandatory before sizing)

Before deciding the team, CAIO must classify the project against the following categories. Multiple may apply.

| Type | Signals | Baseline team |
|---|---|---|
| **API / Backend service** | No end-user UI; consumers are other systems / developers | Backend Engineer (1) |
| **CLI tool / Script** | Terminal-only, no GUI | Software Engineer (1) — generic implementer |
| **Service with user-facing UI** | Has a web/mobile/desktop interface real users interact with — SaaS, blog, dashboard, e-commerce, social, etc. | **Backend Engineer + Frontend Engineer + Product Designer (3)** |
| **Data pipeline / ETL / ML** | Batch processing, model training, no live UI | Data Engineer (or ML Engineer if model-centric) (1) |
| **Library / SDK** | Consumed by other developers via package | Software Engineer (1) |
| **Mobile app** | Native iOS/Android | Mobile Engineer (or platform-specific) + Product Designer (2) |
| **Hybrid (any of above + admin UI / dashboard)** | Combines a backend service with a user/admin UI | Backend Engineer + Frontend Engineer + Product Designer (3) |

**Service-with-UI default trio is non-negotiable**: Backend, Frontend, and Designer are *orthogonal domains* (different stacks AND different deliverables — code vs visual artifacts). Skipping Designer when the project has user-facing UI is a sizing defect — the result is functional UI with poor UX, which fails the project's user-vision.

If the project type is ambiguous (e.g., "blog with auto-generated content" — is it a service? CLI? both?), CAIO must:
1. Surface the ambiguity in chat with PM.
2. Ask PM whether the deliverable includes a website/app users visit (yes → service-with-UI trio applies).
3. Record the classification + justification in `docs/agents/team-composition.md`.

## Valid Specialization Triggers (exactly three)

Beyond the type-baseline above, additional specialization requires one of:

| Trigger | Example | Evidence Required |
|---|---|---|
| **Orthogonal domain** | Frontend vs Backend vs Design — fundamentally different stacks, deliverables, skillsets. | Named stacks/deliverables differ (e.g., React + TypeScript vs Kotlin + Spring vs Figma + design tokens). |
| **Critical expertise** | Security Engineer, Compliance Analyst, ML Engineer — failure mode is existential for the project. | Specific risk the generalist cannot adequately mitigate. |
| **Parallel track** | Two independent streams must progress simultaneously to meet the deadline. | Dependency graph shows the streams cannot be serialized within the schedule. |

## Forbidden Splits

- **Feature-level splits** within one stack. Do *not* create `Backend Engineer (Billing)` and `Backend Engineer (Auth)` and `Backend Engineer (Profile)`. One Backend Engineer covers multiple backend modules.
- **Seniority splits** ("Junior Backend" vs "Senior Backend") — agents have no real seniority; this is theater.
- **Duplicate labels** for the same role (`Backend Engineer` and `Server-Side Engineer` are identical).

## Naming Rules

- Real industry job titles only. LinkedIn test: if it's not a title real humans use on LinkedIn, reject.
- Domain qualifier in parentheses when necessary: `Backend Engineer (Payments)` is acceptable *only* if the "critical expertise" trigger is cited.
- File name: `<kebab-title>.md`. Parentheses removed: `backend-engineer-payments.md`.

### Recognized non-engineering implementation roles

Engineering roles use `docs/templates/software-engineer-template.md`. Non-engineering roles use `docs/templates/designer-template.md` (or future role-templates). Recognized real-title examples:

- **Product Designer** — owns end-to-end UX/UI: information architecture, interaction design, visual design, design system, usability validation. Default for service-with-UI projects.
- **UX Designer** — research-heavy, interaction + flow focused.
- **UI Designer** — visual + design-system focused (paired with UX Designer when the project warrants split).
- **Visual Designer** — brand, marketing surfaces, illustration.
- **Content Strategist** — copy, IA, editorial voice (use when product is content-heavy: blog, news, docs platform).
- **Data Engineer** — pipelines, warehouse, transformations.
- **DevOps Engineer / Platform Engineer / SRE** — infra, deployment, observability (only when infra demands cross a single-engineer threshold).
- **Mobile Engineer (iOS) / Mobile Engineer (Android)** — only when the project ships mobile apps and platform-specific expertise is justified.

If the role is real-job but unlisted, CAIO can still use it provided the LinkedIn test passes and a trigger is cited.

## Evidence Record

Every agent beyond the first `Software Engineer` is appended to `docs/agents/team-composition.md` with:

| Column | Required |
|---|---|
| Job title | Yes |
| File path | Yes |
| Trigger cited | Exactly one of: *orthogonal domain*, *critical expertise*, *parallel track* |
| Justification (≤3 sentences) | Yes |
| Added in milestone | Yes |
| Added by | `/atelier:init-project` or `/atelier:add-agent` |

## Reuse Check (precedes creation)

Before creating any agent, Chief AI Officer must run the `docs/process/capability-management.md` audit. If an existing skill or MCP server covers the proposed responsibility, reference it instead of creating a new agent.

## Soft Guidance (not a hard cap)

- If the total specialized implementation agent count passes **5**, pause and re-evaluate whether splits are truly orthogonal.
- If total passes **8**, the team is almost certainly over-designed. Chief AI Officer should propose a consolidation plan.
- User approval at Phase 1 STEP 5.5 and `/atelier:add-agent` invocations in Phase 2 serve as the governance gates.

## Review-Time Audit

At every PR review, Tech Lead checks whether the PR's author agent matches the responsibility boundary in `docs/agents/team-composition.md`. Out-of-scope work is grounds for `REQUEST_CHANGES`.
