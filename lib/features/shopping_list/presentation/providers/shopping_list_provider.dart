import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rezepte/features/shopping_list/data/repositories/shopping_list_repository.dart';
import 'package:rezepte/features/shopping_list/domain/models/shopping_item.dart';
import 'package:rezepte/features/recipes/presentation/providers/recipes_provider.dart';

final shoppingListRepositoryProvider = Provider<ShoppingListRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return ShoppingListRepository(db);
});

final shoppingItemsProvider =
    StreamProvider.family<List<ShoppingItem>, String?>((ref, mealPlanId) {
  final repo = ref.watch(shoppingListRepositoryProvider);
  return repo.watchShoppingItems(mealPlanId);
});

final allShoppingItemsProvider = StreamProvider<List<ShoppingItem>>((ref) {
  final repo = ref.watch(shoppingListRepositoryProvider);
  return repo.watchShoppingItems(null);
});
