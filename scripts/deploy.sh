#!/bin/bash

# Deployment script for IMA-APP to Cloud Foundry

echo "🚀 Starting deployment of IMA-APP to Cloud Foundry..."

# Check if CF CLI is installed
if ! command -v cf &> /dev/null; then
    echo "❌ Cloud Foundry CLI is not installed. Please install it first."
    exit 1
fi

# Check if MTA plugin is installed
if ! cf plugins | grep -q "multiapps"; then
    echo "📦 Installing MTA plugin..."
    cf install-plugin https://github.com/cloudfoundry/multiapps-cli-plugin/releases/latest/download/multiapps-plugin.linux64 -f
fi

# Check if user is logged in
if ! cf target &> /dev/null; then
    echo "❌ Please log in to Cloud Foundry first: cf login"
    exit 1
fi

echo "📋 Current CF target:"
cf target

read -p "Do you want to continue with this target? (y/n): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    exit 1
fi

# Install dependencies
echo "📦 Installing dependencies..."
npm install

# Build the application
echo "🔨 Building application..."
npm run build

# Deploy using MTA
echo "🚀 Deploying to Cloud Foundry..."
if [ -f "mta_archives/ima-app_1.0.0.mtar" ]; then
    cf deploy mta_archives/ima-app_1.0.0.mtar
else
    echo "❌ MTA archive not found. Please build the MTA first with: mbt build"
    exit 1
fi

echo "✅ Deployment completed successfully!"
echo "🌐 Your application should be available shortly."

# Show app status
echo "📊 Application status:"
cf apps | grep ima-app
