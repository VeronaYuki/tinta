# Tinta — Backend

Rails API for Tinta. See the project docs at [`../docs/`](../docs/README.md).

## Requirements

- Ruby 3.3 (see `.ruby-version`)
- Docker Desktop (Postgres and Redis run in containers — see `../docker-compose.yml`)

## Setup

```bash
docker compose -f ../docker-compose.yml up -d   # start Postgres + Redis
cp .env.sample .env                             # local connection settings
bundle install
bin/rails db:prepare                            # creates tinta_development / tinta_test
bin/rails server                                # http://localhost:3000
```

The containers listen on **shifted host ports** (Postgres `5433`, Redis `6380`) so they never clash with other instances already running on your machine. `.env` points Rails at those ports.

## Health checks

- `GET /up` — Rails' built-in liveness probe: 200 if the process booted.
- `GET /health` — deep check of Postgres and Redis; returns 503 with per-dependency detail when something is down.

```bash
curl localhost:3000/health
# {"status":"ok","checks":{"database":true,"redis":true},...}
```

## Useful commands

```bash
bin/rails console      # Ruby REPL with the app loaded
bin/rails dbconsole    # psql session against the development database
bin/rails routes       # every route, with its controller#action
bin/rubocop            # linter
```

## Tests & lint

RSpec arrives in task 0.4; CI in task 0.5.
