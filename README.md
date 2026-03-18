# clickhouse-secure

Hardened ClickHouse **v26.2.3.2** Docker image with near-zero CVEs.

| Layer | Base | Purpose |
|---|---|---|
| Stage 1 (build) | `clickhouse/clickhouse-server:26.2.3.2-alpine` | Extracts the binary and configs |
| Stage 2 (runtime) | `cgr.dev/chainguard/glibc-dynamic` | Distroless — no shell, no package manager, minimal attack surface |

The runtime image has no shell, so the entrypoint calls the `clickhouse-server` binary directly (not via a shell script).

---

## Quick start

```bash
docker run -d \
  --name clickhouse \
  -p 8123:8123 \
  -p 9000:9000 \
  common-docker.artifactory.corp.ingos.ru/olegkarenkikh/clickhouse-secure:latest
```

### Test the container is running

```bash
# HTTP ping — should return "Ok."
curl http://localhost:8123/ping

# Query the server version
curl 'http://localhost:8123/?query=SELECT+version()'

# Simple arithmetic test
curl 'http://localhost:8123/?query=SELECT+1+%2B+1'
```

---

## Persistent data (recommended for production)

Mount volumes for data, logs, and config so they survive container restarts:

```bash
docker run -d \
  --name clickhouse \
  -p 8123:8123 \
  -p 9000:9000 \
  -v /opt/clickhouse/data:/var/lib/clickhouse \
  -v /opt/clickhouse/logs:/var/log/clickhouse-server \
  -v /opt/clickhouse/config.d:/etc/clickhouse-server/config.d \
  -v /opt/clickhouse/users.d:/etc/clickhouse-server/users.d \
  common-docker.artifactory.corp.ingos.ru/olegkarenkikh/clickhouse-secure:latest
```

| Host path | Container path | Description |
|---|---|---|
| `/opt/clickhouse/data` | `/var/lib/clickhouse` | Database files |
| `/opt/clickhouse/logs` | `/var/log/clickhouse-server` | Server and error logs |
| `/opt/clickhouse/config.d` | `/etc/clickhouse-server/config.d` | Drop-in server config overrides |
| `/opt/clickhouse/users.d` | `/etc/clickhouse-server/users.d` | Drop-in user/password overrides |

---

## Setting a password for the default user

Create `/opt/clickhouse/users.d/password.xml` on the host:

```xml
<clickhouse>
  <users>
    <default>
      <password>my-strong-password</password>
    </default>
  </users>
</clickhouse>
```

Then mount that directory and restart the container.

---

## Ports

| Port | Protocol | Description |
|---|---|---|
| `8123` | HTTP | REST / HTTP interface |
| `9000` | TCP | Native ClickHouse client protocol |
| `9009` | TCP | Inter-server replication |

---

## Overriding the config file

`CMD` in the image defaults to `--config-file=/etc/clickhouse-server/config.xml`.  
You can override it at `docker run` time:

```bash
docker run -d \
  -v /my/config.xml:/etc/clickhouse-server/config.xml \
  common-docker.artifactory.corp.ingos.ru/olegkarenkikh/clickhouse-secure:latest \
  --config-file=/etc/clickhouse-server/config.xml
```

---

## Building locally

```bash
git clone https://github.com/OlegKarenkikh/clickhouse-secure.git
cd clickhouse-secure
make build        # docker build
make scan         # docker build + Trivy CVE scan
```

---

## Why "no such file or directory" happened (and how it was fixed)

The `cgr.dev/chainguard/glibc-dynamic` runtime is intentionally **distroless** — it contains no shell (`/bin/sh`, `/bin/bash`, etc.).  
The original `ENTRYPOINT ["/entrypoint.sh"]` tried to execute a shell script; without a shell the Linux kernel returned:

```
exec /entrypoint.sh: no such file or directory
```

**Fix:** the entrypoint now calls the ClickHouse binary directly — no shell needed:

```dockerfile
ENTRYPOINT ["/usr/bin/clickhouse-server"]
CMD ["--config-file=/etc/clickhouse-server/config.xml"]
```
