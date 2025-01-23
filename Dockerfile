FROM elixir:1.18.1-otp-27-alpine AS base

RUN apk --no-cache update && \
    apk --no-cache upgrade && \
    apk --no-cache add build-base git openssh-client curl inotify-tools bash

RUN mix do local.hex --force, local.rebar --force
RUN mix sass.install

RUN mkdir -p /root/.ssh

# FROM base AS build

# COPY . .

# ENV MIX_ENV=dev

# RUN --mount=type=ssh mix do deps.get --check-locked, deps.compile
# RUN mix sass.install

# RUN mix release --version 0.0.0

# EXPOSE 4000
# ENTRYPOINT ["/init"]
# CMD []
