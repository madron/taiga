#!/bin/sh
set -e

echo $*

if [ "$1" = 'uwsgi' ]; then
    # chown -R uwsgi:uwsgi /run/uwsgi
    chown -R uwsgi:uwsgi /media
    echo 'Migrate'
    gosu uwsgi python3 /src/manage.py migrate --noinput
    echo 'gosu uwsgi uwsgi "${@:6}"'
    exec gosu uwsgi uwsgi "${@:6}"
elif [ "$1" = 'nginx' ]; then
    sed -i 's|TAIGA_FRONT_URL|'$TAIGA_FRONT_URL'|' /front/dist/conf.json
    exec nginx "-g daemon off;"
else
    exec "$@"
fi
