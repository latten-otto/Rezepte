import 'package:drift/drift.dart';
import 'package:rezepte/core/database/tables/meal_plans_table.dart';

class ShoppingItems extends Table {
  TextColumn get id => text()();
  TextColumn get mealPlanId => text().nullable().references(MealPlans, #id)();
  TextColumn get name => text()();
  RealColumn get amount => real().nullable()();
  TextColumn get unit => text().nullable()();
  TextColumn get category => text().withDefault(const Constant('Sonstiges'))();
  BoolColumn get isChecked => boolean().withDefault(const Constant(false))();
  TextColumn get recipeIds => text().withDefault(const Constant(''))();

  @override
  Set<Column> get primaryKey => {id};
}
