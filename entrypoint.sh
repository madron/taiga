#!/bin/sh
set -e

if [ "$1" = 'uwsgi' ]; then
    # chown -R uwsgi:uwsgi /run/uwsgi
    chown -R uwsgi:uwsgi /media
    gosu uwsgi /src/manage.py migrate --noinput
    exec python3 manage.py runserver 0.0.0.0:8000
    # exec gosu uwsgi "$@"
elif [ "$1" = 'nginx' ]; then
    sed -i 's|TAIGA_FRONT_URL|'$TAIGA_FRONT_URL'|' /front/dist/conf.json
    exec nginx "-g daemon off;"
else
    exec "$@"
fi
