#!/bin/bash

# Clear Strawbie App Data and Keychain
# This script removes all stored user data, useful for testing fresh app state

set -e

echo "🧹 Clearing Strawbie app data..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# App bundle ID
BUNDLE_ID="com.sahilhanda.DAOmates"

echo -e "${YELLOW}📱 Bundle ID: ${BUNDLE_ID}${NC}"

# Clear UserDefaults
echo "Clearing UserDefaults..."
defaults delete ${BUNDLE_ID} 2>/dev/null || echo "  ℹ️  No UserDefaults to clear"

# Clear Keychain items (macOS/Simulator)
echo "Clearing Keychain..."
security delete-generic-password -a "userEmail" -s ${BUNDLE_ID} 2>/dev/null || echo "  ℹ️  No userEmail in keychain"
security delete-generic-password -a "userPassword" -s ${BUNDLE_ID} 2>/dev/null || echo "  ℹ️  No userPassword in keychain"
security delete-generic-password -a "userData" -s ${BUNDLE_ID} 2>/dev/null || echo "  ℹ️  No userData in keychain"

# Clear DerivedData
echo "Clearing Xcode DerivedData..."
rm -rf ~/Library/Developer/Xcode/DerivedData/DAOmates-* 2>/dev/null || echo "  ℹ️  No DerivedData to clear"

# Clear app container (if simulator is running)
if command -v xcrun &> /dev/null; then
    echo "Clearing simulator app data..."
    CONTAINER=$(xcrun simctl get_app_container booted ${BUNDLE_ID} 2>/dev/null) || CONTAINER=""
    
    if [ -n "$CONTAINER" ]; then
        echo "  Found app container: ${CONTAINER}"
        rm -rf "${CONTAINER}/Library/Preferences" 2>/dev/null || true
        rm -rf "${CONTAINER}/Documents" 2>/dev/null || true
        rm -rf "${CONTAINER}/Library/Caches" 2>/dev/null || true
        echo -e "${GREEN}  ✅ App container cleared${NC}"
    else
        echo -e "${YELLOW}  ⚠️  Simulator not running or app not installed${NC}"
    fi
fi

echo ""
echo -e "${GREEN}✅ App data cleared successfully!${NC}"
echo ""
echo "Next steps:"
echo "1. Rebuild the app in Xcode (⌘ + B)"
echo "2. Run the app (⌘ + R)"
echo "3. You should now see the signup screen"
echo ""

