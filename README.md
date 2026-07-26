# Tinta 🖋️

**Tattoo studio management + financing platform** — a full-stack learning project built from scratch.

Tinta is a SaaS for tattoo studios: artists, clients, session scheduling, body-map project tracking, quotes, and installment-based financing for big pieces. It is intentionally shaped like a real production system — multi-tenant Rails API, Vue 3 SPA, Postgres, Redis, background jobs, websockets, CI/CD, and free-tier cloud hosting — so that building it teaches how real systems are designed, shipped, and kept alive.

> Working name: **Tinta** (Portuguese for *ink*). Subject to change if a better name shows up.

## Why this exists

This is a didactic project. Every feature is an excuse to learn a concept properly: REST APIs, JWT auth, multi-tenancy, state machines, Redis, Sidekiq, ActionCable, SQL, testing/TDD, Docker, networking, deploys, and observability. The rule is **ship first**: the app is deployed from week one, and every change must keep it working.

## Stack

| Layer | Tech |
|---|---|
| Backend | Ruby on Rails (API mode), PostgreSQL, Redis, Sidekiq |
| Frontend | Vue 3 + Vite, Pinia, Tailwind CSS |
| Testing | RSpec + FactoryBot (backend), Vitest + Cypress (frontend) |
| CI/CD | GitHub Actions |
| Hosting | Render (API + Redis), Neon (Postgres), Cloudflare Pages (SPA) — later migrated to a VPS with Kamal |

## Documentation

Start at [`docs/README.md`](docs/README.md). The docs cover the product vision, architecture, domain model, phased roadmap, learning guide, and contribution workflow.

## Status

🚧 Phase 0 — project setup. See [`docs/05-roadmap.md`](docs/05-roadmap.md).
