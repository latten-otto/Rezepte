// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meal_preferences.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MealPreferencesImpl _$$MealPreferencesImplFromJson(
  Map<String, dynamic> json,
) => _$MealPreferencesImpl(
  mealsPerWeek: (json['mealsPerWeek'] as num?)?.toInt() ?? 5,
  maxMeatMeals: (json['maxMeatMeals'] as num?)?.toInt() ?? 2,
  maxFishMeals: (json['maxFishMeals'] as num?)?.toInt() ?? 1,
  defaultServings: (json['defaultServings'] as num?)?.toInt() ?? 4,
  excludedIngredients:
      (json['excludedIngredients'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  preferredTags:
      (json['preferredTags'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  excludedTags:
      (json['excludedTags'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
);

Map<String, dynamic> _$$MealPreferencesImplToJson(
  _$MealPreferencesImpl instance,
) => <String, dynamic>{
  'mealsPerWeek': instance.mealsPerWeek,
  'maxMeatMeals': instance.maxMeatMeals,
  'maxFishMeals': instance.maxFishMeals,
  'defaultServings': instance.defaultServings,
  'excludedIngredients': instance.excludedIngredients,
  'preferredTags': instance.preferredTags,
  'excludedTags': instance.excludedTags,
};
