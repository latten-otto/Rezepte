import 'package:drift/drift.dart';
import 'package:rezepte/core/database/app_database.dart' as db;
import 'package:rezepte/features/recipes/domain/models/recipe.dart'
    as domain;
import 'package:rezepte/seed/seed_recipes.dart';

class DatabaseSeeder {
  final db.AppDatabase _db;

  DatabaseSeeder(this._db);

  /// Seeds initial recipes if the database is empty.
  Future<void> seedIfEmpty() async {
    final count = await _db.select(_db.recipes).get();
    if (count.isNotEmpty) return;

    for (final recipe in seedRecipes) {
      await _db.into(_db.recipes).insert(db.RecipesCompanion.insert(
            id: recipe.id,
            title: recipe.title,
            description: Value(recipe.description),
            imageUrl: Value(recipe.imageUrl),
            localImagePath: Value(recipe.localImagePath),
            prepTimeMinutes: Value(recipe.prepTimeMinutes),
            cookTimeMinutes: Value(recipe.cookTimeMinutes),
            servings: Value(recipe.servings),
            category: _categoryToString(recipe.category),
            sourceUrl: Value(recipe.sourceUrl),
            createdAt: recipe.createdAt,
            updatedAt: recipe.updatedAt,
            isFavorite: Value(recipe.isFavorite),
            notes: Value(recipe.notes),
          ));

      for (var i = 0; i < recipe.ingredients.length; i++) {
        final ing = recipe.ingredients[i];
        await _db
            .into(_db.ingredients)
            .insert(db.IngredientsCompanion.insert(
              id: ing.id,
              recipeId: recipe.id,
              name: ing.name,
              amount: Value(ing.amount),
              unit: Value(ing.unit),
              category: Value(ing.category),
              originalText: Value(ing.originalText),
              sortOrder: i,
            ));
      }

      for (final step in recipe.steps) {
        await _db
            .into(_db.recipeSteps)
            .insert(db.RecipeStepsCompanion.insert(
              id: step.id,
              recipeId: recipe.id,
              stepNumber: step.stepNumber,
              instruction: step.instruction,
              imageUrl: Value(step.imageUrl),
            ));
      }

      for (final tag in recipe.tags) {
        final tagId = tag.toLowerCase().replaceAll(' ', '-');
        await _db.into(_db.tags).insertOnConflictUpdate(
              db.TagsCompanion.insert(id: tagId, name: tag),
            );
        await _db.into(_db.recipeTags).insert(
              db.RecipeTagsCompanion.insert(recipeId: recipe.id, tagId: tagId),
            );
      }
    }
  }

  static String _categoryToString(domain.RecipeCategory category) {
    switch (category) {
      case domain.RecipeCategory.meat:
        return 'meat';
      case domain.RecipeCategory.fish:
        return 'fish';
      case domain.RecipeCategory.vegetarian:
        return 'vegetarian';
      case domain.RecipeCategory.vegan:
        return 'vegan';
    }
  }
}
