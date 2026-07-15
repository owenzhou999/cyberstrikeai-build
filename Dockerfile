FROM golang:1.23-bookworm AS builder
WORKDIR /app
RUN git clone --depth 1 https://github.com/Ed1s0nZ/CyberStrikeAI.git .
RUN go env -w GOPROXY=https://proxy.golang.org,direct && \
    go mod download && \
    GOOS=linux GOARCH=arm64 CGO_ENABLED=0 go build -o cyberstrike-ai cmd/server/main.go

FROM python:3.12-slim-bookworm
WORKDIR /app
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates curl nmap sqlmap \
    && rm -rf /var/lib/apt/lists/*
COPY --from=builder /app/cyberstrike-ai /app/cyberstrike-ai
COPY --from=builder /app/tools /app/tools
COPY --from=builder /app/roles /app/roles
COPY --from=builder /app/skills /app/skills
COPY --from=builder /app/agents /app/agents
COPY --from=builder /app/web /app/web
COPY config.yaml /app/config.yaml
RUN mkdir -p /app/data /app/knowledge_base && chmod +x /app/cyberstrike-ai
EXPOSE 8080 8081
VOLUME ["/app/data", "/app/knowledge_base"]
CMD ["/app/cyberstrike-ai", "--http"]
