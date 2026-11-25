#!/usr/bin/env bash
set -e

echo "=========================================================="
echo "  LingoAI English - Automated iOS Setup & Pod Installer   "
echo "=========================================================="

# 1. Generate missing native iOS/Android Runner scaffolding without overwriting lib/
if [ ! -d "ios" ]; then
  echo "[1/4] Generating native iOS & Android platform folders..."
  flutter create . --org com.lingoai --project-name english_app --platforms=ios,android
else
  echo "[1/4] Native ios/ directory already exists."
fi

# 2. Inject required iOS Privacy Permissions (Microphone, Speech, Camera & Photo Library) into Info.plist
PLIST_PATH="ios/Runner/Info.plist"
if [ -f "$PLIST_PATH" ]; then
  echo "[2/4] Configuring iOS Microphone, Speech, Camera & Photo Library permissions in Info.plist..."
  /usr/libexec/PlistBuddy -c "Delete :NSMicrophoneUsageDescription" "$PLIST_PATH" 2>/dev/null || true
  /usr/libexec/PlistBuddy -c "Add :NSMicrophoneUsageDescription string 'LingoAI cần quyền Microphone để chấm điểm phát âm IPA và luyện hội thoại tiếng Anh.'" "$PLIST_PATH"

  /usr/libexec/PlistBuddy -c "Delete :NSSpeechRecognitionUsageDescription" "$PLIST_PATH" 2>/dev/null || true
  /usr/libexec/PlistBuddy -c "Add :NSSpeechRecognitionUsageDescription string 'LingoAI sử dụng nhận diện giọng nói trên thiết bị để phân tích phát âm tiếng Anh của bạn.'" "$PLIST_PATH"

  /usr/libexec/PlistBuddy -c "Delete :NSCameraUsageDescription" "$PLIST_PATH" 2>/dev/null || true
  /usr/libexec/PlistBuddy -c "Add :NSCameraUsageDescription string 'LingoAI cần quyền Camera để chụp trang sách hoặc bảng từ vựng lưu vào Kho Từ Ảnh riêng.'" "$PLIST_PATH"

  /usr/libexec/PlistBuddy -c "Delete :NSPhotoLibraryUsageDescription" "$PLIST_PATH" 2>/dev/null || true
  /usr/libexec/PlistBuddy -c "Add :NSPhotoLibraryUsageDescription string 'LingoAI cần quyền Thư viện ảnh để bạn chọn ảnh chụp màn hình và trích xuất từ vựng tiếng Anh.'" "$PLIST_PATH"
fi

# 3. Fetch Flutter packages (generates ios/Podfile if not yet created)
echo "[3/4] Running flutter pub get..."
flutter pub get

# 4. Ensure iOS Deployment Target >= 13.0 in Podfile & install CocoaPods
if [ -f "ios/Podfile" ]; then
  echo "[4/4] Setting minimum iOS platform 13.0 in Podfile & running pod install..."
  sed -i '' "s/# platform :ios, '12.0'/platform :ios, '13.0'/g" ios/Podfile || true
  sed -i '' "s/platform :ios, '12.0'/platform :ios, '13.0'/g" ios/Podfile || true
  (cd ios && pod install)
fi

echo ""
echo "✅ Hoàn tất cấu hình iOS! Chạy ứng dụng ngay bằng lệnh:"
echo "   flutter run -d ios"
