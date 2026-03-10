# syntax=docker/dockerfile:1
FROM clickhouse/clickhouse-server:26.2.3.2

LABEL org.opencontainers.image.title="clickhouse-secure" \
      org.opencontainers.image.source="https://github.com/OlegKarenkikh/clickhouse-secure" \
      org.opencontainers.image.licenses="Apache-2.0"

# policy-rc.d exit 101 prevents dpkg postinst from starting services during build.
# Without it, clickhouse-server postinst triggers entrypoint init and hangs on chown.
RUN printf '#!/bin/sh\nexit 101\n' > /usr/sbin/policy-rc.d \
    && chmod +x /usr/sbin/policy-rc.d \
    && apt-get update -qq \
    && apt-get upgrade -y -qq --no-install-recommends \
    && apt-get remove -y --purge --auto-remove wget apt apt-utils \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
    && rm -f /usr/sbin/policy-rc.d

EXPOSE 8123 9000 9009
