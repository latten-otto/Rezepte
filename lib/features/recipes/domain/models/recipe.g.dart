// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recipe.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$RecipeImpl _$$RecipeImplFromJson(Map<String, dynamic> json) => _$RecipeImpl(
  id: json['id'] as String,
  title: json['title'] as String,
  description: json['description'] as String?,
  imageUrl: json['imageUrl'] as String?,
  localImagePath: json['localImagePath'] as String?,
  ingredients:
      (json['ingredients'] as List<dynamic>)
          .map((e) => Ingredient.fromJson(e as Map<String, dynamic>))
          .toList(),
  steps:
      (json['steps'] as List<dynamic>)
          .map((e) => RecipeStep.fromJson(e as Map<String, dynamic>))
          .toList(),
  prepTimeMinutes: (json['prepTimeMinutes'] as num?)?.toInt(),
  cookTimeMinutes: (json['cookTimeMinutes'] as num?)?.toInt(),
  servings: (json['servings'] as num?)?.toInt() ?? 4,
  tags:
      (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  category:
      $enumDecodeNullable(_$RecipeCategoryEnumMap, json['category']) ??
      RecipeCategory.vegetarian,
  sourceUrl: json['sourceUrl'] as String?,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  isFavorite: json['isFavorite'] as bool? ?? false,
  notes: json['notes'] as String?,
);

Map<String, dynamic> _$$RecipeImplToJson(_$RecipeImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'imageUrl': instance.imageUrl,
      'localImagePath': instance.localImagePath,
      'ingredients': instance.ingredients.map((e) => e.toJson()).toList(),
      'steps': instance.steps.map((e) => e.toJson()).toList(),
      'prepTimeMinutes': instance.prepTimeMinutes,
      'cookTimeMinutes': instance.cookTimeMinutes,
      'servings': instance.servings,
      'tags': instance.tags,
      'category': _$RecipeCategoryEnumMap[instance.category]!,
      'sourceUrl': instance.sourceUrl,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'isFavorite': instance.isFavorite,
      'notes': instance.notes,
    };

const _$RecipeCategoryEnumMap = {
  RecipeCategory.meat: 'meat',
  RecipeCategory.fish: 'fish',
  RecipeCategory.vegetarian: 'vegetarian',
  RecipeCategory.vegan: 'vegan',
};
