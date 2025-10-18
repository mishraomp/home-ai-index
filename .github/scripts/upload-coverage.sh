#!/bin/bash
# Upload coverage results and generate summary
# Optionally posts PR comment if running in pull request context

set -e

echo "📊 Processing coverage results..."

# Check if coverage file exists
if [ ! -f coverage/lcov.info ]; then
    echo "❌ Error: coverage/lcov.info not found"
    echo "ℹ️  Run 'flutter test --coverage' first"
    exit 1
fi

# Parse coverage using lcov
if ! command -v lcov &> /dev/null; then
    echo "⚠️  Warning: lcov not installed, skipping detailed analysis"
    echo "ℹ️  Install with: sudo apt-get install lcov"
    COVERAGE_PCT="N/A"
else
    echo "🔍 Analyzing coverage with lcov..."
    
    # Generate summary
    COVERAGE_SUMMARY=$(lcov --summary coverage/lcov.info 2>&1)
    
    # Extract percentage (format: "lines......: 85.2% (1234 of 1448 lines)")
    COVERAGE_PCT=$(echo "$COVERAGE_SUMMARY" | grep -oP 'lines[\.]*: \K[0-9.]+%' || echo "N/A")
    
    echo "✅ Coverage: $COVERAGE_PCT"
    
    # Generate HTML report
    if [ -n "$GENERATE_HTML" ] && [ "$GENERATE_HTML" = "true" ]; then
        echo "📄 Generating HTML report..."
        genhtml coverage/lcov.info -o coverage/html
        echo "✅ HTML report generated at coverage/html/index.html"
    fi
fi

# Create coverage badge data
echo "🏷️  Generating coverage badge data..."
BADGE_COLOR="red"
if [ "$COVERAGE_PCT" != "N/A" ]; then
    PCT_NUM=$(echo "$COVERAGE_PCT" | sed 's/%//')
    
    # Use bc for float comparisons if available, otherwise fallback to integer comparison
    if command -v bc &> /dev/null; then
        if (( $(echo "$PCT_NUM >= 80" | bc -l) )); then
            BADGE_COLOR="brightgreen"
        elif (( $(echo "$PCT_NUM >= 60" | bc -l) )); then
            BADGE_COLOR="yellow"
        fi
    else
        # Fallback to integer comparison if bc is not available
        PCT_NUM_INT=${PCT_NUM%.*}
        if [ "$PCT_NUM_INT" -ge 80 ]; then
            BADGE_COLOR="brightgreen"
        elif [ "$PCT_NUM_INT" -ge 60 ]; then
            BADGE_COLOR="yellow"
        fi
    fi
fi

cat > coverage/badge.json <<EOF
{
  "schemaVersion": 1,
  "label": "coverage",
  "message": "$COVERAGE_PCT",
  "color": "$BADGE_COLOR"
}
EOF

echo "✅ Badge data saved to coverage/badge.json"

# Generate markdown summary
echo "📝 Generating markdown summary..."
cat > coverage/summary.md <<EOF
# 📊 Code Coverage Report

**Coverage:** $COVERAGE_PCT

## Summary

\`\`\`
$COVERAGE_SUMMARY
\`\`\`

---
*Generated on $(date -u '+%Y-%m-%d %H:%M:%S UTC')*
EOF

echo "✅ Summary saved to coverage/summary.md"

# Post PR comment if in pull request context
if [ -n "$GITHUB_EVENT_NAME" ] && [ "$GITHUB_EVENT_NAME" = "pull_request" ]; then
    if [ -n "$GITHUB_TOKEN" ] && [ -n "$PR_NUMBER" ]; then
        echo "💬 Posting coverage comment to PR #$PR_NUMBER..."
        
        # Prepare comment body
        COMMENT_BODY=$(cat coverage/summary.md)
        
        # Escape JSON (works without jq dependency)
        # Replace newlines with \n and escape double quotes
        ESCAPED_BODY=$(printf '%s' "$COMMENT_BODY" | python3 -c 'import json,sys; print(json.dumps(sys.stdin.read())[1:-1])')
        COMMENT_JSON="{\"body\": \"$ESCAPED_BODY\"}"
        
        # Post comment using GitHub API
        if curl -s -X POST \
            -H "Authorization: token $GITHUB_TOKEN" \
            -H "Accept: application/vnd.github.v3+json" \
            "https://api.github.com/repos/$GITHUB_REPOSITORY/issues/$PR_NUMBER/comments" \
            -d "$COMMENT_JSON" > /dev/null; then
            echo "✅ Coverage comment posted to PR"
        else
            echo "⚠️  Warning: Failed to post PR comment"
        fi
    else
        echo "ℹ️  Skipping PR comment (missing GITHUB_TOKEN or PR_NUMBER)"
    fi
else
    echo "ℹ️  Not a pull request, skipping PR comment"
fi

# Set GitHub Actions outputs if available
if [ -n "$GITHUB_OUTPUT" ]; then
    echo "coverage=$COVERAGE_PCT" >> "$GITHUB_OUTPUT"
    echo "badge_color=$BADGE_COLOR" >> "$GITHUB_OUTPUT"
    echo "✅ GitHub Actions outputs set"
fi

echo ""
echo "✅ Coverage processing complete"
echo "   Coverage: $COVERAGE_PCT"
echo "   Badge: $BADGE_COLOR"

exit 0
