import 'package:flutter/foundation.dart';

@immutable
abstract class BaseModel {
  const BaseModel();

  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other);

  @override
  int get hashCode;

  @override
  String toString();
}

mixin JsonSerializable {
  Map<String, dynamic> toJson();
}

mixin Copyable<T> {
  T copyWith();
}
