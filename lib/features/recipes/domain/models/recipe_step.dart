import 'package:freezed_annotation/freezed_annotation.dart';

part 'recipe_step.freezed.dart';
part 'recipe_step.g.dart';

@freezed
class RecipeStep with _$RecipeStep {
  const factory RecipeStep({
    required String id,
    required int stepNumber,
    required String instruction,
    String? imageUrl,
  }) = _RecipeStep;

  factory RecipeStep.fromJson(Map<String, dynamic> json) => _$RecipeStepFromJson(json);
}
