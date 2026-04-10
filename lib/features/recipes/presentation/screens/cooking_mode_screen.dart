import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:rezepte/features/recipes/domain/models/recipe.dart';
import 'package:rezepte/features/recipes/presentation/providers/recipes_provider.dart';
import 'package:rezepte/features/recipes/presentation/widgets/ingredient_list.dart';
import 'package:rezepte/features/recipes/presentation/widgets/step_view.dart';

class CookingModeScreen extends ConsumerStatefulWidget {
  final String recipeId;

  const CookingModeScreen({super.key, required this.recipeId});

  @override
  ConsumerState<CookingModeScreen> createState() => _CookingModeScreenState();
}

class _CookingModeScreenState extends ConsumerState<CookingModeScreen> {
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    WakelockPlus.enable();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  void dispose() {
    _pageController.dispose();
    WakelockPlus.disable();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  void _showIngredients(Recipe recipe) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Zutaten',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            Flexible(
              child: SingleChildScrollView(
                child: IngredientListWidget(
                  ingredients: recipe.ingredients,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final recipeAsync = ref.watch(recipeByIdProvider(widget.recipeId));
    final theme = Theme.of(context);

    return recipeAsync.when(
      data: (recipe) {
        if (recipe == null) {
          return const Scaffold(
            body: Center(child: Text('Rezept nicht gefunden')),
          );
        }

        final totalSteps = recipe.steps.length;
        final isLastStep = _currentPage == totalSteps - 1;

        return Scaffold(
          backgroundColor: theme.colorScheme.surface,
          body: SafeArea(
            child: Column(
              children: [
                // Top bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      Expanded(
                        child: LinearProgressIndicator(
                          value: totalSteps > 0
                              ? (_currentPage + 1) / totalSteps
                              : 0,
                          backgroundColor: theme.colorScheme.surfaceContainerHighest,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.list_alt),
                        onPressed: () => _showIngredients(recipe),
                        tooltip: 'Zutaten',
                      ),
                    ],
                  ),
                ),

                // Steps PageView
                Expanded(
                  child: totalSteps == 0
                      ? const Center(
                          child: Text('Keine Zubereitungsschritte vorhanden.'))
                      : PageView.builder(
                          controller: _pageController,
                          itemCount: totalSteps,
                          onPageChanged: (page) {
                            setState(() => _currentPage = page);
                          },
                          itemBuilder: (context, index) {
                            if (isLastStep && index == totalSteps - 1) {
                              return _buildLastStep(recipe, totalSteps, theme);
                            }
                            return StepView(
                              step: recipe.steps[index],
                              totalSteps: totalSteps,
                              ingredients: recipe.ingredients,
                            );
                          },
                        ),
                ),

                // Navigation buttons
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      FilledButton.tonalIcon(
                        onPressed: _currentPage > 0
                            ? () => _pageController.previousPage(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                )
                            : null,
                        icon: const Icon(Icons.arrow_back),
                        label: const Text('Zurück'),
                      ),
                      if (!isLastStep)
                        FilledButton.icon(
                          onPressed: () => _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          ),
                          icon: const Icon(Icons.arrow_forward),
                          label: const Text('Weiter'),
                        )
                      else
                        FilledButton.icon(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.check_circle),
                          label: const Text('Fertig!'),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        body: Center(child: Text('Fehler: $e')),
      ),
    );
  }

  Widget _buildLastStep(
      Recipe recipe, int totalSteps, ThemeData theme) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        StepView(
          step: recipe.steps.last,
          totalSteps: totalSteps,
          ingredients: recipe.ingredients,
        ),
        const SizedBox(height: 16),
        Icon(
          Icons.check_circle_outline,
          size: 48,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(height: 8),
        Text(
          'Letzter Schritt!',
          style: theme.textTheme.titleMedium?.copyWith(
            color: theme.colorScheme.primary,
          ),
        ),
      ],
    );
  }
}
