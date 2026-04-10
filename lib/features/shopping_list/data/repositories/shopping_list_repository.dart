import 'package:drift/drift.dart';
import 'package:rezepte/core/database/app_database.dart' as db;
import 'package:rezepte/features/shopping_list/domain/models/shopping_item.dart'
    as domain;

class ShoppingListRepository {
  final db.AppDatabase _db;

  ShoppingListRepository(this._db);

  Stream<List<domain.ShoppingItem>> watchShoppingItems(String? mealPlanId) {
    final query = _db.select(_db.shoppingItems);
    if (mealPlanId != null) {
      query.where((t) => t.mealPlanId.equals(mealPlanId));
    }
    return query.watch().map((rows) => rows.map(_mapRow).toList());
  }

  Future<List<domain.ShoppingItem>> getShoppingItems(
      String? mealPlanId) async {
    final query = _db.select(_db.shoppingItems);
    if (mealPlanId != null) {
      query.where((t) => t.mealPlanId.equals(mealPlanId));
    }
    final rows = await query.get();
    return rows.map(_mapRow).toList();
  }

  Future<void> saveShoppingItems(
      String? mealPlanId, List<domain.ShoppingItem> items) async {
    await _db.transaction(() async {
      if (mealPlanId != null) {
        await (_db.delete(_db.shoppingItems)
              ..where((t) => t.mealPlanId.equals(mealPlanId)))
            .go();
      }
      for (final item in items) {
        await _db.into(_db.shoppingItems).insert(
              db.ShoppingItemsCompanion.insert(
                id: item.id,
                mealPlanId: Value(mealPlanId),
                name: item.name,
                amount: Value(item.amount),
                unit: Value(item.unit),
                category: Value(item.category),
                isChecked: Value(item.isChecked),
                recipeIds: Value(item.fromRecipeIds.join(',')),
              ),
            );
      }
    });
  }

  Future<void> toggleChecked(String id, bool isChecked) {
    return (_db.update(_db.shoppingItems)..where((t) => t.id.equals(id)))
        .write(db.ShoppingItemsCompanion(isChecked: Value(isChecked)));
  }

  Future<void> clearChecked(String? mealPlanId) async {
    final query = _db.delete(_db.shoppingItems)
      ..where((t) => t.isChecked.equals(true));
    if (mealPlanId != null) {
      query.where((t) => t.mealPlanId.equals(mealPlanId));
    }
    await query.go();
  }

  domain.ShoppingItem _mapRow(db.ShoppingItem row) {
    return domain.ShoppingItem(
      id: row.id,
      name: row.name,
      amount: row.amount,
      unit: row.unit,
      category: row.category,
      isChecked: row.isChecked,
      fromRecipeIds:
          row.recipeIds.isNotEmpty ? row.recipeIds.split(',') : [],
    );
  }
}
