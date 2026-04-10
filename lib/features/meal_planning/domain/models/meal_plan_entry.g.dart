// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meal_plan_entry.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MealPlanEntryImpl _$$MealPlanEntryImplFromJson(Map<String, dynamic> json) =>
    _$MealPlanEntryImpl(
      id: json['id'] as String,
      dayOfWeek: (json['dayOfWeek'] as num).toInt(),
      recipeId: json['recipeId'] as String,
      isLocked: json['isLocked'] as bool? ?? false,
      servings: (json['servings'] as num?)?.toInt() ?? 4,
    );

Map<String, dynamic> _$$MealPlanEntryImplToJson(_$MealPlanEntryImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'dayOfWeek': instance.dayOfWeek,
      'recipeId': instance.recipeId,
      'isLocked': instance.isLocked,
      'servings': instance.servings,
    };
