FROM node:12.16.3-buster-slim as Node

FROM ruby:2.6.6-slim-buster as Jemalloc

RUN set -eux; \
  \
  apt-get update; \
  apt-get install -y --no-install-recommends \
    autoconf \
    build-essential \
    wget \
  ; \
  wget -O - https://github.com/jemalloc/jemalloc/releases/download/5.2.1/jemalloc-5.2.1.tar.bz2 | tar -xj; \
    cd jemalloc-5.2.1; \
    ./autogen.sh; \
    ./configure; \
    make -j$(nproc) > /dev/null; \
    make install; \
  rm -rf /var/lib/apt/lists/*; \
  apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false

FROM ruby:2.6.6-slim-buster

ENV NODE_VERSION 12.16.3
ENV YARN_VERSION 1.22.4

COPY --from=Node /usr/local/bin/node /usr/local/bin/node
COPY --from=Node /usr/local/bin/npm /usr/local/bin/npm
COPY --from=Node /opt/yarn-v$YARN_VERSION /opt/yarn-v$YARN_VERSION

COPY --from=Jemalloc /usr/local/lib/libjemalloc.so.2 /usr/local/lib/

ENV LD_PRELOAD=/usr/local/lib/libjemalloc.so.2

RUN set -eux; \
  \
  savedAptMark="$(apt-mark showmanual)"; \
  apt-get update; \
  apt-get install -y --no-install-recommends \
    build-essential \
    libatomic1 \
    python \
  ; \
  rm -rf /var/lib/apt/lists/*; \
  \
  ln -s /usr/local/bin/node /usr/local/bin/nodejs; \
  ln -s /opt/yarn-v$YARN_VERSION/bin/yarn /usr/local/bin/yarn; \
  ln -s /opt/yarn-v$YARN_VERSION/bin/yarnpkg /usr/local/bin/yarnpkg; \
  \
  yarn global add node-sass node-gyp; \
  \
  apt-mark auto '.*' > /dev/null; \
  { [ -z "$savedAptMark" ] || apt-mark manual $savedAptMark > /dev/null; }; \
  find /usr/local -type f -executable -exec ldd '{}' ';' \
    | awk '/=>/ { print $(NF-1) }' \
    | sort -u \
    | xargs -r dpkg-query --search \
    | cut -d: -f1 \
    | sort -u \
    | xargs -r apt-mark manual; \
  apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false
