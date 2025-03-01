FROM elixir:1.18.1 AS base
ARG env=dev
ENV LANG=en_US.UTF-8 \
    TERM=xterm \
    MIX_ENV=$env
WORKDIR /opt/build
CMD ["bin/build_script"]
