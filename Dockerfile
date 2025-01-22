FROM elixir:1.18.1-slim AS dev
LABEL maintainer="Teifion <teifion>"

WORKDIR /app

ARG UID=1000
ARG GID=1000

RUN apt-get update \
    && apt-get install -y --no-install-recommends ca-certificates build-essential curl inotify-tools \
    && rm -rf /var/lib/apt/lists/* /usr/share/doc /usr/share/man \
    && apt-get clean \
    && groupadd -g "${GID}" elixir \
    && useradd --create-home --no-log-init -u "${UID}" -g "${GID}" elixir \
    && mkdir -p /mix && chown elixir:elixir -R /mix /app

USER elixir

RUN mix local.hex --force && mix local.rebar --force

ARG MIX_ENV="prod"
ENV MIX_ENV="${MIX_ENV}" \
    USER="elixir"

COPY --chown=elixir:elixir mix.* ./
RUN if [ "${MIX_ENV}" = "dev" ]; then \
    mix deps.get; else mix deps.get --only "${MIX_ENV}"; fi

COPY --chown=elixir:elixir config/config.exs config/"${MIX_ENV}".exs config/
RUN mix deps.compile

# COPY --chown=elixir:elixir --from=assets /app/priv/static /public
COPY --chown=elixir:elixir . .

RUN if [ "${MIX_ENV}" != "dev" ]; then \
    # ln -s /public /app/priv/static \
    # && mix phx.digest && mix release && rm -rf /app/priv/static; fi
    mix phx.digest && mix release && rm -rf /app/priv/static; fi

ENTRYPOINT ["/app/dev/docker-entrypoint-web"]

EXPOSE 8000

CMD ["iex", "-S", "mix", "phx.server"]

###############################################################################

FROM elixir:1.18.1-slim AS prod
LABEL maintainer="Teifion <teifion>"

WORKDIR /app

ARG UID=1000
ARG GID=1000

RUN apt-get update \
    && apt-get install -y --no-install-recommends curl \
    && rm -rf /var/lib/apt/lists/* /usr/share/doc /usr/share/man \
    && apt-get clean \
    && groupadd -g "${GID}" elixir \
    && useradd --create-home --no-log-init -u "${UID}" -g "${GID}" elixir \
    && chown elixir:elixir -R /app

USER elixir

ENV USER=elixir

COPY --chown=elixir:elixir --from=dev /public /public
COPY --chown=elixir:elixir --from=dev /mix/_build/prod/rel/durandal ./
COPY --chown=elixir:elixir dev/docker-entrypoint-web dev/

ENTRYPOINT ["/app/dev/docker-entrypoint-web"]

EXPOSE 8000

CMD ["bin/durandal", "start"]
