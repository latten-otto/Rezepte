import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:rezepte/core/database/app_database.dart' as db;
import 'package:rezepte/features/meal_planning/data/datasources/meal_plan_local_datasource.dart';
import 'package:rezepte/features/meal_planning/domain/meal_plan_repository_interface.dart';
import 'package:rezepte/features/meal_planning/domain/models/meal_plan.dart'
    as domain;
import 'package:rezepte/features/meal_planning/domain/models/meal_plan_entry.dart'
    as domain;
import 'package:rezepte/features/meal_planning/domain/models/meal_preferences.dart';

class MealPlanRepository implements MealPlanRepositoryInterface {
  final MealPlanLocalDatasource _datasource;

  MealPlanRepository(this._datasource);

  @override
  Future<domain.MealPlan?> getCurrentMealPlan() async {
    final row = await _datasource.getCurrentMealPlan();
    if (row == null) return null;
    return _mapRowToPlan(row);
  }

  @override
  Future<domain.MealPlan?> getMealPlanForWeek(DateTime weekStart) async {
    final row = await _datasource.getMealPlanForWeek(weekStart);
    if (row == null) return null;
    return _mapRowToPlan(row);
  }

  @override
  Future<void> saveMealPlan(domain.MealPlan plan) async {
    final existing = await _datasource.getMealPlanForWeek(plan.weekStartDate);
    if (existing != null) {
      await _datasource.deleteMealPlan(existing.id);
    }

    await _datasource.insertMealPlan(db.MealPlansCompanion.insert(
      id: plan.id,
      weekStartDate: plan.weekStartDate,
      createdAt: plan.createdAt,
    ));

    final entries = plan.entries
        .map((e) => db.MealPlanEntriesCompanion.insert(
              id: e.id,
              mealPlanId: plan.id,
              dayOfWeek: e.dayOfWeek,
              recipeId: e.recipeId,
              isLocked: Value(e.isLocked),
              servings: Value(e.servings),
            ))
        .toList();

    await _datasource.insertEntries(entries);
  }

  @override
  Future<void> deleteMealPlan(String id) {
    return _datasource.deleteMealPlan(id);
  }

  @override
  Future<MealPreferences> getPreferences() async {
    final mealsPerWeek =
        int.tryParse(await _datasource.getPreference('mealsPerWeek') ?? '') ??
            5;
    final maxMeat =
        int.tryParse(await _datasource.getPreference('maxMeatMeals') ?? '') ??
            2;
    final maxFish =
        int.tryParse(await _datasource.getPreference('maxFishMeals') ?? '') ??
            1;
    final servings = int.tryParse(
            await _datasource.getPreference('defaultServings') ?? '') ??
        4;
    final excludedStr =
        await _datasource.getPreference('excludedIngredients') ?? '[]';
    final preferredStr =
        await _datasource.getPreference('preferredTags') ?? '[]';
    final excludedTagsStr =
        await _datasource.getPreference('excludedTags') ?? '[]';

    return MealPreferences(
      mealsPerWeek: mealsPerWeek,
      maxMeatMeals: maxMeat,
      maxFishMeals: maxFish,
      defaultServings: servings,
      excludedIngredients: List<String>.from(jsonDecode(excludedStr)),
      preferredTags: List<String>.from(jsonDecode(preferredStr)),
      excludedTags: List<String>.from(jsonDecode(excludedTagsStr)),
    );
  }

  @override
  Future<void> savePreferences(MealPreferences prefs) async {
    await _datasource.setPreference(
        'mealsPerWeek', prefs.mealsPerWeek.toString());
    await _datasource.setPreference(
        'maxMeatMeals', prefs.maxMeatMeals.toString());
    await _datasource.setPreference(
        'maxFishMeals', prefs.maxFishMeals.toString());
    await _datasource.setPreference(
        'defaultServings', prefs.defaultServings.toString());
    await _datasource.setPreference(
        'excludedIngredients', jsonEncode(prefs.excludedIngredients));
    await _datasource.setPreference(
        'preferredTags', jsonEncode(prefs.preferredTags));
    await _datasource.setPreference(
        'excludedTags', jsonEncode(prefs.excludedTags));
  }

  @override
  Stream<domain.MealPlan?> watchCurrentMealPlan() {
    return _datasource.watchCurrentMealPlan().asyncMap((row) async {
      if (row == null) return null;
      return _mapRowToPlan(row);
    });
  }

  Future<domain.MealPlan> _mapRowToPlan(db.MealPlan row) async {
    final entryRows = await _datasource.getEntriesForPlan(row.id);
    return domain.MealPlan(
      id: row.id,
      weekStartDate: row.weekStartDate,
      entries: entryRows
          .map((e) => domain.MealPlanEntry(
                id: e.id,
                dayOfWeek: e.dayOfWeek,
                recipeId: e.recipeId,
                isLocked: e.isLocked,
                servings: e.servings,
              ))
          .toList(),
      createdAt: row.createdAt,
    );
  }
}
