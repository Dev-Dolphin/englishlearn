import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/local_storage_service.dart';
import '../domain/learning_unit.dart';

class HomeLearningPathNotifier extends Notifier<List<LearningUnit>> {
  @override
  List<LearningUnit> build() {
    _loadCompletedFromStorage();
    return _defaultUnits();
  }

  Future<void> _loadCompletedFromStorage() async {
    final storage = ref.read(localStorageServiceProvider);
    final completedIds =
        await storage.getStringList(storage.keyCompletedLessons);
    if (completedIds.isEmpty) return;

    state = [
      for (final unit in state)
        unit.copyWith(
          lessons: [
            for (final lesson in unit.lessons)
              if (completedIds.contains(lesson.id))
                lesson.copyWith(isCompleted: true, isLocked: false)
              else
                lesson,
          ],
        ),
    ];
  }

  Future<void> markLessonCompleted(String lessonId) async {
    state = [
      for (final unit in state)
        unit.copyWith(
          lessons: [
            for (int i = 0; i < unit.lessons.length; i++)
              if (unit.lessons[i].id == lessonId)
                unit.lessons[i].copyWith(isCompleted: true, isLocked: false)
              else if (i > 0 && unit.lessons[i - 1].id == lessonId)
                unit.lessons[i].copyWith(isLocked: false)
              else
                unit.lessons[i],
          ],
        ),
    ];

    final completedIds = <String>[];
    for (final u in state) {
      for (final l in u.lessons) {
        if (l.isCompleted) completedIds.add(l.id);
      }
    }
    final storage = ref.read(localStorageServiceProvider);
    await storage.setStringList(storage.keyCompletedLessons, completedIds);
  }

  List<LearningUnit> _defaultUnits() {
    return const [
      LearningUnit(
        id: 'unit_1',
        unitNumber: 1,
        title: 'Giao tiếp Hàng ngày & Phản xạ Cơ bản',
        description:
            'Làm chủ các tình huống chào hỏi, Small Talk, gọi đồ uống và mua sắm.',
        cefrLevel: 'A1-A2',
        lessons: [
          LessonNode(
            id: 'lesson_1_1',
            title: 'Greetings & Small Talk',
            subtitle: 'Chào hỏi tự nhiên, bắt chuyện & giới thiệu bản thân',
            xpReward: 25,
            isCompleted: true,
            grammarNote:
                'Dùng "How have things been going?" để hỏi thăm tình hình gần đây tự nhiên hơn "How are you?".',
            keyVocab: [
              LessonVocabItem(
                word: 'Pleasure',
                ipa: '/ˈplɛʒə/',
                meaning: 'Niềm vinh hạnh, rất vui',
                example: 'It is a pleasure to finally meet you in person.',
              ),
              LessonVocabItem(
                word: 'Catch up',
                ipa: '/kætʃ ʌp/',
                meaning: 'Trò chuyện cập nhật tình hình',
                example: 'Let us grab a coffee this week to catch up.',
              ),
              LessonVocabItem(
                word: 'Division',
                ipa: '/dɪˈvɪʒən/',
                meaning: 'Bộ phận, khối (trong công ty)',
                example: 'She works in the mobile product division.',
              ),
            ],
          ),
          LessonNode(
            id: 'lesson_1_2',
            title: 'Ordering at a Café & Restaurant',
            subtitle: 'Gọi đồ uống, yêu cầu ít ngọt & thanh toán hóa đơn',
            xpReward: 30,
            grammarNote:
                'Dùng "Could I get..." hoặc "I would like..." thay vì "Give me..." khi gọi món để lịch sự.',
            keyVocab: [
              LessonVocabItem(
                word: 'For here or to go',
                ipa: '/fɔː hɪər ɔː tuː ɡəʊ/',
                meaning: 'Dùng tại quán hay mang đi',
                example: 'Would you like your iced latte for here or to go?',
              ),
              LessonVocabItem(
                word: 'Contactless',
                ipa: '/ˈkɒntæktləs/',
                meaning: 'Thanh toán một chạm',
                example: 'Can I pay by contactless card or Apple Pay?',
              ),
            ],
          ),
          LessonNode(
            id: 'lesson_1_3',
            title: 'Shopping & Asking for Prices',
            subtitle: 'Hỏi kích cỡ, phòng thử đồ & chính sách hoàn tiền',
            xpReward: 30,
            grammarNote:
                'Dùng "Do you have this in + [size/color]?" để hỏi kích cỡ hoặc màu sắc khác.',
            keyVocab: [
              LessonVocabItem(
                word: 'Fitting room',
                ipa: '/ˈfɪtɪŋ ruːm/',
                meaning: 'Phòng thử đồ',
                example: 'Could I try this jacket on in the fitting room?',
              ),
              LessonVocabItem(
                word: 'Receipt',
                ipa: '/rɪˈsiːt/',
                meaning: 'Biên lai thanh toán (chữ p câm)',
                example: 'Please keep your original receipt for exchanges.',
              ),
            ],
          ),
        ],
      ),
      LearningUnit(
        id: 'unit_2',
        unitNumber: 2,
        title: 'Du lịch Quốc tế, Sân bay & Khách sạn',
        description:
            'Tự tin xử lý mọi tình huống tại quầy thủ tục bay, hải quan và khách sạn.',
        cefrLevel: 'A2-B1',
        lessons: [
          LessonNode(
            id: 'lesson_2_1',
            title: 'Airport Check-in & Immigration',
            subtitle: 'Làm thủ tục bay, chọn ghế ngồi & trả lời hải quan',
            xpReward: 35,
            grammarNote:
                'Tại quầy Hải quan, trả lời ngắn gọn mục đích chuyến đi (for business / for a conference) và số ngày lưu trú.',
            keyVocab: [
              LessonVocabItem(
                word: 'Aisle seat',
                ipa: '/aɪl siːt/',
                meaning: 'Ghế ngồi cạnh lối đi (chữ s câm)',
                example: 'Could I have an aisle seat near the front?',
              ),
              LessonVocabItem(
                word: 'Boarding pass',
                ipa: '/ˈbɔːdɪŋ pɑːs/',
                meaning: 'Thẻ lên máy bay',
                example: 'Please have your boarding pass and passport ready.',
              ),
            ],
          ),
          LessonNode(
            id: 'lesson_2_2',
            title: 'Hotel Reservation & Troubleshooting',
            subtitle: 'Nhận phòng, yêu cầu trả phòng muộn & dịch vụ phòng',
            xpReward: 35,
            grammarNote:
                'Luôn dùng giới từ UNDER khi đọc tên đặt phòng: "I have a reservation UNDER the name...".',
            keyVocab: [
              LessonVocabItem(
                word: 'Complimentary',
                ipa: '/ˌkɒmplɪˈmɛntəri/',
                meaning: 'Miễn phí đi kèm dịch vụ',
                example: 'Our hotel offers a complimentary buffet breakfast.',
              ),
              LessonVocabItem(
                word: 'Late checkout',
                ipa: '/leɪt ˈtʃɛkaʊt/',
                meaning: 'Trả phòng muộn',
                example: 'Could I request a late checkout at 1 PM?',
              ),
            ],
          ),
        ],
      ),
      LearningUnit(
        id: 'unit_3',
        unitNumber: 3,
        title: 'Tiếng Anh Công sở & Họp nhóm Quốc tế',
        description:
            'Báo cáo tiến độ Daily Standup, nêu trở ngại kỹ thuật và phản biện chuyên nghiệp.',
        cefrLevel: 'B1',
        lessons: [
          LessonNode(
            id: 'lesson_3_1',
            title: 'Daily Standup & Project Update',
            subtitle: 'Báo cáo tiến độ, nêu khó khăn (blockers) & kế hoạch ngày',
            xpReward: 40,
            grammarNote:
                'Dùng Hiện tại tiếp diễn "I am currently working on + V-ing" cho việc đang triển khai.',
            keyVocab: [
              LessonVocabItem(
                word: 'Blocker',
                ipa: '/ˈblɒkə/',
                meaning: 'Trở ngại làm gián đoạn công việc',
                example: 'We ran into a minor technical blocker.',
              ),
              LessonVocabItem(
                word: 'Align on',
                ipa: '/əˈlaɪn ɒn/',
                meaning: 'Thống nhất về ưu tiên/mục tiêu',
                example: 'Let us align on the top priorities for this sprint.',
              ),
            ],
          ),
          LessonNode(
            id: 'lesson_3_2',
            title: 'Expressing Opinions & Polite Disagreement',
            subtitle: 'Đồng tình, phản biện khéo léo & tổng kết cuộc họp',
            xpReward: 40,
            grammarNote:
                'Ghi nhận ý kiến đối phương trước khi phản biện: "I see your point, but from a technical perspective...".',
            keyVocab: [
              LessonVocabItem(
                word: 'Elaborate',
                ipa: '/ɪˈlæbəreɪt/',
                meaning: 'Giải thích chi tiết hơn',
                example: 'Could you elaborate on the budget estimate?',
              ),
              LessonVocabItem(
                word: 'Feasible',
                ipa: '/ˈfiːzəbl/',
                meaning: 'Khả thi, có thể thực hiện được',
                example: 'Is it feasible to launch this feature next month?',
              ),
            ],
          ),
        ],
      ),
      LearningUnit(
        id: 'unit_4',
        unitNumber: 4,
        title: 'Phỏng vấn Quốc tế & Phát triển Sự nghiệp',
        description:
            'Chinh phục nhà tuyển dụng bằng phương pháp STAR và đàm phán đãi ngộ.',
        cefrLevel: 'B1-B2',
        lessons: [
          LessonNode(
            id: 'lesson_4_1',
            title: 'Behavioral Interview (STAR Method)',
            subtitle: 'Kể câu chuyện thành tựu định lượng & làm việc nhóm',
            xpReward: 45,
            grammarNote:
                'Nêu rõ Hành động cụ thể ở Quá khứ đơn kèm Kết quả đo lường được (reduced latency by 45%).',
            keyVocab: [
              LessonVocabItem(
                word: 'Spearhead',
                ipa: '/ˈspɪəhɛd/',
                meaning: 'Dẫn dắt, đi đầu thực hiện sáng kiến',
                example: 'I spearheaded the migration to Clean Architecture.',
              ),
              LessonVocabItem(
                word: 'Collaborate',
                ipa: '/kəˈlæbəreɪt/',
                meaning: 'Phối hợp chặt chẽ cùng nhau',
                example: 'I collaborated closely with product and QA teams.',
              ),
            ],
          ),
        ],
      ),
      LearningUnit(
        id: 'unit_5',
        unitNumber: 5,
        title: 'Thuyết trình Chiến lược & Quản trị Rủi ro',
        description:
            'Trình bày lộ trình sản phẩm, cột mốc quan trọng và phương án dự phòng.',
        cefrLevel: 'B2',
        lessons: [
          LessonNode(
            id: 'lesson_5_1',
            title: 'Pitching Roadmap & Mitigating Risks',
            subtitle: 'Trình bày Milestones & kế hoạch dự phòng rủi ro',
            xpReward: 50,
            grammarNote:
                'Sử dụng "To mitigate potential delays, we prepared a contingency plan" để tăng độ thuyết phục.',
            keyVocab: [
              LessonVocabItem(
                word: 'Mitigate',
                ipa: '/ˈmɪtɪɡeɪt/',
                meaning: 'Giảm thiểu rủi ro hoặc tác động xấu',
                example: 'Automated tests help mitigate regression risks.',
              ),
              LessonVocabItem(
                word: 'Milestone',
                ipa: '/ˈmaɪlstəʊn/',
                meaning: 'Cột mốc quan trọng của dự án',
                example: 'Launching offline mode is our biggest milestone.',
              ),
            ],
          ),
        ],
      ),
      LearningUnit(
        id: 'unit_6',
        unitNumber: 6,
        title: 'Học thuật, IELTS & Idioms Bản xứ',
        description:
            'Nâng tầm diễn đạt học thuật C1, tranh biện sâu sắc và sử dụng Idioms tự nhiên.',
        cefrLevel: 'B2-C1',
        lessons: [
          LessonNode(
            id: 'lesson_6_1',
            title: 'Native Idioms & IELTS Academic Fluency',
            subtitle: 'Sử dụng thành ngữ tinh tế & cấu trúc điểm 8.0+ IELTS',
            xpReward: 55,
            grammarNote:
                'Dùng cụm "play a pivotal role in + V-ing" thay cho "is very important for".',
            keyVocab: [
              LessonVocabItem(
                word: 'Ubiquitous',
                ipa: '/juːˈbɪkwɪtəs/',
                meaning: 'Hiện diện ở khắp mọi nơi (C1)',
                example:
                    'Artificial intelligence has become ubiquitous in education.',
              ),
              LessonVocabItem(
                word: 'On the same page',
                ipa: '/ɒn ðə seɪm peɪdʒ/',
                meaning: 'Hiểu thống nhất quan điểm với nhau',
                example: 'Let us make sure everyone is on the same page.',
              ),
            ],
          ),
        ],
      ),
    ];
  }
}

final homeLearningPathProvider =
    NotifierProvider<HomeLearningPathNotifier, List<LearningUnit>>(
  HomeLearningPathNotifier.new,
);
