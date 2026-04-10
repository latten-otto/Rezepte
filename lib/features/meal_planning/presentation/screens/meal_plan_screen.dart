import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rezepte/features/meal_planning/domain/models/meal_plan.dart';
import 'package:rezepte/features/meal_planning/domain/models/meal_plan_entry.dart';
import 'package:rezepte/features/meal_planning/presentation/providers/meal_plan_provider.dart';
import 'package:rezepte/features/meal_planning/presentation/widgets/meal_day_card.dart';
import 'package:rezepte/features/recipes/domain/models/recipe.dart';
import 'package:rezepte/features/recipes/presentation/providers/recipes_provider.dart';

const _dayNames = ['Mo', 'Di', 'Mi', 'Do', 'Fr', 'Sa', 'So'];

class MealPlanScreen extends ConsumerWidget {
  const MealPlanScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final planAsync = ref.watch(currentMealPlanProvider);
    final recipesAsync = ref.watch(allRecipesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Wochenplan'),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune),
            tooltip: 'Vorlieben',
            onPressed: () => context.push('/meal-plan/preferences'),
          ),
        ],
      ),
      body: planAsync.when(
        data: (plan) {
          if (plan == null) {
            return _buildEmptyState(context, ref, recipesAsync);
          }
          return _buildPlan(context, ref, plan, recipesAsync);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Fehler: $e')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _generatePlan(context, ref, recipesAsync),
        icon: const Icon(Icons.auto_awesome),
        label: const Text('Plan erstellen'),
      ),
    );
  }

  Widget _buildEmptyState(
      BuildContext context, WidgetRef ref, AsyncValue<List<Recipe>> recipesAsync) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.calendar_today, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'Noch kein Wochenplan erstellt.',
            style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 8),
          Text(
            'Erstelle einen Plan basierend auf deinen Rezepten!',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  Widget _buildPlan(BuildContext context, WidgetRef ref, MealPlan plan,
      AsyncValue<List<Recipe>> recipesAsync) {
    return recipesAsync.when(
      data: (recipes) {
        final recipeMap = {for (final r in recipes) r.id: r};

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: plan.entries.length,
          itemBuilder: (context, index) {
            final entry = plan.entries[index];
            final recipe = recipeMap[entry.recipeId];
            final dayName =
                entry.dayOfWeek >= 1 && entry.dayOfWeek <= 7
                    ? _dayNames[entry.dayOfWeek - 1]
                    : '?';

            return MealDayCard(
              dayName: dayName,
              recipe: recipe,
              entry: entry,
              onTap: recipe != null
                  ? () => context.push('/recipes/${recipe.id}')
                  : null,
              onSwap: () => _showSwapSheet(context, ref, plan, entry, recipes),
              onToggleLock: () => _toggleLock(ref, plan, entry),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Fehler: $e')),
    );
  }

  Future<void> _generatePlan(
      BuildContext context, WidgetRef ref, AsyncValue<List<Recipe>> recipesAsync) async {
    final recipes = recipesAsync.valueOrNull ?? [];
    if (recipes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Füge zuerst Rezepte hinzu, um einen Plan zu erstellen.'),
        ),
      );
      return;
    }

    final prefs = await ref.read(mealPreferencesProvider.future);
    final generator = ref.read(mealPlanGeneratorProvider);
    final repo = ref.read(mealPlanRepositoryProvider);

    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    final weekStart = DateTime(monday.year, monday.month, monday.day);

    // Keep locked entries from existing plan
    final existingPlan = await repo.getCurrentMealPlan();
    final lockedEntries =
        existingPlan?.entries.where((e) => e.isLocked).toList() ?? [];

    final plan = generator.generate(
      preferences: prefs,
      allRecipes: recipes,
      weekStartDate: weekStart,
      lockedEntries: lockedEntries,
    );

    await repo.saveMealPlan(plan);
  }

  void _showSwapSheet(BuildContext context, WidgetRef ref, MealPlan plan,
      MealPlanEntry entry, List<Recipe> recipes) {
    final usedIds = plan.entries.map((e) => e.recipeId).toSet();
    final available = recipes.where((r) => !usedIds.contains(r.id)).toList();

    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text('Rezept tauschen',
                style: Theme.of(context).textTheme.titleLarge),
          ),
          Expanded(
            child: available.isEmpty
                ? const Center(child: Text('Keine weiteren Rezepte verfügbar.'))
                : ListView.builder(
                    itemCount: available.length,
                    itemBuilder: (context, index) {
                      final recipe = available[index];
                      return ListTile(
                        title: Text(recipe.title),
                        subtitle: Text(_categoryLabel(recipe.category)),
                        onTap: () async {
                          Navigator.pop(context);
                          final updatedEntries = plan.entries.map((e) {
                            if (e.id == entry.id) {
                              return e.copyWith(recipeId: recipe.id);
                            }
                            return e;
                          }).toList();
                          final updatedPlan =
                              plan.copyWith(entries: updatedEntries);
                          await ref
                              .read(mealPlanRepositoryProvider)
                              .saveMealPlan(updatedPlan);
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleLock(
      WidgetRef ref, MealPlan plan, MealPlanEntry entry) async {
    final updatedEntries = plan.entries.map((e) {
      if (e.id == entry.id) {
        return e.copyWith(isLocked: !e.isLocked);
      }
      return e;
    }).toList();
    final updatedPlan = plan.copyWith(entries: updatedEntries);
    await ref.read(mealPlanRepositoryProvider).saveMealPlan(updatedPlan);
  }

  String _categoryLabel(RecipeCategory category) {
    switch (category) {
      case RecipeCategory.meat:
        return 'Fleisch';
      case RecipeCategory.fish:
        return 'Fisch';
      case RecipeCategory.vegetarian:
        return 'Vegetarisch';
      case RecipeCategory.vegan:
        return 'Vegan';
    }
  }
}
