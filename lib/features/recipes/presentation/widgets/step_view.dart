import 'package:flutter/material.dart';
import 'package:rezepte/features/recipes/domain/models/recipe_step.dart';

class StepView extends StatelessWidget {
  final RecipeStep step;
  final int totalSteps;

  const StepView({
    super.key,
    required this.step,
    required this.totalSteps,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
                child: Text(
                  step.instruction,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
