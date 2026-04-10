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
  // Oberbegriffe → welche Zutaten gehören dazu
  static const _groupWords = {
    'gemüse': [
      'paprika', 'zucchini', 'tomate', 'karotte', 'möhre', 'brokkoli',
      'blumenkohl', 'aubergine', 'lauch', 'sellerie', 'spinat', 'mangold',
      'kürbis', 'champignon', 'pilz', 'bohne', 'erbse', 'mais', 'fenchel',
      'kohlrabi', 'radieschen', 'gurke', 'zwiebel', 'knoblauch', 'kartoffel',
      'süßkartoffel', 'spargel', 'rote bete',
    ],
    'fleisch': [
      'hackfleisch', 'hähnchen', 'huhn', 'rind', 'schwein', 'lamm', 'pute',
      'steak', 'schnitzel', 'filet', 'gulasch', 'wurst', 'speck', 'schinken',
    ],
    'fisch': [
      'lachs', 'thunfisch', 'kabeljau', 'forelle', 'garnele', 'scampi',
      'pangasius', 'fischstäbchen', 'dorade', 'zander',
    ],
    'kräuter': [
      'petersilie', 'basilikum', 'oregano', 'thymian', 'rosmarin',
      'schnittlauch', 'dill', 'koriander', 'minze', 'salbei',
    ],
    'gewürze': [
      'salz', 'pfeffer', 'paprikapulver', 'kurkuma', 'kreuzkümmel', 'zimt',
      'muskat', 'chili', 'curry', 'ingwer', 'oregano', 'thymian',
    ],
    'nudeln': ['spaghetti', 'penne', 'fusilli', 'tagliatelle', 'linguine', 'nudel'],
    'sauce': ['passata', 'tomatenmark', 'sojasoße', 'sojasauce', 'sahne', 'brühe'],
  };

  List<Ingredient> _matchingIngredients() {
    if (ingredients.isEmpty) return [];
    final instructionLower = step.instruction.toLowerCase();
    final instructionWords = instructionLower
        .split(RegExp(r'[\s,.\-!?;:]+'))
        .where((w) => w.length >= 3)
        .toList();

    // Oberbegriffe im Text finden → passende Zutatennamen sammeln
    final groupMatches = <String>{};
    for (final entry in _groupWords.entries) {
      if (instructionLower.contains(entry.key)) {
        groupMatches.addAll(entry.value);
      }
    }

    return ingredients.where((ing) {
      final name = ing.name.toLowerCase();
      final mainName = name.split('(').first.trim();
      // 1. Zutatenname kommt direkt im Text vor
      if (instructionLower.contains(mainName)) return true;
      // 2. Ein Wort der Zutat kommt im Text vor (z.B. "Knoblauch" aus "Knoblauchzehe")
      final nameWords = mainName.split(' ').where((w) => w.length >= 4);
      if (nameWords.any((word) => instructionLower.contains(word))) {
        return true;
      }
      // 3. Ein Wort im Text ist Teil des Zutatennamens (z.B. "Reis" in "Basmatireis")
      if (instructionWords.any((word) =>
          word.length >= 4 && mainName.contains(word))) {
        return true;
      }
      // 4. Oberbegriff-Matching (z.B. "Gemüse" → Paprika, Zucchini, ...)
      if (groupMatches.isNotEmpty &&
          groupMatches.any((g) => mainName.contains(g))) {
        return true;
      }
      return false;
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
