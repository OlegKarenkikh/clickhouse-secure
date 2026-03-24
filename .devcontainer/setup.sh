#!/usr/bin/env bash
# setup.sh - postCreateCommand for GitHub Codespaces / VS Code devcontainer
# NOTE: set -e is intentionally NOT used here so that optional steps
# (e.g. trivy DB download, dotfiles noise from other repos) never break
# the devcontainer initialisation.
set -uo pipefail

# ---------------------------------------------------------------------------
# This repo is a Docker-image build project.
# It has NO database, NO Prisma schema, NO golang-migrate.
# If you see messages like "N migrations found" or
# "golang-migrate is not installed" - they come from a global dotfiles
# repository or Codespaces lifecycle hooks configured in your GitHub
# account settings. They are harmless and can be ignored.
# ---------------------------------------------------------------------------

echo "==> [clickhouse-secure] Running devcontainer setup..."

# Update Trivy vulnerability DB (optional - failures are non-fatal)
if command -v trivy &>/dev/null; then
  echo "==> Updating Trivy DB..."
  trivy image --download-db-only || echo "WARN: trivy DB update failed (non-fatal, will retry on first scan)"
else
  echo "WARN: trivy not found in PATH, skipping DB update"
fi

echo ""
echo "==> Setup complete! Available commands:"
echo "    make build   - build Docker image"
echo "    make scan    - build + Trivy CVE scan"
echo "    make test    - build + smoke-test (HTTP ping + SELECT version())"
echo "    make clean   - remove local image"
echo ""
echo "    Note: the runtime image is distroless (no shell)."
echo "          Use 'make test' to verify the container instead of exec-ing into it."
