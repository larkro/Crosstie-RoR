ARG RUBY_VERSION=3.1    # overriden by docker build --build-arg, using make it's supplied from .env
FROM ruby:${RUBY_VERSION} AS builder

## OS and JS deps
# .hadolint.yaml
# ignored:
#  - DL3008
#  - DL3015
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
    && echo "deb https://dl.yarnpkg.com/debian/ stable main" > /etc/apt/sources.list.d/yarn.list \
    && apt-get -y update \
    && apt-get -y install  \
    sqlite3 \
    libsqlite3-dev  \
    mariadb-server \
    libmariadb-dev-compat \
    libmariadb-dev \
    postgresql  \
    postgresql-client   \
    postgresql-contrib  \
    libpq-dev   \
    redis-server    \
    memcached   \
    imagemagick \
    ffmpeg  \
    mupdf   \
    mupdf-tools \
    libxml2-dev \
    yarn \
    libvips42 \
    poppler-utils \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \

FROM builder
# throw errors if Gemfile has been modified since Gemfile.lock
RUN bundle config --global frozen 1

# We expect rails.git to be cloned into dir rails
WORKDIR /usr/src/rails
COPY rails/ .
RUN bundle install \
    && yarn install \
    && yarn cache clean

CMD ["/usr/bin/bash"]
