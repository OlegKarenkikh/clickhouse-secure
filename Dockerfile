# syntax=docker/dockerfile:1
FROM clickhouse/clickhouse-server:26.2.3.2-alpine

LABEL org.opencontainers.image.title="clickhouse-secure" \
      org.opencontainers.image.source="https://github.com/OlegKarenkikh/clickhouse-secure" \
      org.opencontainers.image.licenses="Apache-2.0"

USER root
RUN apk update --no-cache && \
    apk upgrade --no-cache && \
    rm -rf /var/cache/apk/*

EXPOSE 8123 9000 9009
