#!/usr/bin/env bash
set -euo pipefail

echo "==> Updating Trivy DB..."
trivy image --download-db-only

echo ""
echo "==> Setup complete! Available commands:"
echo "    make build   — build Docker image"
echo "    make scan    — build + Trivy CVE scan"
echo "    make test    — build + smoke-test (HTTP ping + SELECT version())"
echo "    make clean   — remove local image"
echo ""
echo "    Note: the runtime image is distroless (no shell)."
echo "          Use 'make test' to verify the container instead of exec-ing into it."
