#!/bin/bash
# Setup Android build environment for CI/CD
# This script decodes the keystore and creates key.properties file

set -e

echo "🔧 Setting up Android build environment..."

# Check required environment variables
if [ -z "$ANDROID_KEYSTORE_BASE64" ]; then
    echo "❌ Error: ANDROID_KEYSTORE_BASE64 environment variable is not set"
    exit 1
fi

if [ -z "$ANDROID_KEYSTORE_PASSWORD" ]; then
    echo "❌ Error: ANDROID_KEYSTORE_PASSWORD environment variable is not set"
    exit 1
fi

if [ -z "$ANDROID_KEY_ALIAS" ]; then
    echo "❌ Error: ANDROID_KEY_ALIAS environment variable is not set"
    exit 1
fi

if [ -z "$ANDROID_KEY_PASSWORD" ]; then
    echo "❌ Error: ANDROID_KEY_PASSWORD environment variable is not set"
    exit 1
fi

# Create android/app directory if it doesn't exist
mkdir -p android/app

# Decode keystore from base64
echo "📦 Decoding keystore..."
if echo "$ANDROID_KEYSTORE_BASE64" | base64 -d > android/app/keystore.jks; then
    echo "✅ Keystore decoded successfully"
else
    echo "❌ Error: Failed to decode keystore"
    exit 2
fi

# Validate keystore file exists and has content
if [ ! -f android/app/keystore.jks ]; then
    echo "❌ Error: Keystore file was not created"
    exit 3
fi

if [ ! -s android/app/keystore.jks ]; then
    echo "❌ Error: Keystore file is empty"
    exit 3
fi

# Create key.properties file
echo "📝 Creating key.properties file..."
cat > android/key.properties <<EOF
storeFile=keystore.jks
storePassword=$ANDROID_KEYSTORE_PASSWORD
keyAlias=$ANDROID_KEY_ALIAS
keyPassword=$ANDROID_KEY_PASSWORD
EOF

echo "✅ key.properties created successfully"

# Validate keystore integrity (optional, requires keytool)
if command -v keytool &> /dev/null; then
    echo "🔍 Validating keystore integrity..."
    if keytool -list -v -keystore android/app/keystore.jks -storepass "$ANDROID_KEYSTORE_PASSWORD" -alias "$ANDROID_KEY_ALIAS" > /dev/null 2>&1; then
        echo "✅ Keystore validation passed"
    else
        echo "⚠️  Warning: Keystore validation failed (this may be normal if alias doesn't exist yet)"
    fi
else
    echo "ℹ️  Skipping keystore validation (keytool not available)"
fi

echo "✅ Android build environment setup complete"
exit 0
