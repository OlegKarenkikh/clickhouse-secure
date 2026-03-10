# syntax=docker/dockerfile:1
# =================================================================
# ClickHouse secure hardened image
#
# Base: clickhouse/clickhouse-server:26.2.3.2 (Ubuntu 22.04)
#
# Security strategy:
#   1. hold clickhouse-* so apt-get upgrade skips them
#      (postinst hangs on chown in Docker build env)
#   2. apt-get upgrade patches only OS/system libs
#   3. remove wget only (apt is essential - cannot be purged)
#   4. .trivyignore - unfixed upstream CVEs suppressed with justification
# =================================================================
FROM clickhouse/clickhouse-server:26.2.3.2

LABEL org.opencontainers.image.title="clickhouse-secure" \
      org.opencontainers.image.source="https://github.com/OlegKarenkikh/clickhouse-secure" \
      org.opencontainers.image.licenses="Apache-2.0"

RUN apt-mark hold clickhouse-server clickhouse-client clickhouse-common-static && \
    apt-get update -qq && \
    apt-get upgrade -y -qq --no-install-recommends && \
    apt-mark unhold clickhouse-server clickhouse-client clickhouse-common-static && \
    apt-get remove -y --purge --auto-remove wget && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

EXPOSE 8123 9000 9009
