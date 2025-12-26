# ===============================
# Base image for Python
# ===============================
FROM python:3.12-slim-bookworm AS base

# Set working directory
WORKDIR /app

# Install Python dependencies
COPY project/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy project files
COPY . .

# Set environment variable
ENV PYTHONUNBUFFERED=1
ENV DJANGO_SETTINGS_MODULE=project.settings.dev


WORKDIR /app/project/
RUN python manage.py collectstatic --noinput
# ===============================
# Development stage
# ===============================
FROM base AS development


# Default command for dev

WORKDIR /app/project
CMD ["gunicorn", "project.wsgi:application", "--bind", "0.0.0.0:8000", "--reload"]

# ===============================
# Production stage
# ===============================
FROM base AS production


# Expose port
EXPOSE 8000

# Start the app
WORKDIR /app/project
CMD ["gunicorn", "project.wsgi:application", "--bind", "0.0.0.0:8000", "--reload"]

