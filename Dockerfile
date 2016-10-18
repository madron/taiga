FROM quay.io/madron/uwsgi:2.0.14

MAINTAINER Massimiliano Ravelli <massimiliano.ravelli@gmail.com>

WORKDIR /src
ENV TAIGA_RELEASE=3.0.0

# Source
RUN    apk update \
    && apk add ca-certificates \
    && wget -O - https://github.com/taigaio/taiga-back/archive/$TAIGA_RELEASE.tar.gz | tar -x --strip-components=1 -z -f - \
    && mkdir /front \
    && wget -O - https://github.com/taigaio/taiga-front-dist/archive/$TAIGA_RELEASE-stable.tar.gz | tar -x --strip-components=1 -z -f - -C /front \
    && apk del ca-certificates \
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
ENV DJANGO_SETTINGS_MODULE=settings.local
COPY settings.py /src/settings/local.py

# Static files and translations
RUN python3 /src/manage.py collectstatic --link --noinput --verbosity=0
RUN python3 /src/manage.py compilemessages --verbosity=0


COPY entrypoint.sh /entrypoint.sh
COPY default.conf /etc/nginx/conf.d/default.conf
COPY conf.json /front/dist/conf.json
ENV TAIGA_FRONT_URL=http://localhost

VOLUME ["/media"]
