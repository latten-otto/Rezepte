// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'meal_plan_entry.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

MealPlanEntry _$MealPlanEntryFromJson(Map<String, dynamic> json) {
  return _MealPlanEntry.fromJson(json);
}

/// @nodoc
mixin _$MealPlanEntry {
  String get id => throw _privateConstructorUsedError;
  int get dayOfWeek => throw _privateConstructorUsedError;
  String get recipeId => throw _privateConstructorUsedError;
  bool get isLocked => throw _privateConstructorUsedError;
  int get servings => throw _privateConstructorUsedError;

  /// Serializes this MealPlanEntry to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MealPlanEntry
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MealPlanEntryCopyWith<MealPlanEntry> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MealPlanEntryCopyWith<$Res> {
  factory $MealPlanEntryCopyWith(
    MealPlanEntry value,
    $Res Function(MealPlanEntry) then,
  ) = _$MealPlanEntryCopyWithImpl<$Res, MealPlanEntry>;
  @useResult
  $Res call({
    String id,
    int dayOfWeek,
    String recipeId,
    bool isLocked,
    int servings,
  });
}

/// @nodoc
class _$MealPlanEntryCopyWithImpl<$Res, $Val extends MealPlanEntry>
    implements $MealPlanEntryCopyWith<$Res> {
  _$MealPlanEntryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MealPlanEntry
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? dayOfWeek = null,
    Object? recipeId = null,
    Object? isLocked = null,
    Object? servings = null,
  }) {
    return _then(
      _value.copyWith(
            id:
                null == id
                    ? _value.id
                    : id // ignore: cast_nullable_to_non_nullable
                        as String,
            dayOfWeek:
                null == dayOfWeek
                    ? _value.dayOfWeek
                    : dayOfWeek // ignore: cast_nullable_to_non_nullable
                        as int,
            recipeId:
                null == recipeId
                    ? _value.recipeId
                    : recipeId // ignore: cast_nullable_to_non_nullable
                        as String,
            isLocked:
                null == isLocked
                    ? _value.isLocked
                    : isLocked // ignore: cast_nullable_to_non_nullable
                        as bool,
            servings:
                null == servings
                    ? _value.servings
                    : servings // ignore: cast_nullable_to_non_nullable
                        as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$MealPlanEntryImplCopyWith<$Res>
    implements $MealPlanEntryCopyWith<$Res> {
  factory _$$MealPlanEntryImplCopyWith(
    _$MealPlanEntryImpl value,
    $Res Function(_$MealPlanEntryImpl) then,
  ) = __$$MealPlanEntryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    int dayOfWeek,
    String recipeId,
    bool isLocked,
    int servings,
  });
}

/// @nodoc
class __$$MealPlanEntryImplCopyWithImpl<$Res>
    extends _$MealPlanEntryCopyWithImpl<$Res, _$MealPlanEntryImpl>
    implements _$$MealPlanEntryImplCopyWith<$Res> {
  __$$MealPlanEntryImplCopyWithImpl(
    _$MealPlanEntryImpl _value,
    $Res Function(_$MealPlanEntryImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MealPlanEntry
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? dayOfWeek = null,
    Object? recipeId = null,
    Object? isLocked = null,
    Object? servings = null,
  }) {
    return _then(
      _$MealPlanEntryImpl(
        id:
            null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                    as String,
        dayOfWeek:
            null == dayOfWeek
                ? _value.dayOfWeek
                : dayOfWeek // ignore: cast_nullable_to_non_nullable
                    as int,
        recipeId:
            null == recipeId
                ? _value.recipeId
                : recipeId // ignore: cast_nullable_to_non_nullable
                    as String,
        isLocked:
            null == isLocked
                ? _value.isLocked
                : isLocked // ignore: cast_nullable_to_non_nullable
                    as bool,
        servings:
            null == servings
                ? _value.servings
                : servings // ignore: cast_nullable_to_non_nullable
                    as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$MealPlanEntryImpl implements _MealPlanEntry {
  const _$MealPlanEntryImpl({
    required this.id,
    required this.dayOfWeek,
    required this.recipeId,
    this.isLocked = false,
    this.servings = 4,
  });

  factory _$MealPlanEntryImpl.fromJson(Map<String, dynamic> json) =>
      _$$MealPlanEntryImplFromJson(json);

  @override
  final String id;
  @override
  final int dayOfWeek;
  @override
  final String recipeId;
  @override
  @JsonKey()
  final bool isLocked;
  @override
  @JsonKey()
  final int servings;

  @override
  String toString() {
    return 'MealPlanEntry(id: $id, dayOfWeek: $dayOfWeek, recipeId: $recipeId, isLocked: $isLocked, servings: $servings)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MealPlanEntryImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.dayOfWeek, dayOfWeek) ||
                other.dayOfWeek == dayOfWeek) &&
            (identical(other.recipeId, recipeId) ||
                other.recipeId == recipeId) &&
            (identical(other.isLocked, isLocked) ||
                other.isLocked == isLocked) &&
            (identical(other.servings, servings) ||
                other.servings == servings));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, dayOfWeek, recipeId, isLocked, servings);

  /// Create a copy of MealPlanEntry
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MealPlanEntryImplCopyWith<_$MealPlanEntryImpl> get copyWith =>
      __$$MealPlanEntryImplCopyWithImpl<_$MealPlanEntryImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MealPlanEntryImplToJson(this);
  }
}

abstract class _MealPlanEntry implements MealPlanEntry {
  const factory _MealPlanEntry({
    required final String id,
    required final int dayOfWeek,
    required final String recipeId,
    final bool isLocked,
    final int servings,
  }) = _$MealPlanEntryImpl;

  factory _MealPlanEntry.fromJson(Map<String, dynamic> json) =
      _$MealPlanEntryImpl.fromJson;

  @override
  String get id;
  @override
  int get dayOfWeek;
  @override
  String get recipeId;
  @override
  bool get isLocked;
  @override
  int get servings;

  /// Create a copy of MealPlanEntry
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MealPlanEntryImplCopyWith<_$MealPlanEntryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
