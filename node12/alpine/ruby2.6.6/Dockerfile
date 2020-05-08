FROM node:12.16.3-alpine3.11 as Node

FROM ruby:2.6.6-alpine3.11 as Jemalloc

RUN set -eux; \
  \
  apk update --no-cache -q; \
  apk add --no-cache --virtual .ruby-builddeps \
    autoconf \
    build-base \
  ; \
  wget -O - https://github.com/jemalloc/jemalloc/releases/download/5.2.1/jemalloc-5.2.1.tar.bz2 | tar -xj; \
    cd jemalloc-5.2.1; \
    ./autogen.sh; \
    ./configure; \
    make -j$(nproc) > /dev/null; \
    make install; \
  apk del --no-network .ruby-builddeps;

FROM ruby:2.6.6-alpine3.11

ENV NODE_VERSION 12.16.3
ENV YARN_VERSION 1.22.4

COPY --from=Node /usr/local/bin/node /usr/local/bin/node
COPY --from=Node /usr/local/bin/npm /usr/local/bin/npm
COPY --from=Node /usr/local/bin/yarn /usr/local/bin/yarn
COPY --from=Node /usr/local/bin/yarnpkg /usr/local/bin/yarnpkg

COPY --from=Jemalloc /usr/local/lib/libjemalloc.so.2 /usr/local/lib/

ENV LD_PRELOAD=/usr/local/lib/libjemalloc.so.2
