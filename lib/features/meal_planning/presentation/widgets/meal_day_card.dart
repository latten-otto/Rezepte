import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:rezepte/features/meal_planning/domain/models/meal_plan_entry.dart';
import 'package:rezepte/features/recipes/domain/models/recipe.dart';

class MealDayCard extends StatelessWidget {
  final String dayName;
  final Recipe? recipe;
  final MealPlanEntry entry;
  final VoidCallback? onTap;
  final VoidCallback onSwap;
  final VoidCallback onToggleLock;

  const MealDayCard({
    super.key,
    required this.dayName,
    required this.recipe,
    required this.entry,
    this.onTap,
    required this.onSwap,
    required this.onToggleLock,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Day label
              SizedBox(
                width: 36,
                child: Text(
                  dayName,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Recipe image
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: 56,
                  height: 56,
                  child: recipe?.imageUrl != null
                      ? CachedNetworkImage(
                          imageUrl: recipe!.imageUrl!,
                          fit: BoxFit.cover,
                          errorWidget: (_, __, ___) => _buildPlaceholder(),
                        )
                      : _buildPlaceholder(),
                ),
              ),
              const SizedBox(width: 12),

              // Recipe info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recipe?.title ?? 'Unbekanntes Rezept',
                      style: theme.textTheme.titleSmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (recipe != null)
                      Text(
                        '${entry.servings} Portionen',
                        style: theme.textTheme.bodySmall,
                      ),
                  ],
                ),
              ),

              // Actions
              IconButton(
                icon: Icon(
                  entry.isLocked ? Icons.lock : Icons.lock_open,
                  size: 20,
                  color: entry.isLocked ? theme.colorScheme.primary : null,
                ),
                onPressed: onToggleLock,
                tooltip: entry.isLocked ? 'Entsperren' : 'Sperren',
              ),
              IconButton(
                icon: const Icon(Icons.swap_horiz, size: 20),
                onPressed: onSwap,
                tooltip: 'Tauschen',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: Colors.grey.shade200,
      child: const Icon(Icons.restaurant, color: Colors.grey),
    );
  }
}
