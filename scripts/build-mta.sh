#!/bin/bash

# Script to build MTA archive for deployment

echo "🔨 Building MTA archive for IMA-APP..."

# Check if MBT is installed
if ! command -v mbt &> /dev/null; then
    echo "❌ MBT (MTA Build Tool) is not installed."
    echo "Please install it with: npm install -g mbt"
    exit 1
fi

# Clean previous builds
echo "🧹 Cleaning previous builds..."
rm -rf gen/
rm -rf mta_archives/

# Install dependencies
echo "📦 Installing dependencies..."
npm install

# Install UI dependencies
echo "📦 Installing UI dependencies..."
cd app
npm install
cd ..

# Build MTA
echo "🔨 Building MTA archive..."
mbt build

echo "✅ MTA build completed successfully!"
echo "📦 Archive location: mta_archives/ima-app_1.0.0.mtar"
