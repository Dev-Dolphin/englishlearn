# Kế Hoạch Phát Triển & Master Prompt Template: Ứng Dụng Học Tiếng Anh AI (Flutter)

Tài liệu này bao gồm:
1. **Master Prompt Template** chuẩn kỹ thuật Flutter (dạng khung điền thông tin và bản điền sẵn cho **EnglishApp**).
2. **Kế hoạch triển khai chi tiết (Implementation Plan)** từ Kiến trúc hệ thống, Quản lý trạng thái (State Management), UI/UX, Tính năng EdTech & AI cho đến Lộ trình phát triển (Roadmap).

---

## Phần 1: Bộ Master Prompt Template Chuẩn Kỹ Thuật Flutter

Bạn có thể sao chép khung prompt dưới đây, thay thế các phần trong ngoặc vuông `[...]` theo nhu cầu riêng, hoặc sử dụng trực tiếp cấu hình mặc định đã tối ưu cho **EnglishApp**.

```markdown
# ROLE & CONTEXT
Bạn là một Principal Flutter Engineer & EdTech Solution Architect với hơn 8 năm kinh nghiệm xây dựng các ứng dụng học ngôn ngữ quy mô lớn (tương tự Duolingo, Elsa Speak, Quizlet).
Nhiệm vụ của bạn là thiết kế và lập trình ứng dụng học tập "[TÊN ỨNG DỤNG - VD: EnglishApp]" bằng Flutter theo tiêu chuẩn Production-ready, Clean Code, dễ mở rộng và bảo trì.
có thể dùng được trên cả app cả web 

# 1. TỔNG QUAN SẢN PHẨM (PRODUCT OVERVIEW)
- **Mục tiêu ứng dụng:** [VD: Ứng dụng học tiếng Anh tích hợp AI giúp người học luyện từ vựng theo SRS, giao tiếp hội thoại với AI Tutor, và chấm điểm phát âm, 
luyện từ vựng cho người  đi làm, theo từng chủ đề , luyền nghe, nói  dudơcj thì càng tốt, 
sẽ có thêm tính năng

tôi đang di học và muốn luyện lại từ vựng của buổi học, bài giảng , tôi sẽ có thể upload image  sau đó app sẽ thông kê những ngữ pháp hoặc từ vựng , các từ này sẽ tự động,
]
- **Đối tượng người dùng:** [VD: người đi làm từ trình độ B1 đến B2]
- **Nền tảng mục tiêu:** [VD: iOS & Android (ưu tiên), hỗ trợ Web/Tablet responsive]

# 2. KIẾN TRÚC HỆ THỐNG & TECH STACK (SYSTEM ARCHITECTURE)
- **Flutter & Dart Version:** Flutter 3.x (latest stable), Dart 3.x (hỗ trợ Records, Patterns, Sealed Classes).
- **Kiến trúc (Architecture Pattern):** [Feature-First Clean Architecture (Data - Domain - Presentation)]
- **Quản lý trạng thái (State Management):** [Riverpod 2.x với Code Generation (@riverpod) / hoặc flutter_bloc]
- **Điều hướng (Navigation):** [go_router với StatefulShellRoute cho Bottom Navigation & Deep Linking]
- **Dependency Injection:** [Riverpod Providers / hoặc get_it + injectable]
- **Networking & API:** [Dio + Retrofit + PrettyDioLogger, hỗ trợ SSE/WebSocket cho AI Text & Audio Streaming]
- **Data Modeling & Serialization:** [Freezed + json_serializable (Immutable models, Union states)]
- **Cơ sở dữ liệu nội bộ (Offline-first Local DB):** [Drift (SQLite) hoặc Isar cho lưu trữ từ vựng, bài học, lịch sử SRS; flutter_secure_storage cho Token]
- **Backend & Cloud Services:** [Supabase hoặc Firebase (Auth, Firestore/PostgreSQL, Storage, Cloud Functions, FCM Push Notification)]

# 3. GIAO DIỆN & TRẢI NGHIỆM NGƯỜI DÙNG (UI/UX & DESIGN SYSTEM)
- **Design System:** Material 3 tùy biến, hỗ trợ Light/Dark Mode, hệ thống Design Tokens đồng nhất (Colors, Typography, Spacing, Radius).
- **Phong cách thiết kế:** Gamification hiện đại, thân thiện, phản hồi tức thì (Micro-interactions).
- **Animations & Haptics:** Sử dụng `flutter_animate`, `lottie`, `rive` và `HapticFeedback` khi trả lời đúng/sai, hoàn thành bài học, giữ chuỗi (Streak).
- **Responsive & Accessibility:** Tương thích nhiều kích thước màn hình, hỗ trợ Dynamic Font Size và Screen Reader.

# 4. TÍNH NĂNG ĐẶC THÙ GIÁO DỤC & AI (EDTECH & AI FEATURES)
1. **Onboarding & Placement Test:**
   - Khảo sát mục tiêu học tập, thời gian rảnh mỗi ngày (5, 10, 15, 30 phút).
   - Bài kiểm tra đầu vào thích ứng (Adaptive Placement Test) để xếp trình độ CEFR (A1 -> C2).
2. **Hệ thống bài học & Bài tập tương tác (Interactive Lessons & Quizzes):**
   - Đa dạng loại câu hỏi: Trắc nghiệm (Multiple Choice), Điền từ (Cloze/Fill-in-the-blank), Sắp xếp câu (Sentence Builder), Nghe chép chính tả (Dictation), Nối từ (Matching Pairs).
3. **Học từ vựng thông minh (Flashcards & Spaced Repetition - SRS):**
   - Áp dụng thuật toán SM-2 hoặc FSRS (Free Spaced Repetition Scheduler) để tính toán thời điểm ôn tập tối ưu.
   - Hỗ trợ âm thanh chuẩn (IPA), ví dụ ngữ cảnh, hình ảnh minh họa, và chế độ học Offline.
4. **AI Tutor & Roleplay (Hội thoại với AI):**
   - Trò chuyện theo kịch bản thực tế (phỏng vấn, du lịch, nhà hàng) qua Text & Voice.
   - Phản hồi streaming theo thời gian thực, tự động gợi ý câu trả lời (Hints) và sửa lỗi ngữ pháp/từ vựng tự nhiên (Grammar Correction).
5. **Luyện Phát Âm & Nghe Nói (Speech & Pronunciation Assessment):**
   - Tích hợp Speech-to-Text (STT) và Text-to-Speech (TTS).
   - Phân tích và chấm điểm phát âm chi tiết đến từng âm tiết / IPA phoneme (hiển thị màu Xanh/Vàng/Đỏ theo độ chính xác).
6. **Gamification & Động lực học tập:**
   - Chuỗi ngày học (Daily Streak) & Streak Freeze.
   - Điểm kinh nghiệm (XP), Cấp độ (Level), Tim/Năng lượng (Hearts), Huy hiệu (Badges) và Bảng xếp hạng tuần (Leaderboard).
7. **Thống kê & Báo cáo tiến độ (Learning Analytics):**
   - Biểu đồ thời gian học, số từ đã thuộc, biểu đồ nhiệt (Heatmap), phân tích kỹ năng Nghe - Nói - Đọc - Viết (Radar Chart).

# 5. TIÊU CHUẨN CODE & QUY TRÌNH LÀM VIỆC (CODING STANDARDS)
- Tuân thủ nguyên tắc SOLID, DRY, KISS.
- Mỗi tính năng tách biệt hoàn toàn trong `lib/features/<feature_name>/` gồm 3 tầng: `data`, `domain`, `presentation`.
- Xử lý lỗi tập trung bằng Functional Error Handling (`fpdart` với `Either<Failure, T>`) hoặc Sealed Result class.
- Viết code kèm Unit Test cho tầng Domain/Algorithm (đặc biệt là thuật toán SRS & tính điểm) và Widget Test cho các component cốt lõi.

# YÊU CẦU ĐẦU RA (EXPECTED OUTPUT)
Khi tôi yêu cầu phát triển từng phần, hãy:
1. Giải thích ngắn gọn luồng kiến trúc và quyết định kỹ thuật.
2. Cung cấp cấu trúc file cần tạo/chỉnh sửa.
3. Viết code đầy đủ, sạch, có chú thích rõ ràng, không dùng pseudo-code bỏ lửng.
4. Nêu các trường hợp biên (Edge Cases) cần lưu ý (mất mạng, microphone bị từ chối quyền, AI phản hồi chậm...).
```

---

## Phần 2: Kế Hoạch Triển Khai Dự Án (Project Implementation Plan)

### 1. Kiến trúc Hệ thống (Feature-First Clean Architecture)

Dự án được tổ chức theo mô hình **Feature-First kết hợp Clean Architecture** giúp cô lập logic nghiệp vụ, dễ kiểm thử và dễ mở rộng khi thêm tính năng AI mới.

```text
lib/
├── core/
│   ├── config/              # Env, AppConfig, AI API configs
│   ├── constants/           # AppColors, AppTypography, AppAssets, ApiEndpoints
│   ├── database/            # Drift / Isar local database setup & migrations
│   ├── error/               # Failures, Exceptions, ErrorHandler
│   ├── network/             # DioClient, AuthInterceptor, NetworkInfo, SSEStreamClient
│   ├── router/              # AppRouter (go_router configuration & guards)
│   ├── services/            # AudioService, SpeechService, NotificationService
│   ├── theme/               # AppTheme (Light & Dark Material 3)
│   ├── utils/               # Extensions, Validators, DateFormatter
│   └── widgets/             # Shared UI components (AppButton, ProgressBar, LoadingShimmer)
│
├── features/
│   ├── auth/                # Đăng nhập, Đăng ký, Quản lý phiên
│   ├── onboarding/          # Khảo sát mục tiêu, Placement Test xếp lớp
│   ├── home/                # Dashboard, Lộ trình học (Learning Path), Daily Goals
│   ├── lesson/              # Engine bài học, Quiz tương tác, Tính điểm
│   │   ├── data/            # Models, LocalDataSource, RemoteDataSource, RepositoryImpl
│   │   ├── domain/          # Entities, Repository Interfaces, UseCases
│   │   └── presentation/    # Providers/Blocs, Screens, Quiz Widgets
│   ├── vocabulary_srs/      # Flashcards, Thuật toán SM-2/FSRS, Từ điển cá nhân
│   ├── ai_tutor/            # Chat/Voice Roleplay với AI, Sửa lỗi ngữ pháp
│   ├── pronunciation/       # Ghi âm, Đánh giá phát âm IPA, Luyện nói
│   ├── gamification/        # Streak, XP, Leaderboard, Thành tựu (Badges)
│   └── profile_analytics/   # Hồ sơ, Biểu đồ tiến độ, Cài đặt (Nhắc nhở học tập)
│
└── main.dart                # Entry point, ProviderScope, Bootstrap
```

---

### 2. Thiết kế Quản lý Trạng thái (State Management Strategy)

Sử dụng **Riverpod 2.x (`flutter_riverpod` + `riverpod_annotation` + `freezed`)** để đảm bảo an toàn kiểu dữ liệu (Compile-time safety) và xử lý bất đồng bộ mượt mà:

| Luồng trạng thái | Loại Provider / State Pattern | Mô tả chi tiết |
| :--- | :--- | :--- |
| **User & Auth State** | `AsyncNotifierProvider` | Quản lý trạng thái đăng nhập, thông tin hồ sơ, cấp độ CEFR hiện tại. |
| **Lesson & Quiz Engine** | `NotifierProvider` + `Freezed Union State` | Quản lý câu hỏi hiện tại, danh sách câu trả lời, số mạng (Hearts), tiến độ thanh `LinearProgressIndicator`, trạng thái kiểm tra đáp án (`idle`, `checking`, `correct`, `incorrect`, `completed`). |
| **SRS Flashcard Queue** | `AsyncNotifierProvider` | Tải danh sách từ cần ôn tập trong ngày từ Local DB, cập nhật hệ số nhớ (`easeFactor`, `interval`, `repetitions`) ngay lập tức và đồng bộ ngầm lên Cloud. |
| **AI Chat & Roleplay** | `StreamNotifierProvider` / `AsyncNotifier` | Quản lý luồng token trả về từ LLM (Server-Sent Events), trạng thái đang ghi âm, đang chuyển giọng nói thành văn bản (STT) và phát âm thanh AI (TTS). |
| **Gamification State** | `AsyncNotifierProvider` | Theo dõi XP, Streak, kích hoạt hiệu ứng chúc mừng khi đạt mục tiêu ngày. |

---

### 3. Thiết kế Tính năng Đặc thù Giáo dục (EdTech Core Engines)

#### 3.1. Thuật toán Lặp lại Ngắt quãng (SRS - SM-2 / FSRS)
Mỗi thẻ từ vựng (`FlashcardEntity`) lưu trữ các chỉ số học tập:
- `repetition` ($n$): Số lần nhớ liên tiếp đúng.
- `easeFactor` ($EF$): Độ dễ của từ (mặc định $2.5$, tối thiểu $1.3$).
- `interval` ($I$): Khoảng cách ngày đến lần ôn tiếp theo.
- `nextReviewDate`: Thời điểm cần ôn tập lại.
- **Đánh giá của người học sau mỗi thẻ:** `Again (0)` / `Hard (1)` / `Good (2)` / `Easy (3)`.

#### 3.1b. Đấu Trường Phản Xạ & Đoán Từ Vựng Ẩn (Masked Word Recall & Timed Challenge)
> Tài liệu đặc tả chi tiết các bước và cơ chế: Xem thêm tại [WORD_CHALLENGE_PLAN.md](./WORD_CHALLENGE_PLAN.md).

Tính năng giúp chuyển từ vựng từ **trí nhớ thụ động (Passive Recognition)** sang **trí nhớ chủ động (Active Recall)**:

1. **Cơ chế Ẩn từ & Gợi ý chữ cái (Masked Letter Hinting)**:
   - Từ tiếng Anh mục tiêu được ẩn các ký tự và chỉ hiển thị **1-2 chữ cái gợi ý** tùy độ dài và trình độ (ví dụ: `R _ s _ _ _ e _ t` cho `Resilient`).
   - Hiển thị nghĩa tiếng Việt, từ loại và câu ví dụ đã che từ khóa (`Our team built a [_______] architecture.`).
   - Hỗ trợ công cụ trợ giúp trong lúc đếm ngược:
     - **Mở thêm 1 chữ cái gợi ý (Reveal Letter Hint)**.
     - **Nghe phát âm gợi ý (Audio Pronunciation Hint)**.

2. **Đồng hồ đếm ngược thích ứng theo trình độ (CEFR Adaptive Countdown Timer)**:
   - **Trình độ A1 - A2 (Sơ cấp):** `30 giây / từ` — Hiển thị ~30% ký tự gợi ý (2-3 chữ cái).
   - **Trình độ B1 - B2 (Trung cấp):** `20 giây / từ` — Hiển thị ~20% ký tự gợi ý (1-2 chữ cái).
   - **Trình độ C1 - C2 (Cao cấp):** `12 giây / từ` — Chỉ hiển thị chữ cái đầu tiên (1 chữ cái).

3. **Thẻ Kiến Thức Chuyên Sâu Sau Khi Trả Lời (Post-Answer Deep Dive Card)**:
   Sau khi người học gửi đáp án hoặc hết giờ, hệ thống hiển thị chi tiết:
   - **Đáp án chuẩn + Phiên âm IPA + Phát âm TTS (1.0x & 0.7x)**.
   - **Ngữ pháp & Cấu trúc đi kèm (Grammar & Structure):** Giới từ đi kèm, cấu trúc câu chuẩn.
   - **Cách dùng thực tế (Usage & Register):** Ngữ cảnh sử dụng (Formal, Business, IELTS, Giao tiếp hàng ngày) và lỗi người học hay mắc.
   - **Cụm từ cố định (Collocations), Gia đình từ (Word Family) & Từ đồng nghĩa / Trái nghĩa (Synonyms & Antonyms)**.

4. **3 Chế độ chơi (3 Game Modes) & Ý tưởng Mở rộng**:
   - **Chế độ 1 — Kiểm tra Trình độ (Level Test Mode - 10 từ):**
     - Chọn bộ từ theo trình độ (`A1-A2`, `B1-B2`, `C1-C2` hoặc Hỗn hợp).
     - Chấm điểm độ chính xác, thời gian phản xạ trung bình (giây/từ) và đánh giá năng lực từ vựng chủ động.
   - **Chế độ 2 — Vô Tận / Sinh Tồn (Endless Survival Mode):**
     - Thử thách liên tục không giới hạn số lượng từ với **3 Tim (Lives)** và **Hệ thống Combo Multiplier** (`x1`, `x2`, `x3`, `x5` XP).
     - Lưu kỷ lục **Điểm cao nhất (High Score)** và **Chuỗi đúng liên tiếp dài nhất (Best Combo)**.
   - **Chế độ 3 — Thử thách Mỗi Ngày (Daily Challenge - "1% Tốt Hơn Mỗi Ngày"):**
     - Bộ 5 từ vựng trọng tâm mỗi ngày + ưu tiên các từ người học từng trả lời sai/chậm.
     - Theo dõi chỉ số **"Tốt hơn mỗi ngày" (Better Every Day Analytics)**: so sánh tốc độ phản xạ trung bình và tỉ lệ nhớ từ hôm nay so với hôm qua.

#### 3.2. Polymorphic Quiz Engine (Động cơ Câu hỏi Đa hình)
Sử dụng `Freezed` Sealed Classes để định nghĩa các dạng bài tập trong cùng một bài học:
- `QuizQuestion.multipleChoice(...)`
- `QuizQuestion.fillInTheBlank(...)`
- `QuizQuestion.sentenceOrdering(...)`
- `QuizQuestion.listeningDictation(...)`
- `QuizQuestion.speakingPronunciation(...)`

Nhờ cấu trúc này, `LessonPlayerScreen` chỉ cần dùng `question.when(...)` để render đúng Widget tương ứng mà không cần dùng nhiều câu lệnh `if-else` phức tạp.

#### 3.3. Kiến trúc AI Tutor & Luyện Phát Âm
- **System Prompting động cho AI Tutor:** Truyền ngữ cảnh gồm trình độ người học (VD: B1), chủ đề hội thoại (VD: Đặt phòng khách sạn), và danh sách từ vựng mục tiêu cần người học sử dụng trong buổi trò chuyện.
- **Structured JSON Output từ AI:** Yêu cầu AI trả về cấu trúc gồm:
  - `reply`: Câu phản hồi tiếp nối hội thoại.
  - `correction`: Nhận xét và sửa lỗi câu vừa nói của người học (nếu có lỗi ngữ pháp/từ vựng).
  - `suggestions`: 2-3 gợi ý câu trả lời tiếp theo cho người học.

---

### 4. Lộ trình Phát triển (Development Roadmap)

#### Giai đoạn 1: Khởi tạo & Nền tảng cốt lõi (Foundation & Core)
- [x] Khởi tạo project Flutter, cấu hình Linter (`flutter_lints` / `very_good_analysis`), cấu trúc thư mục Feature-First.
- [x] Cài đặt các thư viện cốt lõi: `flutter_riverpod`, `go_router`, `dio`, `freezed`, `drift`/`isar`.
- [x] Xây dựng Design System: `AppTheme` (Material 3, Light/Dark), `AppColors`, `AppTypography`, các Base Widgets (`PrimaryButton`, `CustomAppBar`, `AppCard`).
- [x] Thiết lập Local Database (Offline-first) và Network Layer (Dio + Interceptors).

#### Giai đoạn 2: Xác thực, Onboarding & Lộ trình học (Auth & Onboarding)
- [x] Xây dựng màn hình Splash, Onboarding khảo sát mục tiêu học tập.
- [x] Xây dựng bài kiểm tra đầu vào (Placement Test) để xác định trình độ.
- [x] Tích hợp đăng nhập/đăng ký (Email, Google, Apple) và lưu trữ hồ sơ người học.
- [x] Xây dựng màn hình Trang chủ (Home Learning Path) hiển thị các Chương (Units) và Bài học (Nodes).

#### Giai đoạn 3: Động cơ Bài học & Học từ vựng SRS (Lesson Engine & SRS)
- [x] Xây dựng `LessonPlayerScreen` cùng 5 dạng câu hỏi tương tác (Trắc nghiệm, Điền từ, Sắp xếp câu, Nghe, Nói).
- [x] Tích hợp phản hồi âm thanh, Haptic Feedback và Bottom Sheet thông báo Đúng/Sai kèm giải thích.
- [x] Xây dựng phân hệ Flashcards cùng thuật toán SRS (SM-2/FSRS), cho phép ôn tập từ vựng đến hạn hàng ngày (kể cả khi Offline).

#### Giai đoạn 3b: Đấu Trường Phản Xạ Đoán Từ Vựng Ẩn (Masked Word Recall & 3 Game Modes)
- [x] **Bước 1 — Mở rộng Cấu trúc Dữ liệu Từ vựng Chuyên sâu:** Bổ sung cấp độ `cefr` (A1-A2, B1-B2, C1-C2), `grammarNote` (ngữ pháp & giới từ đi kèm), `usageTip` (cách dùng & ngữ cảnh), `collocations` (cụm từ cố định), `wordFamily` (gia đình từ) và `synonyms` / `antonyms` (đồng nghĩa / trái nghĩa).
- [x] **Bước 2 — Thuật toán Ẩn chữ cái & Gợi ý Thích ứng (Masked Word Generator):** Tự động che ký tự của từ, chỉ hiển thị 1-2 chữ cái gợi ý theo trình độ; cho phép bấm mở thêm chữ cái gợi ý hoặc nghe phát âm gợi ý.
- [x] **Bước 3 — Đồng hồ Đếm ngược theo Trình độ Tiếng Anh (CEFR Countdown Timer):** Tự động thiết lập thời gian đếm ngược theo cấp độ (`A1-A2: 30s`, `B1-B2: 20s`, `C1-C2: 12s`) kèm thanh tiến độ thời gian trực quan.
- [x] **Bước 4 — Xây dựng 3 Chế độ chơi (3 Game Modes):**
  - `Level Test (Kiểm tra theo số lượng từ & trình độ)`: Test 5 hoặc 10 từ để đánh giá tốc độ phản xạ và xếp hạng trình độ.
  - `Endless Survival (Chế độ Vô tận)`: Chơi liên tục với 3 Tim (Lives), chuỗi Combo nhân điểm (`x1` -> `x5`) và lưu Kỷ lục High Score.
  - `Daily Challenge (Mỗi ngày tốt hơn 1%)`: Bộ 5 từ mỗi ngày + từ hay sai, thống kê sự tiến bộ về tốc độ phản xạ và độ chính xác so với ngày hôm trước.
- [x] **Bước 5 — Thẻ Kiến Thức Chuyên Sâu Sau Khi Trả Lời:** Hiển thị đầy đủ Ngữ pháp, Cách dùng, Collocations, Gia đình từ, Đồng/Trái nghĩa và tự động cập nhật điểm nhớ SRS SM-2.

#### Giai đoạn 3c: Kho Dữ Liệu Từ Ảnh Chụp Riêng Biệt & Đồng Bộ Liên Tục (Photo Vocab Vault)
- [x] **Lưu trữ tách biệt hoàn toàn (`uploaded_vault/`):** Ảnh upload (hoặc dán `Ctrl+V` / thả vào thư mục `uploaded_vault/drop_images_here/`) được lưu riêng tại `uploaded_vault/images/` và cơ sở dữ liệu JSON riêng tại `uploaded_vault/photo_vocab_db.json` (không lẫn với bộ từ hệ thống).
- [x] **Nhận diện chữ OCR Offline & Bóc tách Từ vựng thông minh:** Quét văn bản tiếng Anh từ ảnh chụp bằng Offline OCR (`scripts/ocr_extract.ps1`), tự động tách từ vựng mới, nhận diện cặp `Từ tiếng Anh - Nghĩa tiếng Việt` nếu là ảnh chụp vở ghi, và tra cứu phiên âm IPA / câu ngữ cảnh.
- [x] **Cập nhật liên tục theo thời gian thực (Real-time Continuous Stream):** Sử dụng Server-Sent Events (`/api/photo-vault/stream`) kết hợp theo dõi thư mục tự động (`fs.watch`), giúp giao diện hiển thị ngay lập tức mỗi khi có ảnh mới được tải lên mà không cần tải lại trang.
- [x] **Hiển thị riêng & Chọn dữ liệu tùy ý để học:** Màn hình **📸 Kho Ảnh Chụp** riêng biệt, cho phép người dùng tick chọn **1 ảnh**, **nhiều ảnh**, hoặc **từng từ cụ thể** trong ảnh để đưa vào **⚡ Đấu Trường Đoán Từ Ẩn** hoặc **🗂️ Lật Thẻ Flashcard**.

#### Giai đoạn 4: Tích hợp AI Tutor & Luyện phát âm (AI & Speech Features)
- [x] Tích hợp dịch vụ Audio Recording, Text-to-Speech (TTS) và Speech-to-Text (STT).
- [x] Xây dựng màn hình **AI Roleplay Chat/Voice**: hỗ trợ streaming phản hồi, dịch nhanh, sửa lỗi ngữ pháp tự động và gợi ý câu trả lời.
- [x] Xây dựng màn hình **Pronunciation Coach**: chấm điểm phát âm và đánh dấu màu những từ/âm tiết phát âm chưa chuẩn.

#### Giai đoạn 5: Gamification, Thống kê & Đồng bộ (Gamification & Analytics)
- [x] Xây dựng hệ thống tính điểm XP, chuỗi ngày học (Daily Streak), Streak Freeze và Huy hiệu.
- [x] Xây dựng bảng xếp hạng (Leaderboard) và màn hình Thống kê học tập (Biểu đồ thời gian học, số từ đã thuộc, Radar kỹ năng).
- [x] Cấu hình Local Notifications nhắc nhở học tập hàng ngày thông minh.
- [x] Đồng bộ dữ liệu hai chiều (Local DB <-> Cloud Backend).

#### Giai đoạn 6: Kiểm thử, Tối ưu hiệu năng & Phát hành (Testing & Release)
- [x] Viết Unit Tests cho thuật toán SRS, bộ chấm điểm Quiz, và các Repositories/Notifiers.
- [x] Viết Widget Tests và Integration Tests cho luồng học bài chính.
- [x] Tối ưu kích thước ứng dụng, bộ nhớ cache âm thanh/hình ảnh, và trải nghiệm 60/120fps.
- [x] Cấu hình CI/CD (GitHub Actions / Codemagic) và chuẩn bị phát hành lên App Store & Google Play.

---

## Phần 3: Danh sách Packages Khuyên Dùng (`pubspec.yaml`)

| Nhóm chức năng | Packages đề xuất |
| :--- | :--- |
| **State Management & DI** | `flutter_riverpod`, `riverpod_annotation` |
| **Navigation** | `go_router` |
| **Code Gen & Models** | `freezed_annotation`, `json_annotation`, `build_runner`, `freezed`, `json_serializable` |
| **Networking** | `dio`, `retrofit`, `connectivity_plus` |
| **Local Storage (Offline-first)** | `drift` (hoặc `isar`), `shared_preferences`, `flutter_secure_storage` |
| **Audio & Speech (EdTech)** | `just_audio`, `record`, `speech_to_text`, `flutter_tts`, `permission_handler` |
| **UI, Animations & Charts** | `flutter_animate`, `lottie`, `fl_chart`, `cached_network_image`, `google_fonts`, `gap` |
| **Functional & Utilities** | `fpdart`, `intl`, `uuid`, `equatable` |
