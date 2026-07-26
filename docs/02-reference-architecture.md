# 02 — Reference Architecture

Tinta deliberately imitates the architecture of production Brazilian vertical-SaaS + embedded-fintech systems (multi-tenant Rails monolith + Vue SPA). None of the patterns below are proprietary — they are industry-standard Rails/Vue practice — but seeing *why* each exists is the point of this project.

## Backend patterns we adopt

| Pattern | What it is | Why production apps use it | Where Tinta uses it |
|---|---|---|---|
| **Service objects** | One class per business operation with a single `.call` | Keeps controllers and models thin; operations become testable units | `app/services/` — e.g. `PaymentPlans::Activate` |
| **Form objects** | `ActiveModel::Model` classes that validate + persist complex input | Controller params → one object that owns validation for a use case | `app/forms/` — e.g. `Quotes::CreateForm` |
| **Query objects** | Classes that build filtered/paginated ActiveRecord scopes | Complex filtering stays out of controllers and models | `app/queries/` — e.g. `SessionsQuery` |
| **Adapter layer** | One namespace per external service: client + payload builders + response parsers | Third-party APIs change and fail; adapters isolate the blast radius | `app/adapters/skin_score/` (mock bureau) |
| **State machines (AASM)** | Explicit states + named transitions + guards + callbacks | Business lifecycles (loan states, appointment states) must be impossible to corrupt | `Project`, `Session`, `Quote`, `PaymentPlan`, `Installment` |
| **JSON:API serializers** | Standardized `{data: {id, type, attributes}}` responses | Predictable contract between backend and frontend teams | `app/serializers/` |
| **Money as integer cents** | `amount_cents: 350000` = R$ 3.500,00. Never floats. | Floats corrupt money math; integer cents is the fintech standard | Every monetary column |
| **Row-level multi-tenancy** | Every table carries `studio_id`; a `Current` attributes object holds the request's tenant; default scopes filter by it | Cheapest isolation model; the interesting part is where it *leaks* (jobs, consoles) and how to defend | `Current.studio` + `MultiTenant` concern |
| **Request specs as the main integration layer** | Test the full HTTP stack per endpoint, few controller/system tests | Highest confidence per test-second spent | `spec/requests/` |
| **Background jobs + cron** | Sidekiq workers on Redis queues; scheduled jobs for recurring work | Anything slow or time-based leaves the request cycle | Overdue detection, reminders, email |
| **ActionCable (websockets)** | Server pushes events to subscribed clients over Redis pub/sub | Calendars and dashboards need live updates | Session changes broadcast to the studio's calendar |
| **ENV-based feature flags** | `FF_*` env vars checked by a tiny module | Decouple deploy from release; ship dark, then enable | `FeatureFlag.enabled?(:financing)` |
| **Encrypted credentials + `.env`** | Rails credentials for secrets, dotenv locally | Secrets never in git | `config/credentials.yml.enc` |
| **Soft delete (discard)** | `discarded_at` timestamps instead of `DELETE` | Auditability; undelete; referential integrity | Clients, projects |
| **Audit trail (paper_trail)** | Row-level change history | "Who changed this installment?" is a real question in fintech | Financial models |

## Frontend patterns we adopt

| Pattern | Description | Where Tinta uses it |
|---|---|---|
| **API layer per resource** | `src/api/clients.js` exports methods wrapping a shared axios instance | All backend communication |
| **Pinia store per domain** | `useClientsStore`, `useSessionsStore` — views never call axios directly | All state |
| **DTO mappers** | Functions converting API JSON:API payloads ↔ frontend shapes | Decouples UI from backend contract |
| **Design-system components** | `Tin*` prefixed components in `src/components/design-system/` | Consistent UI, teaches component API design |
| **Route guards + policy checks** | Router `beforeEach` for auth, role checks for authorization | Private routes |
| **JWT in `Authorization` header** | Token from login stored client-side, injected by axios interceptor, 401 → logout | Auth flow |

## The paid → free substitution map

Production systems in this space lean on paid infrastructure. Part of the learning is understanding what those services do — by replacing each with a free equivalent and feeling the trade-off.

| Production (paid) | What it does | Tinta uses instead | Trade-off we accept |
|---|---|---|---|
| Sidekiq Pro/Enterprise | Reliable job fetching, unique jobs, cron | **Sidekiq OSS + sidekiq-cron** | No super_fetch (jobs can be lost on hard kill); uniqueness done by hand where needed |
| Heroku / AWS ECS | Managed containers | **Render free tier** → later **VPS + Kamal** | Cold starts after idle; fewer knobs |
| AWS RDS Postgres | Managed Postgres | **Neon free tier** | 0.5 GB storage, autosuspend |
| AWS ElastiCache / Redis Cloud | Managed Redis | **Render Key Value free (25 MB)** | No persistence — queues are lost on restart (acceptable: our jobs are re-derivable) |
| Elasticsearch + Chewy | Full-text search | **Postgres full-text search (`pg_search`)** | Less powerful ranking; fine at our scale, and teaches Postgres deeper |
| Kafka (Karafka) | Event streaming between services | **Skipped**; late stretch phase may simulate with an outbox table + poller | We learn the *concept* without the operational cost |
| Sentry (paid tiers) | Error tracking | **Sentry free tier** | Lower quota — plenty for us |
| New Relic / Datadog / AppSignal | APM | **Rails logs + `/health` endpoint + free uptime monitor** | No fancy dashboards; we learn to read logs first |
| Twilio / WhatsApp / SMS vendors | Client notifications | **Email via Resend free tier** (+ `letter_opener` in dev) | Email instead of WhatsApp; same async-notification architecture |
| S3 | File storage | **ActiveStorage local disk** first; free S3-compatible bucket (Cloudflare R2 free tier) when we deploy file uploads | Two storage backends teaches the abstraction |
| Clicksign (e-signature) | Signed documents | **Skipped** (quote acceptance is a state transition, not a signature) | — |
| Mixpanel / analytics stack | Product analytics | **Skipped** | — |
| Codecov / SonarCloud | Coverage & quality dashboards | **SimpleCov output + GitHub Actions artifacts** | We read the reports ourselves |

## What we intentionally do differently

1. **Monorepo.** Production systems here are typically multi-repo (per app). We keep `backend/` and `frontend/` in one repo so every PR can show both sides of a feature and review stays in one place. The deploy pipeline treats them as independent units — which teaches the same lessons.
2. **One backend, namespaced by domain.** Instead of two backends (SaaS + credit) talking over HTTP/shared DB/events, Tinta is a single Rails app with `studio/` and `financing/` domains kept deliberately decoupled. A late stretch phase extracts SkinScore (the mock bureau) into a real second service to experience service-to-service communication.
3. **Authorization done properly with Pundit from day one** — production codebases often accrete scattered permission checks; we get to start clean and feel why the discipline matters.
