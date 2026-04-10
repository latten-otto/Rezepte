import 'package:freezed_annotation/freezed_annotation.dart';
import 'ingredient.dart';
import 'recipe_step.dart';

part 'recipe.freezed.dart';
part 'recipe.g.dart';

enum RecipeCategory { meat, fish, vegetarian, vegan }

@freezed
class Recipe with _$Recipe {
  const factory Recipe({
    required String id,
    required String title,
    String? description,
    String? imageUrl,
    String? localImagePath,
    required List<Ingredient> ingredients,
    required List<RecipeStep> steps,
    int? prepTimeMinutes,
    int? cookTimeMinutes,
    @Default(4) int servings,
    @Default([]) List<String> tags,
    @Default(RecipeCategory.vegetarian) RecipeCategory category,
    String? sourceUrl,
    required DateTime createdAt,
    required DateTime updatedAt,
    @Default(false) bool isFavorite,
    String? notes,
  }) = _Recipe;

  factory Recipe.fromJson(Map<String, dynamic> json) => _$RecipeFromJson(json);
}
