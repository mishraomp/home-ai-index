#!/bin/bash
# Verify that all required secrets are present and valid
# Exit with error code if any secrets are missing or invalid

set -e

echo "🔐 Verifying CI/CD secrets..."

EXIT_CODE=0
MISSING_SECRETS=()
INVALID_SECRETS=()

# Function to check if a secret exists and is not empty
check_secret() {
    local secret_name=$1
    local secret_value=${!secret_name}
    
    if [ -z "$secret_value" ]; then
        echo "❌ Missing: $secret_name"
        MISSING_SECRETS+=("$secret_name")
        EXIT_CODE=1
        return 1
    else
        echo "✅ Present: $secret_name"
        return 0
    fi
}

# Function to validate base64 encoding
validate_base64() {
    local secret_name=$1
    local secret_value=${!secret_name}
    
    if [ -z "$secret_value" ]; then
        return 1  # Already handled by check_secret
    fi
    
    # Try to decode the base64 value
    if echo "$secret_value" | base64 -d > /dev/null 2>&1; then
        echo "✅ Valid base64: $secret_name"
        return 0
    else
        echo "❌ Invalid base64: $secret_name"
        INVALID_SECRETS+=("$secret_name")
        EXIT_CODE=2
        return 1
    fi
}

echo ""
echo "📋 Checking Android signing secrets..."

# Check Android keystore secrets
check_secret "ANDROID_KEYSTORE_BASE64"
check_secret "ANDROID_KEYSTORE_PASSWORD"
check_secret "ANDROID_KEY_ALIAS"
check_secret "ANDROID_KEY_PASSWORD"

echo ""
echo "📋 Validating base64-encoded secrets..."

# Validate base64 encoding for keystore
if [ -n "$ANDROID_KEYSTORE_BASE64" ]; then
    validate_base64 "ANDROID_KEYSTORE_BASE64"
fi

# Optional: Check service account key if provided
if [ -n "$ANDROID_SERVICE_ACCOUNT_JSON_BASE64" ]; then
    echo ""
    echo "📋 Checking Google Play service account (optional)..."
    check_secret "ANDROID_SERVICE_ACCOUNT_JSON_BASE64"
    validate_base64 "ANDROID_SERVICE_ACCOUNT_JSON_BASE64"
fi

# Summary
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
if [ $EXIT_CODE -eq 0 ]; then
    echo "✅ All required secrets are present and valid"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
else
    echo "❌ Secret validation failed"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    if [ ${#MISSING_SECRETS[@]} -gt 0 ]; then
        echo ""
        echo "Missing secrets:"
        for secret in "${MISSING_SECRETS[@]}"; do
            echo "  - $secret"
        done
    fi
    
    if [ ${#INVALID_SECRETS[@]} -gt 0 ]; then
        echo ""
        echo "Invalid base64 encoding:"
        for secret in "${INVALID_SECRETS[@]}"; do
            echo "  - $secret"
        done
    fi
    
    echo ""
    echo "ℹ️  Please check your GitHub repository secrets:"
    echo "   Settings > Secrets and variables > Actions"
fi

exit $EXIT_CODE
