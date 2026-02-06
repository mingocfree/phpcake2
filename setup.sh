#!/bin/bash

echo "========================================="
echo "CakePHP 2 Docker Setup Script"
echo "========================================="
echo ""

# Create app directory if it doesn't exist
if [ ! -d "app" ]; then
    echo "Creating app directory..."
    mkdir app
fi

# Check if CakePHP is already downloaded
if [ -z "$(ls -A app)" ]; then
    echo "Downloading CakePHP 2.10.24..."
    curl -L https://github.com/cakephp/cakephp/archive/2.10.24.tar.gz -o cakephp.tar.gz
    
    echo "Extracting CakePHP..."
    tar -xzf cakephp.tar.gz --strip-components=1 -C app
    
    echo "Cleaning up..."
    rm cakephp.tar.gz
    
    echo "CakePHP 2 downloaded successfully!"
else
    echo "CakePHP appears to be already downloaded. Skipping download."
fi

# Copy database config if it doesn't exist
if [ ! -f "app/app/Config/database.php" ]; then
    echo "Setting up database configuration..."
    cp app/app/Config/database.php.default app/app/Config/database.php
    
    # Update database config using sed (macOS compatible)
    sed -i '' "s/'host' => 'localhost',/'host' => 'db',/g" app/app/Config/database.php
    sed -i '' "s/'login' => 'user',/'login' => 'cakephp_user',/g" app/app/Config/database.php
    sed -i '' "s/'password' => 'password',/'password' => 'cakephp_pass',/g" app/app/Config/database.php
    sed -i '' "s/'database' => 'project_name',/'database' => 'cakephp_db',/g" app/app/Config/database.php
    
    echo "Database configuration updated!"
else
    echo "Database configuration already exists. Skipping."
fi

# Generate random security keys
SALT=$(openssl rand -base64 40 | tr -d "=+/" | cut -c1-40)
SEED=$(shuf -i 100000000-999999999 -n 1)

echo "Updating security keys in core.php..."
sed -i '' "s/DYhG93b0qyJfIxfs2guVoUubWwvniR2G0FgaC9mi/$SALT/g" app/app/Config/core.php
sed -i '' "s/76859309657453542496749683645/$SEED/g" app/app/Config/core.php

echo ""
echo "Building Docker containers..."
docker compose build

echo ""
echo "Starting Docker containers..."
docker compose up -d

echo ""
echo "Waiting for containers to be ready..."
sleep 10

echo ""
echo "Setting proper permissions..."
docker exec cakephp2-app chmod -R 777 /app/app/tmp

echo ""
echo "========================================="
echo "Setup Complete!"
echo "========================================="
echo ""
echo "Your CakePHP 2 application is now running:"
echo "- Application: http://localhost:8080"
echo "- phpMyAdmin: http://localhost:8081"
echo ""
echo "Database credentials:"
echo "- Host: db"
echo "- Database: cakephp_db"
echo "- Username: cakephp_user"
echo "- Password: cakephp_pass"
echo ""
echo "To view logs: docker compose logs -f"
echo "To stop: docker compose down"
echo "========================================="