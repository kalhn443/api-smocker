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
# Start smocker in background (redirect to /dev/null to suppress logs)
echo "Starting smocker..."
nohup ./smocker -mock-server-listen-port=8081 -config-listen-port=8082 > /dev/null 2>&1 &

# Wait a moment for smocker to start
sleep 2

# Start nginx in foreground
echo "Starting nginx..."
exec nginx -g 'daemon off;'
EOF

# Make startup script executable
RUN chmod +x /app/start.sh

# Expose ports
EXPOSE 8080

# Use startup script as entrypoint
CMD ["/app/start.sh"]