# Production-Ready Django E‑commerce API 🛒

A production-oriented, extensible backend API for e-commerce built with Django, Django REST Framework and integrated with Paymob for payments. This project includes user authentication, product inventory and filtering, cart + orders, admin management, Swagger/OpenAPI docs, Docker configs for dev & prod, and test coverage using pytest.

---

## 📋 Table of Contents

- [Highlights](#-highlights)
- [Features](#-features)
- [Tech Stack](#-tech-stack)
- [Project Structure](#-project-structure)
- [Prerequisites](#-prerequisites)
- [Installation & Setup](#-installation--setup)
  - [Option 1: Docker (recommended)](#option-1-docker-recommended)
  - [Option 2: Local development](#option-2-local-development)
  - [Seeding & test accounts](#seeding--test-accounts)
- [API Documentation & Endpoints](#api-documentation--endpoints)
- [Security & Best Practices](#security--best-practices)
- [Testing](#testing)
- [Database Schema (summary)](#database-schema-summary)
- [Architecture Decisions](#architecture-decisions)
- [Performance & Scaling](#performance--scaling)
- [Deployment Checklist](#deployment-checklist)
- [Troubleshooting](#troubleshooting)
- [Contributing & License](#contributing--license)

---

## ✨ Highlights

- Production-focused patterns (separate dev/prod settings, Docker compose)
- SimpleJWT-based JWT authentication + email OTP flows
- Paymob payment integration (start + callback endpoints)
- Seed command for sample products and factories for tests
- Auto-generated OpenAPI docs (Swagger & Redoc)

---

## ✅ Features

### Core Functionality
- **Authentication & Users**
  - Email-based registration and login with JWT
  - Email OTP for verification and password reset
  - Token refresh and logout (token blacklist supported)
  - Admin & Buyer roles (via `user_type` on `accounts.User`)
- **Product catalog**
  - Product, Brand, Category models
  - CRUD operations (Admin-level for create/update/delete)
  - Filtering and pagination for list endpoints
  - Management command to seed sample products (`products_dummy_data`)
- **Cart & Orders**
  - Cart and CartItem models
  - Create multi-item orders with server-side price/stock calculations
  - Order status tracking (Pending → Processing → Shipped → Delivered)
- **Payments**
  - Paymob start payment endpoint and callback handler
  - HMAC secret verification for callback integrity

### Developer Experience
- Swagger UI & Redoc auto-generated from view schemas
- Tests written with pytest and factory_boy
- Management commands for seeding dummy data

---

## 🔧 Tech Stack

- Python 3.11+ / Django 5.x
- Django REST Framework
- djangorestframework-simplejwt (JWT)
- drf-yasg (Swagger/OpenAPI)
- Paymob integration for payments
- pytest, factory_boy, Faker for tests
- Docker & docker-compose for local and production deployments

---

## 📁 Project Structure (high level)

- `project/` – Django project
  - `accounts/` – custom user model, auth views & serializers
  - `products/` – product, brand, category models, filters, seed command
  - `orders/` – cart, order, payment logic (`paymob` views)
  - `project/settings/` – `base.py`, `dev.py`, `prod.py`
- `Dockerfile`, `docker-compose*.yml`
- `README.md` – this file

> Open `project/project/urls.py` to view registered routes and Swagger endpoints.

---

## 🧭 Prerequisites

- Python 3.11+
- pip
- (recommended) Docker & Docker Compose
- (production) PostgreSQL (or another production RDBMS)
- (optional) Redis for caching/session storage

---

## 🛠️ Installation & Setup

### Option 1: Docker (recommended)

1. Clone the repository:

```bash
git clone <repo-url>
cd Django-Ecommerce-API
```

2. Copy env and customize (or supply env vars in your CI / orchestration):

```bash
cp project/.env .env
# edit .env for production secrets
```

3. Start dev services (this will build the image and run the app locally):

```bash
docker-compose -f docker-compose.dev.yml up --build
```

What this does:
- Builds and starts the Django service
- (Optionally) Starts any DB / services declared in the compose file
- Runs migrations on container startup (if configured)

Access:
- API: http://localhost:8000
- Swagger: http://localhost:8000/swagger/

### Option 2: Local development (venv)

1. Create & activate venv

```bash
python -m venv .venv
# PowerShell
& .\.venv\Scripts\Activate.ps1
```

2. Install dependencies

```bash
pip install -r project/requirements.txt
```

3. Populate `.env` in `project/.env` (use the included `.env` as a base).

4. Run migrations, seed data & create a superuser

```bash
cd project
python manage.py migrate
python manage.py products_dummy_data   # seed sample brands/categories/products
python manage.py createsuperuser
```

5. Run the server

```bash
python manage.py runserver
```

### Seeding & test accounts

- Seed products & categories:
  - `python manage.py products_dummy_data`
- Create a test admin via `createsuperuser` or shell:

```python
# python manage.py shell
from accounts.models.user import User
User.objects.create_superuser(email='admin@ecommerce.com', password='Admin@123', full_name='Admin')
User.objects.create_user(email='customer1@example.com', password='Customer@123', full_name='Customer One')
```

> Tip: The `products_dummy_data` management command will populate ~50 sample products for quick local testing.

---

## 📚 API Documentation & Endpoints

- **Swagger UI**: `http://localhost:8000/swagger/`
- **Redoc**: `http://localhost:8000/redoc/`

### Authentication
- `POST /accounts/register/` — register a new user
- `POST /accounts/login/` — obtain JWT access & refresh tokens
- `POST /accounts/token/refresh/` — refresh token
- `POST /accounts/logout/` — logout (token blacklist)
- `POST /accounts/verify/` — verify email OTP
- Password reset flows (forgot/verify/reset)

### Products
- `GET /products/` — list & filter products
- `GET /products/<uuid>/` — product detail
- `POST/PATCH/DELETE /products/` — admin-only create/update/delete
- `GET /products/categories/`, `GET /products/brands/` — category & brand APIs

### Orders & Cart
- `POST /orders/` — create an order
- `GET /orders/` — list orders (admin: all, customer: own)
- `GET /orders/<id>/` — order details
- `POST /orders/cart/` — add/remove items (via Cart endpoints)

### Payments
- `POST /payments/start/<order_id>/` — start Paymob payment
- `POST /payments/callback/` — Paymob callback (HMAC verified)

### Admin
- `http://localhost:8000/admin/` — Django admin

> For full parameter & response specs, use Swagger UI.

---

## 🔐 Security & Best Practices

- **Passwords**: Handled by Django's secure password hashing (PBKDF2 by default). Enforce strong passwords in your front-end and validation logic.
- **JWT**: Uses `djangorestframework-simplejwt` for access/refresh tokens.
- **Paymob**: verify callback authenticity using HMAC secret (`PAYMOB_HMAC_SECRET`) and `PAYMOB_CALLBACK_SECRET`.
- **Secrets**: Keep `SECRET_KEY`, DB credentials, and payment credentials out of VCS. Use environment variables or a secrets manager.
- **Rate limiting & throttling**: DRF supports throttling — set `DEFAULT_THROTTLE_CLASSES` and rates in production.
- **Input validation**: Use serializers for strict input validation and sanitization.

---

## 🧪 Testing

Run tests from the `project/` directory:

```bash
pytest -q
```

- Unit tests for `accounts`, `products`, `orders` exist.
- Use `-k` to run a subset: `pytest -q -k products`
- Add `pytest-cov` if you need coverage reports:

```bash
pip install pytest-cov
pytest --cov=project --cov-report=term-missing
```

Testing notes:
- Factories live in each app's `tests/factories/` (factory_boy + Faker)

---

## 🗄️ Database Schema (summary)

- **User** — custom user with `email`, `full_name`, `user_type` (admin/buyer), profile fields
- **Product** — name, description, price, stock, category, brand, metadata
- **Category, Brand** — product organization
- **Cart / CartItem** — temporary cart system per user
- **Order / OrderItem** — finalized order with snapshots of price/quantity
- **Payment** — payment records and status

---

## 🧾 Architecture Decisions

- **Why Django & DRF?**
  - Mature framework, batteries-included admin, excellent ORM, and a large ecosystem.
  - DRF provides request/response serialization, authentication, and useful class-based views.
- **Auth** — `rest_framework_simplejwt` for token-based auth and token blacklist support.
- **Docs** — `drf-yasg` for auto-generated OpenAPI docs.
- **Extensibility** — modular apps (`accounts`, `products`, `orders`) for maintainability.

---

## 📈 Performance & Scaling (recommendations)

- Use PostgreSQL in production (connection pooling)
- Add Redis for:
  - Caching product lists/results
  - Task queue backend if async jobs (Celery)
- Add database indexes on frequently queried fields (e.g., product `code`, order `created_at`, user `email`)
- Optimize list endpoints with proper pagination and selective prefetching (`select_related`/`prefetch_related`)

---

## 🚀 Deployment Checklist

1. Set `DEBUG=False` and configure `ALLOWED_HOSTS`.
2. Provide secure environment variables and secrets (use a secrets manager or CI secret store).
3. Use `gunicorn` and `nginx` (reverse proxy) to serve app and static files.
4. Run migrations and collect static:

```bash
python manage.py migrate
python manage.py collectstatic --noinput
```

5. Configure monitoring & logging and set up regular DB backups.

Docker production (example):

```bash
docker build -t django-ecommerce:latest .
docker-compose -f docker-compose..prod.yml up -d --build
```

---

## ⚠️ Troubleshooting

- Docker weird state: `docker-compose down -v && docker-compose up -d --build`
- DB migration problems: confirm DB credentials & `python manage.py migrate` logs
- Paymob callbacks failing: check `PAYMOB_HMAC_SECRET` and callback payload signature
- Tests failing: ensure virtualenv and dependencies match `requirements.txt` and run `pytest -q -k <name>` to isolate

---

## 🤝 Contributing & License

Contributions are welcome:

1. Fork the repo
2. Create a branch: `git checkout -b feature/your-feature`
3. Add tests and run `pytest`
4. Open a PR with a clear description
---


