# Multi-stage build for better reliability
FROM alpine:latest as downloader

# Install required packages for downloading
RUN apk add --no-cache wget file

# Download smocker binary
RUN wget -O /tmp/smocker https://github.com/smocker-dev/smocker/releases/latest/download/smocker_linux_amd64 && \
    chmod +x /tmp/smocker && \
    file /tmp/smocker

# Final stage
FROM alpine:latest

# Install runtime dependencies
RUN apk add --no-cache ca-certificates libc6-compat

# Create smocker directory and user
RUN mkdir -p /opt/smocker && \
    addgroup -g 1001 smocker && \
    adduser -D -s /bin/sh -u 1001 -G smocker smocker

# Copy smocker binary from downloader stage
COPY --from=downloader /tmp/smocker /opt/smocker/smocker

# Set ownership and permissions
RUN chown -R smocker:smocker /opt/smocker && \
    chmod +x /opt/smocker/smocker

# Set working directory
WORKDIR /opt/smocker

# Switch to non-root user
USER smocker

# Expose ports
EXPOSE 8080 8081

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD wget --no-verbose --tries=1 --spider http://localhost:8081 || exit 1

# Run smocker
CMD ["./smocker", "-mock-server-listen-port=8080", "-config-listen-port=8081"]