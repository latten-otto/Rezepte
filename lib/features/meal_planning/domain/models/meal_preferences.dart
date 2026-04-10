import 'package:freezed_annotation/freezed_annotation.dart';

part 'meal_preferences.freezed.dart';
part 'meal_preferences.g.dart';

@freezed
class MealPreferences with _$MealPreferences {
  const factory MealPreferences({
    @Default(5) int mealsPerWeek,
    @Default(2) int maxMeatMeals,
    @Default(1) int maxFishMeals,
    @Default(4) int defaultServings,
    @Default([]) List<String> excludedIngredients,
    @Default([]) List<String> preferredTags,
    @Default([]) List<String> excludedTags,
  }) = _MealPreferences;

  factory MealPreferences.fromJson(Map<String, dynamic> json) => _$MealPreferencesFromJson(json);
}
