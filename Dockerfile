# syntax=docker/dockerfile:1
# =================================================================
# ClickHouse secure hardened image
#
# Base: clickhouse/clickhouse-server:26.1.3-noble (Ubuntu 24.04)
#
# Почему не Chainguard:
#   cgr.dev/chainguard/clickhouse зависает при сборке на chown-инициализации
#   ("/var/run/clickhouse-server already exists") и не подходит для CI.
#
# Стратегия по безопасности:
#   1. apt-get upgrade  — патчим всё что доступно в Ubuntu 24.04
#   2. удаляем dev-инструменты (apt, wget, gpgv, tar) после патчинга
#   3. .trivyignore — unfixed CVE без upstream-фикса подавляются обоснованно
# =================================================================
FROM clickhouse/clickhouse-server:26.1.3-noble

LABEL org.opencontainers.image.title="clickhouse-secure" \
      org.opencontainers.image.source="https://github.com/OlegKarenkikh/clickhouse-secure" \
      org.opencontainers.image.licenses="Apache-2.0"

# Патчим все доступные обновления Ubuntu 24.04 и удаляем dev-пакеты
RUN apt-get update -qq && \
    apt-get upgrade -y -qq --no-install-recommends && \
    apt-get remove -y --purge --auto-remove \
        wget \
        apt \
        apt-utils \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

EXPOSE 8123 9000 9009
