import 'package:drift/drift.dart';
import 'package:rezepte/core/database/tables/meal_plans_table.dart';
import 'package:rezepte/core/database/tables/recipes_table.dart';

class MealPlanEntries extends Table {
  TextColumn get id => text()();
  TextColumn get mealPlanId => text().references(MealPlans, #id)();
  IntColumn get dayOfWeek => integer()();
  TextColumn get recipeId => text().references(Recipes, #id)();
  BoolColumn get isLocked => boolean().withDefault(const Constant(false))();
  IntColumn get servings => integer().withDefault(const Constant(4))();

  @override
  Set<Column> get primaryKey => {id};
}
