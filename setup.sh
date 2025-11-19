#!/bin/bash

# DAOmates Setup Script
# This script helps you set up your development environment

set -e

echo "🚀 DAOmates Setup Script"
echo "========================="
echo ""

# Check if Xcode is installed
if ! command -v xcodebuild &> /dev/null; then
    echo "❌ Xcode is not installed. Please install Xcode from the App Store."
    exit 1
fi

echo "✅ Xcode found: $(xcodebuild -version | head -n 1)"
echo ""

# Check if Info.plist exists
if [ ! -f "DAOmates/Info.plist" ]; then
    echo "📝 Creating Info.plist from template..."
    cp DAOmates/Info.plist.template DAOmates/Info.plist
    echo "✅ Info.plist created"
    echo ""
    echo "⚠️  IMPORTANT: Edit DAOmates/Info.plist and add your OpenAI API key"
    echo ""
else
    echo "✅ Info.plist already exists"
    echo ""
fi

# Check for API key
if grep -q "YOUR_OPENAI_API_KEY_HERE" DAOmates/Info.plist 2>/dev/null; then
    echo "⚠️  Warning: OpenAI API key not configured in Info.plist"
    echo "   Please edit DAOmates/Info.plist and replace YOUR_OPENAI_API_KEY_HERE with your actual key"
    echo ""
fi

# Check Git configuration
if [ ! -f ".gitignore" ]; then
    echo "⚠️  Warning: .gitignore not found"
else
    echo "✅ .gitignore configured"
fi

# Print next steps
echo ""
echo "📋 Next Steps:"
echo "=============="
echo ""
echo "1. Configure API Keys:"
echo "   - Edit DAOmates/Info.plist"
echo "   - Add your OpenAI API key"
echo "   - Never commit API keys to git!"
echo ""
echo "2. Open the project:"
echo "   $ open DAOmates.xcodeproj"
echo ""
echo "3. Select your development team in Xcode:"
echo "   - Project Settings → Signing & Capabilities"
echo "   - Choose your Apple Developer team"
echo ""
echo "4. Build and run:"
echo "   - Press ⌘R or click the Play button"
echo "   - Test on simulator or device"
echo ""
echo "5. For production setup, see:"
echo "   - PRODUCTION_SETUP.md"
echo ""
echo "📖 Documentation:"
echo "================"
echo "- README.md - Project overview and features"
echo "- PRODUCTION_SETUP.md - Complete production guide"
echo "- LICENSE - License information"
echo ""
echo "🎉 Setup complete! Happy coding!"

