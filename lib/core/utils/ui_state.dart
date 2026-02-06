import 'package:equatable/equatable.dart';

/// Represents the state of an async UI operation (loading, success, empty, error).
sealed class UiState<T> extends Equatable {
  const UiState();

  R when<R>({
    required R Function() loading,
    required R Function(T data) success,
    required R Function() empty,
    required R Function(String message) error,
  }) {
    return switch (this) {
      UiLoading() => loading(),
      UiSuccess(value: final v) => success(v),
      UiEmpty() => empty(),
      UiError(message: final m) => error(m),
    };
  }

  bool get isLoading => this is UiLoading;
  bool get isSuccess => this is UiSuccess;
  bool get isEmpty => this is UiEmpty;
  bool get isError => this is UiError;

  T? get dataOrNull => switch (this) {
        UiSuccess(value: final v) => v,
        _ => null,
      };
}

final class UiLoading<T> extends UiState<T> {
  const UiLoading();

  @override
  List<Object?> get props => [];
}

final class UiSuccess<T> extends UiState<T> {
  const UiSuccess(this.value);
  final T value;

  @override
  List<Object?> get props => [value];
}

final class UiEmpty<T> extends UiState<T> {
  const UiEmpty();

  @override
  List<Object?> get props => [];
}

final class UiError<T> extends UiState<T> {
  const UiError(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}
