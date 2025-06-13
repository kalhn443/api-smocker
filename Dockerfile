FROM alpine:3.20

# Install dependencies: wget, tar, and nginx
RUN apk add --no-cache wget tar nginx

# Create directory for Smocker and set as working directory
RUN mkdir -p /opt/smocker && cd /opt/smocker

# Download and extract the latest Smocker release
RUN wget -P /tmp https://github.com/smocker-dev/smocker/releases/latest/download/smocker.tar.gz && \
    tar -xf /tmp/smocker.tar.gz -C /opt/smocker && \
    chmod +x /opt/smocker/smocker && \
    rm /tmp/smocker.tar.gz

# Set working directory
WORKDIR /opt/smocker

# Create custom nginx.conf
RUN mkdir -p /etc/nginx && \
    echo -e "worker_processes 1;\n\nevents { worker_connections 1024; }\n\nhttp {\n    server {\n        listen 8080;\n\n        location / {\n            proxy_pass http://localhost:8081;\n        }\n\n        location /admin/ {\n            proxy_pass http://localhost:8082;\n        }\n    }\n}" > /etc/nginx/nginx.conf

# Expose port for Nginx (8080)
EXPOSE 8080

# Create a script to run both Smocker and Nginx
RUN echo -e "#!/bin/sh\n/opt/smocker/smocker --mock-server-listen-port=8081 --config-listen-port=8082 &\nnginx -g 'daemon off;'" > /start.sh && \
    chmod +x /start.sh

# Run the startup script
CMD ["/start.sh"]