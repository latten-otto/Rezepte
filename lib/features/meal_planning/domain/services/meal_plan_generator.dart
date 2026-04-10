import 'dart:math';

import 'package:rezepte/features/meal_planning/domain/models/meal_plan.dart'
    as domain;
import 'package:rezepte/features/meal_planning/domain/models/meal_plan_entry.dart'
    as domain;
import 'package:rezepte/features/meal_planning/domain/models/meal_preferences.dart';
import 'package:rezepte/features/recipes/domain/models/recipe.dart';
import 'package:uuid/uuid.dart';

class MealPlanGenerator {
  final _random = Random();
  final _uuid = const Uuid();

  domain.MealPlan generate({
    required MealPreferences preferences,
    required List<Recipe> allRecipes,
    required DateTime weekStartDate,
    List<domain.MealPlanEntry> lockedEntries = const [],
  }) {
    final available = _filterRecipes(allRecipes, preferences);
    final entries = <domain.MealPlanEntry>[...lockedEntries];

    // Count locked meals per category
    int lockedMeat = 0, lockedFish = 0;
    final lockedRecipeIds = lockedEntries.map((e) => e.recipeId).toSet();

    for (final entry in lockedEntries) {
      final recipe = allRecipes.firstWhere(
        (r) => r.id == entry.recipeId,
        orElse: () => allRecipes.first,
      );
      if (recipe.category == RecipeCategory.meat) lockedMeat++;
      if (recipe.category == RecipeCategory.fish) lockedFish++;
    }

    // Calculate remaining slots
    final totalNeeded = preferences.mealsPerWeek - lockedEntries.length;
    final remainingMeat = max(0, preferences.maxMeatMeals - lockedMeat);
    final remainingFish = max(0, preferences.maxFishMeals - lockedFish);
    final remainingVeg = max(0, totalNeeded - remainingMeat - remainingFish);

    // Get recipes by category
    final meatRecipes = available
        .where((r) => r.category == RecipeCategory.meat)
        .where((r) => !lockedRecipeIds.contains(r.id))
        .toList();
    final fishRecipes = available
        .where((r) => r.category == RecipeCategory.fish)
        .where((r) => !lockedRecipeIds.contains(r.id))
        .toList();
    final vegRecipes = available
        .where((r) =>
            r.category == RecipeCategory.vegetarian ||
            r.category == RecipeCategory.vegan)
        .where((r) => !lockedRecipeIds.contains(r.id))
        .toList();
    final allAvailable = available
        .where((r) => !lockedRecipeIds.contains(r.id))
        .toList();

    final selected = <Recipe>[];

    // Fill meat slots
    selected.addAll(_pickRandom(meatRecipes, remainingMeat, selected));
    // Fill fish slots
    selected.addAll(_pickRandom(fishRecipes, remainingFish, selected));
    // Fill vegetarian slots
    selected.addAll(_pickRandom(vegRecipes, remainingVeg, selected));

    // If not enough recipes in categories, fill from all available
    while (selected.length < totalNeeded && allAvailable.isNotEmpty) {
      final remaining = allAvailable
          .where((r) => !selected.any((s) => s.id == r.id))
          .toList();
      if (remaining.isEmpty) break;
      selected.add(remaining[_random.nextInt(remaining.length)]);
    }

    // Assign to days (avoid consecutive meat days)
    _shuffleWithConstraints(selected);

    // Find free days
    final lockedDays = lockedEntries.map((e) => e.dayOfWeek).toSet();
    final freeDays = List.generate(7, (i) => i + 1)
        .where((d) => !lockedDays.contains(d))
        .toList();

    for (var i = 0; i < selected.length && i < freeDays.length; i++) {
      entries.add(domain.MealPlanEntry(
        id: _uuid.v4(),
        dayOfWeek: freeDays[i],
        recipeId: selected[i].id,
        servings: preferences.defaultServings,
      ));
    }

    entries.sort((a, b) => a.dayOfWeek.compareTo(b.dayOfWeek));

    return domain.MealPlan(
      id: _uuid.v4(),
      weekStartDate: weekStartDate,
      entries: entries,
      createdAt: DateTime.now(),
    );
  }

  List<Recipe> _filterRecipes(
      List<Recipe> recipes, MealPreferences preferences) {
    return recipes.where((r) {
      // Exclude recipes with excluded ingredients
      for (final excluded in preferences.excludedIngredients) {
        if (r.ingredients.any(
            (i) => i.name.toLowerCase().contains(excluded.toLowerCase()))) {
          return false;
        }
      }
      // Exclude recipes with excluded tags
      for (final tag in preferences.excludedTags) {
        if (r.tags.any((t) => t.toLowerCase() == tag.toLowerCase())) {
          return false;
        }
      }
      return true;
    }).toList();
  }

  List<Recipe> _pickRandom(
      List<Recipe> pool, int count, List<Recipe> alreadySelected) {
    final available =
        pool.where((r) => !alreadySelected.any((s) => s.id == r.id)).toList();
    available.shuffle(_random);
    // Favor favorites
    available.sort((a, b) {
      if (a.isFavorite && !b.isFavorite) return -1;
      if (!a.isFavorite && b.isFavorite) return 1;
      return 0;
    });
    return available.take(count).toList();
  }

  void _shuffleWithConstraints(List<Recipe> recipes) {
    // Simple shuffle then try to avoid consecutive meat days
    recipes.shuffle(_random);
    for (var i = 1; i < recipes.length; i++) {
      if (recipes[i].category == RecipeCategory.meat &&
          recipes[i - 1].category == RecipeCategory.meat) {
        // Find a non-meat recipe to swap with
        for (var j = i + 1; j < recipes.length; j++) {
          if (recipes[j].category != RecipeCategory.meat) {
            final temp = recipes[i];
            recipes[i] = recipes[j];
            recipes[j] = temp;
            break;
          }
        }
      }
    }
  }
}
