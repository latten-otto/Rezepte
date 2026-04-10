import 'package:freezed_annotation/freezed_annotation.dart';

part 'meal_plan_entry.freezed.dart';
part 'meal_plan_entry.g.dart';

@freezed
class MealPlanEntry with _$MealPlanEntry {
  const factory MealPlanEntry({
    required String id,
    required int dayOfWeek,
    required String recipeId,
    @Default(false) bool isLocked,
    @Default(4) int servings,
  }) = _MealPlanEntry;

  factory MealPlanEntry.fromJson(Map<String, dynamic> json) => _$MealPlanEntryFromJson(json);
}
