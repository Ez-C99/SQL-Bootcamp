# SQL-Bootcamp

A SQL skills refresher and refiner through the Udemy course "The Complete SQL Bootcamp (30 Hours): Go from Zero to Hero" by Baraa Khatib Salkini

## Local Postgres for the Udemy SQL Bootcamp

This repo runs **PostgreSQL 16** locally with your course datasets loaded on startup, plus CI smoke tests.

### Layout

```plaintext
SQL-Bootcamp/
├─ docker-compose.yml
├─ sql-ultimate-course/
│  ├─ datasets/
│  │  └─ postgres/
│  │     ├─ 00\_init\_schemas.sql
│  │     ├─ 10\_mydatabase\_seed.sql
│  │     └─ 20\_sales\_seed.sql
│  └─ checks/
│     └─ checks\_postgres.sql
├─ tools/
│  └─ audit\_postgres\_dataset.sh
└─ .github/
└─ workflows/
└─ postgres-smoke.yml
````

### Start the DB

```bash
docker compose up -d
# reset (rerun init scripts):
# docker compose down -v && docker compose up -d
````

### Run checks

```bash
psql -h localhost -U postgres -d udemy_sql -f sql-ultimate-course/checks/checks_postgres.sql
```

### VS Code (Microsoft PostgreSQL extension)

1. Install **PostgreSQL for Visual Studio Code** (Microsoft).
2. Create a **New Connection** to `localhost:5432` → DB `udemy_sql` → user `postgres` / password `postgres`.
3. Browse objects and run queries from the editor.
   (See Microsoft’s quickstart for the extension if you need a walkthrough.)

Links to docs: search “VS Code PostgreSQL Quickstart” on Microsoft Learn.

The official extension and quickstart are here if you want references.
If you prefer a GUI, pgAdmin in Compose is ready at `http://localhost:5050` (login with the env vars shown). Docs for container deployment & first-time login behaviour are here.

---

## Cohesiveness notes from the data (kept on purpose)

- `mydatabase.customers`: `id=2` has `first_name = ' John'` (leading space).  
- `mydatabase.orders`: `order_id=1004` references non-existent `customer_id=6` (useful for LEFT JOIN practice).  
- `sales.ordersarchive`: multiple records share the same `orderid` (no PK by design).  
- `sales.orders`: includes `quantity=0` (edge case for aggregates/filters).

The **checks** will highlight all of the above without breaking your load.

---

## How this aligns with the tools you’re using

- **Docker init workflow**: scripts execute once on a fresh data dir; a reset (`down -v`) re-runs them.
- **`psql` flags**: `-1` wraps the run in a single transaction; `ON_ERROR_STOP` halts on first error — great for CI.
- **VS Code extension**: the official Microsoft PostgreSQL extension supports connections, object browsing, and query authoring directly in VS Code.
- **pgAdmin**: env vars `PGADMIN_DEFAULT_EMAIL` / `PGADMIN_DEFAULT_PASSWORD` are required for the containerised pgAdmin login.
