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
# Start smocker in background with explicit binding to all interfaces
echo "Starting smocker..."
nohup ./smocker -mock-server-listen-port=8081 -config-listen-port=8082 -mock-server-listen-host=0.0.0.0 -config-listen-host=0.0.0.0 > /dev/null 2>&1 &

# Wait longer for smocker to start and verify it's running
echo "Waiting for smocker to start..."
for i in {1..30}; do
    if curl -s http://localhost:8081 > /dev/null 2>&1; then
        echo "Smocker is ready!"
        break
    fi
    echo "Waiting... ($i/30)"
    sleep 1
done

# Check if smocker is actually running
if ! curl -s http://localhost:8081 > /dev/null 2>&1; then
    echo "ERROR: Smocker failed to start properly"
    exit 1
fi

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