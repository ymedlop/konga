# FROM node:10.16-alpine as builder
FROM node:10.16.3-stretch AS builder
ENV NODE_ENV production

COPY package.json package-lock.json bower.json ./

# RUN apk add --no-cache --virtual \
#    .gip \
#    build-base \ 
#    linux-headers \
#    udev \
#    g++ \
#    make \
 #   python \
 #   git

RUN npm --unsafe-perm i \
# Node Sass does not support Linux architecture (arm)
# Hotfix: https://github.com/sass/node-sass/issues/1609
    && npm rebuild node-sass
    # && npm i -g bower \
    # && bower install

FROM node:10.16-alpine

ENV NODE_ENV development
ENV STORAGE_PATH /app/kongadata

WORKDIR /app

RUN chown -R node /app

USER node

COPY . .
COPY --from=builder node_modules node_modules

EXPOSE 1337

VOLUME /app/kongadata

ENTRYPOINT ["/app/start.sh"]
