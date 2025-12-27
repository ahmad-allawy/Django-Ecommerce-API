FROM python:3.12-slim-bookworm AS base

ENV PYTHONUNBUFFERED=1
WORKDIR /app

# System deps
RUN apt-get update && apt-get install -y \
    build-essential \
    libpq-dev \
    && rm -rf /var/lib/apt/lists/*

COPY project/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy project
COPY . .


FROM base AS development

ENV DJANGO_SETTINGS_MODULE=project.settings.dev

WORKDIR /app/project

CMD ["gunicorn", "project.wsgi:application", "--bind", "0.0.0.0:8000", "--reload"]


FROM base AS production

ENV DJANGO_SETTINGS_MODULE=project.settings.prod

WORKDIR /app/project

RUN python manage.py collectstatic --noinput

EXPOSE 8000
CMD ["gunicorn", "project.wsgi:application", "--bind", "0.0.0.0:8000"]
