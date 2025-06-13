FROM ubuntu:22.04

# Install Nginx and dependencies
RUN apt-get update && apt-get install -y nginx curl

# Download Smocker binary
RUN curl -L https://github.com/SmockerDev/smocker/releases/download/v0.19.0/smocker-linux-amd64 -o /usr/local/bin/smocker && \
    chmod +x /usr/local/bin/smocker

# Copy nginx config
COPY nginx.conf /etc/nginx/nginx.conf

# Run both smocker and nginx
CMD /usr/local/bin/smocker & nginx -g 'daemon off;'
