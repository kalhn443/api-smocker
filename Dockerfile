FROM alpine:3.20

# Install dependencies: wget, tar, and nginx
RUN apk add --no-cache wget tar nginx

# Create directory for Smocker
RUN mkdir -p /opt/smocker

# Set working directory
WORKDIR /opt/smocker

# Download and extract the latest Smocker release
RUN wget -P /tmp https://github.com/smocker-dev/smocker/releases/latest/download/smocker.tar.gz && \
    tar xf /tmp/smocker.tar.gz -C /opt/smocker && \
    rm /tmp/smocker.tar.gz

# Create custom nginx.conf
RUN mkdir -p /etc/nginx
RUN echo -e "worker_processes 1;\n\nevents { worker_connections 1024; }\n\nhttp {\n    server {\n        listen 80;\n\n        location / {\n            proxy_pass http://localhost:8080;\n        }\n\n        location /admin/ {\n            proxy_pass http://localhost:8081;\n        }\n    }\n}" > /etc/nginx/nginx.conf

# Expose ports for Nginx (80) and Smocker (8080, 8081)
EXPOSE 80 8080 8081

# Create a script to run both Smocker and Nginx
RUN echo -e "#!/bin/sh\n./smocker --mock-server-listen-port=8080 --config-listen-port=8081 &\nnginx -g 'daemon off;'" > /start.sh
RUN chmod +x /start.sh

# Run the startup script
CMD ["/start.sh"]