@echo off
echo 🗄️ Setting up HANA Cloud instance for IMA-APP...

echo 📋 Current CF target:
cf target

set /p continue=Do you want to continue with this target? (y/n): 
if /i not "%continue%"=="y" exit /b 1

echo 🔍 Checking available HANA Cloud service plans...
cf marketplace -e hana-cloud

echo.
echo 🗄️ Creating HANA Cloud database instance...
echo ⚠️  This will take 10-15 minutes to complete.

set /p db_password=Enter a password for the HANA database administrator (min 8 chars, mixed case, numbers): 

echo {> hana-cloud-config.json
echo   "data": {>> hana-cloud-config.json
echo     "memory": 30,>> hana-cloud-config.json
echo     "vcpu": 2,>> hana-cloud-config.json
echo     "generateSystemPassword": false,>> hana-cloud-config.json
echo     "systemPassword": "%db_password%",>> hana-cloud-config.json
echo     "enabledservices": {>> hana-cloud-config.json
echo       "docstore": false,>> hana-cloud-config.json
echo       "dpserver": false>> hana-cloud-config.json
echo     }>> hana-cloud-config.json
echo   }>> hana-cloud-config.json
echo }>> hana-cloud-config.json

cf create-service hana-cloud hana ima-hana-cloud-db -c hana-cloud-config.json

echo 🕐 Waiting for HANA Cloud database to be created...
echo ℹ️  You can check the status with: cf service ima-hana-cloud-db
echo ℹ️  Once it shows 'create succeeded', you can proceed with HDI container creation.

del hana-cloud-config.json

echo.
echo 📝 Next steps after HANA Cloud is ready:
echo 1. Verify: cf service ima-hana-cloud-db
echo 2. Create HDI container: cf create-service hana hdi-shared ima-app-db
echo 3. Continue with deployment: scripts\deploy.bat
