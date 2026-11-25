import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/services/speech_audio_service.dart';
import '../domain/ai_chat_message.dart';
import 'ai_tutor_provider.dart';

class AiTutorScreen extends ConsumerStatefulWidget {
  const AiTutorScreen({super.key});

  @override
  ConsumerState<AiTutorScreen> createState() => _AiTutorScreenState();
}

class _AiTutorScreenState extends ConsumerState<AiTutorScreen> {
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isVoiceListening = false;

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _handleSend([String? presetText]) {
    final text = presetText ?? _inputController.text;
    if (text.trim().isEmpty) return;
    FocusScope.of(context).unfocus();
    ref.read(aiTutorProvider.notifier).sendUserMessage(text);
    if (presetText == null) {
      _inputController.clear();
    }
    _scrollToBottom();
  }

  Future<void> _handleVoiceInput(String fallbackSuggestion) async {
    if (_isVoiceListening) return;
    HapticFeedback.selectionClick();
    setState(() => _isVoiceListening = true);

    final spoken = await ref
        .read(speechAudioServiceProvider)
        .listenAndTranscribe(expectedSentence: fallbackSuggestion);

    if (!mounted) return;
    setState(() {
      _isVoiceListening = false;
      _inputController.text = spoken;
    });
  }

  @override
  Widget build(BuildContext context) {
    final tutorState = ref.watch(aiTutorProvider);
    final lastAiMsg = tutorState.messages.lastWhere(
      (m) => !m.isUser,
      orElse: () => tutorState.messages.first,
    );

    return Column(
      children: [
        _ScenarioHeader(
          scenarios: tutorState.scenarios,
          activeScenario: tutorState.activeScenario,
          onSelect: (sc) =>
              ref.read(aiTutorProvider.notifier).selectScenario(sc),
        ),
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.all(16),
            itemCount: tutorState.messages.length,
            itemBuilder: (context, index) {
              final msg = tutorState.messages[index];
              return _ChatBubble(
                message: msg,
                onSpeak: () => ref
                    .read(speechAudioServiceProvider)
                    .speakEnglish(msg.text),
              );
            },
          ),
        ),
        if (lastAiMsg.suggestions.isNotEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: lastAiMsg.suggestions.map((suggestion) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ActionChip(
                      avatar: const Icon(
                        Icons.auto_awesome_rounded,
                        size: 16,
                        color: AppColors.secondary,
                      ),
                      label: Text(
                        suggestion,
                        style: const TextStyle(fontSize: 12),
                      ),
                      onPressed: () => _handleSend(suggestion),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 6, 12, 10),
            child: Row(
              children: [
                IconButton.filledTonal(
                  tooltip: 'Nói bằng giọng đọc iOS',
                  onPressed: _isVoiceListening
                      ? null
                      : () => _handleVoiceInput(
                            lastAiMsg.suggestions.isNotEmpty
                                ? lastAiMsg.suggestions.first
                                : 'Could you tell me more about that?',
                          ),
                  icon: Icon(
                    _isVoiceListening
                        ? Icons.graphic_eq_rounded
                        : Icons.mic_rounded,
                    color: _isVoiceListening
                        ? AppColors.heartRed
                        : AppColors.primary,
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: TextField(
                    controller: _inputController,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _handleSend(),
                    decoration: const InputDecoration(
                      hintText: 'Nhập hoặc chạm Mic để nói...',
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(48, 48),
                  ),
                  onPressed: tutorState.isAiTyping ? null : () => _handleSend(),
                  icon: tutorState.isAiTyping
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.send_rounded),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ScenarioHeader extends StatelessWidget {
  final List<RoleplayScenario> scenarios;
  final RoleplayScenario activeScenario;
  final ValueChanged<RoleplayScenario> onSelect;

  const _ScenarioHeader({
    required this.scenarios,
    required this.activeScenario,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderCol = isDark ? AppColors.borderDark : AppColors.borderLight;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: borderCol)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: scenarios.map((sc) {
                final isSelected = sc.id == activeScenario.id;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(sc.title),
                    selected: isSelected,
                    onSelected: (_) => onSelect(sc),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              const Text(
                'Từ mục tiêu:',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
              ),
              ...activeScenario.targetVocabulary.map(
                (word) => Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    word,
                    style: const TextStyle(
                      color: AppColors.secondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  final AiChatMessage message;
  final VoidCallback onSpeak;

  const _ChatBubble({
    required this.message,
    required this.onSpeak,
  });

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderCol = isDark ? AppColors.borderDark : AppColors.borderLight;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        constraints: const BoxConstraints(maxWidth: 330),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isUser
              ? AppColors.primary.withValues(alpha: 0.14)
              : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isUser
                ? AppColors.primary.withValues(alpha: 0.45)
                : borderCol,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isUser ? Icons.person_rounded : Icons.smart_toy_rounded,
                  size: 16,
                  color: isUser ? AppColors.primary : AppColors.secondary,
                ),
                const SizedBox(width: 6),
                Text(
                  isUser ? 'Bạn' : 'AI Tutor',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                    color: isUser ? AppColors.primary : AppColors.secondary,
                  ),
                ),
                const Spacer(),
                InkWell(
                  onTap: onSpeak,
                  child: const Icon(
                    Icons.volume_up_rounded,
                    size: 18,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(message.text, style: AppTypography.bodyLarge),
            if (message.vietnameseTranslation != null) ...[
              const SizedBox(height: 6),
              Text(
                message.vietnameseTranslation!,
                style: AppTypography.bodyMedium.copyWith(
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
            if (message.grammarCorrection != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  message.grammarCorrection!,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
