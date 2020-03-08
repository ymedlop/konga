FROM node:10.16-alpine as builder

ENV NODE_ENV production

COPY package.json package-lock.json bower.json ./

RUN apk add --no-cache --virtual \
    .gip \
    build-base \ 
    linux-headers \
    udev \
    g++ \
    make \
    python \
    bash \
    git \
    ca-certificates \
    && npm --unsafe-perm i -g bower \
    && npm --unsafe-perm ci \
    # Node Sass does not support Linux architecture (arm)
    # Hotfix: https://github.com/sass/node-sass/issues/1609
    && npm rebuild node-sass

FROM node:10.16-alpine

ENV NODE_ENV development
ENV STORAGE_PATH /app/kongadata

WORKDIR /app
COPY . .
COPY --from=builder node_modules node_modules

RUN apk upgrade --update \
    && apk add bash git ca-certificates \
    && apk del git \
    && rm -rf /var/cache/apk/* \
    && chown -R node /app

USER node

EXPOSE 1337

VOLUME /app/kongadata

ENTRYPOINT ["/app/start.sh"]