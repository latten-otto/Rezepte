import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rezepte/features/meal_planning/domain/models/meal_plan.dart';
import 'package:rezepte/features/meal_planning/domain/models/meal_plan_entry.dart';
import 'package:rezepte/features/meal_planning/presentation/providers/meal_plan_provider.dart';
import 'package:rezepte/features/recipes/domain/models/recipe.dart';
import 'package:rezepte/features/recipes/presentation/providers/recipes_provider.dart';

const _dayNamesFull = [
  'Montag',
  'Dienstag',
  'Mittwoch',
  'Donnerstag',
  'Freitag',
  'Samstag',
  'Sonntag',
];

class MealPlanScreen extends ConsumerStatefulWidget {
  const MealPlanScreen({super.key});

  @override
  ConsumerState<MealPlanScreen> createState() => _MealPlanScreenState();
}

class _MealPlanScreenState extends ConsumerState<MealPlanScreen> {
  // Tracks which entries are currently animating a swap
  final Map<String, GlobalKey<_SwapCardState>> _cardKeys = {};

  @override
  Widget build(BuildContext context) {
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
      body: recipesAsync.when(
        data: (recipes) {
          final recipeMap = {for (final r in recipes) r.id: r};
          final plan = planAsync.valueOrNull;
          return _buildWeekList(context, plan, recipeMap, recipes);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Fehler: $e')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openPlanningSheet(context),
        icon: const Icon(Icons.auto_awesome),
        label: const Text('Rezepte planen'),
      ),
    );
  }

  Widget _buildWeekList(BuildContext context, MealPlan? plan,
      Map<String, Recipe> recipeMap, List<Recipe> allRecipes) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 88),
      itemCount: 7,
      itemBuilder: (context, index) {
        final date = today.add(Duration(days: index));
        final isToday = index == 0;

        // Find entry by absolute date: position in plan = days since plan.weekStartDate + 1
        MealPlanEntry? entry;
        if (plan != null) {
          final diff = date.difference(plan.weekStartDate).inDays;
          if (diff >= 0 && diff < 7) {
            final positionInPlan = diff + 1;
            entry = plan.entries
                .where((e) => e.dayOfWeek == positionInPlan)
                .firstOrNull;
          }
        }
        final recipe = entry != null ? recipeMap[entry.recipeId] : null;

        return _buildDayRow(
          context,
          dayName: _dayNamesFull[date.weekday - 1],
          date: date,
          isToday: isToday,
          entry: entry,
          recipe: recipe,
          plan: plan,
          allRecipes: allRecipes,
        );
      },
    );
  }

  Widget _buildDayRow(
    BuildContext context, {
    required String dayName,
    required DateTime date,
    required bool isToday,
    required MealPlanEntry? entry,
    required Recipe? recipe,
    required MealPlan? plan,
    required List<Recipe> allRecipes,
  }) {
    final theme = Theme.of(context);
    final dateStr =
        '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.';

    if (entry == null || recipe == null) {
      // Empty day
      return Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Card(
          elevation: isToday ? 2 : 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: isToday
                ? BorderSide(color: theme.colorScheme.primary, width: 2)
                : BorderSide(color: theme.colorScheme.outlineVariant),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Row(
              children: [
                _buildDayLabel(theme, dayName, dateStr, isToday),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    'Kein Gericht geplant',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Day with recipe - use swap card
    final cardKey = _cardKeys.putIfAbsent(
      entry.id,
      () => GlobalKey<_SwapCardState>(),
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: _SwapCard(
        key: cardKey,
        theme: theme,
        dayName: dayName,
        dateStr: dateStr,
        isToday: isToday,
        entry: entry,
        recipe: recipe,
        onTap: () => context.push('/recipes/${recipe.id}'),
        onSwap: () =>
            _swapRecipe(context, cardKey, plan!, entry, allRecipes),
        onToggleLock: () => _toggleLock(plan!, entry),
      ),
    );
  }

  Widget _buildDayLabel(
      ThemeData theme, String dayName, String dateStr, bool isToday) {
    return SizedBox(
      width: 72,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            dayName,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: isToday
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurface,
            ),
          ),
          Text(
            dateStr,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _swapRecipe(
    BuildContext context,
    GlobalKey<_SwapCardState> cardKey,
    MealPlan plan,
    MealPlanEntry entry,
    List<Recipe> allRecipes,
  ) async {
    final usedIds = plan.entries.map((e) => e.recipeId).toSet();
    final available =
        allRecipes.where((r) => !usedIds.contains(r.id)).toList();

    if (available.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Keine weiteren Rezepte zum Tauschen verfügbar.')),
        );
      }
      return;
    }

    // Pick a random new recipe
    final newRecipe = available[Random().nextInt(available.length)];

    // Trigger flip animation
    await cardKey.currentState?.flipTo(newRecipe);

    // Save to DB
    final updatedEntries = plan.entries.map((e) {
      if (e.id == entry.id) {
        return e.copyWith(recipeId: newRecipe.id);
      }
      return e;
    }).toList();
    final updatedPlan = plan.copyWith(entries: updatedEntries);
    await ref.read(mealPlanRepositoryProvider).saveMealPlan(updatedPlan);
  }

  Future<void> _toggleLock(MealPlan plan, MealPlanEntry entry) async {
    final updatedEntries = plan.entries.map((e) {
      if (e.id == entry.id) {
        return e.copyWith(isLocked: !e.isLocked);
      }
      return e;
    }).toList();
    final updatedPlan = plan.copyWith(entries: updatedEntries);
    await ref.read(mealPlanRepositoryProvider).saveMealPlan(updatedPlan);
  }

  void _openPlanningSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => _PlanningSheet(
        onConfirm: (selectedDays) => _generateForDays(context, selectedDays),
      ),
    );
  }

  Future<void> _generateForDays(
    BuildContext context,
    Map<int, _DayConfig> selectedDays,
  ) async {
    final recipes = ref.read(allRecipesProvider).valueOrNull ?? [];
    if (recipes.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content:
                  Text('Füge zuerst Rezepte hinzu, um einen Plan zu erstellen.')),
        );
      }
      return;
    }

    final prefs = await ref.read(mealPreferencesProvider.future);
    final generator = ref.read(mealPlanGeneratorProvider);
    final repo = ref.read(mealPlanRepositoryProvider);

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Map locked entries from existing plan to positions in the new plan (today-based)
    final existingPlan = await repo.getCurrentMealPlan();
    final lockedEntries = <MealPlanEntry>[];
    if (existingPlan != null) {
      for (final e in existingPlan.entries) {
        if (!e.isLocked) continue;
        // Absolute date of this entry
        final entryDate = existingPlan.weekStartDate
            .add(Duration(days: e.dayOfWeek - 1));
        // Position in new plan (1..7)
        final newPos = entryDate.difference(today).inDays + 1;
        if (newPos >= 1 && newPos <= 7 &&
            !selectedDays.containsKey(newPos)) {
          lockedEntries.add(e.copyWith(dayOfWeek: newPos));
        }
      }
    }

    // Adjust preferences for the selected number of days
    final adjustedPrefs = prefs.copyWith(
      mealsPerWeek: selectedDays.length + lockedEntries.length,
    );

    var plan = generator.generate(
      preferences: adjustedPrefs,
      allRecipes: recipes,
      weekStartDate: today,
      lockedEntries: lockedEntries,
    );

    // Apply custom servings from day configs
    final updatedEntries = plan.entries.map((e) {
      final config = selectedDays[e.dayOfWeek];
      if (config != null && config.servings != prefs.defaultServings) {
        return e.copyWith(servings: config.servings);
      }
      return e;
    }).toList();

    plan = plan.copyWith(entries: updatedEntries);
    await repo.saveMealPlan(plan);
  }

  String categoryLabel(RecipeCategory category) {
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

// ──────────────────────────────────────────
// SwapCard with flip animation
// ──────────────────────────────────────────

class _SwapCard extends StatefulWidget {
  final ThemeData theme;
  final String dayName;
  final String dateStr;
  final bool isToday;
  final MealPlanEntry entry;
  final Recipe recipe;
  final VoidCallback onTap;
  final VoidCallback onSwap;
  final VoidCallback onToggleLock;

  const _SwapCard({
    super.key,
    required this.theme,
    required this.dayName,
    required this.dateStr,
    required this.isToday,
    required this.entry,
    required this.recipe,
    required this.onTap,
    required this.onSwap,
    required this.onToggleLock,
  });

  @override
  State<_SwapCard> createState() => _SwapCardState();
}

class _SwapCardState extends State<_SwapCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _flipAnimation;
  Recipe? _newRecipe;
  bool _showingNew = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _flipAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutBack),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> flipTo(Recipe newRecipe) async {
    setState(() {
      _newRecipe = newRecipe;
      _showingNew = false;
    });

    _controller.reset();

    // Listen for midpoint to flip content
    void listener() {
      if (_flipAnimation.value >= 0.5 && !_showingNew) {
        setState(() => _showingNew = true);
      }
    }

    _controller.addListener(listener);
    await _controller.forward();
    _controller.removeListener(listener);
  }

  @override
  Widget build(BuildContext context) {
    final recipe =
        (_showingNew && _newRecipe != null) ? _newRecipe! : widget.recipe;
    final entry = widget.entry;
    final theme = widget.theme;

    return AnimatedBuilder(
      animation: _flipAnimation,
      builder: (context, child) {
        final angle = _flipAnimation.value * pi;
        final isBack = _flipAnimation.value >= 0.5;

        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateX(isBack ? angle - pi : angle),
          child: child,
        );
      },
      child: Card(
        elevation: widget.isToday ? 2 : 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: widget.isToday
              ? BorderSide(color: theme.colorScheme.primary, width: 2)
              : BorderSide(color: theme.colorScheme.outlineVariant),
        ),
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                _buildDayLabel(theme),
                const SizedBox(width: 12),
                // Recipe image
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    width: 64,
                    height: 64,
                    child: recipe.imageUrl != null
                        ? CachedNetworkImage(
                            imageUrl: recipe.imageUrl!,
                            fit: BoxFit.cover,
                            errorWidget: (_, __, ___) => _buildPlaceholder(theme),
                          )
                        : _buildPlaceholder(theme),
                  ),
                ),
                const SizedBox(width: 12),
                // Recipe info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        recipe.title,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.people_outline,
                              size: 14,
                              color: theme.colorScheme.onSurfaceVariant),
                          const SizedBox(width: 4),
                          Text(
                            '${entry.servings} Portionen',
                            style: theme.textTheme.bodySmall,
                          ),
                          if (recipe.cookTimeMinutes != null) ...[
                            const SizedBox(width: 12),
                            Icon(Icons.timer_outlined,
                                size: 14,
                                color: theme.colorScheme.onSurfaceVariant),
                            const SizedBox(width: 4),
                            Text(
                              '${recipe.cookTimeMinutes} Min.',
                              style: theme.textTheme.bodySmall,
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                // Actions
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(
                        entry.isLocked ? Icons.lock : Icons.lock_open_outlined,
                        size: 20,
                        color: entry.isLocked
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurfaceVariant,
                      ),
                      onPressed: widget.onToggleLock,
                      tooltip: entry.isLocked ? 'Entsperren' : 'Sperren',
                      visualDensity: VisualDensity.compact,
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.refresh_rounded,
                        size: 20,
                        color: entry.isLocked
                            ? theme.colorScheme.onSurfaceVariant
                                .withValues(alpha: 0.3)
                            : theme.colorScheme.onSurfaceVariant,
                      ),
                      onPressed: entry.isLocked ? null : widget.onSwap,
                      tooltip: 'Anderes Rezept',
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDayLabel(ThemeData theme) {
    return SizedBox(
      width: 72,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.dayName,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: widget.isToday
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurface,
            ),
          ),
          Text(
            widget.dateStr,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder(ThemeData theme) {
    return Container(
      color: theme.colorScheme.surfaceContainerHighest,
      child: Icon(Icons.restaurant,
          color: theme.colorScheme.onSurfaceVariant),
    );
  }
}

// ──────────────────────────────────────────
// Planning Sheet – select days + configure
// ──────────────────────────────────────────

class _DayConfig {
  int servings = 4;
  String? note;
}

class _PlanningSheet extends StatefulWidget {
  final void Function(Map<int, _DayConfig> selectedDays) onConfirm;

  const _PlanningSheet({required this.onConfirm});

  @override
  State<_PlanningSheet> createState() => _PlanningSheetState();
}

class _PlanningSheetState extends State<_PlanningSheet> {
  // Map key = position in plan (1..7), where 1 = today
  final Map<int, _DayConfig> _selectedDays = {};

  @override
  void initState() {
    super.initState();
    // Pre-select the next 5 days (excluding weekend days)
    final now = DateTime.now();
    for (var i = 0; i < 7; i++) {
      final date = now.add(Duration(days: i));
      // weekday: 1..5 = Mon..Fri
      if (date.weekday >= 1 && date.weekday <= 5) {
        _selectedDays[i + 1] = _DayConfig();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Icon(Icons.calendar_month, color: theme.colorScheme.primary),
                const SizedBox(width: 12),
                Text(
                  'Tage auswählen',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Wähle die Tage, für die du Gerichte planst',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: 7,
              itemBuilder: (context, index) {
                final position = index + 1; // 1..7, 1 = today
                final date = today.add(Duration(days: index));
                final isSelected = _selectedDays.containsKey(position);
                final config = _selectedDays[position];
                final dateStr =
                    '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.';
                final dayName = _dayNamesFull[date.weekday - 1];

                return Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                      side: BorderSide(
                        color: isSelected
                            ? theme.colorScheme.primary
                            : theme.colorScheme.outlineVariant,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    color: isSelected
                        ? theme.colorScheme.primaryContainer
                            .withValues(alpha: 0.3)
                        : null,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () {
                        setState(() {
                          if (isSelected) {
                            _selectedDays.remove(position);
                          } else {
                            _selectedDays[position] = _DayConfig();
                          }
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        child: Row(
                          children: [
                            // Checkbox
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isSelected
                                    ? theme.colorScheme.primary
                                    : Colors.transparent,
                                border: Border.all(
                                  color: isSelected
                                      ? theme.colorScheme.primary
                                      : theme.colorScheme.outline,
                                  width: 2,
                                ),
                              ),
                              child: isSelected
                                  ? const Icon(Icons.check,
                                      size: 16, color: Colors.white)
                                  : null,
                            ),
                            const SizedBox(width: 16),
                            // Day name
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        dayName,
                                        style: theme.textTheme.titleSmall
                                            ?.copyWith(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      if (position == 1) ...[
                                        const SizedBox(width: 6),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: theme.colorScheme.primary,
                                            borderRadius:
                                                BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            'Heute',
                                            style: theme.textTheme.labelSmall
                                                ?.copyWith(
                                              color:
                                                  theme.colorScheme.onPrimary,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                  Text(
                                    dateStr,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color:
                                          theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Servings + config
                            if (isSelected && config != null) ...[
                              Text(
                                '${config.servings} P.',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(width: 4),
                              IconButton(
                                icon: Icon(
                                  Icons.settings_outlined,
                                  size: 20,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                                visualDensity: VisualDensity.compact,
                                onPressed: () =>
                                    _showDayConfig(context, dayName, config),
                                tooltip: 'Einstellungen',
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          // Confirm button
          Padding(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _selectedDays.isEmpty
                    ? null
                    : () {
                        Navigator.pop(context);
                        widget.onConfirm(Map.from(_selectedDays));
                      },
                icon: const Icon(Icons.auto_awesome),
                label: Text(
                  _selectedDays.isEmpty
                      ? 'Tage auswählen'
                      : 'Für ${_selectedDays.length} Tage planen',
                ),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDayConfig(
      BuildContext context, String dayName, _DayConfig config) {
    final theme = Theme.of(context);
    var servings = config.servings;
    final noteController = TextEditingController(text: config.note ?? '');

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('$dayName konfigurieren'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Servings
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Portionen', style: theme.textTheme.bodyLarge),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline),
                        onPressed: servings > 1
                            ? () => setDialogState(() => servings--)
                            : null,
                      ),
                      Text(
                        '$servings',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline),
                        onPressed: servings < 12
                            ? () => setDialogState(() => servings++)
                            : null,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Note / special wishes
              TextField(
                controller: noteController,
                decoration: const InputDecoration(
                  labelText: 'Besondere Wünsche',
                  hintText: 'z.B. "etwas Leichtes", "Pasta"',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Abbrechen'),
            ),
            FilledButton(
              onPressed: () {
                setState(() {
                  config.servings = servings;
                  config.note = noteController.text.isEmpty
                      ? null
                      : noteController.text;
                });
                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
          ],
        ),
      ),
    );
  }
}
