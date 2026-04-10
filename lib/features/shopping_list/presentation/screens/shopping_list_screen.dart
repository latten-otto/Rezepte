import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rezepte/features/meal_planning/presentation/providers/meal_plan_provider.dart';
import 'package:rezepte/features/recipes/domain/models/recipe.dart';
import 'package:rezepte/features/recipes/presentation/providers/recipes_provider.dart';
import 'package:rezepte/features/shopping_list/domain/models/shopping_item.dart';
import 'package:rezepte/features/shopping_list/domain/services/shopping_list_generator.dart';
import 'package:rezepte/features/shopping_list/presentation/providers/shopping_list_provider.dart';

class ShoppingListScreen extends ConsumerWidget {
  const ShoppingListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemsAsync = ref.watch(allShoppingItemsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Einkaufsliste'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            tooltip: 'Abgehakte entfernen',
            onPressed: () async {
              await ref.read(shoppingListRepositoryProvider).clearChecked(null);
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Aus Wochenplan generieren',
            onPressed: () => _generateFromMealPlan(context, ref),
          ),
        ],
      ),
      body: itemsAsync.when(
        data: (items) {
          if (items.isEmpty) {
            return _buildEmptyState(context, ref);
          }
          return _buildList(context, ref, items);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Fehler: $e')),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_cart_outlined,
              size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'Keine Einkaufsliste vorhanden.',
            style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 8),
          FilledButton.icon(
            onPressed: () => _generateFromMealPlan(context, ref),
            icon: const Icon(Icons.auto_awesome),
            label: const Text('Aus Wochenplan generieren'),
          ),
        ],
      ),
    );
  }

  Widget _buildList(
      BuildContext context, WidgetRef ref, List<ShoppingItem> items) {
    // Group by category
    final grouped = <String, List<ShoppingItem>>{};
    for (final item in items) {
      grouped.putIfAbsent(item.category, () => []).add(item);
    }

    // Sort: unchecked first within each group
    for (final list in grouped.values) {
      list.sort((a, b) {
        if (a.isChecked != b.isChecked) return a.isChecked ? 1 : -1;
        return a.name.compareTo(b.name);
      });
    }

    final categories = grouped.keys.toList()..sort();

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 80),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        final categoryItems = grouped[category]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
              child: Text(
                category,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            ...categoryItems.map((item) => _ShoppingItemTile(
                  item: item,
                  onToggle: () {
                    ref
                        .read(shoppingListRepositoryProvider)
                        .toggleChecked(item.id, !item.isChecked);
                  },
                )),
          ],
        );
      },
    );
  }

  Future<void> _generateFromMealPlan(
      BuildContext context, WidgetRef ref) async {
    final plan = await ref.read(currentMealPlanProvider.future);
    if (plan == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Erstelle zuerst einen Wochenplan.')),
        );
      }
      return;
    }

    final recipes = await ref.read(allRecipesProvider.future);
    final recipeMap = <String, Recipe>{for (final r in recipes) r.id: r};

    final generator = ShoppingListGenerator();
    final items = generator.generate(
      entries: plan.entries,
      recipeMap: recipeMap,
    );

    await ref
        .read(shoppingListRepositoryProvider)
        .saveShoppingItems(plan.id, items);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('${items.length} Artikel zur Einkaufsliste hinzugefügt.')),
      );
    }
  }
}

class _ShoppingItemTile extends StatelessWidget {
  final ShoppingItem item;
  final VoidCallback onToggle;

  const _ShoppingItemTile({required this.item, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Checkbox(
        value: item.isChecked,
        onChanged: (_) => onToggle(),
      ),
      title: Text(
        item.name,
        style: TextStyle(
          decoration: item.isChecked ? TextDecoration.lineThrough : null,
          color: item.isChecked ? Colors.grey : null,
        ),
      ),
      subtitle: _buildAmountText(),
      dense: true,
    );
  }

  Widget? _buildAmountText() {
    if (item.amount == null) return null;
    final formatted = item.amount == item.amount!.roundToDouble()
        ? item.amount!.toInt().toString()
        : item.amount!.toStringAsFixed(1);
    final text = item.unit != null ? '$formatted ${item.unit}' : formatted;
    return Text(text, style: TextStyle(color: Colors.grey.shade600));
  }
}
