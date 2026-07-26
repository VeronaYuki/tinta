# 05 — Roadmap

## Principles

- **Phase 0 ends with the app in production.** Everything after that is iterating on a live system — which forces the discipline of never breaking what's running.
- **Each task below is one PR** (occasionally two). PRs stay small enough to review in one sitting.
- **A phase is done** when its Definition of Done checks pass and production still works.
- Phases are sequential, but tasks inside a phase can be reordered.

---

## Phase 0 — Hello, production 🚀
*Goal: empty-but-deployed full stack. Learning focus: project setup, CI, deploys, environments.*

| # | PR | Teaches |
|---|---|---|
| 0.1 | Docs folder (this one), README, .gitignore, license | Project hygiene |
| 0.2 | Rails API app in `backend/` (`rails new --api`), Postgres config, health endpoint `GET /health` | Rails structure, Rack, config layers |
| 0.3 | Docker Compose for local Postgres + Redis | Containers, ports, volumes |
| 0.4 | RSpec + FactoryBot + RuboCop wired, first spec (health endpoint) | Test harness anatomy |
| 0.5 | Backend CI: GitHub Actions running RuboCop + RSpec with Postgres/Redis services | CI pipelines, service containers |
| 0.6 | Vue 3 app in `frontend/` (Vite), Tailwind, landing page showing API health | SPA scaffold, dev proxy |
| 0.7 | Frontend CI: ESLint + Vitest with one smoke test | JS toolchain |
| 0.8 | Deploy backend to Render + Neon; deploy frontend to Cloudflare Pages | DNS, env vars, release steps, migrations on deploy |

**DoD:** visiting the public URL shows the landing page reporting live API status; CI green; both deploys automatic from `main`.

---

## Phase 1 — Auth & tenancy 🔐
*Learning focus: Devise, JWT, CORS, CurrentAttributes, Pundit, the multi-tenant mental model.*

| # | PR | Teaches |
|---|---|---|
| 1.1 | `Studio` + `User` models (TDD), roles enum, MultiTenant concern + custom RSpec matcher | Migrations, model specs, concerns |
| 1.2 | Devise + devise-jwt, login/logout endpoints, request specs | Sessions vs tokens, JWT anatomy |
| 1.3 | Signup flow (studio + owner in one transaction — form object) | Transactions, form objects |
| 1.4 | `Current` attributes set from JWT; default tenant scope; CORS locked to frontend origin | Request lifecycle, middleware |
| 1.5 | Pundit setup + first policy; seed data script | Authorization vs authentication |
| 1.6 | Frontend: login page, auth store, axios interceptors, route guards, 401 handling | Token storage trade-offs, guards |

**DoD:** two seeded studios can log in on production and cannot see each other's data (verified by request specs + manual check).

---

## Phase 2 — Clients: the reference CRUD 📇
*Learning focus: the full vertical slice every later feature copies. This phase is the template.*

| # | PR | Teaches |
|---|---|---|
| 2.1 | `Client` model TDD: CPF validation, uniqueness per studio, soft delete | Value validation, discard |
| 2.2 | Clients endpoints: create/update via form objects, JSON:API serializer, request specs | REST design, status codes |
| 2.3 | Index with search (pg_search) + pagination (Kaminari) via query object | SQL LIKE vs FTS, LIMIT/OFFSET |
| 2.4 | Frontend: clients list (TinTable), search, pagination | Store + api + mapper slice |
| 2.5 | Frontend: client form (vee-validate + zod), create/edit/archive | Form UX, optimistic vs pessimistic updates |

**DoD:** full client management usable in production; the PR sequence documented as "how to add a resource".

---

## Phase 3 — Calendar & sessions 📅
*Learning focus: state machines, time handling, websockets, N+1s.*

| # | PR | Teaches |
|---|---|---|
| 3.1 | `Project` model (minimal: title, client, artist) + `Session` model TDD with AASM | State machines, guards, callbacks |
| 3.2 | Overlap validation + timezone-safe time handling | Time zones (the classic pain) |
| 3.3 | Sessions endpoints + week-view query object (eager loading, bullet) | N+1 queries, includes |
| 3.4 | Frontend: week calendar view, create/edit session drawer | Complex component state |
| 3.5 | ActionCable: `StudioCalendarChannel`, broadcast on session changes; frontend subscription | Websockets, Redis pub/sub |
| 3.6 | Session lifecycle UI (confirm/complete/no-show/cancel) + policies | UI ↔ state machine mapping |

**DoD:** two browsers logged into the same studio see each other's calendar changes live, in production.

---

## Phase 4 — Projects & the body map 🎨
*Learning focus: richer domain modeling, SVG interaction, computed state.*

| # | PR | Teaches |
|---|---|---|
| 4.1 | Project full lifecycle (AASM) + `ProjectRegion` model TDD | Enum design, composite uniqueness |
| 4.2 | Project endpoints + nested regions (JSON:API relationships) | Nested resources |
| 4.3 | Frontend: interactive SVG body map component (select regions, show status) | SVG, component API design |
| 4.4 | Project detail view: sessions history, region status board | Aggregating state |
| 4.5 | Auto-transitions: first completed session → `in_progress`; artist project list | Cross-model callbacks done safely (service, not callback soup) |

**DoD:** a project's body map is visible and editable in production; the SVG body map makes a great screenshot for posting.

---

## Phase 5 — Quotes 💰
*Learning focus: money math, computed totals, document-style resources.*

| # | PR | Teaches |
|---|---|---|
| 5.1 | `Quote` + `QuoteItem` TDD: integer-cents math, totals, discount rules | Money as integers, rounding policy |
| 5.2 | Quote lifecycle (AASM) + expiry cron job (sidekiq-cron, first scheduled job) | Cron, idempotent jobs |
| 5.3 | Quote endpoints + printable quote view (frontend print CSS) | Print stylesheets (cheap PDF substitute) |
| 5.4 | Frontend: quote builder (line items, live totals) | Derived state in stores |

**DoD:** a quote created in production expires automatically when `valid_until` passes.

---

## Phase 6 — Financing: SkinScore & payment plans 🏦
*Learning focus: HTTP integrations done right, adapters, resilience, fintech state machines. The heart of the credit half.*

| # | PR | Teaches |
|---|---|---|
| 6.1 | SkinScore mock bureau: a tiny Sinatra/Rack app in `skinscore/` (deployed as a second free Render service) — deterministic scores by CPF, artificial latency and error rates | Building an API from the consumer's perspective |
| 6.2 | `adapters/skin_score/`: Faraday client with timeouts, retries, error classes; WebMock/VCR specs | Resilient HTTP clients |
| 6.3 | `CreditCheck` model with 30-day cache-by-table + `PaymentPlans::RunCreditCheck` service | Caching with TTL, idempotency |
| 6.4 | `PaymentPlan` + `Installment` TDD: split math, remainder policy, lifecycle | The fintech core |
| 6.5 | Plan endpoints + activation flow (credit check gate, Pundit: owner-only) | Orchestrating services |
| 6.6 | Daily overdue-detection cron + plan default rules (N overdue → defaulted) | Batch jobs, scale thinking |
| 6.7 | Frontend: financing tab — plan wizard, installment schedule, credit check result | Multi-step forms |
| 6.8 | Renegotiation: new plan from defaulted plan, old installments frozen | Immutable financial history |

**DoD:** end-to-end in production: quote → accept → credit check (live HTTP to SkinScore) → active plan → cron marks an installment overdue → renegotiate.

---

## Phase 7 — Notifications 📬
*Learning focus: async side-effects, email infrastructure, background job patterns.*

| # | PR | Teaches |
|---|---|---|
| 7.1 | Email setup: Resend + ActionMailer, `letter_opener` in dev, base template | SMTP vs API email, deliverability basics |
| 7.2 | Session reminder: daily cron enqueues per-session jobs (fan-out pattern) | Job fan-out, uniqueness by hand |
| 7.3 | Installment due / overdue emails | Event-driven side effects |
| 7.4 | Notification preferences per studio (settings jsonb) + kill-switch feature flag | Feature flags in practice |

**DoD:** reminder emails arrive for tomorrow's production sessions; a flag can disable all sending instantly.

---

## Phase 8 — Dashboard & performance 📊
*Learning focus: aggregation SQL, Redis caching, measuring before optimizing.*

| # | PR | Teaches |
|---|---|---|
| 8.1 | Dashboard endpoint: revenue by month, pending/overdue totals, upcoming sessions — raw SQL / Arel aggregates | GROUP BY, window functions |
| 8.2 | Redis caching layer (`Rails.cache`) with explicit invalidation on writes | Cache keys, invalidation pain |
| 8.3 | A database view (Scenic) for the financial summary + benchmark vs live aggregation | SQL views, EXPLAIN ANALYZE |
| 8.4 | Frontend dashboard with stat cards + simple charts | Data viz |

**DoD:** dashboard loads < 300ms warm from production; we can show the EXPLAIN output before/after.

---

## Phase 9 — Hardening 🛡️
*Learning focus: what "production-ready" actually means.*

| # | PR | Teaches |
|---|---|---|
| 9.1 | Sentry (backend + frontend), structured logging with request/studio IDs | Observability |
| 9.2 | Brakeman + bundler-audit in CI; fix findings; rate limiting (rack-attack) on auth | AppSec basics |
| 9.3 | Postgres backups (Neon PITR + manual dump script), restore drill | Backups are only real if restored |
| 9.4 | Load test with `oha`/`k6` free tier against Render; document limits | Capacity thinking |
| 9.5 | rswag: OpenAPI docs published | API documentation |

**DoD:** a forced exception shows up in Sentry with a studio ID; a restore drill has actually been executed.

---

## Phase 10 — The great migration: VPS + Kamal 🚢
*Learning focus: servers, networking, DNS, TLS, Docker in production. The capstone.*

| # | PR/Task | Teaches |
|---|---|---|
| 10.1 | Provision Oracle Cloud Always Free VM, SSH hardening, firewall (ufw) | Linux server admin, ports |
| 10.2 | Dockerfile for the Rails app (multi-stage, non-root) | Production images |
| 10.3 | Kamal config: deploy API + separate Sidekiq process + Postgres + Redis as accessories | Orchestration, service discovery |
| 10.4 | DNS + TLS via kamal-proxy/Let's Encrypt; migrate frontend or keep on Cloudflare | DNS records, certificates, reverse proxies |
| 10.5 | Data migration Neon → self-hosted Postgres, cutover plan, rollback plan | Zero(ish)-downtime migrations |
| 10.6 | Post-migration: backups, monitoring, the "3 AM incident" runbook | Operating what you own |

**DoD:** production runs on the VPS; the PaaS setup is decommissioned; a written runbook exists.

---

## Stretch ideas (unordered, post-Phase 10)

- Extract SkinScore consumption to an **event-driven** flow (outbox table + poller) to simulate messaging between services
- Client-facing portal (view sessions, accept quotes, pay installments — mock payment)
- Artist commission tracking (percentage per completed session)
- Full-text search across clients/projects with weighted ranking
- A second frontend surface (public studio page with booking request form)
