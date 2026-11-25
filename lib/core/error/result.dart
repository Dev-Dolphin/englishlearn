import 'failures.dart';

/// Dart 3 Sealed Result class for Functional Error Handling (replaces Either<Failure, T>)
sealed class Result<T> {
  const Result();

  R fold<R>(
    R Function(Failure failure) onFailure,
    R Function(T data) onSuccess,
  ) {
    return switch (this) {
      Success<T>(data: final d) => onSuccess(d),
      Err<T>(failure: final f) => onFailure(f),
    };
  }

  bool get isSuccess => this is Success<T>;
  bool get isFailure => this is Err<T>;
}

final class Success<T> extends Result<T> {
  final T data;
  const Success(this.data);
}

final class Err<T> extends Result<T> {
  final Failure failure;
  const Err(this.failure);
}
