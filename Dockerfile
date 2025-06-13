# Use official nginx image as base
FROM nginx:alpine

# Install required packages
RUN apk add --no-cache \
    bash \
    curl \
    procps

# Create working directory
WORKDIR /app

# Copy nginx configuration
COPY nginx.conf /etc/nginx/nginx.conf

# Copy smocker binary
COPY smocker /app/smocker
COPY /client /app/client


# Make smocker executable
RUN chmod +x /app/smocker

# Copy startup script
COPY <<EOF /app/start.sh
#!/bin/bash

# Start smocker in background
echo "Starting smocker..."
nohup ./smocker -mock-server-listen-port=8081 -config-listen-port=8082 > /var/log/smocker.log 2>&1 &

# Wait a moment for smocker to start
sleep 2

# Start nginx in foreground
echo "Starting nginx..."
exec nginx -g 'daemon off;'
EOF

# Make startup script executable
RUN chmod +x /app/start.sh

# Expose ports
EXPOSE 80 8081 8082

# Use startup script as entrypoint
CMD ["/app/start.sh"]