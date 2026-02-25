#!/bin/bash

# Configuration
PROJECT_ROOT=$(pwd)
BACKEND_DIR="$PROJECT_ROOT/kobo-admin"
BUILD_DIR="$PROJECT_ROOT/build/web"
PUBLIC_DIR="$BACKEND_DIR/public"

echo "🚀 Starting KOBBO Web Deployment..."

# 1. Build Flutter Web
echo "📦 Building Flutter Web (Release)..."
flutter build web --release

# 2. Prepare Backend Public Directory
echo "🧹 Cleaning backend public directory..."
rm -rf "$PUBLIC_DIR"
mkdir -p "$PUBLIC_DIR"

# 3. Copy files
echo "🚚 Copying build files to backend..."
cp -r "$BUILD_DIR/"* "$PUBLIC_DIR/"

echo "✅ Deployment Complete!"
echo "👉 You can now run 'node index.js' in the kobo-admin folder."
echo "🌐 Then access the dashboard at: http://localhost:3000"
