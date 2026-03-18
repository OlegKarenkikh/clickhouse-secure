IMAGE_NAME  := clickhouse-secure
IMAGE_TAG   := $(shell git rev-parse --short HEAD 2>/dev/null || echo dev)
FULL_IMAGE  := $(IMAGE_NAME):$(IMAGE_TAG)

.PHONY: build scan test clean

build:
	docker build -t $(FULL_IMAGE) .
	@echo "Built: $(FULL_IMAGE)"

scan: build
	trivy image \
		--ignorefile .trivyignore \
		--ignore-unfixed \
		--severity CRITICAL,HIGH,MEDIUM \
		$(FULL_IMAGE)

# Smoke-test: verify the server starts and responds to an HTTP ping.
# The runtime is distroless (no shell), so interactive exec is not available.
test: build
	@echo "Starting container..."
	@CID=$$(docker run -d --rm -p 18123:8123 $(FULL_IMAGE)); \
	sleep 10; \
	echo "Ping:"; \
	curl -sf http://localhost:18123/ping || (docker logs $$CID; docker stop $$CID; exit 1); \
	echo "Version:"; \
	curl -sf 'http://localhost:18123/?query=SELECT+version()'; \
	docker stop $$CID; \
	echo "Test passed."

clean:
	docker rmi $(FULL_IMAGE) 2>/dev/null || true
