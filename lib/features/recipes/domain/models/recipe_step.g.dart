// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recipe_step.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$RecipeStepImpl _$$RecipeStepImplFromJson(Map<String, dynamic> json) =>
    _$RecipeStepImpl(
      id: json['id'] as String,
      stepNumber: (json['stepNumber'] as num).toInt(),
      instruction: json['instruction'] as String,
      imageUrl: json['imageUrl'] as String?,
    );

Map<String, dynamic> _$$RecipeStepImplToJson(_$RecipeStepImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'stepNumber': instance.stepNumber,
      'instruction': instance.instruction,
      'imageUrl': instance.imageUrl,
    };
