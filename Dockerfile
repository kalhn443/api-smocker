FROM  ghcr.io/smocker-dev/smocker:latest

# Install nginx
RUN apk add --no-cache nginx

# Create custom nginx.conf
RUN mkdir -p /etc/nginx && \
    echo -e "worker_processes 1;\n\nevents { worker_connections 1024; }\n\nhttp {\n    server {\n        listen 8080;\n\n        location / {\n            proxy_pass http://localhost:8081;\n        }\n\n        location /admin/ {\n            proxy_pass http://localhost:8082;\n        }\n    }\n}" > /etc/nginx/nginx.conf

# Expose ports for Nginx (8080)
EXPOSE 8080

# Create a script to run both Smocker and Nginx
RUN echo -e "#!/bin/sh\nsmocker --mock-server-listen-port=8081 --config-listen-port=8082 &\nnginx -g 'daemon off;'" > /start.sh && \
    chmod +x /start.sh

# Run the startup script
CMD ["/start.sh"]