import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rezepte/core/theme/app_colors.dart';
import 'package:rezepte/features/recipes/domain/models/recipe.dart';
import 'package:rezepte/features/recipes/presentation/providers/recipes_provider.dart';

class RecipeCard extends ConsumerWidget {
  final Recipe recipe;

  const RecipeCard({super.key, required this.recipe});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push('/recipes/${recipe.id}'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image or gradient placeholder
            AspectRatio(
              aspectRatio: 16 / 10,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _buildImage(),
                  // Gradient overlay for readability
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.5),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Category badge
                  Positioned(
                    top: 8,
                    left: 8,
                    child: _CategoryBadge(category: recipe.category),
                  ),
                  // Favorite icon
                  Positioned(
                    top: 4,
                    right: 4,
                    child: IconButton(
                      icon: Icon(
                        recipe.isFavorite
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color: recipe.isFavorite
                            ? Colors.redAccent
                            : Colors.white,
                        size: 22,
                      ),
                      onPressed: () {
                        ref
                            .read(recipeRepositoryProvider)
                            .toggleFavorite(recipe.id, !recipe.isFavorite);
                      },
                    ),
                  ),
                ],
              ),
            ),
            // Title and time info
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 4),
              child: Text(
                recipe.title,
                style: theme.textTheme.titleSmall,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 8),
              child: _buildTimeInfo(theme),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage() {
    if (recipe.imageUrl != null && recipe.imageUrl!.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: recipe.imageUrl!,
        fit: BoxFit.cover,
        placeholder: (context, url) => _buildPlaceholder(),
        errorWidget: (context, url, error) => _buildPlaceholder(),
      );
    }
    return _buildPlaceholder();
  }

  Widget _buildPlaceholder() {
    final colors = _categoryGradient(recipe.category);
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
      ),
      child: const Center(
        child: Icon(
          Icons.restaurant,
          size: 40,
          color: Colors.white70,
        ),
      ),
    );
  }

  Widget _buildTimeInfo(ThemeData theme) {
    final totalTime = (recipe.prepTimeMinutes ?? 0) + (recipe.cookTimeMinutes ?? 0);
    if (totalTime == 0) return const SizedBox.shrink();
    return Row(
      children: [
        Icon(Icons.access_time, size: 14, color: Colors.grey.shade600),
        const SizedBox(width: 4),
        Text(
          '$totalTime Min.',
          style: theme.textTheme.bodySmall?.copyWith(
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  static List<Color> _categoryGradient(RecipeCategory category) {
    switch (category) {
      case RecipeCategory.meat:
        return [const Color(0xFFD32F2F), const Color(0xFFFF7043)];
      case RecipeCategory.fish:
        return [const Color(0xFF0288D1), const Color(0xFF4FC3F7)];
      case RecipeCategory.vegetarian:
        return [const Color(0xFF388E3C), const Color(0xFF81C784)];
      case RecipeCategory.vegan:
        return [const Color(0xFF558B2F), const Color(0xFFAED581)];
    }
  }
}

class _CategoryBadge extends StatelessWidget {
  final RecipeCategory category;

  const _CategoryBadge({required this.category});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _categoryColor(category),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        _categoryLabel(category),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  static Color _categoryColor(RecipeCategory category) {
    switch (category) {
      case RecipeCategory.meat:
        return AppColors.error;
      case RecipeCategory.fish:
        return const Color(0xFF0288D1);
      case RecipeCategory.vegetarian:
        return AppColors.secondary;
      case RecipeCategory.vegan:
        return const Color(0xFF558B2F);
    }
  }

  static String _categoryLabel(RecipeCategory category) {
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
