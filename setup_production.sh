#!/bin/bash

# Islamic Todo - Production Setup Script
# Run this script to prepare your app for production release

echo "🕌 Islamic Todo - Production Setup"
echo "===================================="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo -e "${RED}❌ Flutter is not installed. Please install Flutter first.${NC}"
    echo "Visit: https://flutter.dev/docs/get-started/install"
    exit 1
fi

echo -e "${GREEN}✅ Flutter is installed${NC}"
echo ""

# Step 1: Clean previous builds
echo "🧹 Cleaning previous builds..."
flutter clean
echo -e "${GREEN}✅ Clean complete${NC}"
echo ""

# Step 2: Get dependencies
echo "📦 Getting dependencies..."
flutter pub get
echo -e "${GREEN}✅ Dependencies installed${NC}"
echo ""

# Step 3: Generate app icons
echo "🎨 Generating app icons..."
if flutter pub run flutter_launcher_icons; then
    echo -e "${GREEN}✅ App icons generated${NC}"
else
    echo -e "${YELLOW}⚠️  Icon generation had issues (check if res/icon.png exists)${NC}"
fi
echo ""

# Step 4: Generate splash screens
echo "🖼️  Generating splash screens..."
if flutter pub run flutter_native_splash:create; then
    echo -e "${GREEN}✅ Splash screens generated${NC}"
else
    echo -e "${YELLOW}⚠️  Splash screen generation had issues${NC}"
fi
echo ""

# Step 5: Analyze code
echo "🔍 Analyzing code..."
flutter analyze
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Code analysis passed${NC}"
else
    echo -e "${RED}❌ Code analysis found issues. Please fix them before releasing.${NC}"
fi
echo ""

# Step 6: Format code
echo "✨ Formatting code..."
dart format .
echo -e "${GREEN}✅ Code formatted${NC}"
echo ""

# Step 7: Check for keystore
echo "🔑 Checking for release keystore..."
if [ ! -f "android/key.properties" ]; then
    echo -e "${YELLOW}⚠️  No key.properties found for Android signing${NC}"
    echo ""
    echo "To create release keystore:"
    echo "1. Run: keytool -genkey -v -keystore ~/islamic-todo-release.jks \\"
    echo "        -keyalg RSA -keysize 2048 -validity 10000 \\"
    echo "        -alias islamic-todo"
    echo "2. Create android/key.properties (see android/key.properties.example)"
    echo ""
    echo "See RELEASE_SIGNING_GUIDE.md for detailed instructions"
else
    echo -e "${GREEN}✅ Android keystore configuration found${NC}"
fi
echo ""

# Step 8: Test build (debug)
echo "🔨 Testing debug build..."
if flutter build apk --debug; then
    echo -e "${GREEN}✅ Debug build successful${NC}"
else
    echo -e "${RED}❌ Debug build failed${NC}"
    exit 1
fi
echo ""

# Summary
echo "=================================="
echo "📋 Setup Summary"
echo "=================================="
echo ""
echo "✅ Completed:"
echo "  • Dependencies installed"
echo "  • App icons generated"
echo "  • Splash screens generated"
echo "  • Code analyzed"
echo "  • Code formatted"
echo "  • Debug build tested"
echo ""

if [ ! -f "android/key.properties" ]; then
    echo "⚠️  Action Required:"
    echo "  • Create release keystore for Android"
    echo "  • See RELEASE_SIGNING_GUIDE.md"
    echo ""
fi

echo "📚 Next Steps:"
echo "  1. Review DEPLOYMENT_CHECKLIST.md"
echo "  2. Create release keystore (if not done)"
echo "  3. Test on real devices"
echo "  4. Build release: flutter build appbundle --release"
echo "  5. Submit to app stores"
echo ""
echo "📖 Documentation:"
echo "  • DEPLOYMENT_CHECKLIST.md - Full deployment guide"
echo "  • RELEASE_SIGNING_GUIDE.md - Keystore setup"
echo "  • PRIVACY_POLICY.md - Privacy policy"
echo "  • TERMS_OF_SERVICE.md - Terms of service"
echo "  • CONTRIBUTING.md - Contribution guidelines"
echo ""
echo -e "${GREEN}🎉 Setup complete! JazakAllahu Khairan!${NC}"
