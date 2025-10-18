#!/bin/bash
# Increment build number based on git commit count
# Outputs JSON with version information for use in GitHub Actions

set -e

echo "🔢 Generating build number..."

# Get git commit count as build number
BUILD_NUMBER=$(git rev-list --count HEAD)
echo "ℹ️  Git commit count: $BUILD_NUMBER"

# Get current version from pubspec.yaml
if [ ! -f pubspec.yaml ]; then
    echo "❌ Error: pubspec.yaml not found"
    exit 1
fi

# Extract version line (format: "version: 1.0.0+1")
VERSION_LINE=$(grep "^version:" pubspec.yaml | head -n 1)
if [ -z "$VERSION_LINE" ]; then
    echo "❌ Error: Version not found in pubspec.yaml"
    exit 2
fi

# Extract version name (e.g., "1.0.0")
VERSION_NAME=$(echo "$VERSION_LINE" | sed 's/version: *//' | sed 's/+.*//')
echo "ℹ️  Current version name: $VERSION_NAME"

# Create new version string
NEW_VERSION="${VERSION_NAME}+${BUILD_NUMBER}"
echo "✅ New version: $NEW_VERSION"

# Update pubspec.yaml with new build number
echo "📝 Updating pubspec.yaml..."
if sed -i.bak "s/^version: .*/version: ${NEW_VERSION}/" pubspec.yaml; then
    rm -f pubspec.yaml.bak
    echo "✅ pubspec.yaml updated successfully"
else
    echo "❌ Error: Failed to update pubspec.yaml"
    exit 3
fi

# Verify the update
UPDATED_VERSION=$(grep "^version:" pubspec.yaml | head -n 1 | sed 's/version: *//')
if [ "$UPDATED_VERSION" != "$NEW_VERSION" ]; then
    echo "❌ Error: Version update verification failed"
    echo "Expected: $NEW_VERSION"
    echo "Got: $UPDATED_VERSION"
    exit 4
fi

# Extract build number from updated version
FINAL_BUILD_NUMBER=$(echo "$NEW_VERSION" | sed 's/.*+//')

# Output as JSON for GitHub Actions
echo "📤 Outputting version info..."
cat <<EOF
{
  "version_name": "$VERSION_NAME",
  "build_number": "$FINAL_BUILD_NUMBER",
  "full_version": "$NEW_VERSION"
}
EOF

# Also set as GitHub Actions outputs if running in GitHub Actions
if [ -n "$GITHUB_OUTPUT" ]; then
    echo "version_name=$VERSION_NAME" >> "$GITHUB_OUTPUT"
    echo "build_number=$FINAL_BUILD_NUMBER" >> "$GITHUB_OUTPUT"
    echo "full_version=$NEW_VERSION" >> "$GITHUB_OUTPUT"
    echo "✅ GitHub Actions outputs set"
fi

echo "✅ Build number increment complete"
exit 0
