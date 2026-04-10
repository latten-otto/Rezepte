import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rezepte/core/database/app_database.dart' show AppDatabase;
import 'package:rezepte/features/recipes/data/datasources/recipe_local_datasource.dart';
import 'package:rezepte/features/recipes/data/repositories/recipe_repository.dart';
import 'package:rezepte/features/recipes/domain/models/recipe.dart';

/// Override provider – set from main.dart so the pre-seeded DB is shared.
final databaseOverrideProvider = Provider<AppDatabase>((ref) {
  throw UnimplementedError('databaseOverrideProvider must be overridden');
});

/// Provides the AppDatabase singleton instance.
final databaseProvider = Provider<AppDatabase>((ref) {
  return ref.watch(databaseOverrideProvider);
});

/// Provides the local datasource backed by Drift.
final recipeLocalDatasourceProvider = Provider<RecipeLocalDatasource>((ref) {
  final db = ref.watch(databaseProvider);
  return RecipeLocalDatasource(db);
});

/// Provides the recipe repository.
final recipeRepositoryProvider = Provider<RecipeRepository>((ref) {
  final datasource = ref.watch(recipeLocalDatasourceProvider);
  return RecipeRepository(datasource);
});

/// Watches all recipes as a stream (auto-updates on DB changes).
final allRecipesProvider = StreamProvider<List<Recipe>>((ref) {
  final repository = ref.watch(recipeRepositoryProvider);
  return repository.watchAllRecipes();
});

/// Fetches a single recipe by ID.
final recipeByIdProvider =
    FutureProvider.family<Recipe?, String>((ref, id) async {
  final repository = ref.watch(recipeRepositoryProvider);
  return repository.getRecipeById(id);
});

/// Fetches only favorite recipes.
final favoriteRecipesProvider = FutureProvider<List<Recipe>>((ref) async {
  final repository = ref.watch(recipeRepositoryProvider);
  return repository.getFavoriteRecipes();
});

/// Searches recipes by a query string.
final recipeSearchProvider =
    FutureProvider.family<List<Recipe>, String>((ref, query) async {
  final repository = ref.watch(recipeRepositoryProvider);
  return repository.searchRecipes(query);
});
