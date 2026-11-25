# Hướng Dẫn Chạy Ứng Dụng LingoAI Trên iOS (iPhone / iPad / Simulator)

Dự án đã được tối ưu toàn diện cho hệ sinh thái **Apple iOS**:
- **Âm thanh iOS (`AVAudioSession`):** Tự động phát giọng đọc tiếng Anh qua loa ngoài kể cả khi gạt cần gạt **Silent (Im lặng)** bên sườn iPhone.
- **Chống lộ đáp án bàn phím iOS:** Đã tắt `QuickType Suggestions` & `Auto-Correction` trên các ô nhập **Đoán Từ Ẩn** và **Nghe Chép Chính Tả**.
- **Giao diện chuẩn Apple HIG:** Hỗ trợ Dynamic Island, SafeArea, vuốt trượt đóng bàn phím (`onDrag`), `CupertinoSlidingSegmentedControl` và Dark Mode.
- **100% Dữ liệu Offline:** Toàn bộ 6 Units, Sổ tay Lý thuyết, 30 Thẻ SRS + Đấu trường Đoán Từ Ẩn, 5 Kịch bản AI Roleplay và Bài luyện IPA hoạt động ngay mà không cần Internet.

---

## Cách 1: Build & Chạy Native Flutter App trên macOS + Xcode (Khuyên dùng)

Khi mở thư mục dự án này trên máy **Mac** (đã cài Flutter SDK & Xcode), bạn chỉ cần mở Terminal tại thư mục dự án và chạy duy nhất script tự động sau:

```bash
chmod +x setup_ios.sh
./setup_ios.sh
flutter run
```

### Script `setup_ios.sh` đã làm tự động cho bạn những gì?
1. Sinh thư mục `ios/` chuẩn Xcode (`flutter create . --org com.lingoai --project-name english_app --platforms=ios,android`) mà **giữ nguyên 100%** code trong `lib/`.
2. Tự động chèn 2 quyền bắt buộc của Apple vào `ios/Runner/Info.plist` (tránh văng app khi bấm nút Thu âm):
   - `NSMicrophoneUsageDescription`
   - `NSSpeechRecognitionUsageDescription`
3. Nâng cấu hình `platform :ios, '13.0'` trong `ios/Podfile` và chạy `pod install` cho `flutter_tts` & `speech_to_text`.

> **Nếu cắm iPhone thật qua cáp USB / Wi-Fi:**
> Mở `open ios/Runner.xcworkspace`, chọn mục **Runner -> Signing & Capabilities**, tích chọn **Automatically manage signing** và chọn **Team (Apple ID cá nhân của bạn)** rồi bấm nút **Run (▶)** trên Xcode hoặc chạy `flutter run`.

---

## Cách 2: Cài đặt nhanh lên iPhone như App Offline (iOS Safari PWA — Không cần Mac/Xcode)

Nếu bạn đang dùng máy Windows hiện tại và muốn mang lên **iPhone** dùng thử ngay lập tức:
1. Kết nối iPhone và máy tính vào cùng mạng Wi-Fi.
2. Mở Safari trên iPhone, truy cập địa chỉ IP mạng LAN của máy tính ở cổng `3000` (ví dụ `http://192.168.1.x:3000`).
3. Nhấn nút **Chia sẻ (Share)** trên Safari -> chọn **Thêm vào Màn hình chính (Add to Home Screen)**.
4. Mở icon **LingoAI** từ màn hình chính iPhone: ứng dụng sẽ chạy **Full-screen không thanh địa chỉ**, lưu toàn bộ kho dữ liệu bằng **Service Worker Offline** để bạn học trên máy bay hoặc nơi không có mạng!
