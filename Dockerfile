# This should match the version of Alpine that elixir image uses.
ARG ALPINE_VERSION=3.9

FROM elixir:1.9.2-alpine AS builder

ARG APP_NAME
ARG APP_VSN
ARG MIX_ENV=prod

RUN apk add --update git build-base

WORKDIR /app

RUN mix local.rebar --force && \
  mix local.hex --force

ENV APP_NAME=${APP_NAME} \
  APP_VSN=${APP_VSN} \
  MIX_ENV=${MIX_ENV}

COPY mix.exs mix.lock ./

RUN mix do deps.get, deps.compile

COPY . .

RUN mix compile
RUN mix release

FROM alpine:${ALPINE_VERSION}

RUN apk add --update bash openssl imagemagick

ENV APP_NAME=scixir

WORKDIR /app

COPY --from=builder /app/_build/prod/rel/scixir ./

CMD trap 'exit' INT; /app/bin/${APP_NAME} start
