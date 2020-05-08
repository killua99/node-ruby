FROM node:13.14.0-alpine3.11 as Node

FROM ruby:2.7.1-alpine3.11 as Jemalloc

RUN wget -O - https://github.com/jemalloc/jemalloc/releases/download/5.2.1/jemalloc-5.2.1.tar.bz2 | tar -xj && \
    cd jemalloc-5.2.1 && \
    ./configure && \
    make && \
    make install

FROM ruby:2.7.1-alpine3.11

ENV NODE_VERSION 13.14.0
ENV YARN_VERSION 1.22.4

COPY --from=Node /usr/local/bin/node /usr/local/bin/node
COPY --from=Node /usr/local/bin/npm /usr/local/bin/npm
COPY --from=Node /usr/local/bin/yarn /usr/local/bin/yarn
COPY --from=Node /usr/local/bin/yarnpkg /usr/local/bin/yarnpkg

ENV LD_PRELOAD=/usr/local/lib/libjemalloc.so.2

COPY --from=Jemalloc /usr/local/lib/libjemalloc.so.2 /usr/local/lib/

RUN ruby -r rbconfig -e "abort 'jemalloc not enabled' unless RbConfig::CONFIG['LIBS'].include?('jemalloc') || RbConfig::CONFIG['MAINLIBS'].include?('jemalloc')"
