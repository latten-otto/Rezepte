import 'package:drift/drift.dart';
import 'package:rezepte/core/database/app_database.dart' as db;
import 'package:rezepte/features/recipes/data/datasources/recipe_local_datasource.dart';
import 'package:rezepte/features/recipes/domain/models/ingredient.dart';
import 'package:rezepte/features/recipes/domain/models/recipe.dart';
import 'package:rezepte/features/recipes/domain/models/recipe_step.dart';
import 'package:rezepte/features/recipes/domain/recipe_repository_interface.dart';

class RecipeRepository implements RecipeRepositoryInterface {
  final RecipeLocalDatasource _datasource;

  RecipeRepository(this._datasource);

  // --- Mapping helpers ---

  Future<Recipe> _mapRowToRecipe(db.Recipe row) async {
    final ingredients = await _datasource.getIngredients(row.id);
    final steps = await _datasource.getSteps(row.id);
    final tags = await _datasource.getTagsForRecipe(row.id);

    return Recipe(
      id: row.id,
      title: row.title,
      description: row.description,
      imageUrl: row.imageUrl,
      localImagePath: row.localImagePath,
      ingredients: ingredients.map(_mapIngredientRow).toList(),
      steps: steps.map(_mapStepRow).toList(),
      prepTimeMinutes: row.prepTimeMinutes,
      cookTimeMinutes: row.cookTimeMinutes,
      servings: row.servings,
      tags: tags,
      category: _categoryFromString(row.category),
      sourceUrl: row.sourceUrl,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
      isFavorite: row.isFavorite,
      notes: row.notes,
    );
  }

  Ingredient _mapIngredientRow(db.Ingredient row) {
    return Ingredient(
      id: row.id,
      name: row.name,
      amount: row.amount,
      unit: row.unit,
      category: row.category,
      originalText: row.originalText,
    );
  }

  RecipeStep _mapStepRow(db.RecipeStep row) {
    return RecipeStep(
      id: row.id,
      stepNumber: row.stepNumber,
      instruction: row.instruction,
      imageUrl: row.imageUrl,
    );
  }

  db.RecipesCompanion _recipeToCompanion(Recipe recipe) {
    return db.RecipesCompanion(
      id: Value(recipe.id),
      title: Value(recipe.title),
      description: Value(recipe.description),
      imageUrl: Value(recipe.imageUrl),
      localImagePath: Value(recipe.localImagePath),
      prepTimeMinutes: Value(recipe.prepTimeMinutes),
      cookTimeMinutes: Value(recipe.cookTimeMinutes),
      servings: Value(recipe.servings),
      category: Value(_categoryToString(recipe.category)),
      sourceUrl: Value(recipe.sourceUrl),
      createdAt: Value(recipe.createdAt),
      updatedAt: Value(recipe.updatedAt),
      isFavorite: Value(recipe.isFavorite),
      notes: Value(recipe.notes),
    );
  }

  List<db.IngredientsCompanion> _ingredientsToCompanions(
      String recipeId, List<Ingredient> ingredients) {
    return ingredients
        .asMap()
        .entries
        .map((e) => db.IngredientsCompanion(
              id: Value(e.value.id),
              recipeId: Value(recipeId),
              name: Value(e.value.name),
              amount: Value(e.value.amount),
              unit: Value(e.value.unit),
              category: Value(e.value.category),
              originalText: Value(e.value.originalText),
              sortOrder: Value(e.key),
            ))
        .toList();
  }

  List<db.RecipeStepsCompanion> _stepsToCompanions(
      String recipeId, List<RecipeStep> steps) {
    return steps
        .map((step) => db.RecipeStepsCompanion(
              id: Value(step.id),
              recipeId: Value(recipeId),
              stepNumber: Value(step.stepNumber),
              instruction: Value(step.instruction),
              imageUrl: Value(step.imageUrl),
            ))
        .toList();
  }

  static RecipeCategory _categoryFromString(String value) {
    switch (value) {
      case 'meat':
        return RecipeCategory.meat;
      case 'fish':
        return RecipeCategory.fish;
      case 'vegetarian':
        return RecipeCategory.vegetarian;
      case 'vegan':
        return RecipeCategory.vegan;
      default:
        return RecipeCategory.vegetarian;
    }
  }

  static String _categoryToString(RecipeCategory category) {
    switch (category) {
      case RecipeCategory.meat:
        return 'meat';
      case RecipeCategory.fish:
        return 'fish';
      case RecipeCategory.vegetarian:
        return 'vegetarian';
      case RecipeCategory.vegan:
        return 'vegan';
    }
  }

  // --- Interface Implementation ---

  @override
  Stream<List<Recipe>> watchAllRecipes() {
    return _datasource.watchAllRecipes().asyncMap((rows) async {
      final recipes = <Recipe>[];
      for (final row in rows) {
        recipes.add(await _mapRowToRecipe(row));
      }
      return recipes;
    });
  }

  @override
  Future<List<Recipe>> getAllRecipes() async {
    final rows = await _datasource.getAllRecipes();
    final recipes = <Recipe>[];
    for (final row in rows) {
      recipes.add(await _mapRowToRecipe(row));
    }
    return recipes;
  }

  @override
  Future<Recipe?> getRecipeById(String id) async {
    final row = await _datasource.getRecipeById(id);
    if (row == null) return null;
    return _mapRowToRecipe(row);
  }

  @override
  Future<void> insertRecipe(Recipe recipe) async {
    await _datasource.insertRecipe(_recipeToCompanion(recipe));
    await _datasource.insertIngredients(
      _ingredientsToCompanions(recipe.id, recipe.ingredients),
    );
    await _datasource.insertSteps(
      _stepsToCompanions(recipe.id, recipe.steps),
    );
    if (recipe.tags.isNotEmpty) {
      await _datasource.setTagsForRecipe(recipe.id, recipe.tags);
    }
  }

  @override
  Future<void> updateRecipe(Recipe recipe) async {
    await _datasource.updateRecipe(_recipeToCompanion(recipe));
    await _datasource.deleteIngredients(recipe.id);
    await _datasource.insertIngredients(
      _ingredientsToCompanions(recipe.id, recipe.ingredients),
    );
    await _datasource.deleteSteps(recipe.id);
    await _datasource.insertSteps(
      _stepsToCompanions(recipe.id, recipe.steps),
    );
    await _datasource.setTagsForRecipe(recipe.id, recipe.tags);
  }

  @override
  Future<void> deleteRecipe(String id) async {
    await _datasource.deleteIngredients(id);
    await _datasource.deleteSteps(id);
    await _datasource.setTagsForRecipe(id, []);
    await _datasource.deleteRecipe(id);
  }

  @override
  Future<List<Recipe>> searchRecipes(String query) async {
    final rows = await _datasource.searchRecipes(query);
    final recipes = <Recipe>[];
    for (final row in rows) {
      recipes.add(await _mapRowToRecipe(row));
    }
    return recipes;
  }

  @override
  Future<List<Recipe>> getRecipesByCategory(RecipeCategory category) async {
    final all = await getAllRecipes();
    return all.where((r) => r.category == category).toList();
  }

  @override
  Future<List<Recipe>> getFavoriteRecipes() async {
    final all = await getAllRecipes();
    return all.where((r) => r.isFavorite).toList();
  }

  @override
  Future<void> toggleFavorite(String id, bool isFavorite) {
    return _datasource.toggleFavorite(id, isFavorite);
  }
}
