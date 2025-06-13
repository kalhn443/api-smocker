FROM ubuntu:22.04

# Install nginx and curl
RUN apt-get update && \
    apt-get install -y curl nginx

# Download Smocker
RUN curl -L https://github.com/SmockerDev/smocker/releases/download/v0.19.0/smocker-linux-amd64 -o /usr/local/bin/smocker && \
    chmod +x /usr/local/bin/smocker

# Copy Nginx config
COPY nginx.conf /etc/nginx/nginx.conf

# Expose Nginx port
EXPOSE 8080

# Run Smocker with custom ports: --port=8081 (API), --ui-port=8082 (Admin UI)
CMD /usr/local/bin/smocker -mock-server-listen-port=8081 -config-listen-port=8082 & \
    nginx -g 'daemon off;'
