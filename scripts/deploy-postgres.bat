@echo off
echo 🚀 Starting PostgreSQL deployment of IMA-APP to Cloud Foundry...

REM Check if CF CLI is installed
where cf >nul 2>nul
if %errorlevel% neq 0 (
    echo ❌ Cloud Foundry CLI is not installed. Please install it first.
    exit /b 1
)

REM Check if MTA plugin is installed
cf plugins | findstr /c:"multiapps" >nul
if %errorlevel% neq 0 (
    echo 📦 Installing MTA plugin...
    cf install-plugin https://github.com/cloudfoundry/multiapps-cli-plugin/releases/latest/download/multiapps-plugin.win64.exe -f
)

REM Check if user is logged in
cf target >nul 2>nul
if %errorlevel% neq 0 (
    echo ❌ Please log in to Cloud Foundry first: cf login
    exit /b 1
)

echo 📋 Current CF target:
cf target

set /p continue=Do you want to continue with this target? (y/n): 
if /i not "%continue%"=="y" exit /b 1

REM Check if services exist
echo 🔍 Checking if required services exist...
cf service ima-app-db >nul 2>nul
if %errorlevel% neq 0 (
    echo ❌ PostgreSQL service 'ima-app-db' not found. Please run: scripts\setup-postgres-services.bat
    exit /b 1
)

cf service ima-app-xsuaa >nul 2>nul
if %errorlevel% neq 0 (
    echo ❌ XSUAA service 'ima-app-xsuaa' not found. Please run: scripts\setup-postgres-services.bat
    exit /b 1
)

REM Install dependencies
echo 📦 Installing dependencies...
call npm install

REM Build the application
echo 🔨 Building application...
call npm run build

REM Deploy using MTA
echo 🚀 Deploying to Cloud Foundry...
if exist "mta_archives\ima-app_1.0.0.mtar" (
    cf deploy mta_archives\ima-app_1.0.0.mtar
) else (
    echo ❌ MTA archive not found. Please build the MTA first with: scripts\build-mta.bat
    exit /b 1
)

echo ✅ Deployment completed successfully!
echo 🌐 Your application should be available shortly.

REM Show app status
echo 📊 Application status:
cf apps | findstr ima-app

echo.
echo 🎉 PostgreSQL deployment complete!
echo 📝 Your IMA-APP is now running on PostgreSQL in Cloud Foundry.
