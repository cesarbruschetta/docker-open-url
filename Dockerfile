# https://github.com/jlesage/docker-firefox
FROM jlesage/firefox:v1.18.0

# https://github.com/sibson/vncdotool
RUN apk update \
    && apk add --virtual \
        build-deps \
        gcc \
        python3-dev \
        musl-dev \
        jpeg-dev \
        zlib-dev \
        libjpeg \
        py3-pip \
    && pip install -U vncdotool

# to allow Firefox to start playing videos in background tabs.
COPY ./rootfs/autoconfig.js /usr/lib/firefox/defaults/pref/autoconfig.js
COPY ./rootfs/firefox.cfg /usr/lib/firefox/firefox.cfg
COPY ./rootfs/startapp.sh /startapp.sh