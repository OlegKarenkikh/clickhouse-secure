# syntax=docker/dockerfile:1
# =================================================================
# ClickHouse secure hardened image
# Base: cgr.dev/chainguard/clickhouse:latest
#   - собирается ежедневно из Wolfi-пакетов
#   - 0 CVE на момент сборки
#   - встроенный SBOM + Sigstore-подпись
#   - non-root по умолчанию (uid=65532)
# =================================================================
FROM cgr.dev/chainguard/clickhouse:latest

LABEL org.opencontainers.image.title="clickhouse-secure" \
      org.opencontainers.image.source="https://github.com/OlegKarenkikh/clickhouse-secure" \
      org.opencontainers.image.licenses="Apache-2.0"

# Chainguard образ уже запускается от non-root пользователя
# shell отсутствует — минимальная поверхность атаки

EXPOSE 8123 9000 9009
