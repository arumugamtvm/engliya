import 'package:flutter/foundation.dart';

@immutable
sealed class Result<T> {
  const Result();

  bool get isSuccess => this is Success<T>;
  bool get isFailure => this is Failure<T>;

  T? get valueOrNull => isSuccess ? (this as Success<T>).value : null;
  AppError? get errorOrNull => isFailure ? (this as Failure<T>).error : null;

  T getOrThrow() {
    if (this is Success<T>) {
      return (this as Success<T>).value;
    }
    throw (this as Failure<T>).error;
  }

  T getOrElse(T Function() orElse) {
    if (this is Success<T>) {
      return (this as Success<T>).value;
    }
    return orElse();
  }

  T getOrDefault(T defaultValue) {
    if (this is Success<T>) {
      return (this as Success<T>).value;
    }
    return defaultValue;
  }

  Result<R> map<R>(R Function(T value) transform) {
    if (this is Success<T>) {
      try {
        return Success(transform((this as Success<T>).value));
      } catch (e, stackTrace) {
        return Failure(AppError.fromException(e, stackTrace));
      }
    }
    return Failure((this as Failure<T>).error);
  }

  Result<R> flatMap<R>(Result<R> Function(T value) transform) {
    if (this is Success<T>) {
      try {
        return transform((this as Success<T>).value);
      } catch (e, stackTrace) {
        return Failure(AppError.fromException(e, stackTrace));
      }
    }
    return Failure((this as Failure<T>).error);
  }

  R fold<R>(R Function(T value) onSuccess, R Function(AppError error) onFailure) {
    if (this is Success<T>) {
      return onSuccess((this as Success<T>).value);
    }
    return onFailure((this as Failure<T>).error);
  }

  void when({
    required void Function(T value) success,
    required void Function(AppError error) failure,
  }) {
    if (this is Success<T>) {
      success((this as Success<T>).value);
    } else {
      failure((this as Failure<T>).error);
    }
  }

  static Result<T> tryCatch<T>(T Function() operation) {
    try {
      return Success(operation());
    } catch (e, stackTrace) {
      return Failure(AppError.fromException(e, stackTrace));
    }
  }

  static Future<Result<T>> tryCatchAsync<T>(Future<T> Function() operation) async {
    try {
      return Success(await operation());
    } catch (e, stackTrace) {
      return Failure(AppError.fromException(e, stackTrace));
    }
  }
}

@immutable
final class Success<T> extends Result<T> {
  final T value;
  const Success(this.value);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Success<T> && other.value == value;
  }

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'Success($value)';
}

@immutable
final class Failure<T> extends Result<T> {
  final AppError error;
  const Failure(this.error);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Failure<T> && other.error == error;
  }

  @override
  int get hashCode => error.hashCode;

  @override
  String toString() => 'Failure($error)';
}

enum ErrorCode {
  unknown,
  network,
  timeout,
  notFound,
  invalidData,
  storage,
  permission,
  initialization,
  parsing,
  validation,
  audioPlayback,
  speechRecognition,
  testGeneration,
  lessonLoading,
  progressSaving,
}

@immutable
class AppError implements Exception {
  final ErrorCode code;
  final String message;
  final String? details;
  final Object? originalError;
  final StackTrace? stackTrace;

  const AppError({
    required this.code,
    required this.message,
    this.details,
    this.originalError,
    this.stackTrace,
  });

  factory AppError.fromException(Object error, [StackTrace? stackTrace]) {
    if (error is AppError) {
      return error;
    }
    
    return AppError(
      code: ErrorCode.unknown,
      message: error.toString(),
      originalError: error,
      stackTrace: stackTrace,
    );
  }

  factory AppError.network(String message, {Object? originalError}) {
    return AppError(
      code: ErrorCode.network,
      message: message,
      originalError: originalError,
    );
  }

  factory AppError.notFound(String resource) {
    return AppError(
      code: ErrorCode.notFound,
      message: '$resource not found',
    );
  }

  factory AppError.invalidData(String message, {String? details}) {
    return AppError(
      code: ErrorCode.invalidData,
      message: message,
      details: details,
    );
  }

  factory AppError.storage(String message, {Object? originalError}) {
    return AppError(
      code: ErrorCode.storage,
      message: message,
      originalError: originalError,
    );
  }

  factory AppError.lessonLoading(String lessonId, {Object? originalError}) {
    return AppError(
      code: ErrorCode.lessonLoading,
      message: 'Failed to load lesson: $lessonId',
      originalError: originalError,
    );
  }

  String get userFriendlyMessage {
    switch (code) {
      case ErrorCode.network:
        return 'Please check your internet connection and try again.';
      case ErrorCode.timeout:
        return 'The request timed out. Please try again.';
      case ErrorCode.notFound:
        return 'The requested content could not be found.';
      case ErrorCode.storage:
        return 'There was a problem saving your progress.';
      case ErrorCode.audioPlayback:
        return 'Unable to play audio. Please try again.';
      case ErrorCode.speechRecognition:
        return 'Speech recognition is not available. Please check your permissions.';
      case ErrorCode.lessonLoading:
        return 'Unable to load the lesson. Please try again.';
      default:
        return 'An unexpected error occurred. Please try again.';
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AppError && 
        other.code == code && 
        other.message == message;
  }

  @override
  int get hashCode => Object.hash(code, message);

  @override
  String toString() => 'AppError(${code.name}: $message)';
}
