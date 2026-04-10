import 'package:drift/drift.dart';
import 'package:rezepte/core/database/tables/recipes_table.dart';

class Tags extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();

  @override
  Set<Column> get primaryKey => {id};
}

class RecipeTags extends Table {
  TextColumn get recipeId => text().references(Recipes, #id)();
  TextColumn get tagId => text().references(Tags, #id)();

  @override
  Set<Column> get primaryKey => {recipeId, tagId};
}
