// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'recipe.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Recipe _$RecipeFromJson(Map<String, dynamic> json) {
  return _Recipe.fromJson(json);
}

/// @nodoc
mixin _$Recipe {
  String get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  String? get imageUrl => throw _privateConstructorUsedError;
  String? get localImagePath => throw _privateConstructorUsedError;
  List<Ingredient> get ingredients => throw _privateConstructorUsedError;
  List<RecipeStep> get steps => throw _privateConstructorUsedError;
  int? get prepTimeMinutes => throw _privateConstructorUsedError;
  int? get cookTimeMinutes => throw _privateConstructorUsedError;
  int get servings => throw _privateConstructorUsedError;
  List<String> get tags => throw _privateConstructorUsedError;
  RecipeCategory get category => throw _privateConstructorUsedError;
  String? get sourceUrl => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;
  bool get isFavorite => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;

  /// Serializes this Recipe to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Recipe
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RecipeCopyWith<Recipe> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RecipeCopyWith<$Res> {
  factory $RecipeCopyWith(Recipe value, $Res Function(Recipe) then) =
      _$RecipeCopyWithImpl<$Res, Recipe>;
  @useResult
  $Res call({
    String id,
    String title,
    String? description,
    String? imageUrl,
    String? localImagePath,
    List<Ingredient> ingredients,
    List<RecipeStep> steps,
    int? prepTimeMinutes,
    int? cookTimeMinutes,
    int servings,
    List<String> tags,
    RecipeCategory category,
    String? sourceUrl,
    DateTime createdAt,
    DateTime updatedAt,
    bool isFavorite,
    String? notes,
  });
}

/// @nodoc
class _$RecipeCopyWithImpl<$Res, $Val extends Recipe>
    implements $RecipeCopyWith<$Res> {
  _$RecipeCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Recipe
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? description = freezed,
    Object? imageUrl = freezed,
    Object? localImagePath = freezed,
    Object? ingredients = null,
    Object? steps = null,
    Object? prepTimeMinutes = freezed,
    Object? cookTimeMinutes = freezed,
    Object? servings = null,
    Object? tags = null,
    Object? category = null,
    Object? sourceUrl = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? isFavorite = null,
    Object? notes = freezed,
  }) {
    return _then(
      _value.copyWith(
            id:
                null == id
                    ? _value.id
                    : id // ignore: cast_nullable_to_non_nullable
                        as String,
            title:
                null == title
                    ? _value.title
                    : title // ignore: cast_nullable_to_non_nullable
                        as String,
            description:
                freezed == description
                    ? _value.description
                    : description // ignore: cast_nullable_to_non_nullable
                        as String?,
            imageUrl:
                freezed == imageUrl
                    ? _value.imageUrl
                    : imageUrl // ignore: cast_nullable_to_non_nullable
                        as String?,
            localImagePath:
                freezed == localImagePath
                    ? _value.localImagePath
                    : localImagePath // ignore: cast_nullable_to_non_nullable
                        as String?,
            ingredients:
                null == ingredients
                    ? _value.ingredients
                    : ingredients // ignore: cast_nullable_to_non_nullable
                        as List<Ingredient>,
            steps:
                null == steps
                    ? _value.steps
                    : steps // ignore: cast_nullable_to_non_nullable
                        as List<RecipeStep>,
            prepTimeMinutes:
                freezed == prepTimeMinutes
                    ? _value.prepTimeMinutes
                    : prepTimeMinutes // ignore: cast_nullable_to_non_nullable
                        as int?,
            cookTimeMinutes:
                freezed == cookTimeMinutes
                    ? _value.cookTimeMinutes
                    : cookTimeMinutes // ignore: cast_nullable_to_non_nullable
                        as int?,
            servings:
                null == servings
                    ? _value.servings
                    : servings // ignore: cast_nullable_to_non_nullable
                        as int,
            tags:
                null == tags
                    ? _value.tags
                    : tags // ignore: cast_nullable_to_non_nullable
                        as List<String>,
            category:
                null == category
                    ? _value.category
                    : category // ignore: cast_nullable_to_non_nullable
                        as RecipeCategory,
            sourceUrl:
                freezed == sourceUrl
                    ? _value.sourceUrl
                    : sourceUrl // ignore: cast_nullable_to_non_nullable
                        as String?,
            createdAt:
                null == createdAt
                    ? _value.createdAt
                    : createdAt // ignore: cast_nullable_to_non_nullable
                        as DateTime,
            updatedAt:
                null == updatedAt
                    ? _value.updatedAt
                    : updatedAt // ignore: cast_nullable_to_non_nullable
                        as DateTime,
            isFavorite:
                null == isFavorite
                    ? _value.isFavorite
                    : isFavorite // ignore: cast_nullable_to_non_nullable
                        as bool,
            notes:
                freezed == notes
                    ? _value.notes
                    : notes // ignore: cast_nullable_to_non_nullable
                        as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$RecipeImplCopyWith<$Res> implements $RecipeCopyWith<$Res> {
  factory _$$RecipeImplCopyWith(
    _$RecipeImpl value,
    $Res Function(_$RecipeImpl) then,
  ) = __$$RecipeImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String title,
    String? description,
    String? imageUrl,
    String? localImagePath,
    List<Ingredient> ingredients,
    List<RecipeStep> steps,
    int? prepTimeMinutes,
    int? cookTimeMinutes,
    int servings,
    List<String> tags,
    RecipeCategory category,
    String? sourceUrl,
    DateTime createdAt,
    DateTime updatedAt,
    bool isFavorite,
    String? notes,
  });
}

/// @nodoc
class __$$RecipeImplCopyWithImpl<$Res>
    extends _$RecipeCopyWithImpl<$Res, _$RecipeImpl>
    implements _$$RecipeImplCopyWith<$Res> {
  __$$RecipeImplCopyWithImpl(
    _$RecipeImpl _value,
    $Res Function(_$RecipeImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Recipe
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? description = freezed,
    Object? imageUrl = freezed,
    Object? localImagePath = freezed,
    Object? ingredients = null,
    Object? steps = null,
    Object? prepTimeMinutes = freezed,
    Object? cookTimeMinutes = freezed,
    Object? servings = null,
    Object? tags = null,
    Object? category = null,
    Object? sourceUrl = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? isFavorite = null,
    Object? notes = freezed,
  }) {
    return _then(
      _$RecipeImpl(
        id:
            null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                    as String,
        title:
            null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                    as String,
        description:
            freezed == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                    as String?,
        imageUrl:
            freezed == imageUrl
                ? _value.imageUrl
                : imageUrl // ignore: cast_nullable_to_non_nullable
                    as String?,
        localImagePath:
            freezed == localImagePath
                ? _value.localImagePath
                : localImagePath // ignore: cast_nullable_to_non_nullable
                    as String?,
        ingredients:
            null == ingredients
                ? _value._ingredients
                : ingredients // ignore: cast_nullable_to_non_nullable
                    as List<Ingredient>,
        steps:
            null == steps
                ? _value._steps
                : steps // ignore: cast_nullable_to_non_nullable
                    as List<RecipeStep>,
        prepTimeMinutes:
            freezed == prepTimeMinutes
                ? _value.prepTimeMinutes
                : prepTimeMinutes // ignore: cast_nullable_to_non_nullable
                    as int?,
        cookTimeMinutes:
            freezed == cookTimeMinutes
                ? _value.cookTimeMinutes
                : cookTimeMinutes // ignore: cast_nullable_to_non_nullable
                    as int?,
        servings:
            null == servings
                ? _value.servings
                : servings // ignore: cast_nullable_to_non_nullable
                    as int,
        tags:
            null == tags
                ? _value._tags
                : tags // ignore: cast_nullable_to_non_nullable
                    as List<String>,
        category:
            null == category
                ? _value.category
                : category // ignore: cast_nullable_to_non_nullable
                    as RecipeCategory,
        sourceUrl:
            freezed == sourceUrl
                ? _value.sourceUrl
                : sourceUrl // ignore: cast_nullable_to_non_nullable
                    as String?,
        createdAt:
            null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                    as DateTime,
        updatedAt:
            null == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                    as DateTime,
        isFavorite:
            null == isFavorite
                ? _value.isFavorite
                : isFavorite // ignore: cast_nullable_to_non_nullable
                    as bool,
        notes:
            freezed == notes
                ? _value.notes
                : notes // ignore: cast_nullable_to_non_nullable
                    as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$RecipeImpl implements _Recipe {
  const _$RecipeImpl({
    required this.id,
    required this.title,
    this.description,
    this.imageUrl,
    this.localImagePath,
    required final List<Ingredient> ingredients,
    required final List<RecipeStep> steps,
    this.prepTimeMinutes,
    this.cookTimeMinutes,
    this.servings = 4,
    final List<String> tags = const [],
    this.category = RecipeCategory.vegetarian,
    this.sourceUrl,
    required this.createdAt,
    required this.updatedAt,
    this.isFavorite = false,
    this.notes,
  }) : _ingredients = ingredients,
       _steps = steps,
       _tags = tags;

  factory _$RecipeImpl.fromJson(Map<String, dynamic> json) =>
      _$$RecipeImplFromJson(json);

  @override
  final String id;
  @override
  final String title;
  @override
  final String? description;
  @override
  final String? imageUrl;
  @override
  final String? localImagePath;
  final List<Ingredient> _ingredients;
  @override
  List<Ingredient> get ingredients {
    if (_ingredients is EqualUnmodifiableListView) return _ingredients;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_ingredients);
  }

  final List<RecipeStep> _steps;
  @override
  List<RecipeStep> get steps {
    if (_steps is EqualUnmodifiableListView) return _steps;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_steps);
  }

  @override
  final int? prepTimeMinutes;
  @override
  final int? cookTimeMinutes;
  @override
  @JsonKey()
  final int servings;
  final List<String> _tags;
  @override
  @JsonKey()
  List<String> get tags {
    if (_tags is EqualUnmodifiableListView) return _tags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_tags);
  }

  @override
  @JsonKey()
  final RecipeCategory category;
  @override
  final String? sourceUrl;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  @override
  @JsonKey()
  final bool isFavorite;
  @override
  final String? notes;

  @override
  String toString() {
    return 'Recipe(id: $id, title: $title, description: $description, imageUrl: $imageUrl, localImagePath: $localImagePath, ingredients: $ingredients, steps: $steps, prepTimeMinutes: $prepTimeMinutes, cookTimeMinutes: $cookTimeMinutes, servings: $servings, tags: $tags, category: $category, sourceUrl: $sourceUrl, createdAt: $createdAt, updatedAt: $updatedAt, isFavorite: $isFavorite, notes: $notes)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RecipeImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            (identical(other.localImagePath, localImagePath) ||
                other.localImagePath == localImagePath) &&
            const DeepCollectionEquality().equals(
              other._ingredients,
              _ingredients,
            ) &&
            const DeepCollectionEquality().equals(other._steps, _steps) &&
            (identical(other.prepTimeMinutes, prepTimeMinutes) ||
                other.prepTimeMinutes == prepTimeMinutes) &&
            (identical(other.cookTimeMinutes, cookTimeMinutes) ||
                other.cookTimeMinutes == cookTimeMinutes) &&
            (identical(other.servings, servings) ||
                other.servings == servings) &&
            const DeepCollectionEquality().equals(other._tags, _tags) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.sourceUrl, sourceUrl) ||
                other.sourceUrl == sourceUrl) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.isFavorite, isFavorite) ||
                other.isFavorite == isFavorite) &&
            (identical(other.notes, notes) || other.notes == notes));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    title,
    description,
    imageUrl,
    localImagePath,
    const DeepCollectionEquality().hash(_ingredients),
    const DeepCollectionEquality().hash(_steps),
    prepTimeMinutes,
    cookTimeMinutes,
    servings,
    const DeepCollectionEquality().hash(_tags),
    category,
    sourceUrl,
    createdAt,
    updatedAt,
    isFavorite,
    notes,
  );

  /// Create a copy of Recipe
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RecipeImplCopyWith<_$RecipeImpl> get copyWith =>
      __$$RecipeImplCopyWithImpl<_$RecipeImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RecipeImplToJson(this);
  }
}

abstract class _Recipe implements Recipe {
  const factory _Recipe({
    required final String id,
    required final String title,
    final String? description,
    final String? imageUrl,
    final String? localImagePath,
    required final List<Ingredient> ingredients,
    required final List<RecipeStep> steps,
    final int? prepTimeMinutes,
    final int? cookTimeMinutes,
    final int servings,
    final List<String> tags,
    final RecipeCategory category,
    final String? sourceUrl,
    required final DateTime createdAt,
    required final DateTime updatedAt,
    final bool isFavorite,
    final String? notes,
  }) = _$RecipeImpl;

  factory _Recipe.fromJson(Map<String, dynamic> json) = _$RecipeImpl.fromJson;

  @override
  String get id;
  @override
  String get title;
  @override
  String? get description;
  @override
  String? get imageUrl;
  @override
  String? get localImagePath;
  @override
  List<Ingredient> get ingredients;
  @override
  List<RecipeStep> get steps;
  @override
  int? get prepTimeMinutes;
  @override
  int? get cookTimeMinutes;
  @override
  int get servings;
  @override
  List<String> get tags;
  @override
  RecipeCategory get category;
  @override
  String? get sourceUrl;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;
  @override
  bool get isFavorite;
  @override
  String? get notes;

  /// Create a copy of Recipe
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RecipeImplCopyWith<_$RecipeImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
