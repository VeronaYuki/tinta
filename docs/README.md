# Tinta — Documentation

This folder is the source of truth for what Tinta is, how it is built, and in what order. Read in sequence the first time; after that, each doc stands alone.

| Doc | What it answers |
|---|---|
| [01 — Vision & Concept](01-vision-and-concept.md) | What are we building and for whom? |
| [02 — Reference Architecture](02-reference-architecture.md) | Which production patterns are we deliberately imitating, and what do the paid pieces get replaced with? |
| [03 — Domain Model](03-domain-model.md) | Entities, relationships, state machines, money, tenancy. |
| [04 — Architecture](04-architecture.md) | System design, stack decisions with rationale, auth flow, infra and deploy pipeline. |
| [05 — Roadmap](05-roadmap.md) | Phased plan, PR-sized tasks, definitions of done. |
| [06 — Learning Guide](06-learning-guide.md) | Every concept this project teaches, where you'll practice it, and free resources. |
| [07 — Workflow](07-workflow.md) | How we work: TDD rules, git/PR conventions, review checklist, shipping discipline. |

## Project principles

1. **Ship first.** The app is deployed to production in Phase 0, before any real feature exists. Every PR afterwards must keep production working.
2. **Small PRs, always reviewed.** Nothing merges without review. PRs are scoped so they can be read and understood in one sitting.
3. **Tests are not optional.** Business logic is written test-first (hybrid TDD — see [07 — Workflow](07-workflow.md)). CI is the gatekeeper.
4. **Every PR teaches something.** PR descriptions include a *teaching notes* section explaining the concepts involved.
5. **Free tier only.** Paid production services are replaced by free alternatives; the trade-offs are documented, because understanding those trade-offs is part of the learning.
