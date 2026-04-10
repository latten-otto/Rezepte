import 'package:drift/drift.dart';
import 'package:rezepte/core/database/tables/recipes_table.dart';

class RecipeSteps extends Table {
  TextColumn get id => text()();
  TextColumn get recipeId =>
      text().references(Recipes, #id)();
  IntColumn get stepNumber => integer()();
  TextColumn get instruction => text()();
  TextColumn get imageUrl => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
