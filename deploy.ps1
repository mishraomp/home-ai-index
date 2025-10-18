# Quick Deploy Script for Windows PowerShell
# This script will deploy Home AI Index to your connected Android device

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Home AI Index - Quick Deploy" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check if Flutter is installed
Write-Host "Checking Flutter installation..." -ForegroundColor Yellow
if (!(Get-Command flutter -ErrorAction SilentlyContinue)) {
    Write-Host "ERROR: Flutter is not installed or not in PATH!" -ForegroundColor Red
    Write-Host "Please install Flutter from https://flutter.dev" -ForegroundColor Red
    exit 1
}

Write-Host "✓ Flutter found" -ForegroundColor Green
Write-Host ""

# Check for connected devices
Write-Host "Checking for connected devices..." -ForegroundColor Yellow
$devices = flutter devices --machine | ConvertFrom-Json

if ($devices.Count -eq 0) {
    Write-Host "ERROR: No devices found!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Please ensure:" -ForegroundColor Yellow
    Write-Host "  1. Your Android phone is connected via USB" -ForegroundColor Yellow
    Write-Host "  2. USB Debugging is enabled on your phone" -ForegroundColor Yellow
    Write-Host "  3. You've accepted the USB debugging prompt on your phone" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Or start an emulator with: flutter emulators --launch <emulator_id>" -ForegroundColor Yellow
    exit 1
}

# Show available devices
Write-Host "Available devices:" -ForegroundColor Green
foreach ($device in $devices) {
    $indicator = if ($device.targetPlatform -eq "android-x64" -or $device.targetPlatform -eq "android-arm" -or $device.targetPlatform -eq "android-arm64") { "✓" } else { " " }
    Write-Host "  $indicator $($device.name) [$($device.id)]" -ForegroundColor Cyan
}
Write-Host ""

# Get dependencies
Write-Host "Getting dependencies..." -ForegroundColor Yellow
flutter pub get
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Failed to get dependencies!" -ForegroundColor Red
    exit 1
}
Write-Host "✓ Dependencies ready" -ForegroundColor Green
Write-Host ""

# Ask user for deployment type
Write-Host "Select deployment type:" -ForegroundColor Yellow
Write-Host "  1. Quick Install (Release mode) - Recommended" -ForegroundColor Cyan
Write-Host "  2. Build APK only" -ForegroundColor Cyan
Write-Host "  3. Debug mode" -ForegroundColor Cyan
Write-Host ""

$choice = Read-Host "Enter choice (1-3)"

switch ($choice) {
    "1" {
        Write-Host ""
        Write-Host "Deploying in release mode..." -ForegroundColor Yellow
        Write-Host "This may take a few minutes on first build..." -ForegroundColor Gray
        Write-Host ""
        flutter run --release
    }
    "2" {
        Write-Host ""
        Write-Host "Building APK..." -ForegroundColor Yellow
        Write-Host "This may take a few minutes..." -ForegroundColor Gray
        Write-Host ""
        flutter build apk --release
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host ""
            Write-Host "========================================" -ForegroundColor Green
            Write-Host "  Build Successful!" -ForegroundColor Green
            Write-Host "========================================" -ForegroundColor Green
            Write-Host ""
            Write-Host "APK Location:" -ForegroundColor Cyan
            Write-Host "  build\app\outputs\flutter-apk\app-release.apk" -ForegroundColor Yellow
            Write-Host ""
            Write-Host "To install on your device:" -ForegroundColor Cyan
            Write-Host "  adb install build\app\outputs\flutter-apk\app-release.apk" -ForegroundColor Yellow
            Write-Host ""
        }
    }
    "3" {
        Write-Host ""
        Write-Host "Deploying in debug mode..." -ForegroundColor Yellow
        Write-Host ""
        flutter run
    }
    default {
        Write-Host "Invalid choice. Exiting." -ForegroundColor Red
        exit 1
    }
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "  Deployment Complete!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "  1. Open 'Home AI Index' on your device" -ForegroundColor Yellow
Write-Host "  2. Grant camera and storage permissions" -ForegroundColor Yellow
Write-Host "  3. Start adding items!" -ForegroundColor Yellow
Write-Host ""
