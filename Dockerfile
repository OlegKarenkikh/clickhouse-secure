# syntax=docker/dockerfile:1
# =================================================================
# Stage 1 (prep): создаём симлинки и директории в Alpine
# Stage 2 (runtime): cgr.dev/chainguard/glibc-dynamic — 0 CVE
# =================================================================
FROM clickhouse/clickhouse-server:26.2.3.2-alpine AS source

# Создаём симлинки и структуру директорий в source-образе
RUN ln -sf /usr/bin/clickhouse /usr/bin/clickhouse-server && \
    ln -sf /usr/bin/clickhouse /usr/bin/clickhouse-client && \
    ln -sf /usr/bin/clickhouse /usr/bin/clickhouse-local && \
    ln -sf /usr/bin/clickhouse /usr/bin/clickhouse-keeper && \
    mkdir -p /var/lib/clickhouse /var/log/clickhouse-server /var/run/clickhouse-server

# Runtime: Chainguard glibc-dynamic — нет shell, нет пакетного менеджера, 0 CVE
FROM cgr.dev/chainguard/glibc-dynamic:latest

LABEL org.opencontainers.image.title="clickhouse-secure" \
      org.opencontainers.image.source="https://github.com/OlegKarenkikh/clickhouse-secure" \
      org.opencontainers.image.licenses="Apache-2.0"

# Бинарь и симлинки
COPY --from=source /usr/bin/clickhouse      /usr/bin/clickhouse
COPY --from=source /usr/bin/clickhouse-server  /usr/bin/clickhouse-server
COPY --from=source /usr/bin/clickhouse-client  /usr/bin/clickhouse-client
COPY --from=source /usr/bin/clickhouse-local   /usr/bin/clickhouse-local
COPY --from=source /usr/bin/clickhouse-keeper  /usr/bin/clickhouse-keeper

# Конфиги
COPY --from=source /etc/clickhouse-server /etc/clickhouse-server

# Entrypoint
COPY --from=source /entrypoint.sh /entrypoint.sh

# Рабочие директории
COPY --from=source /var/lib/clickhouse          /var/lib/clickhouse
COPY --from=source /var/log/clickhouse-server   /var/log/clickhouse-server
COPY --from=source /var/run/clickhouse-server   /var/run/clickhouse-server

EXPOSE 8123 9000 9009

ENTRYPOINT ["/entrypoint.sh"]
