import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/widgets/app_button.dart';
import '../../auth/presentation/auth_provider.dart';
import '../../gamification/presentation/gamification_provider.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  final VoidCallback onFinished;

  const OnboardingScreen({
    super.key,
    required this.onFinished,
  });

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  int _step = 0;
  String _selectedGoal = 'Giao tiếp Công việc & IT';
  int _selectedMinutes = 15;
  int _placementScore = 0;
  int? _selectedPlacementOption;

  static const List<String> _goals = [
    'Giao tiếp Công việc & IT',
    'Luyện thi IELTS / TOEIC',
    'Du lịch & Khám phá Thế giới',
    'Phát triển Tư duy & Đọc tài liệu',
  ];

  static const List<int> _dailyOptions = [5, 10, 15, 30];

  static const List<Map<String, Object>> _placementQuestions = [
    {
      'level': 'A2',
      'question': 'Choose the most natural response:\n"How long have you been working on this project?"',
      'options': [
        'Since three months ago.',
        'For about three months.',
        'During three months.',
        'In three months.',
      ],
      'correctIndex': 1,
    },
    {
      'level': 'B1',
      'question': 'Complete the conditional sentence:\n"If I _____ earlier about the meeting, I would have prepared the slides."',
      'options': [
        'knew',
        'have known',
        'had known',
        'would know',
      ],
      'correctIndex': 2,
    },
    {
      'level': 'B2',
      'question': 'Select the best business idiom:\n"Let\'s not get bogged down in minor details; we need to look at the _____."',
      'options': [
        'big picture',
        'large photo',
        'wide frame',
        'high view',
      ],
      'correctIndex': 0,
    },
  ];

  void _handleNext() {
    if (_step < 2 + _placementQuestions.length - 1) {
      if (_step >= 2) {
        final qIndex = _step - 2;
        final correctIndex =
            _placementQuestions[qIndex]['correctIndex'] as int;
        if (_selectedPlacementOption == correctIndex) {
          _placementScore++;
        }
        _selectedPlacementOption = null;
      }
      setState(() => _step++);
    } else {
      final qIndex = _step - 2;
      final correctIndex = _placementQuestions[qIndex]['correctIndex'] as int;
      if (_selectedPlacementOption == correctIndex) {
        _placementScore++;
      }

      final cefr = switch (_placementScore) {
        0 => 'A1',
        1 => 'A2',
        2 => 'B1',
        _ => 'B2',
      };

      ref.read(authProvider.notifier).updateProfile(
            learningGoal: _selectedGoal,
            dailyGoalMinutes: _selectedMinutes,
            cefrLevel: cefr,
          );
      ref.read(gamificationProvider.notifier).setCefrLevel(
            cefr,
            dailyGoalMinutes: _selectedMinutes,
          );

      widget.onFinished();
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalSteps = 2 + _placementQuestions.length;
    final progress = (_step + 1) / totalSteps;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Thiết lập lộ trình cá nhân hóa'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(6),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 6,
            backgroundColor: AppColors.borderLight,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildStepContent(),
              ),
              AppButton(
                label: _step == totalSteps - 1
                    ? 'Hoàn tất & Nhận lộ trình AI'
                    : 'Tiếp tục',
                onPressed: (_step >= 2 && _selectedPlacementOption == null)
                    ? null
                    : _handleNext,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepContent() {
    if (_step == 0) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Mục tiêu học tiếng Anh chính của bạn là gì?',
            style: AppTypography.headlineMedium,
          ),
          const SizedBox(height: 8),
          const Text(
            'AI Tutor sẽ tối ưu chủ đề từ vựng và tình huống hội thoại theo mục tiêu này.',
            style: AppTypography.bodyMedium,
          ),
          const SizedBox(height: 20),
          ..._goals.map((goal) {
            final isSelected = goal == _selectedGoal;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => setState(() => _selectedGoal = goal),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.borderLight,
                      width: isSelected ? 2.5 : 1.5,
                    ),
                    color: isSelected
                        ? AppColors.primary.withValues(alpha: 0.08)
                        : null,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isSelected
                            ? Icons.check_circle_rounded
                            : Icons.circle_outlined,
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.textSecondaryLight,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          goal,
                          style: AppTypography.titleMedium,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      );
    }

    if (_step == 1) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Bạn muốn dành bao nhiêu thời gian mỗi ngày?',
            style: AppTypography.headlineMedium,
          ),
          const SizedBox(height: 8),
          const Text(
            'Duy trì thói quen đều đặn cùng thuật toán SRS giúp nhớ lâu gấp 3 lần.',
            style: AppTypography.bodyMedium,
          ),
          const SizedBox(height: 20),
          ..._dailyOptions.map((mins) {
            final isSelected = mins == _selectedMinutes;
            final label = switch (mins) {
              5 => '5 phút / ngày • Nhẹ nhàng',
              10 => '10 phút / ngày • Đều đặn',
              15 => '15 phút / ngày • Tiêu chuẩn (Khuyên dùng)',
              _ => '30 phút / ngày • Tăng tốc bứt phá',
            };
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => setState(() => _selectedMinutes = mins),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.borderLight,
                      width: isSelected ? 2.5 : 1.5,
                    ),
                    color: isSelected
                        ? AppColors.primary.withValues(alpha: 0.08)
                        : null,
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.timer_outlined,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          label,
                          style: AppTypography.titleMedium,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      );
    }

    final qIndex = _step - 2;
    final question = _placementQuestions[qIndex];
    final options = question['options'] as List<String>;
    final levelTag = question['level'] as String;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.secondary.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            'Placement Test • Câu ${qIndex + 1}/${_placementQuestions.length} (Mức $levelTag)',
            style: const TextStyle(
              color: AppColors.secondary,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
        ),
        const SizedBox(height: 14),
        Text(
          question['question'] as String,
          style: AppTypography.titleLarge,
        ),
        const SizedBox(height: 20),
        ...List.generate(options.length, (idx) {
          final isSelected = _selectedPlacementOption == idx;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () => setState(() => _selectedPlacementOption = idx),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.secondary
                        : AppColors.borderLight,
                    width: isSelected ? 2.2 : 1.4,
                  ),
                  color: isSelected
                      ? AppColors.secondary.withValues(alpha: 0.08)
                      : null,
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 14,
                      backgroundColor: isSelected
                          ? AppColors.secondary
                          : AppColors.borderLight,
                      child: Text(
                        String.fromCharCode(65 + idx),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: isSelected
                              ? Colors.white
                              : AppColors.textPrimaryLight,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        options[idx],
                        style: AppTypography.bodyLarge,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}
