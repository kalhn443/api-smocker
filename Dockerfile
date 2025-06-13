# Use Alpine Linux as base image for smaller size
FROM alpine:latest

# Install required packages
RUN apk add --no-cache \
    wget \
    tar \
    ca-certificates

# Create smocker directory
RUN mkdir -p /opt/smocker

# Set working directory
WORKDIR /opt/smocker

# Download and extract smocker
RUN wget -O /tmp/smocker.tar.gz https://github.com/smocker-dev/smocker/releases/latest/download/smocker.tar.gz && \
    tar xf /tmp/smocker.tar.gz -C /opt/smocker && \
    rm /tmp/smocker.tar.gz && \
    chmod +x /opt/smocker/smocker

# Expose ports
# Mock server port
EXPOSE 8080
# Config/Admin UI port  
EXPOSE 8081

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD wget --no-verbose --tries=1 --spider http://localhost:8081 || exit 1

# Run smocker
CMD ["./smocker", "-mock-server-listen-port=8080", "-config-listen-port=8081"]