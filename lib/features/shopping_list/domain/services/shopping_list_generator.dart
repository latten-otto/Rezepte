import 'package:rezepte/core/utils/unit_converter.dart';
import 'package:rezepte/features/meal_planning/domain/models/meal_plan_entry.dart';
import 'package:rezepte/features/recipes/domain/models/recipe.dart';
import 'package:rezepte/features/shopping_list/domain/models/shopping_item.dart';
import 'package:uuid/uuid.dart';

class ShoppingListGenerator {
  final _uuid = const Uuid();

  /// Category mapping for common German ingredients
  static const _categoryMap = <String, String>{
    // Obst & Gemüse
    'tomate': 'Obst & Gemüse', 'tomaten': 'Obst & Gemüse',
    'zwiebel': 'Obst & Gemüse', 'zwiebeln': 'Obst & Gemüse',
    'knoblauch': 'Obst & Gemüse', 'kartoffel': 'Obst & Gemüse',
    'karotte': 'Obst & Gemüse', 'möhre': 'Obst & Gemüse',
    'paprika': 'Obst & Gemüse', 'zucchini': 'Obst & Gemüse',
    'salat': 'Obst & Gemüse', 'gurke': 'Obst & Gemüse',
    'pilze': 'Obst & Gemüse', 'champignons': 'Obst & Gemüse',
    'spinat': 'Obst & Gemüse', 'brokkoli': 'Obst & Gemüse',
    'lauch': 'Obst & Gemüse', 'sellerie': 'Obst & Gemüse',
    'zitrone': 'Obst & Gemüse', 'limette': 'Obst & Gemüse',
    'apfel': 'Obst & Gemüse', 'banane': 'Obst & Gemüse',
    'ingwer': 'Obst & Gemüse', 'petersilie': 'Obst & Gemüse',
    'basilikum': 'Obst & Gemüse', 'koriander': 'Obst & Gemüse',

    // Milchprodukte
    'milch': 'Milchprodukte', 'käse': 'Milchprodukte',
    'sahne': 'Milchprodukte', 'butter': 'Milchprodukte',
    'joghurt': 'Milchprodukte', 'quark': 'Milchprodukte',
    'schmand': 'Milchprodukte', 'crème fraîche': 'Milchprodukte',
    'mozzarella': 'Milchprodukte', 'parmesan': 'Milchprodukte',
    'ei': 'Milchprodukte', 'eier': 'Milchprodukte',

    // Fleisch & Fisch
    'hähnchen': 'Fleisch & Fisch', 'huhn': 'Fleisch & Fisch',
    'rind': 'Fleisch & Fisch', 'schwein': 'Fleisch & Fisch',
    'hackfleisch': 'Fleisch & Fisch', 'lachs': 'Fleisch & Fisch',
    'garnelen': 'Fleisch & Fisch', 'thunfisch': 'Fleisch & Fisch',
    'schinken': 'Fleisch & Fisch', 'speck': 'Fleisch & Fisch',
    'wurst': 'Fleisch & Fisch',

    // Trockenwaren
    'nudeln': 'Trockenwaren', 'pasta': 'Trockenwaren',
    'reis': 'Trockenwaren', 'mehl': 'Trockenwaren',
    'zucker': 'Trockenwaren', 'linsen': 'Trockenwaren',
    'bohnen': 'Trockenwaren', 'couscous': 'Trockenwaren',
    'haferflocken': 'Trockenwaren',

    // Gewürze
    'salz': 'Gewürze', 'pfeffer': 'Gewürze',
    'paprikapulver': 'Gewürze', 'kreuzkümmel': 'Gewürze',
    'kurkuma': 'Gewürze', 'oregano': 'Gewürze',
    'thymian': 'Gewürze', 'zimt': 'Gewürze',
    'muskatnuss': 'Gewürze', 'chilipulver': 'Gewürze',

    // Konserven & Saucen
    'olivenöl': 'Öl & Saucen', 'öl': 'Öl & Saucen',
    'sojasauce': 'Öl & Saucen', 'essig': 'Öl & Saucen',
    'tomatenmark': 'Konserven', 'passata': 'Konserven',
    'kokosmilch': 'Konserven', 'brühe': 'Konserven',
  };

  List<ShoppingItem> generate({
    required List<MealPlanEntry> entries,
    required Map<String, Recipe> recipeMap,
    List<String> pantryStaples = const [],
  }) {
    final aggregated = <String, _AggregatedItem>{};

    for (final entry in entries) {
      final recipe = recipeMap[entry.recipeId];
      if (recipe == null) continue;

      final scaleFactor = entry.servings / recipe.servings;

      for (final ing in recipe.ingredients) {
        final key = ing.name.toLowerCase().trim();
        final scaledAmount =
            ing.amount != null ? ing.amount! * scaleFactor : null;

        if (aggregated.containsKey(key)) {
          final existing = aggregated[key]!;
          existing.recipeIds.add(recipe.id);

          if (scaledAmount != null && existing.amount != null) {
            if (existing.unit == ing.unit ||
                (existing.unit != null &&
                    ing.unit != null &&
                    UnitConverter.canConvert(existing.unit!, ing.unit!))) {
              // Same unit or convertible: add together
              if (existing.unit != null &&
                  ing.unit != null &&
                  existing.unit != ing.unit) {
                final converted = UnitConverter.convert(
                    scaledAmount, ing.unit!, existing.unit!);
                existing.amount = (existing.amount ?? 0) + converted;
              } else {
                existing.amount = (existing.amount ?? 0) + scaledAmount;
              }
            }
            // If incompatible units, keep the existing amount (simplified)
          } else if (scaledAmount != null) {
            existing.amount = (existing.amount ?? 0) + scaledAmount;
          }
        } else {
          aggregated[key] = _AggregatedItem(
            name: ing.name,
            amount: scaledAmount,
            unit: ing.unit,
            recipeIds: {recipe.id},
          );
        }
      }
    }

    // Remove pantry staples
    final pantryLower = pantryStaples.map((s) => s.toLowerCase()).toSet();
    aggregated.removeWhere((key, _) => pantryLower.contains(key));

    // Convert to ShoppingItems
    return aggregated.entries.map((e) {
      final item = e.value;
      return ShoppingItem(
        id: _uuid.v4(),
        name: item.name,
        amount: item.amount,
        unit: item.unit,
        category: _categorize(item.name),
        fromRecipeIds: item.recipeIds.toList(),
      );
    }).toList()
      ..sort((a, b) => a.category.compareTo(b.category));
  }

  String _categorize(String ingredientName) {
    final lower = ingredientName.toLowerCase();
    for (final entry in _categoryMap.entries) {
      if (lower.contains(entry.key)) {
        return entry.value;
      }
    }
    return 'Sonstiges';
  }
}

class _AggregatedItem {
  final String name;
  double? amount;
  final String? unit;
  final Set<String> recipeIds;

  _AggregatedItem({
    required this.name,
    this.amount,
    this.unit,
    required this.recipeIds,
  });
}
