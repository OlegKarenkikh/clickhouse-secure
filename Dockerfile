# syntax=docker/dockerfile:1
FROM clickhouse/clickhouse-server:26.2.3.2

LABEL org.opencontainers.image.title="clickhouse-secure" \
      org.opencontainers.image.source="https://github.com/OlegKarenkikh/clickhouse-secure" \
      org.opencontainers.image.licenses="Apache-2.0"

RUN apt-get update -qq && \
    apt-get upgrade -y -qq --no-install-recommends && \
    apt-get remove -y --purge --auto-remove wget apt apt-utils && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

EXPOSE 8123 9000 9009
