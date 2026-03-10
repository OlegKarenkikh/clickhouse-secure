# syntax=docker/dockerfile:1
# =================================================================
# ClickHouse secure hardened image — multi-stage Chainguard build
#
# Stage 1 (source): clickhouse/clickhouse-server:26.2.3.2-alpine
#   - extract binary, configs, data dirs
#
# Stage 2 (runtime): cgr.dev/chainguard/glibc-dynamic
#   - minimal Wolfi-based image, 0 CVE
#   - ClickHouse binary is ~statically linked (libstdc++, libssl, etc.
#     are compiled in); only glibc dynamic loader is required at runtime
# =================================================================
FROM clickhouse/clickhouse-server:26.2.3.2-alpine AS source

# Runtime stage on Chainguard — only glibc dynamic loader needed
FROM cgr.dev/chainguard/glibc-dynamic:latest

LABEL org.opencontainers.image.title="clickhouse-secure" \
      org.opencontainers.image.source="https://github.com/OlegKarenkikh/clickhouse-secure" \
      org.opencontainers.image.licenses="Apache-2.0"

# Copy ClickHouse binary (single binary, all applets via symlinks)
COPY --from=source /usr/bin/clickhouse /usr/bin/clickhouse

# Symlinks for clickhouse applets
RUN ln -s /usr/bin/clickhouse /usr/bin/clickhouse-server && \
    ln -s /usr/bin/clickhouse /usr/bin/clickhouse-client && \
    ln -s /usr/bin/clickhouse /usr/bin/clickhouse-local && \
    ln -s /usr/bin/clickhouse /usr/bin/clickhouse-keeper

# Copy default configs
COPY --from=source /etc/clickhouse-server /etc/clickhouse-server

# Copy entrypoint
COPY --from=source /entrypoint.sh /entrypoint.sh

# Create required runtime dirs and user
RUN groupadd -r clickhouse && \
    useradd -r -g clickhouse --no-create-home --shell /sbin/nologin clickhouse && \
    mkdir -p /var/lib/clickhouse /var/log/clickhouse-server /var/run/clickhouse-server && \
    chown -R clickhouse:clickhouse \
        /var/lib/clickhouse \
        /var/log/clickhouse-server \
        /var/run/clickhouse-server \
        /etc/clickhouse-server

USER clickhouse

EXPOSE 8123 9000 9009

ENTRYPOINT ["/entrypoint.sh"]
