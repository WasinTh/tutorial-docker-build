#!/bin/sh
set -e

>&2 echo "Collecting statics"
python manage.py collectstatic --noinput

if [ "x$DJANGO_MANAGEPY_MIGRATE" = 'xon' ]; then
    >&2 echo "Migrating database"
    python manage.py migrate --noinput
fi


exec "$@"
