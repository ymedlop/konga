FROM node:10.16.3-stretch AS builder

ENV NODE_ENV production

COPY package.json package-lock.json bower.json ./

RUN npm ci \
    && npm run bower-deps \
    # Node Sass does not support Linux architecture (arm)
    # Hotfix: https://github.com/sass/node-sass/issues/1609
    && set -eux; \
	dpkgArch="$(dpkg --print-architecture || echo amd64)"; \
	case "${dpkgArch##*-}" in \
		arm64) npm rebuild node-sass ;; \
    esac;

FROM node:10.16-alpine

ENV NODE_ENV development
ENV STORAGE_PATH /app/kongadata

WORKDIR /app

RUN chown -R node /app

USER node

COPY . .
COPY --from=builder node_modules node_modules
COPY --from=builder bower_components bower_components

EXPOSE 1337

VOLUME /app/kongadata

ENTRYPOINT ["/app/start.sh"]
