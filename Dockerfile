FROM quay.io/madron/uwsgi:2.0.14

MAINTAINER Massimiliano Ravelli <massimiliano.ravelli@gmail.com>

WORKDIR /src
ENV TAIGA_RELEASE=3.0.0

# Source
RUN    apk update \
    && apk add curl openssl \
    && curl https://codeload.github.com/taigaio/taiga-back/tar.gz/$TAIGA_RELEASE | tar -x --strip-components=1 -z -f - \
    && mkdir /front \
    && curl https://codeload.github.com/taigaio/taiga-front-dist/tar.gz/$TAIGA_RELEASE-stable | tar -x --strip-components=1 -z -f - -C /front \
    && apk del curl openssl \
    && rm -rf /var/cache/apk/*

# Requirements
RUN    apk update \
    && apk add gettext py3-psycopg2 py3-lxml libjpeg-turbo \
    && apk add git jpeg-dev zlib-dev musl-dev gcc \
    && ln -s /lib/libz.so /usr/lib \
    && sed -i '/psycopg2/d' requirements.txt \
    && sed -i '/lxml/d' requirements.txt \
    && pip3 install -r /src/requirements.txt \
    && ln -s /usr/bin/python3 /usr/bin/python \
    && apk del git jpeg-dev zlib-dev musl-dev gcc \
    && rm -rf /var/cache/apk/*


# Settings
ENV DJANGO_SETTINGS_MODULE=settings.docker
COPY settings_docker.py /src/settings/docker.py

# Static files and translations
RUN    touch /src/settings/local.py \
    && python3 /src/manage.py collectstatic --link --noinput --verbosity=0 \
    && python3 /src/manage.py compilemessages --verbosity=0

# Fix
RUN sed -i 's|ng-href="::vm.item.external_reference\[1\]"|ng-href="{{::vm.item.external_reference\[1\]}}"|' /front/dist/v-1475257132248/js/templates.js
RUN sed -i 's|<span>{{ ::vm.item.external_reference\[1\] }}</span>|<span> {{ ::vm.item.external_reference\[0\] }}</span>|' /front/dist/v-1475257132248/js/templates.js

COPY entrypoint.sh /docker/entrypoint.sh
COPY nginx.conf /docker/nginx.conf
COPY conf.json /front/dist/conf.json
ENV TAIGA_FRONT_URL=http://localhost

VOLUME ["/files/media"]

CMD ["uwsgi", "--plugins", "/usr/lib/uwsgi/python3_plugin.so", "--master", "--processes", "1", "--threads", "2", "--chdir", "/src", "--wsgi", "taiga.wsgi", "--http-socket", ":8000", "--stats", ":9191"]
