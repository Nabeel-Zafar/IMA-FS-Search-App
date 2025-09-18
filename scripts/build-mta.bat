@echo off
echo 🔨 Building MTA archive for IMA-APP...

REM Check if MBT is installed
where mbt >nul 2>nul
if %errorlevel% neq 0 (
    echo ❌ MBT (MTA Build Tool) is not installed.
    echo Please install it with: npm install -g mbt
    exit /b 1
)

REM Clean previous builds
echo 🧹 Cleaning previous builds...
if exist gen rmdir /s /q gen
if exist mta_archives rmdir /s /q mta_archives

REM Install dependencies
echo 📦 Installing dependencies...
call npm install

REM Install UI dependencies
echo 📦 Installing UI dependencies...
cd app
call npm install
cd ..

REM Build MTA
echo 🔨 Building MTA archive...
call mbt build

echo ✅ MTA build completed successfully!
echo 📦 Archive location: mta_archives\ima-app_1.0.0.mtar
