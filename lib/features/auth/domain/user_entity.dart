import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String name;
  final String email;
  final String learningGoal;
  final int dailyGoalMinutes;
  final String cefrLevel;

  const UserEntity({
    required this.id,
    required this.name,
    required this.email,
    required this.learningGoal,
    required this.dailyGoalMinutes,
    required this.cefrLevel,
  });

  UserEntity copyWith({
    String? id,
    String? name,
    String? email,
    String? learningGoal,
    int? dailyGoalMinutes,
    String? cefrLevel,
  }) {
    return UserEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      learningGoal: learningGoal ?? this.learningGoal,
      dailyGoalMinutes: dailyGoalMinutes ?? this.dailyGoalMinutes,
      cefrLevel: cefrLevel ?? this.cefrLevel,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        email,
        learningGoal,
        dailyGoalMinutes,
        cefrLevel,
      ];
}
