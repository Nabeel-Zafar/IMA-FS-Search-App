@echo off
echo 🐘 Setting up PostgreSQL services for IMA-APP...

echo 📋 Current CF target:
cf target

set /p continue=Do you want to continue with this target? (y/n): 
if /i not "%continue%"=="y" exit /b 1

echo 🔍 Checking available PostgreSQL service plans...
cf marketplace | findstr postgres

echo.
echo 🐘 Creating PostgreSQL service instance...
cf create-service postgresql v9.4-dev ima-app-db

echo 📱 Creating XSUAA service...
cf create-service xsuaa application ima-app-xsuaa -c xs-security.json

echo 🌐 Creating Destination service...
cf create-service destination lite ima-app-destination-service

echo 🗂️ Creating HTML5 Repository service...
cf create-service html5-apps-repo app-host ima-app-html5-repo-host

echo.
echo ✅ All services created successfully!
echo 📝 You can now proceed with deployment.

echo.
echo 📊 Current services:
cf services

echo.
echo 🚀 Next steps:
echo 1. Build the application: scripts\build-mta.bat
echo 2. Deploy to Cloud Foundry: scripts\deploy.bat
