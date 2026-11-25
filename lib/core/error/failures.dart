import 'package:equatable/equatable.dart';

sealed class Failure extends Equatable {
  final String message;
  final String? code;

  const Failure(this.message, {this.code});

  @override
  List<Object?> get props => [message, code];
}

final class NetworkFailure extends Failure {
  const NetworkFailure([
    super.message = 'Không có kết nối mạng. Đang chuyển sang chế độ Offline.',
  ]);
}

final class ServerFailure extends Failure {
  const ServerFailure([
    super.message = 'Máy chủ AI đang bận, vui lòng thử lại sau.',
    String? code,
  ]) : super(code: code);
}

final class CacheFailure extends Failure {
  const CacheFailure([
    super.message = 'Không thể đọc dữ liệu lưu trữ cục bộ.',
  ]);
}

final class PermissionFailure extends Failure {
  const PermissionFailure([
    super.message = 'Vui lòng cấp quyền Microphone để luyện phát âm.',
  ]);
}
