# =============================================================================
#  Multi-stage Dockerfile Example
# =============================================================================
#  This is a simple Dockerfile that will build an image of scratch-base image.
#  Usage:
#    docker build -t simple:local . && docker run --rm simple:local
# =============================================================================

# -----------------------------------------------------------------------------
#  Build Stage
# -----------------------------------------------------------------------------
FROM golang:alpine AS build

# Important:
#   Because this is a CGO enabled package, you are required to set it as 1.
ENV CGO_ENABLED=1

RUN apk add --no-cache \
    # Important: required for go-sqlite3
    gcc \
    # Required for Alpine
    musl-dev

WORKDIR /workspace

COPY . /workspace/

RUN \
    go install -ldflags='-s -w -extldflags "-static"' .
# -----------------------------------------------------------------------------
#  Main Stage
# -----------------------------------------------------------------------------
FROM alpine:3.14 as production
# Add certificates
RUN apk add --no-cache ca-certificates
RUN mkdir /usr/db
# Copy built binary from builder
COPY --from=build /go/bin/timeline /usr/local/bin/timeline
# Expose port
EXPOSE 3000
# Exec built binary
ENTRYPOINT [ "/usr/local/bin/timeline" ]