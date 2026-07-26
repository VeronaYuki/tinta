# Tinta — Backend

Rails API for Tinta. See the project docs at [`../docs/`](../docs/README.md).

## Requirements

- Ruby 3.3 (see `.ruby-version`)
- PostgreSQL (local install or Docker Compose — task 0.3)

## Setup

```bash
bundle install
bin/rails db:prepare   # creates tinta_development / tinta_test
bin/rails server       # http://localhost:3000
```

## Health checks

- `GET /up` — Rails' built-in liveness probe: 200 if the process booted.
- `GET /health` — deep check: verifies the database (and Redis, from task 0.3), returns 503 with per-dependency detail when something is down.

## Tests & lint

RSpec and RuboCop arrive in task 0.4; CI in task 0.5.
