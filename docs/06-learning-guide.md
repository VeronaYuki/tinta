# 06 — Learning Guide

Every concept this project is designed to teach, where you'll practice it, and a good free resource for each. Ordered roughly by when the roadmap hits them.

## 1. Rails fundamentals
**What:** MVC, the request lifecycle (Rack → middleware → router → controller), ActiveRecord, migrations, environments and configuration layers (`config/`, credentials, ENV).
**Where you'll practice:** every backend PR; Phase 0.2 sets it all up by hand.
**Resource:** [Rails Guides](https://guides.rubyonrails.org/) (read *Getting Started*, *Routing*, *Active Record Basics* first). The [Rails API docs](https://api.rubyonrails.org/) for everything else.

## 2. HTTP & REST API design
**What:** methods, status codes, headers, content negotiation, idempotency, resource modeling, versioning, pagination, error contracts, CORS (what a preflight request actually is).
**Where:** Phase 2 (the reference CRUD), CORS in Phase 1.4, rswag/OpenAPI in Phase 9.5.
**Resource:** [MDN HTTP docs](https://developer.mozilla.org/en-US/docs/Web/HTTP) and the [JSON:API spec](https://jsonapi.org/format/).

## 3. SQL & PostgreSQL
**What:** schema design, indexes (and when they're used — `EXPLAIN ANALYZE`), constraints, transactions and isolation, N+1 queries, aggregation (GROUP BY, window functions), full-text search, views.
**Where:** every model PR; explicitly in Phase 2.3 (FTS), 3.3 (N+1), 8.1–8.3 (aggregation, views, EXPLAIN).
**Resource:** [Use The Index, Luke](https://use-the-index-luke.com/) and [pgexercises.com](https://pgexercises.com/).

## 4. Authentication & authorization
**What:** sessions vs tokens, JWT structure (header/payload/signature — decode one by hand), token storage trade-offs (localStorage vs cookies, XSS vs CSRF), password hashing (bcrypt), role-based authorization, policy objects.
**Where:** Phase 1 entirely; Pundit policies grow through every phase after.
**Resource:** [jwt.io](https://jwt.io/introduction) + the OWASP cheat sheets on [session management](https://cheatsheetseries.owasp.org/cheatsheets/Session_Management_Cheat_Sheet.html) and [JWT](https://cheatsheetseries.owasp.org/cheatsheets/JSON_Web_Token_for_Java_Cheat_Sheet.html).

## 5. Multi-tenancy
**What:** isolation models (row-level vs schema vs database-per-tenant), `CurrentAttributes`, default scopes and their dangers, where tenancy leaks (jobs, consoles, rake).
**Where:** Phase 1.1/1.4; the custom RSpec matcher enforces it forever after.
**Resource:** search "Rails multi-tenancy row level vs schema" — read a couple of comparisons, then read our `MultiTenant` concern.

## 6. Testing & TDD
**What:** the red-green-refactor loop, test pyramid, unit vs request vs E2E, factories, mocking external HTTP (WebMock/VCR), coverage as a signal (not a goal), CI as gatekeeper.
**Where:** every PR. The hybrid-TDD rules are in [07 — Workflow](07-workflow.md). Phase 6.2 teaches VCR properly.
**Resource:** [Better Specs](https://www.betterspecs.org/) for RSpec style; *Growing Object-Oriented Software, Guided by Tests* if you want the book that defined the discipline.

## 7. Redis
**What:** what Redis actually is (in-memory data structures over a socket), its five uses in a typical Rails shop: job queues, cache store, pub/sub (ActionCable), locks/uniqueness, rate limiting. Persistence models (RDB/AOF) and why "no persistence" is survivable for some workloads and fatal for others.
**Where:** Phase 0.3 (run it), 3.5 (pub/sub), 5.2+ (queues), 8.2 (cache), 9.2 (rate limiting).
**Resource:** [Redis University RU101](https://university.redis.io/) (free) or just `redis-cli` + the [command docs](https://redis.io/commands/) — run `MONITOR` while the app works and watch.

## 8. Background jobs
**What:** why work leaves the request cycle, at-least-once delivery (jobs WILL run twice — idempotency is law), retries and backoff, queues and priorities, cron scheduling, fan-out patterns, the danger of enqueueing inside open transactions.
**Where:** Phase 5.2 (first cron), 6.6 (overdue batch), 7.2 (fan-out).
**Resource:** [Sidekiq wiki](https://github.com/sidekiq/sidekiq/wiki) — especially *Best Practices*.

## 9. WebSockets & real-time
**What:** what a websocket is vs HTTP, ActionCable's model (connection → channel → stream), Redis pub/sub as the broadcast bus, auth on connect, reconnection handling.
**Where:** Phase 3.5.
**Resource:** [Action Cable Overview](https://guides.rubyonrails.org/action_cable_overview.html) guide.

## 10. Frontend architecture (Vue)
**What:** Composition API, reactivity fundamentals (ref/computed/watch), Pinia store design, API-layer separation, DTO mapping, route guards, form validation architecture, component API design (the design system), print CSS.
**Where:** every frontend PR; the design system grows from Phase 2 on.
**Resource:** [Vue docs](https://vuejs.org/guide/) (read *Essentials* + *Composition API FAQ*), [Pinia docs](https://pinia.vuejs.org/).

## 11. State machines & domain modeling
**What:** why explicit states beat boolean soup, transitions with guards, events vs direct writes, callbacks vs services (and why callback chains rot), immutable financial history (renegotiation pattern).
**Where:** Phases 3–6 — five state machines of increasing consequence.
**Resource:** [AASM README](https://github.com/aasm/aasm) + Martin Fowler on [state machines](https://martinfowler.com/dslCatalog/stateMachine.html).

## 12. Money handling
**What:** why floats corrupt money, integer cents, rounding/remainder policies, formatting at the edge.
**Where:** Phase 5.1 and 6.4.
**Resource:** search "falsehoods programmers believe about money"; then read our `Money` helper and its specs.

## 13. HTTP integrations & resilience
**What:** timeouts (connect vs read), retries with backoff and their idempotency requirements, error taxonomies, circuit breakers, caching external responses, testing with recorded cassettes.
**Where:** Phase 6.1–6.3 (SkinScore is *designed* to be slow and flaky so you have to handle it).
**Resource:** the [Faraday docs](https://lostisland.github.io/faraday/) + search "release it stability patterns" for the concepts (timeout, retry, circuit breaker, bulkhead).

## 14. Docker & containers
**What:** images vs containers, Dockerfiles (layers, multi-stage builds, non-root users), Compose for local dev, volumes, networks, port mapping.
**Where:** Phase 0.3 (Compose), Phase 10.2 (production Dockerfile).
**Resource:** [Docker's get-started guide](https://docs.docker.com/get-started/) + read our Compose file line by line.

## 15. CI/CD
**What:** pipelines as code, service containers in CI, caching dependencies, quality gates (lint, tests, security scans), deploy-on-green, migration/release steps, backward-compatible migrations.
**Where:** Phase 0.5/0.7/0.8; hardened in Phase 9.
**Resource:** [GitHub Actions docs](https://docs.github.com/en/actions) — then read our workflows, they're short.

## 16. Networking, DNS & TLS
**What:** what happens when you type the URL (DNS resolution, TCP, TLS handshake, HTTP), record types (A/AAAA/CNAME), reverse proxies, ports and firewalls, Let's Encrypt/ACME, SSH.
**Where:** touched in Phase 0.8 (DNS for the deployed apps), hands-on for real in Phase 10.
**Resource:** [How DNS works (comic)](https://howdns.works/), Julia Evans' [networking zines](https://wizardzines.com/) — several are free.

## 17. Observability & operations
**What:** structured logging, error tracking, health checks, uptime monitoring, reading production logs under stress, backups and restore drills, runbooks, capacity limits.
**Where:** `/health` from Phase 0, Sentry + logging in Phase 9, full ops in Phase 10.
**Resource:** search "Google SRE book" (free online) — read the *Monitoring* and *Being On-Call* chapters.

## 18. Security basics
**What:** OWASP Top 10 as applied to Rails/SPA (injection, XSS, CSRF, IDOR — which multi-tenancy scoping prevents), secret management, rate limiting, dependency auditing.
**Where:** woven through; explicit pass in Phase 9.2.
**Resource:** [OWASP Top 10](https://owasp.org/www-project-top-ten/) + [Rails Security Guide](https://guides.rubyonrails.org/security.html).

---

## How to use this guide

Before each phase, skim the linked resource for that phase's focus topics (30–60 min, not a deep dive). Then build. Then come back and read deeper — the concepts stick when they attach to something you fought with.
