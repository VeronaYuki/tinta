# 07 — Workflow

How we build Tinta. The process is part of the curriculum: it imitates how a disciplined production team works.

## Roles

- **Verona** — product owner, developer, and reviewer. Decides what gets built, writes a growing share of the code, and nothing merges without her sign-off.
- **Claude** — pair partner and teacher. Sometimes writes tests for Verona to implement, sometimes navigates while she drives, sometimes implements for her to review. Never merges.

We work as a **pair**, and the mode of pairing depends on what the task can teach.

## Pairing model

Four modes, chosen per task (the roadmap task's nature decides — see the mapping below):

| Mode | How it works | Best for |
|---|---|---|
| 🏓 **Ping-pong TDD** | Claude writes one failing spec + a short mission brief → **Verona writes the code** until green → refactor together → next spec. As confidence grows, roles swap: Verona writes the specs, Claude implements. | Business logic: models, services, forms, money math, state machines — the strict-TDD layers |
| 🧭 **Verona drives, Claude navigates** | Verona writes everything. Claude sets direction, answers questions, and flags problems as they appear — but doesn't type. | Frontend components and views; the *second+* occurrence of any backend pattern |
| 📖 **Claude drives, Verona reviews** | Claude implements with heavy teaching annotations. Verona reviews line by line — and must leave **at least two questions or change requests** per PR (a review with nothing to say is a skipped workout). | Novel/complex wiring the first time it appears: Devise setup, ActionCable plumbing, CI pipelines, deploy configs |
| 🔍 **Solo + real review** | Verona implements an entire task alone. Claude reviews it like a rigorous senior colleague — real findings, follow-up questions, requested changes. | Repeat patterns after a 🏓 or 🧭 round — this is where reading/reviewing skills get trained from both sides |

Default mapping: infra & boilerplate → 📖; first-of-a-kind business logic → 🏓; frontend → 🧭; anything we've done twice → 🔍.

### The hint ladder (for when Verona is stuck)

Being stuck is where learning happens, so hints are opt-in and graded. Ask for the level you want:

1. **Concept** — "this is about X, re-read that part of the learning guide"
2. **Direction** — "look at how the Session spec handles this; the answer has the same shape"
3. **Code** — pseudocode or the actual line, with explanation

Rule of thumb: try ~20–30 minutes before taking a hint, and there's zero shame in level 3 — a hint understood beats an hour of frustration.

### Mechanics of a ping-pong task

1. **Kickoff** — Claude posts a short concept intro (2–3 min read) + the first failing spec + acceptance criteria for the task.
2. **Verona codes** until `bundle exec rspec` is green. Commits her own work under her own name.
3. **Refactor conversation** — is the green code good code? Verona proposes, Claude counter-proposes, best argument wins.
4. Repeat spec-by-spec until the task is done.
5. **Verona writes the PR description** — including the Teaching notes 🎓 *in her own words* (explaining a thing is the strongest way to retain it). Claude reviews the description too.

### Review direction

Whoever wrote less of the code reviews the PR. When Claude implemented (📖), Verona reviews and must find things to question. When Verona implemented (🏓/🧭/🔍), Claude gives a genuine review — praise where earned, findings where found — and Verona fixes before merge. Either way, Verona owns the merge button.

### Optional: bug-hunt mode 🐛

On request, Claude plants one deliberate, subtle flaw in a 📖 PR and says so upfront ("this PR contains one planted bug"). Verona's review has to find it. Never used silently, and never on financial logic — it's a training drill, not a trap.

## Git conventions

- Default branch: `main`. Always deployable — a red `main` is an incident.
- Branches: `phase-X/short-description` (e.g. `phase-1/devise-jwt-login`).
- Commits: imperative mood, small and meaningful (`Add Session overlap validation`). Conventional-commit prefixes optional but encouraged for practice: `feat:`, `fix:`, `test:`, `chore:`, `docs:`, `refactor:`.
- No force-pushes to `main`. Rebase feature branches instead of merge-commits from `main`.

## PR rules

1. **Small.** Target ≤ ~300 changed lines of production code (tests and docs don't count). If a task grows, split it.
2. **Generated code ships alone.** Generator/scaffold output (`rails new`, `create-vue`, lockfiles, `schema.rb`) goes in its **own PR**, untouched, with the command and every flag documented — the flags are the review surface, not the output. Hand-written code stacks on top in a separate PR that stays within the size limit. (Rule born in PR #1 → #2/#3.)
3. **One concern per PR.** A PR does one thing its title can state without "and".
3. **Template** — every PR description contains:

```markdown
## What
One paragraph: what this PR does.

## Why
The roadmap task (e.g. "Phase 2, PR 2.3") and the reason this exists.

## How
Key implementation decisions and any trade-offs taken.

## Teaching notes 🎓
The concepts this PR demonstrates, explained. Links to the relevant
Learning Guide section. This is the didactic heart of the project.

## How to verify
Exact steps: commands to run, URLs to click, what you should see.

## Risks
What could break, and how we'd notice.
```

4. **CI must be green** before review is requested.
5. **Review before merge, always.** Questions in review are answered in review (they're part of the learning record).

## Testing discipline (Hybrid TDD)

The rule of thumb: **the closer to business logic, the stricter the TDD.**

| Layer | Approach |
|---|---|
| Models: validations, state machines, money math, scopes | **Strict TDD** — failing spec first, watch it fail, make it pass, refactor |
| Services / forms / queries / adapters | **Strict TDD** |
| Controllers + serializers | Request specs, may be written after the endpoint (same PR) |
| Jobs | TDD the service the job delegates to; a thin job spec after |
| Frontend stores & composables | Vitest, test-first when logic is non-trivial |
| Frontend components | Component tests for behavior (not markup), written with or after |
| Critical user flows | Cypress E2E — login, book a session, accept a quote, activate a plan. Few and stable. |

**The TDD loop, as practiced here:**
1. 🔴 Write the smallest failing spec that expresses the next requirement. Run it. **Read the failure** — it must fail for the right reason.
2. 🟢 Write the least code that passes. Resist generalizing.
3. 🔵 Refactor with green tests. Then loop.

Hard rules:
- Jobs and crons must be **idempotent** — every job spec includes a "runs twice safely" example.
- External HTTP is never hit in specs — WebMock blocks it globally; SkinScore interactions use VCR cassettes.
- Every new model's spec asserts tenant scoping (custom matcher).
- Coverage is reported (SimpleCov) and watched, but there is no numeric gate — untested *business logic* fails review regardless of the percentage.

## Definition of Done (per PR)

- [ ] CI green (lint + tests, both apps if touched)
- [ ] Reviewed and approved
- [ ] Deployed to production after merge, and verified there (the "How to verify" steps, run against prod)
- [ ] No console errors / new Sentry noise
- [ ] Docs updated if behavior or architecture changed

## Shipping discipline

- Deploys happen on every merge to `main` — small, boring, frequent.
- Migrations must be safe with the **previous** code version still running (strong_migrations enforces most of it; the rest we review).
- Risky changes ship behind a feature flag, dark.
- If production breaks: fix-forward for small things, `git revert` for anything unclear. The revert PR gets a teaching note about what happened — incidents are curriculum.

## Cadence

No fixed sprints. The unit of progress is the phase; the unit of work is the PR. Each phase ends with a short retro note in the Notion project (what was learned, what surprised, what to revisit).
