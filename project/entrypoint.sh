#!/bin/sh
# entrypoint.sh

echo "Running Django migrations..."
python manage.py makemigrations
python manage.py migrate

echo "Collecting static files..."
python manage.py collectstatic --noinput

echo "Starting Gunicorn..."
exec gunicorn project.wsgi:application --bind 0.0.0.0:8000 --reload
