# User Involvement Levels

Selected once at STEP 0.5 A of `/atelier:init-project`. Recorded in `operating-preferences-template.md`. Enforced by Project Manager and Conductor throughout Phase 2.

## Levels

### 1. Fully Autonomous
- User approves Phase 1 output at STEP 5.5.
- User is notified of merged PRs via `atelier-notify` (if communication channel configured) but does not need to approve.
- Milestone checkpoints still run but auto-approve after a grace period unless the user intervenes.
- Recommended for: well-scoped projects with trusted teams and low reversibility cost.

### 2. Milestone Checkpoints *(default)*
- User approves Phase 1 output at STEP 5.5.
- At each milestone boundary, `/atelier:milestone-checkpoint` runs and requires explicit user approval before the next milestone starts.
- Individual PRs merge autonomously (three-reviewer gate still applies).
- Recommended for: most projects. Balances autonomy and oversight.

### 3. PR-Level Checkpoints
- User approves Phase 1 output at STEP 5.5.
- Every merged PR requires a user sign-off (added as a fourth approval after the three reviewers).
- Recommended for: sensitive domains (security, payments, regulated systems) or early project establishment.

### 4. Detailed Supervision
- User approves Phase 1 output at STEP 5.5.
- Before any code is written for a task, the implementation agent posts an implementation plan and the user signs off.
- Every merged PR requires user sign-off.
- Recommended for: research prototypes where direction shifts frequently, or when the user wants to learn the codebase in real time.

## Enforcement

- **Project Manager** pauses or resumes task flow per the selected level.
- **Conductor** (main thread) routes checkpoint prompts to the user via the configured communication channel.
- Deviations are escalations: `/atelier:escalate` is the only mechanism to change behavior mid-project.

## Change Policy

Involvement level can be changed mid-project by updating `operating-preferences-template.md` and announcing the change. The change takes effect on the next task boundary — not mid-PR.
