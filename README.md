# LingoAI English — Flutter AI Learning App

Ứng dụng học tiếng Anh tích hợp AI được xây dựng theo kiến trúc **Feature-First Clean Architecture** như được đặc tả trong [PLAN.md](./PLAN.md).

## Kiến trúc & Tính năng đã triển khai

1. **Core Architecture (`lib/core/`)**:
   - Design System Material 3 hỗ trợ **Light / Dark Mode** (`AppTheme`, `AppColors`, `AppTypography`).
   - Functional Error Handling với Dart 3 Sealed Class (`Result<T>`, `Success<T>`, `Err<T>`).
   - Offline-first Local Storage (`LocalStorageService`) & Speech/Audio TTS/STT abstraction (`SpeechAudioService`).
2. **Onboarding & Adaptive Placement Test (`lib/features/onboarding/`)**:
   - Khảo sát mục tiêu học tập, thời gian rảnh mỗi ngày (5/10/15/30 phút) và bài kiểm tra xếp lớp CEFR (A1 -> B2).
3. **Home Learning Path (`lib/features/home/`)**:
   - Giao diện lộ trình học theo các Chương (Units) và Bài học (Lesson Nodes) kèm thanh tiến độ Mục tiêu XP hàng ngày.
4. **Polymorphic Quiz Engine (`lib/features/lesson/`)**:
   - Sử dụng Dart 3 Sealed Class `QuizQuestion` hỗ trợ 5 dạng bài tập tương tác trong cùng 1 luồng học:
     - Trắc nghiệm (`MultipleChoiceQuestion`)
     - Điền từ vào chỗ trống (`FillInTheBlankQuestion`)
     - Sắp xếp từ thành câu (`SentenceOrderingQuestion`)
     - Nghe chép chính tả TTS (`ListeningDictationQuestion`)
     - Luyện nói phát âm (`SpeakingPronunciationQuestion`)
5. **Spaced Repetition Flashcards - SM-2 (`lib/features/vocabulary_srs/`)**:
   - Thuật toán **SuperMemo SM-2** tính toán `repetition`, `easeFactor`, `intervalDays`, `nextReviewDate` với 4 mức đánh giá (`Again`, `Hard`, `Good`, `Easy`) và hỗ trợ thêm từ vựng cá nhân.
6. **AI Tutor Roleplay (`lib/features/ai_tutor/`)**:
   - Trò chuyện hội thoại theo kịch bản thực tế (Phỏng vấn IT, Khách sạn, Thuyết trình) kèm tự động kiểm tra ngữ pháp (Grammar Correction), bản dịch và gợi ý câu trả lời (Suggested Replies).
7. **IPA Pronunciation Coach (`lib/features/pronunciation/`)**:
   - Phân tích phát âm chi tiết đến từng từ và phiên âm IPA với hệ thống màu trực quan: Xanh (`>=85%`), Vàng (`70-84%`), Đỏ (`<70%`).
8. **Gamification & Learning Analytics (`lib/features/gamification/`, `lib/features/profile_analytics/`)**:
   - Chuỗi ngày học (Daily Streak), Điểm kinh nghiệm (XP), Tim (Hearts), Huy hiệu (Badges), Bảng xếp hạng tuần và Biểu đồ 4 kỹ năng Nghe - Nói - Đọc - Viết.

## Cách chạy dự án

### 1. Chạy trên iOS (iPhone / iPad / Xcode Simulator)
Xem hướng dẫn tự động chi tiết tại [IOS_SETUP.md](./IOS_SETUP.md):

```bash
chmod +x setup_ios.sh
./setup_ios.sh
flutter run -d ios
```

### 2. Chạy trên các nền tảng Flutter khác (Android / Desktop / Web)
Đảm bảo máy đã cài đặt [Flutter SDK](https://docs.flutter.dev/get-started/install) (`>=3.4.0`), sau đó chạy:

```bash
flutter create . --org com.lingoai --project-name english_app
flutter pub get
flutter test
flutter run
```
