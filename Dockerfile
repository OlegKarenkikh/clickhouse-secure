# syntax=docker/dockerfile:1
# ClickHouse secure hardened image
# Base: official clickhouse-server v26.2.3.2
FROM clickhouse/clickhouse-server:26.2.3.2

LABEL org.opencontainers.image.title="clickhouse-secure" \
      org.opencontainers.image.version="26.2.3.2" \
      org.opencontainers.image.source="https://github.com/OlegKarenkikh/clickhouse-secure" \
      org.opencontainers.image.licenses="Apache-2.0"

# Remove unnecessary packages and apply security hardening
USER root

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Drop to non-root clickhouse user
USER clickhouse

EXPOSE 8123 9000 9009
