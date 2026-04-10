import 'package:flutter/material.dart';
import 'package:rezepte/features/recipes/domain/models/ingredient.dart';

class IngredientListWidget extends StatelessWidget {
  final List<Ingredient> ingredients;
  final double scaleFactor;

  const IngredientListWidget({
    super.key,
    required this.ingredients,
    this.scaleFactor = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: ingredients.map((ing) => _buildIngredientRow(context, ing)).toList(),
    );
  }

  Widget _buildIngredientRow(BuildContext context, Ingredient ingredient) {
    final scaledAmount = ingredient.amount != null
        ? ingredient.amount! * scaleFactor
        : null;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 70,
            child: Text(
              _formatAmount(scaledAmount, ingredient.unit),
              style: const TextStyle(fontWeight: FontWeight.w600),
              textAlign: TextAlign.right,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(ingredient.name),
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
