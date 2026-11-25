import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../gamification/presentation/gamification_provider.dart';
import '../domain/ai_chat_message.dart';

class AiTutorState extends Equatable {
  final List<RoleplayScenario> scenarios;
  final RoleplayScenario activeScenario;
  final List<AiChatMessage> messages;
  final bool isAiTyping;

  const AiTutorState({
    required this.scenarios,
    required this.activeScenario,
    required this.messages,
    this.isAiTyping = false,
  });

  AiTutorState copyWith({
    List<RoleplayScenario>? scenarios,
    RoleplayScenario? activeScenario,
    List<AiChatMessage>? messages,
    bool? isAiTyping,
  }) {
    return AiTutorState(
      scenarios: scenarios ?? this.scenarios,
      activeScenario: activeScenario ?? this.activeScenario,
      messages: messages ?? this.messages,
      isAiTyping: isAiTyping ?? this.isAiTyping,
    );
  }

  @override
  List<Object?> get props => [
        scenarios,
        activeScenario,
        messages,
        isAiTyping,
      ];
}

class AiTutorNotifier extends Notifier<AiTutorState> {
  static const List<RoleplayScenario> _defaultScenarios = [
    RoleplayScenario(
      id: 'sc_interview',
      title: 'Phỏng vấn Kỹ sư Phần mềm Quốc tế',
      roleDescription: 'AI đóng vai Tech Lead tại công ty công nghệ Mỹ.',
      targetCefr: 'B1-B2',
      targetVocabulary: ['scalable', 'architecture', 'collaborate', 'deadline'],
      initialAiGreeting:
          'Hi there! Welcome to the technical interview. Could you tell me about a challenging project you worked on recently?',
    ),
    RoleplayScenario(
      id: 'sc_hotel',
      title: 'Nhận phòng & Yêu cầu dịch vụ Khách sạn',
      roleDescription: 'AI đóng vai Lễ tân khách sạn 5 sao tại London.',
      targetCefr: 'A2-B1',
      targetVocabulary: ['reservation', 'upgrade', 'complimentary', 'checkout'],
      initialAiGreeting:
          'Good evening! Welcome to The Grand London Hotel. How may I assist you with your check-in today?',
    ),
    RoleplayScenario(
      id: 'sc_pitch',
      title: 'Thuyết trình Giải pháp với Khách hàng',
      roleDescription: 'AI đóng vai Giám đốc Sản phẩm của đối tác.',
      targetCefr: 'B2-C1',
      targetVocabulary: ['feasible', 'milestone', 'prioritize', 'bottleneck'],
      initialAiGreeting:
          'Thanks for hopping on this call. How does your proposed roadmap help us hit our Q4 milestones?',
    ),
    RoleplayScenario(
      id: 'sc_cafe',
      title: 'Gọi món & Trò chuyện tại Quán Cà Phê',
      roleDescription: 'AI đóng vai Barista thân thiện tại New York.',
      targetCefr: 'A1-A2',
      targetVocabulary: ['recommend', 'oat milk', 'pastries', 'contactless'],
      initialAiGreeting:
          'Good morning! Welcome to Central Perk Café. What can I get started for you today?',
    ),
    RoleplayScenario(
      id: 'sc_airport',
      title: 'Làm thủ tục Sân bay & Hải quan',
      roleDescription: 'AI đóng vai Nhân viên hãng hàng không quốc tế.',
      targetCefr: 'A2-B1',
      targetVocabulary: ['aisle seat', 'boarding pass', 'carry-on', 'connection'],
      initialAiGreeting:
          'Hello! May I see your passport and booking reference? Would you prefer a window or an aisle seat today?',
    ),
  ];

  @override
  AiTutorState build() {
    final first = _defaultScenarios.first;
    return AiTutorState(
      scenarios: _defaultScenarios,
      activeScenario: first,
      messages: [
        AiChatMessage(
          id: 'msg_init',
          isUser: false,
          text: first.initialAiGreeting,
          vietnameseTranslation:
              'Xin chào! Chào mừng bạn đến với buổi phỏng vấn kỹ thuật. Bạn có thể chia sẻ về một dự án thử thách mà bạn mới tham gia gần đây không?',
          suggestions: const [
            'I recently built a scalable mobile app using Flutter Clean Architecture.',
            'Last month, I collaborated with my team to optimize our backend API.',
          ],
          timestamp: DateTime.now(),
        ),
      ],
    );
  }

  void selectScenario(RoleplayScenario scenario) {
    state = state.copyWith(
      activeScenario: scenario,
      messages: [
        AiChatMessage(
          id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
          isUser: false,
          text: scenario.initialAiGreeting,
          vietnameseTranslation:
              'Hãy bắt đầu tình huống "${scenario.title}". Cố gắng sử dụng các từ vựng mục tiêu nhé!',
          suggestions: [
            'I would like to discuss our ${scenario.targetVocabulary.first} plan.',
            'Could you tell me more about the options available?',
          ],
          timestamp: DateTime.now(),
        ),
      ],
    );
  }

  Future<void> sendUserMessage(String rawText) async {
    final trimmed = rawText.trim();
    if (trimmed.isEmpty || state.isAiTyping) return;

    final grammarFeedback = _analyzeGrammarCorrection(trimmed);

    final userMsg = AiChatMessage(
      id: 'usr_${DateTime.now().millisecondsSinceEpoch}',
      isUser: true,
      text: trimmed,
      grammarCorrection: grammarFeedback,
      timestamp: DateTime.now(),
    );

    state = state.copyWith(
      messages: [...state.messages, userMsg],
      isAiTyping: true,
    );

    await Future<void>.delayed(const Duration(milliseconds: 500));

    final aiResponse = _generateContextualAiResponse(
      userText: trimmed,
      scenario: state.activeScenario,
      turnIndex: state.messages.length,
    );

    state = state.copyWith(
      messages: [...state.messages, aiResponse],
      isAiTyping: false,
    );

    ref.read(gamificationProvider.notifier).addXp(10);
  }

  String? _analyzeGrammarCorrection(String input) {
    final lower = input.toLowerCase();
    if (lower.contains('i work on') && lower.contains('yesterday')) {
      return '💡 Gợi ý ngữ pháp: Dùng thì quá khứ đơn "I worked on..." khi đi kèm với "yesterday".';
    }
    if (lower.contains('more better')) {
      return '💡 Gợi ý ngữ pháp: "Better" đã là so sánh hơn, không dùng "more better" (hãy dùng "much better").';
    }
    if (lower.contains('discuss about')) {
      return '💡 Gợi ý ngữ pháp: Động từ "discuss" không đi kèm giới từ "about" (chỉ cần dùng "discuss something").';
    }
    if (!RegExp(r'[.?!]$').hasMatch(input)) {
      return '✅ Câu tự nhiên! Lưu ý viết hoa đầu câu và thêm dấu chấm câu khi giao tiếp văn bản chuyên nghiệp.';
    }
    return '✅ Ngữ pháp chính xác & diễn đạt rất tự nhiên!';
  }

  AiChatMessage _generateContextualAiResponse({
    required String userText,
    required RoleplayScenario scenario,
    required int turnIndex,
  }) {
    final usedVocab = scenario.targetVocabulary
        .where((word) => userText.toLowerCase().contains(word.toLowerCase()))
        .toList();

    final praisePrefix = usedVocab.isNotEmpty
        ? 'Excellent use of "${usedVocab.first}"! '
        : '';

    return AiChatMessage(
      id: 'ai_${DateTime.now().millisecondsSinceEpoch}',
      isUser: false,
      text:
          '${praisePrefix}That makes a lot of sense. What would be your next step to ensure everything stays on track?',
      vietnameseTranslation:
          'Điều đó rất hợp lý! Bước tiếp theo của bạn là gì để đảm bảo mọi thứ đi đúng tiến độ?',
      suggestions: const [
        'We prioritized core features first and communicated early with stakeholders.',
        'I would double-check the requirements and follow up with the team.',
      ],
      timestamp: DateTime.now(),
    );
  }
}

final aiTutorProvider = NotifierProvider<AiTutorNotifier, AiTutorState>(
  AiTutorNotifier.new,
);
