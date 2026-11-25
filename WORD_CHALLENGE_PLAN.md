# Kế Hoạch Chi Tiết Tính Năng: Đấu Trường Đoán Từ Vựng Ẩn (Masked Word Recall Arena)

Tài liệu này mô tả thiết kế nghiệp vụ, các ý tưởng sư phạm nâng cao (EdTech Gamification) và các bước triển khai kỹ thuật cho tính năng **Học & Ôn Từ Vựng Chủ Động qua Ô Chữ Ẩn + Đếm Ngược Theo Trình Độ**.

---

## 1. Mục Tiêu Sư Phạm (Tại sao tính năng này hiệu quả?)

Khi học bằng Flashcard lật thẻ thông thường, não bộ thường chỉ dừng ở **Nhận diện thụ động (Passive Recognition)** — nhìn thấy từ tiếng Anh thì nhớ nghĩa, nhưng khi cần nói hoặc viết lại không bật ra được từ đó.

Cơ chế **Ẩn chữ cái + Giới hạn thời gian theo trình độ + Giải thích ngữ pháp/cách dùng sâu sau khi trả lời** giải quyết triệt để vấn đề này nhờ 3 nguyên lý:
1. **Active Recall & Generation Effect:** Buộc não bộ tự truy xuất chính tả của từ dựa trên ngữ cảnh câu và 1-2 ký tự gợi ý.
2. **Time-pressured Fluency:** Rèn tốc độ phản xạ ngôn ngữ sát với áp lực giao tiếp thực tế theo từng bậc CEFR.
3. **Contextual Deep Encoding:** Ngay khoảnh khắc vừa trả lời xong (khi sự chú ý của não đạt đỉnh), cung cấp **Ngữ pháp, Giới từ đi kèm, Cách dùng, Cụm từ cố định (Collocations) và Đồng/Trái nghĩa** giúp nhớ sâu gấp nhiều lần.

---

## 2. Cơ Chế Cốt Lõi & Các Ý Tưởng Bổ Sung Hợp Lý

### 2.1. Thuật toán Ẩn chữ cái thông minh (Smart Letter Masking)
- Hiển thị từ vựng dưới dạng dãy **Ô Chữ Cái (Letter Tiles)** để người học biết chính xác độ dài của từ (ví dụ 9 chữ cái: `R _ _ _ l _ _ _ t`).
- **Số chữ cái gợi ý ban đầu phụ thuộc vào độ dài từ & trình độ chọn chơi:**
  - Từ ngắn (`<= 5` ký tự) hoặc trình độ **C1-C2**: Chỉ mở **1 chữ cái đầu tiên** (VD: `A _ _ _ _`).
  - Từ trung bình/dài (`>= 6` ký tự) ở trình độ **A1-B2**: Mở **2 chữ cái** ở vị trí chiến lược (chữ cái đầu + 1 chữ cái giữa từ để định hình khung âm tiết, VD: `N _ _ _ t _ _ _ _` cho `Negotiate`).
- **Câu ví dụ khuyết từ (Cloze Context Hint):** Hiển thị luôn câu ví dụ thực tế nhưng che từ mục tiêu thành `[ _________ ]` để người học đoán từ dựa trên ngữ cảnh ngữ pháp (Danh từ / Động từ / Tính từ).

### 2.2. Hệ thống 3 Trợ giúp thông minh khi đang đếm ngược (Lifelines / Hints)
Để người học không bị "đứng hình" bỏ cuộc khi gặp từ khó:
1. **💡 Mở thêm 1 chữ cái (Letter Hint):** Mở thêm tối đa 2 ký tự ngẫu nhiên chưa lộ (giảm nhẹ điểm thưởng tốc độ).
2. **🔊 Nghe phát âm của từ (Audio Hint):** Phát âm thanh TTS của từ mà không hiện chữ — biến câu hỏi thành bài luyện *Nghe - Chép chính tả (Dictation)* cực tốt!
3. **🧩 Gợi ý Từ đồng nghĩa (Synonym Hint):** Hiển thị 1-2 từ đồng nghĩa tiếng Anh (VD: hiện `Robust, Tough` để người học nhớ ra từ `Resilient`).

### 2.3. Đồng hồ đếm ngược theo từng trình độ Tiếng Anh (CEFR Adaptive Timer)
| Cấp độ Trình độ | Thời gian / từ | Số ký tự gợi ý ban đầu | Hệ số nhân điểm XP | Đối tượng phù hợp |
| :--- | :---: | :---: | :---: | :--- |
| **🟢 Sơ cấp (A1 - A2)** | **30 giây** | 2 ký tự (hoặc ~30%) | `1.0x` | Mới bắt đầu, cần thời gian nhớ mặt chữ & gõ phím |
| **🔵 Trung cấp (B1 - B2)** | **20 giây** | 1 - 2 ký tự (~20%) | `1.5x` | Đã có nền tảng, rèn tốc độ phản xạ công sở / giao tiếp |
| **🟣 Cao cấp (C1 - C2)** | **12 giây** | Chỉ 1 ký tự đầu | `2.0x` | Luyện phản xạ tức thì chuẩn IELTS 7.5+ / Chuyên gia |

*Thanh tiến độ thời gian chuyển màu trực quan: Xanh lá (>50%) -> Vàng cam (25%-50%) -> Đỏ cảnh báo (<5 giây cuối).*

### 2.4. Màn hình Giải Thích Chuyên Sâu Sau Khi Có Kết Quả (Post-Answer Deep Dive)
Dù người dùng trả lời **Đúng**, **Gần đúng (chỉ sai 1 ký tự chính tả - Near Miss!)**, **Sai**, hay **Hết giờ**, hệ thống sẽ dừng đồng hồ và hiển thị:
- **Đáp án chuẩn + Phiên âm IPA + Nút nghe giọng chuẩn (`1.0x`) & giọng chậm (`0.7x`)**.
- **Câu ví dụ hoàn chỉnh** tô sáng từ khóa + nút nghe cả câu.
- **4 Góc Kiến Thức Mở Rộng:**
  1. **📐 Ngữ pháp & Giới từ đi kèm (Grammar & Structure):** VD: `elaborate + ON + something`, `indispensable + TO/FOR`, danh từ đếm được hay không đếm được.
  2. **💬 Cách dùng & Lưu ý lỗi hay gặp (Usage & Pitfalls):** Văn phong trang trọng hay thân mật, lưu ý âm câm (`aisle`, `receipt`), phân biệt từ dễ nhầm (`complimentary` vs `complementary`).
  3. **🔗 Cụm từ tự nhiên & Gia đình từ (Collocations & Word Family):** Các cụm từ người bản xứ luôn đi kèm + biến thể Noun / Verb / Adj / Adv.
  4. **🔄 Từ đồng nghĩa & Trái nghĩa (Synonyms & Antonyms):** Mở rộng mạng lưới từ vựng.
- **Tự động cập nhật lịch ôn SRS (SM-2) & Sổ tay Từ Hay Sai (Mistake Bank):**
  - Đúng nhanh -> Tăng chu kỳ nhớ SRS (`Easy` / `Good`).
  - Sai / Hết giờ -> Tự động lưu vào **Sổ tay Từ Hay Sai** để ưu tiên xuất hiện lại trong bài *Thử thách Mỗi Ngày*!

---

## 3. Chi Tiết 3 Chế Độ Chơi (3 Game Modes)

### Chế độ 1: Kiểm Tra Trình Độ (Level Test — Giới hạn số từ cố định)
- **Cách chơi:** Chọn trình độ muốn thử sức (`A1-A2`, `B1-B2`, `C1-C2`, hoặc `Tổng hợp A1->C1`) và số lượng câu (`5 từ` hoặc `10 từ`).
- **Kết quả cuối màn:**
  - Chấm điểm tổng kết, Độ chính xác (%), **Tốc độ phản xạ trung bình (giây/từ)**.
  - Đánh giá xếp hạng năng lực phản xạ từ vựng hiện tại và liệt kê các từ cần ôn lại.

### Chế độ 2: Chế Độ Vô Tận / Sinh Tồn (Endless Survival Mode)
- **Cách chơi:** Kho từ vựng xoay vòng bất tận với độ khó tăng dần theo chuỗi thắng.
- **Luật Sinh Tồn & Ý tưởng Gamification bổ sung:**
  - Bắt đầu với **3 Tim Sinh Tồn (❤️❤️❤️)**. Trả lời sai hoặc hết giờ mất 1 Tim; hết 3 Tim sẽ kết thúc lượt chơi (Game Over).
  - **Hệ thống Combo Multiplier:** Trả lời đúng liên tiếp tăng hệ số nhân điểm (`Combo x1 -> x2 -> x3 -> x5`).
  - **Thưởng Hồi Tim (Bonus Heart):** Cứ mỗi chuỗi **5 từ đúng liên tiếp**, người chơi được hồi lại `+1 Tim` (tối đa 3 Tim)!
  - Lưu trữ **Kỷ lục Điểm Cao Nhất (High Score)** và **Chuỗi Combo Dài Nhất (Best Streak)** Offline.

### Chế độ 3: Thử Thách Mỗi Ngày (Daily Challenge — "Tốt Hơn Mỗi Ngày 1%")
- **Cách chơi:** Mỗi ngày hệ thống tuyển chọn **5 từ vựng trọng tâm của ngày** — kết hợp thông minh giữa **từ mới theo ngày** và **các từ trong Sổ tay Từ Hay Sai** của riêng người học.
- **Chỉ số "Tốt Hơn Mỗi Ngày" (Better Every Day Analytics):**
  - Lưu lịch sử làm bài hàng ngày (Độ chính xác %, Tốc độ phản xạ trung bình giây/từ, Điểm số).
  - Cuối màn chơi, hệ thống so sánh trực tiếp hôm nay với phiên trước đó:
    - Ví dụ: *"🚀 Hôm nay bạn phản xạ nhanh hơn **1.3 giây/từ** và chính xác hơn **+20%** so với lần trước!"*
  - Duy trì **Chuỗi Ngày Vượt Thử Thách (Daily Recall Streak)**.

---

## 4. Các Bước Thực Hiện Kỹ Thuật (Implementation Steps)

- [x] **Bước 1:** Thiết kế đặc tả chi tiết vào `WORD_CHALLENGE_PLAN.md` và tích hợp vào `PLAN.md`.
- [x] **Bước 2:** Mở rộng cơ sở dữ liệu từ vựng Offline (`curriculum_data.js` & `FlashcardEntity`) lên **30 từ vựng chuẩn phủ đều A1 -> C1**, bổ sung các trường: `cefr`, `grammarNote`, `usageTip`, `collocations`, `wordFamily`, `synonyms`, `antonyms`.
- [x] **Bước 3:** Xây dựng Engine tạo Ô chữ ẩn (`generateMaskedIndices`), kiểm tra lỗi chính tả gần đúng (`Levenshtein distance <= 1`), đồng hồ đếm ngược thời gian thực (`100ms tick`), và 3 chế độ chơi (`level_test`, `endless`, `daily`) trong bản Web Demo (`web_demo/app.js`, `styles.css`, `index.html`).
- [x] **Bước 4:** Đồng bộ màn hình `WordChallengeScreen` vào kiến trúc Flutter (`lib/features/vocabulary_srs/presentation/word_challenge_screen.dart`), liên kết với `VocabularySrsScreen` và kiểm tra hoạt động toàn trình.
