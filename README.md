# Student Management Application

A modern Student Management Application built using Ruby on Rails 8.

---

## Features

* Add Students
* View Students
* Edit Students
* Delete Students
* Search Students
* Filter by Course
* Dashboard Analytics
* Validation Handling
* Pass/Fail Result Logic

---

## Tech Stack

* Ruby 3.4.6
* Rails 8.0.3
* PostgreSQL
* Bootstrap 5

---

## Setup Instructions

Clone the repository:

```bash
git clone <repository-url>
```

Move into project:

```bash
cd student_management_app
```

Install dependencies:

```bash
bundle install
```

### Local development with Docker Compose (recommended)

The app runs against PostgreSQL, Redis, and Sidekiq via Docker Compose:

```bash
docker compose build
docker compose up -d db
docker compose run --rm web bin/rails db:prepare
docker compose up
```

Open browser:

```text
http://localhost:3001
```

---

## Project Structure

* Models → Business Logic
* Controllers → Request Handling
* Views → UI Rendering

---

## Future Improvements

* Authentication
* Pagination
* API Integration
* Role-based Access

---

## Production Deployment on Render

### Architecture

- Rails Docker Web Service (built from the repo `Dockerfile`)
- Render PostgreSQL (primary datastore)
- GitHub-based automatic deployment on push to `main`
- Redis + Sidekiq worker are **not** part of the first deployment (see Known Limitations)

### Required environment variables

Set these on the Render Web Service (never commit actual values):

- `RAILS_ENV` = `production`
- `RAILS_MASTER_KEY` = contents of local `config/master.key`
- `DATABASE_URL` = Render Postgres **Internal Database URL**
- `RAILS_LOG_TO_STDOUT` = `true`
- `RAILS_SERVE_STATIC_FILES` = `true`
- `RAILS_MAX_THREADS` = `5`
- `RUN_DB_SEEDS` = `true` only for the first deploy that needs sample data, then remove it

Render supplies `PORT` automatically — do not set it manually.

### Docker build

```bash
docker build -t student-management-render .
```

### Local PostgreSQL setup

```bash
docker compose up -d db
docker compose run --rm web bin/rails db:prepare
docker compose up
```

### Render health check

Path: `/up`

### Database migrations

The container's startup script (`bin/render-start`) runs `bundle exec rails db:prepare`
before starting Puma, so a fresh Render Postgres database is migrated automatically
on each deploy.

### Known limitations

- The free Render web service filesystem is ephemeral — it may spin down after
  inactivity, and any locally written files (uploads, SQLite-style data) do not persist
  across restarts/redeploys.
- Active Storage is configured for local disk (`config.active_storage.service = :local`)
  in production. For real file persistence, configure external object storage
  (e.g. S3, Cloudinary) before relying on uploads in production.
- Free Render PostgreSQL instances can expire after a fixed period — see
  https://render.com/docs/free for current limits.
- Background jobs use Sidekiq only when `REDIS_URL` is set; otherwise they run
  in-process via Rails' `:async` adapter. Deploy a Render Key Value (Redis) instance
  and a Background Worker service, then set `REDIS_URL`, to enable durable
  Sidekiq-backed job processing.

Never include in this file or in commits:
- `RAILS_MASTER_KEY`
- `DATABASE_URL`
- Passwords
- API keys
- SMTP credentials
