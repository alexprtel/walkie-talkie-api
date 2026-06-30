ARG ELIXIR_VERSION=1.19.5
ARG OTP_VERSION=28.5
ARG DEBIAN_VERSION=trixie-20260610-slim

ARG BUILDER_IMAGE="docker.io/hexpm/elixir:${ELIXIR_VERSION}-erlang-${OTP_VERSION}-debian-${DEBIAN_VERSION}"
ARG RUNNER_IMAGE="docker.io/debian:${DEBIAN_VERSION}"

FROM ${BUILDER_IMAGE} AS builder

# ===== INSTALAR DEPENDENCIAS DEL SISTEMA (incluye FFmpeg) =====
RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    build-essential \
    git \
    ffmpeg \
    libsndfile1-dev \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /app

RUN mix local.hex --force \
  && mix local.rebar --force

ENV MIX_ENV="prod"

# ===== INSTALAR DEPENDENCIAS DE ELIXIR =====
COPY mix.exs mix.lock ./
RUN mix deps.get --only $MIX_ENV
RUN mkdir config

COPY config/config.exs config/${MIX_ENV}.exs config/
RUN mix deps.compile

# ===== COPIAR CÓDIGO FUENTE =====
COPY priv priv
COPY lib lib

RUN mix compile

COPY config/runtime.exs config/
COPY rel rel
RUN mix release

# ===== ETAPA FINAL =====
FROM ${RUNNER_IMAGE} AS final

# ===== INSTALAR DEPENDENCIAS DE EJECUCIÓN (incluye FFmpeg) =====
RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    libstdc++6 \
    openssl \
    libncurses6 \
    locales \
    ca-certificates \
    ffmpeg \
    libsndfile1 \
  && rm -rf /var/lib/apt/lists/*

RUN sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen \
  && locale-gen

ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

WORKDIR "/app"
RUN chown nobody /app

ENV MIX_ENV="prod"

# ===== COPIAR EL RELEASE GENERADO =====
COPY --from=builder --chown=nobody:root /app/_build/${MIX_ENV}/rel/walkie_talkie ./

# ===== CREAR DIRECTORIOS DE UPLOADS (SEGMENTOS, COMPLETADOS, TEMPORALES) =====
RUN mkdir -p /app/uploads/segments /app/uploads/completed /app/uploads/temp \
  && chown -R nobody:nogroup /app/uploads

# ===== SCRIPT DE ENTRADA (MIGRACIONES + SERVIDOR) =====
RUN echo '#!/bin/bash\n\
echo "🔧 Ejecutando migraciones..."\n\
/app/bin/walkie_talkie eval "WalkieTalkie.Release.migrate()"\n\
echo "✅ Migraciones completadas. Iniciando servidor..."\n\
/app/bin/server' > /app/entrypoint.sh && chmod +x /app/entrypoint.sh

RUN chmod +x /app/bin/server

USER nobody

ENTRYPOINT ["/app/entrypoint.sh"]