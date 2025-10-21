#!/bin/bash

# Check Writer Production Startup Script

echo "====================================="
echo "Check Writer Production Build"
echo "====================================="
echo ""

# Check if npm is installed
if ! command -v npm &> /dev/null; then
    echo "Error: npm is not installed. Please install Node.js and npm"
    exit 1
fi

# Build frontend
echo "Building frontend..."
cd frontend
npm run build
cd ..

echo ""
echo "Frontend built successfully!"
echo ""
echo "Starting production server on http://localhost:4567"
echo "Press Ctrl+C to stop"
echo ""

# Start server
ruby server.rb
