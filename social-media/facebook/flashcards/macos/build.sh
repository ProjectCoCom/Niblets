#!/bin/bash

# Exit on error
set -e

APP_NAME="FlashcardAutomation"
PROJECT_DIR="FlashcardAutomation"
BUILD_DIR=".build"
RELEASE_DIR="$BUILD_DIR/release"
ARCHIVE_PATH="$RELEASE_DIR/$APP_NAME.xcarchive"
EXPORT_PATH="$RELEASE_DIR/Export"
APP_PATH="$EXPORT_PATH/$APP_NAME.app"
DMG_PATH="$RELEASE_DIR/$APP_NAME.dmg"

echo "### Cleaning previous builds..."
rm -rf "$RELEASE_DIR"

echo "### Generating Xcode project..."
swift package generate-xcodeproj

echo "### Archiving the application..."
xcodebuild archive \
    -project "$PROJECT_DIR/$APP_NAME.xcodeproj" \
    -scheme "$APP_NAME" \
    -archivePath "$ARCHIVE_PATH"

echo "### Exporting the application..."
xcodebuild -exportArchive \
    -archivePath "$ARCHIVE_PATH" \
    -exportPath "$EXPORT_PATH" \
    -exportOptionsPlist "$PROJECT_DIR/ExportOptions.plist"

echo "### Creating the DMG..."
hdiutil create -volname "$APP_NAME" -srcfolder "$APP_PATH" -ov -format UDZO "$DMG_PATH"

echo "### Done! DMG created at $DMG_PATH"
