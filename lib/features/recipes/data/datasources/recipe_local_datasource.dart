import 'package:drift/drift.dart';
import 'package:rezepte/core/database/app_database.dart' as db;

class RecipeLocalDatasource {
  final db.AppDatabase _db;

  RecipeLocalDatasource(this._db);

  // --- Recipes ---

  Stream<List<db.Recipe>> watchAllRecipes() {
    return (_db.select(_db.recipes)
          ..orderBy([
            (t) => OrderingTerm(
                  expression: t.updatedAt,
                  mode: OrderingMode.desc,
                ),
          ]))
        .watch();
  }

  Future<List<db.Recipe>> getAllRecipes() {
    return (_db.select(_db.recipes)
          ..orderBy([
            (t) => OrderingTerm(
                  expression: t.updatedAt,
                  mode: OrderingMode.desc,
                ),
          ]))
        .get();
  }

  Future<db.Recipe?> getRecipeById(String id) {
    return (_db.select(_db.recipes)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
  }

  Future<void> insertRecipe(db.RecipesCompanion recipe) {
    return _db.into(_db.recipes).insert(recipe);
  }

  Future<void> updateRecipe(db.RecipesCompanion recipe) {
    return (_db.update(_db.recipes)
          ..where((t) => t.id.equals(recipe.id.value)))
        .write(recipe);
  }

  Future<void> deleteRecipe(String id) {
    return (_db.delete(_db.recipes)..where((t) => t.id.equals(id))).go();
  }

  Future<void> toggleFavorite(String id, bool isFavorite) {
    return (_db.update(_db.recipes)..where((t) => t.id.equals(id))).write(
      db.RecipesCompanion(
        isFavorite: Value(isFavorite),
      ),
    );
  }

  Future<List<db.Recipe>> searchRecipes(String query) {
    final pattern = '%$query%';
    return (_db.select(_db.recipes)
          ..where(
            (t) => t.title.like(pattern) | t.description.like(pattern),
          ))
        .get();
  }

  // --- Ingredients ---

  Future<List<db.Ingredient>> getIngredients(String recipeId) {
    return (_db.select(_db.ingredients)
          ..where((t) => t.recipeId.equals(recipeId))
          ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
        .get();
  }

  Future<void> insertIngredients(List<db.IngredientsCompanion> ingredients) async {
    await _db.batch((batch) {
      batch.insertAll(_db.ingredients, ingredients);
    });
  }

  Future<void> deleteIngredients(String recipeId) {
    return (_db.delete(_db.ingredients)
          ..where((t) => t.recipeId.equals(recipeId)))
        .go();
  }

  // --- Recipe Steps ---

  Future<List<db.RecipeStep>> getSteps(String recipeId) {
    return (_db.select(_db.recipeSteps)
          ..where((t) => t.recipeId.equals(recipeId))
          ..orderBy([(t) => OrderingTerm.asc(t.stepNumber)]))
        .get();
  }

  Future<void> insertSteps(List<db.RecipeStepsCompanion> steps) async {
    await _db.batch((batch) {
      batch.insertAll(_db.recipeSteps, steps);
    });
  }

  Future<void> deleteSteps(String recipeId) {
    return (_db.delete(_db.recipeSteps)
          ..where((t) => t.recipeId.equals(recipeId)))
        .go();
  }

  // --- Tags ---

  Future<List<String>> getTagsForRecipe(String recipeId) async {
    final query = _db.select(_db.recipeTags).join([
      innerJoin(_db.tags, _db.tags.id.equalsExp(_db.recipeTags.tagId)),
    ])
      ..where(_db.recipeTags.recipeId.equals(recipeId));

    final rows = await query.get();
    return rows.map((row) => row.readTable(_db.tags).name).toList();
  }

  Future<void> setTagsForRecipe(String recipeId, List<String> tags) async {
    await _db.transaction(() async {
      await (_db.delete(_db.recipeTags)
            ..where((t) => t.recipeId.equals(recipeId)))
          .go();

      for (final tagName in tags) {
        var existingTag = await (_db.select(_db.tags)
              ..where((t) => t.name.equals(tagName)))
            .getSingleOrNull();

        String tagId;
        if (existingTag == null) {
          tagId = tagName.toLowerCase().replaceAll(' ', '-');
          await _db.into(_db.tags).insert(
                db.TagsCompanion.insert(
                  id: tagId,
                  name: tagName,
                ),
              );
        } else {
          tagId = existingTag.id;
        }

        await _db.into(_db.recipeTags).insert(
              db.RecipeTagsCompanion.insert(
                recipeId: recipeId,
                tagId: tagId,
              ),
            );
      }
    });
  }
}
