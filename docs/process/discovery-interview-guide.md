# Discovery Interview Guide

Used by Product Manager in Phase 1 STEP 1.

**★ Ask exactly ONE question per turn. ★** Never list multiple questions in one message, even within the same round. The rounds below are *organizational groupings* of related questions — not chunks to be posted as a single message. After each answer, optionally follow up to clarify, then proceed to the next single question.

Anti-patterns:
- "Please answer the following: 1) ... 2) ... 3) ..."
- Bulleted lists of multiple questions in one turn.
- Embedding 2 questions in a single sentence ("What's the vision **and** target users?").

## Round 1 — Vision & Purpose

1. In one or two sentences, what is this project? (The elevator pitch.)
2. What outcome does success produce? (Not a feature list — an outcome.)
3. Who benefits if this exists? Who suffers if it doesn't?
4. Why build this *now*?
5. What is the single most important thing this project must do well?

## Round 2 — Users & Stakeholders

1. Who will use this? (Roles, not names.)
2. Who decides whether it ships? Who signs off?
3. Are there regulators, auditors, or compliance stakeholders involved?
4. Who else's workflows are affected even if they don't use it directly?
5. Are there anti-users (people we specifically do not want using it)?

## Round 3 — Core Features & Deliverables

1. If you could only ship three capabilities, what are they?
2. What does the user do in the first 60 seconds of using this?
3. Is there an existing product/process this replaces, augments, or competes with?
4. What is explicitly **out of scope** for v1?
5. What counts as v1 being "shipped"?

## Round 4 — Success Criteria (measurable)

1. How do we measure adoption?
2. How do we measure quality? (Latency, accuracy, uptime, etc.)
3. How do we measure user success? (Task completion, time saved, error rate dropped.)
4. What is an unacceptable outcome we must prevent?
5. Where will we observe these metrics? (Dashboard, survey, analytics.)

## Round 5 — Constraints

1. What is the target delivery date and who set it?
2. What is the budget ceiling and who holds it?
3. What technology is required or forbidden? (Cloud provider, language, licensing.)
4. What regulations apply? (GDPR, 개인정보보호법, 전자금융거래법, SOC2, HIPAA, etc.)
5. Team capacity: how many humans are available and in what roles?

## Round 6 — Existing Solutions & Differentiation

1. Have you or others tried to solve this before? What happened?
2. What off-the-shelf products solve this partially? Why aren't you using them?
3. What differentiates this attempt from prior work?
4. Are there open-source projects we should reuse or fork?
5. What is the cost of being "almost as good" as an existing solution?

## Probing Discipline

For every answer:
- If vague → ask for a concrete example.
- If metric is missing → ask how they'd measure it.
- If assumption is implicit → surface it and mark `assumption:unconfirmed`.
- If answer contradicts a prior answer → flag for reconciliation.

Never move to the next round until the current round's artifact (section of `docs/requirements/*.md`) is written.
