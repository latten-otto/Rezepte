import 'package:flutter/material.dart';
import 'package:rezepte/features/recipes/domain/models/ingredient.dart';
import 'package:rezepte/features/recipes/domain/models/recipe_step.dart';

class StepView extends StatelessWidget {
  final RecipeStep step;
  final int totalSteps;
  final List<Ingredient> ingredients;

  const StepView({
    super.key,
    required this.step,
    required this.totalSteps,
    this.ingredients = const [],
  });

  /// Findet Zutaten, deren Name im Schritt-Text vorkommt.
  List<Ingredient> _matchingIngredients() {
    if (ingredients.isEmpty) return [];
    final instructionLower = step.instruction.toLowerCase();
    return ingredients.where((ing) {
      final name = ing.name.toLowerCase();
      // Hauptwort der Zutat matchen (z.B. "Hackfleisch" aus "Hackfleisch (gemischt)")
      final mainName = name.split('(').first.trim();
      // Auch einzelne Wörter prüfen (z.B. "Knoblauch" in "Knoblauchzehe")
      return instructionLower.contains(mainName) ||
          mainName.split(' ').any((word) =>
              word.length >= 4 && instructionLower.contains(word));
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final matched = _matchingIngredients();

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Schritt ${step.stepNumber} von $totalSteps',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 32),
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      step.instruction,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (matched.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      Divider(color: theme.colorScheme.outlineVariant),
                      const SizedBox(height: 12),
                      Text(
                        'Zutaten für diesen Schritt',
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...matched.map((ing) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 3),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (ing.amount != null || ing.unit != null)
                                  Text(
                                    _formatAmount(ing.amount, ing.unit),
                                    style: theme.textTheme.bodyLarge?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                if (ing.amount != null || ing.unit != null)
                                  const SizedBox(width: 8),
                                Text(
                                  ing.name,
                                  style: theme.textTheme.bodyLarge,
                                ),
                              ],
                            ),
                          )),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatAmount(double? amount, String? unit) {
    if (amount == null) return '';
    final formatted = amount == amount.roundToDouble()
        ? amount.toInt().toString()
        : amount.toStringAsFixed(1);
    if (unit != null && unit.isNotEmpty) {
      return '$formatted $unit';
    }
    return formatted;
  }
}
