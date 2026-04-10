import 'package:freezed_annotation/freezed_annotation.dart';
import 'meal_plan_entry.dart';

part 'meal_plan.freezed.dart';
part 'meal_plan.g.dart';

@freezed
class MealPlan with _$MealPlan {
  const factory MealPlan({
    required String id,
    required DateTime weekStartDate,
    @Default([]) List<MealPlanEntry> entries,
    required DateTime createdAt,
  }) = _MealPlan;

  factory MealPlan.fromJson(Map<String, dynamic> json) => _$MealPlanFromJson(json);
}
