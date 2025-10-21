#!/bin/bash

# Check Writer Development Startup Script

echo "====================================="
echo "Check Writer Development Environment"
echo "====================================="
echo ""

# Check if bundle is installed
if ! command -v bundle &> /dev/null; then
    echo "Error: bundler is not installed. Please run: gem install bundler"
    exit 1
fi

# Check if npm is installed
if ! command -v npm &> /dev/null; then
    echo "Error: npm is not installed. Please install Node.js and npm"
    exit 1
fi

# Install dependencies if needed
if [ ! -d "frontend/node_modules" ]; then
    echo "Installing frontend dependencies..."
    cd frontend && npm install && cd ..
fi

echo "Starting servers..."
echo ""
echo "Backend will run on: http://localhost:4567"
echo "Frontend will run on: http://localhost:3000"
echo ""
echo "Press Ctrl+C to stop both servers"
echo ""

# Start backend in background
ruby server.rb &
BACKEND_PID=$!

# Give backend time to start
sleep 2

# Start frontend
cd frontend && npm run dev &
FRONTEND_PID=$!

# Wait for Ctrl+C
trap "kill $BACKEND_PID $FRONTEND_PID; exit" INT

# Wait for both processes
wait
