import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:rezepte/core/database/tables/recipes_table.dart';
import 'package:rezepte/core/database/tables/ingredients_table.dart';
import 'package:rezepte/core/database/tables/recipe_steps_table.dart';
import 'package:rezepte/core/database/tables/tags_table.dart';
import 'package:rezepte/core/database/tables/meal_plans_table.dart';
import 'package:rezepte/core/database/tables/meal_plan_entries_table.dart';
import 'package:rezepte/core/database/tables/shopping_items_table.dart';
import 'package:rezepte/core/database/tables/user_preferences_table.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [
  Recipes,
  Ingredients,
  RecipeSteps,
  Tags,
  RecipeTags,
  MealPlans,
  MealPlanEntries,
  ShoppingItems,
  UserPreferencesTable,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  static QueryExecutor _openConnection() {
    return driftDatabase(name: 'rezepte_db');
  }
}

