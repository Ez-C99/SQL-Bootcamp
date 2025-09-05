# Makefile for SQL-Bootcamp
# Usage: `make help` (or any target below)

# ---- Config ----
COMPOSE            ?= docker compose
DB_SVC             ?= db
DB_NAME            ?= udemy_sql
DB_USER            ?= postgres
DB_PASSWORD        ?= postgres
CHECKS_SQL         ?= sql-ultimate-course/checks/checks_postgres.sql
PGADMIN_URL        ?= http://localhost:5050

SHELL := bash

# ---- Top-level helpers ----
.PHONY: help up down ps logs restart reset health psql psqlc check pga-open dump restore

help:
	@echo ""
	@echo "Targets:"
	@echo "  up        - Start Postgres + pgAdmin in background"
	@echo "  down      - Stop containers (keep data volume)"
	@echo "  reset     - Stop & REMOVE data volume, then start fresh (re-runs seed SQL)"
	@echo "  ps        - Show container status"
	@echo "  logs      - Tail Postgres logs"
	@echo "  restart   - Restart the database service"
	@echo "  health    - Check DB readiness (pg_isready)"
	@echo "  psql      - Open interactive psql inside the db container"
	@echo "  psqlc     - Run a one-off psql command; e.g. make psqlc CMD=\"\\dt\""
	@echo "  check     - Run the dataset sanity checks script"
	@echo "  pga-open  - Open pgAdmin in your browser"
	@echo "  dump      - Create ./udemy_sql.dump (custom format) from running container"
	@echo "  restore   - Restore from ./udemy_sql.dump into the running DB"
	@echo ""

# ---- Docker Compose lifecycle ----
up:
	$(COMPOSE) up -d

down:
	$(COMPOSE) down

reset:
	$(COMPOSE) down -v
	$(COMPOSE) up -d

ps:
	$(COMPOSE) ps

logs:
	$(COMPOSE) logs -f $(DB_SVC)

restart:
	$(COMPOSE) restart $(DB_SVC)

health:
	$(COMPOSE) exec -T $(DB_SVC) pg_isready -U $(DB_USER) -d $(DB_NAME)

# ---- Postgres helpers ----
psql:
	$(COMPOSE) exec -e PGPASSWORD=$(DB_PASSWORD) $(DB_SVC) psql -U $(DB_USER) -d $(DB_NAME)

# One-off psql command: make psqlc CMD="\dt+"
psqlc:
	@test -n "$(CMD)" || (echo 'Usage: make psqlc CMD="\dt"'; exit 1)
	$(COMPOSE) exec -T -e PGPASSWORD=$(DB_PASSWORD) $(DB_SVC) psql -U $(DB_USER) -d $(DB_NAME) -c "$(CMD)"

check:
	$(COMPOSE) exec -T -e PGPASSWORD=$(DB_PASSWORD) $(DB_SVC) \
	  psql -U $(DB_USER) -d $(DB_NAME) -f $(CHECKS_SQL)

# ---- pgAdmin convenience ----
pga-open:
	@echo "$(PGADMIN_URL)"
	@{ command -v open >/dev/null && open "$(PGADMIN_URL)"; } || \
	 { command -v xdg-open >/dev/null && xdg-open "$(PGADMIN_URL)"; } || \
	 { echo "Open $(PGADMIN_URL) in your browser."; }

# ---- Backup & restore (optional) ----
dump:
	$(COMPOSE) exec -T -e PGPASSWORD=$(DB_PASSWORD) $(DB_SVC) \
	  pg_dump -U $(DB_USER) -d $(DB_NAME) -Fc -f /tmp/udemy_sql.dump
	$(COMPOSE) cp $(DB_SVC):/tmp/udemy_sql.dump ./udemy_sql.dump
	@echo "Wrote ./udemy_sql.dump"

restore:
	@test -f ./udemy_sql.dump || (echo "Missing ./udemy_sql.dump. Run 'make dump' first."; exit 1)
	$(COMPOSE) cp ./udemy_sql.dump $(DB_SVC):/tmp/restore.dump
	$(COMPOSE) exec -T -e PGPASSWORD=$(DB_PASSWORD) $(DB_SVC) \
	  pg_restore -U $(DB_USER) -d $(DB_NAME) -c /tmp/restore.dump
