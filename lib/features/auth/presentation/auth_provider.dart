import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/user_entity.dart';

class AuthNotifier extends Notifier<UserEntity> {
  @override
  UserEntity build() {
    return const UserEntity(
      id: 'usr_01',
      name: 'Minh Anh',
      email: 'minhanh@lingoai.vn',
      learningGoal: 'Giao tiếp Công việc & Phỏng vấn Quốc tế',
      dailyGoalMinutes: 15,
      cefrLevel: 'B1',
    );
  }

  void updateProfile({
    String? name,
    String? learningGoal,
    int? dailyGoalMinutes,
    String? cefrLevel,
  }) {
    state = state.copyWith(
      name: name,
      learningGoal: learningGoal,
      dailyGoalMinutes: dailyGoalMinutes,
      cefrLevel: cefrLevel,
    );
  }
}

final authProvider = NotifierProvider<AuthNotifier, UserEntity>(
  AuthNotifier.new,
);
