import 'models/meal_plan.dart';
import 'models/meal_preferences.dart';

abstract class MealPlanRepositoryInterface {
  Future<MealPlan?> getCurrentMealPlan();
  Future<MealPlan?> getMealPlanForWeek(DateTime weekStart);
  Future<void> saveMealPlan(MealPlan plan);
  Future<void> deleteMealPlan(String id);
  Future<MealPreferences> getPreferences();
  Future<void> savePreferences(MealPreferences prefs);
  Stream<MealPlan?> watchCurrentMealPlan();
}
