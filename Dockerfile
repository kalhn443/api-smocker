FROM debian:bullseye-slim

# Install dependencies: wget, tar, and nginx
RUN apt-get update && apt-get install -y wget tar nginx && rm -rf /var/lib/apt/lists/*

# Create directory for Smocker and set as working directory
RUN mkdir -p /opt/smocker
WORKDIR /opt/smocker

# Download and extract the latest Smocker release with debug
RUN wget -P /tmp https://github.com/smocker-dev/smocker/releases/latest/download/smocker_linux_amd64.tar.gz && \
    tar -xvf /tmp/smocker_linux_amd64.tar.gz -C /opt/smocker && \
    ls -l /opt/smocker && \
    chmod +x /opt/smocker/smocker && \
    rm /tmp/smocker_linux_amd64.tar.gz

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