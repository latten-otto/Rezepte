import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rezepte/features/meal_planning/data/datasources/meal_plan_local_datasource.dart';
import 'package:rezepte/features/meal_planning/data/repositories/meal_plan_repository.dart';
import 'package:rezepte/features/meal_planning/domain/models/meal_plan.dart';
import 'package:rezepte/features/meal_planning/domain/models/meal_preferences.dart';
import 'package:rezepte/features/meal_planning/domain/services/meal_plan_generator.dart';
import 'package:rezepte/features/recipes/presentation/providers/recipes_provider.dart';

final mealPlanLocalDatasourceProvider =
    Provider<MealPlanLocalDatasource>((ref) {
  final db = ref.watch(databaseProvider);
  return MealPlanLocalDatasource(db);
});

final mealPlanRepositoryProvider = Provider<MealPlanRepository>((ref) {
  final datasource = ref.watch(mealPlanLocalDatasourceProvider);
  return MealPlanRepository(datasource);
});

final mealPlanGeneratorProvider = Provider<MealPlanGenerator>((ref) {
  return MealPlanGenerator();
});

final currentMealPlanProvider = StreamProvider<MealPlan?>((ref) {
  final repo = ref.watch(mealPlanRepositoryProvider);
  return repo.watchCurrentMealPlan();
});

final mealPreferencesProvider = FutureProvider<MealPreferences>((ref) {
  final repo = ref.watch(mealPlanRepositoryProvider);
  return repo.getPreferences();
});
