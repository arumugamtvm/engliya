import 'dart:math' as math;

extension StringExtensions on String {
  bool get isBlank => trim().isEmpty;
  bool get isNotBlank => trim().isNotEmpty;

  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  String capitalizeWords() {
    if (isEmpty) return this;
    return split(' ')
        .map((word) => word.isEmpty ? word : word.capitalize())
        .join(' ');
  }

  String truncate(int maxLength, {String suffix = '...'}) {
    if (length <= maxLength) return this;
    return '${substring(0, maxLength - suffix.length)}$suffix';
  }

  String? get nullIfBlank => isBlank ? null : this;
}

extension NullableStringExtensions on String? {
  bool get isNullOrBlank => this == null || this!.isBlank;
  bool get isNotNullOrBlank => this != null && this!.isNotBlank;
  String orEmpty() => this ?? '';
}

extension ListExtensions<T> on List<T> {
  T? get firstOrNull => isEmpty ? null : first;
  T? get lastOrNull => isEmpty ? null : last;

  T? elementAtOrNull(int index) {
    if (index < 0 || index >= length) return null;
    return this[index];
  }

  List<T> takeLast(int count) {
    if (count >= length) return this;
    return sublist(length - count);
  }

  List<T> shuffledCopy([int? seed]) {
    final copy = List<T>.from(this);
    copy.shuffle(seed != null ? math.Random(seed) : null);
    return copy;
  }
}

extension MapExtensions<K, V> on Map<K, V> {
  V? getOrNull(K key) => containsKey(key) ? this[key] : null;

  Map<K, V> where(bool Function(K key, V value) test) {
    final result = <K, V>{};
    forEach((key, value) {
      if (test(key, value)) {
        result[key] = value;
      }
    });
    return result;
  }
}

extension DoubleExtensions on double {
  String toPercentString({int decimalPlaces = 0}) {
    return '${(this * 100).toStringAsFixed(decimalPlaces)}%';
  }

  double clampBetween(double min, double max) {
    return clamp(min, max).toDouble();
  }
}

extension IntExtensions on int {
  String toOrdinal() {
    if (this >= 11 && this <= 13) return '${this}th';
    switch (this % 10) {
      case 1:
        return '${this}st';
      case 2:
        return '${this}nd';
      case 3:
        return '${this}rd';
      default:
        return '${this}th';
    }
  }

  Duration get milliseconds => Duration(milliseconds: this);
  Duration get seconds => Duration(seconds: this);
  Duration get minutes => Duration(minutes: this);
}

extension DurationExtensions on Duration {
  String toFormattedString() {
    final minutes = inMinutes;
    final seconds = inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}
