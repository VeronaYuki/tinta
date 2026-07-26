# 01 — Vision & Concept

## The pitch

**Tinta** is a management platform for tattoo studios, with a built-in financing product for expensive pieces.

Tattoo studios in Brazil run on WhatsApp, paper notebooks, and Instagram DMs. Scheduling is chaotic, quotes are informal, and large projects (a full sleeve can cost R$ 3.000–10.000 and take 5+ sessions) are paid through improvised installment agreements that nobody tracks. Tinta gives studios:

1. **A management dashboard (the SaaS half)** — clients, artists, session calendar, project tracking on a visual body map, quotes with line items.
2. **A financing product (the credit half)** — split an approved quote into installments, run a (mock) credit check on the client, track payments, chase overdue installments, renegotiate defaulted plans.

The two halves mirror how real vertical-SaaS + embedded-fintech products are structured, which is exactly the architecture this project exists to teach.

## Personas

| Persona | Role in the system |
|---|---|
| **Studio owner** | Tenant admin. Manages artists, sees financials, approves financing plans. |
| **Tattoo artist** | Works the calendar, manages their projects and sessions, records session progress. |
| **Front desk** | Books sessions, registers clients, sends quotes. |
| **Client** | The person getting tattooed. Not a system user initially — they exist as records. (A client-facing portal is a stretch goal.) |

## Core concepts

- **Studio** — the tenant. All data belongs to a studio; studios never see each other's data.
- **Client** — a person, identified by CPF, with contact info.
- **Project** — a tattoo project ("black-and-grey full sleeve, right arm"). Has a style, target body regions, an estimated number of sessions, and a lifecycle from idea to healed skin.
- **Body map** — the visual model of the body divided into regions (the domain's signature feature). Each project marks which regions it covers and their status. This is rendered as an interactive SVG in the frontend.
- **Session** — a calendar appointment binding artist + client + project + a time slot. Sessions get confirmed, completed, no-showed, canceled.
- **Quote** — a priced proposal for a project: line items (per session, per piece, materials), discount, total. Sent to the client, accepted or expired.
- **Payment plan** — how an accepted quote gets paid: upfront, or split into N installments with a down payment. The financing half of the product.
- **Installment** — one slice of a payment plan, with amount, due date, and a paid/overdue lifecycle.
- **Credit check** — before approving an installment plan, the studio runs a credit check on the client through "SkinScore", our fictional credit bureau (a mock external API — built to teach HTTP integrations, adapters, and resilient client code).

## MVP feature list (what "done enough to demo" means)

- [ ] Studio signup, user login (JWT), roles (owner / artist / front_desk)
- [ ] Clients CRUD with search and pagination
- [ ] Artists management
- [ ] Session calendar: create, confirm, complete, cancel, no-show — with live updates (websockets)
- [ ] Projects with body-map region selection and per-region status
- [ ] Quotes: line items, totals, send/accept lifecycle
- [ ] Payment plans: cash or installments, mock credit check, installment schedule
- [ ] Overdue detection (daily background job) + email reminders
- [ ] Studio dashboard: revenue, pending installments, upcoming sessions (cached)

## Explicit non-goals (for now)

- Real payment processing (no gateway integration — money movement is recorded, not executed)
- Client-facing app / portal
- Mobile apps
- Multi-language (pt-BR UI copy is fine, but no i18n infrastructure until needed)
- Search infrastructure beyond Postgres (no Elasticsearch)
- Event streaming (no Kafka) — may appear as a late stretch phase in simplified form

## Naming

Working name **Tinta**. The fictional credit bureau is **SkinScore**. The design-system components use the `Tin` prefix (`TinButton`, `TinModal`, …).
