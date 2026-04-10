import 'models/recipe.dart';

abstract class RecipeRepositoryInterface {
  Future<List<Recipe>> getAllRecipes();
  Future<Recipe?> getRecipeById(String id);
  Future<void> insertRecipe(Recipe recipe);
  Future<void> updateRecipe(Recipe recipe);
  Future<void> deleteRecipe(String id);
  Future<List<Recipe>> searchRecipes(String query);
  Future<List<Recipe>> getRecipesByCategory(RecipeCategory category);
  Future<List<Recipe>> getFavoriteRecipes();
  Future<void> toggleFavorite(String id, bool isFavorite);
  Stream<List<Recipe>> watchAllRecipes();
}
