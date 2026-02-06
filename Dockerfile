FROM webdevops/php-apache-dev:5.6

# Set working directory
WORKDIR /app

# Copy application files (will be mounted as volume)
# Application files will come from the volume mount

# Set proper permissions for tmp directory
RUN mkdir -p /app/app/tmp && \
    chown -R application:application /app

# Expose port 80
EXPOSE 80