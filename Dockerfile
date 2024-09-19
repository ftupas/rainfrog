FROM rust:alpine3.20 AS builder
WORKDIR /app

# Install system dependencies
RUN apk add --no-cache musl-dev=1.2.5-r0

# Build application
COPY . .
RUN cargo build --release

# Create runtime image
FROM debian:bookworm-slim AS runtime
WORKDIR /usr/src/app

# Create non-root user
RUN useradd -m -s /bin/bash rainfrog

# Copy the binary from the builder image
COPY --chmod=755 --from=builder /app/target/release/rainfrog /usr/local/bin/rainfrog

# Change ownership of the files to the non-root user
RUN chown -R rainfrog:rainfrog /usr/src/app
USER rainfrog

HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
  CMD pidof rainfrog || exit 1

# Command to construct the full connection URL using environment variables
CMD ["bash", "-c", "rainfrog --url postgres://$username:$password@$hostname:$db_port/$dbname"]
