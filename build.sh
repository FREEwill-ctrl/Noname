#!/bin/bash

# BuildFork Optimized Build Script
# This script builds the Flutter application for Android

echo "Starting BuildFork Optimized build process..."

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo "Flutter not found. Installing Flutter SDK..."
    
    # Download and install Flutter
    cd /tmp
    wget https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.16.0-stable.tar.xz
    tar xf flutter_linux_3.16.0-stable.tar.xz
    export PATH="$PATH:/tmp/flutter/bin"
    
    # Add Flutter to PATH permanently
    echo 'export PATH="$PATH:/tmp/flutter/bin"' >> ~/.bashrc
    
    echo "Flutter SDK installed successfully!"
fi

# Navigate to project directory
cd "$(dirname "$0")"

echo "Getting Flutter dependencies..."
flutter pub get

echo "Running Flutter doctor..."
flutter doctor

echo "Building APK..."
flutter build apk --release

echo "Building App Bundle..."
flutter build appbundle --release

echo "Build completed successfully!"
echo "APK location: build/app/outputs/flutter-apk/app-release.apk"
echo "App Bundle location: build/app/outputs/bundle/release/app-release.aab"

