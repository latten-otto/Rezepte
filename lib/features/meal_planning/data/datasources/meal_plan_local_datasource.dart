import 'package:drift/drift.dart';
import 'package:rezepte/core/database/app_database.dart' as db;

class MealPlanLocalDatasource {
  final db.AppDatabase _db;

  MealPlanLocalDatasource(this._db);

  Future<db.MealPlan?> getCurrentMealPlan() async {
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    final weekStart = DateTime(monday.year, monday.month, monday.day);

    return (_db.select(_db.mealPlans)
          ..where((t) => t.weekStartDate.equals(weekStart)))
        .getSingleOrNull();
  }

  Future<db.MealPlan?> getMealPlanForWeek(DateTime weekStart) {
    return (_db.select(_db.mealPlans)
          ..where((t) => t.weekStartDate.equals(weekStart)))
        .getSingleOrNull();
  }

  Stream<db.MealPlan?> watchCurrentMealPlan() {
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    final weekStart = DateTime(monday.year, monday.month, monday.day);

    return (_db.select(_db.mealPlans)
          ..where((t) => t.weekStartDate.equals(weekStart)))
        .watchSingleOrNull();
  }

  Future<void> insertMealPlan(db.MealPlansCompanion plan) {
    return _db.into(_db.mealPlans).insert(plan);
  }

  Future<void> deleteMealPlan(String id) async {
    await (_db.delete(_db.mealPlanEntries)
          ..where((t) => t.mealPlanId.equals(id)))
        .go();
    await (_db.delete(_db.mealPlans)..where((t) => t.id.equals(id))).go();
  }

  Future<List<db.MealPlanEntry>> getEntriesForPlan(String planId) {
    return (_db.select(_db.mealPlanEntries)
          ..where((t) => t.mealPlanId.equals(planId))
          ..orderBy([(t) => OrderingTerm.asc(t.dayOfWeek)]))
        .get();
  }

  Future<void> insertEntries(List<db.MealPlanEntriesCompanion> entries) async {
    await _db.batch((batch) {
      batch.insertAll(_db.mealPlanEntries, entries);
    });
  }

  Future<void> deleteEntriesForPlan(String planId) {
    return (_db.delete(_db.mealPlanEntries)
          ..where((t) => t.mealPlanId.equals(planId)))
        .go();
  }

  Future<void> updateEntry(db.MealPlanEntriesCompanion entry) {
    return (_db.update(_db.mealPlanEntries)
          ..where((t) => t.id.equals(entry.id.value)))
        .write(entry);
  }

  // Preferences stored as key-value
  Future<String?> getPreference(String key) async {
    final row = await (_db.select(_db.userPreferencesTable)
          ..where((t) => t.key.equals(key)))
        .getSingleOrNull();
    return row?.value;
  }

  Future<void> setPreference(String key, String value) async {
    await _db.into(_db.userPreferencesTable).insertOnConflictUpdate(
          db.UserPreferencesTableCompanion.insert(
            key: key,
            value: value,
          ),
        );
  }
}
