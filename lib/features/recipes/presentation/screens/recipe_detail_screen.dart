import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rezepte/features/recipes/domain/models/recipe.dart';
import 'package:rezepte/features/recipes/presentation/providers/recipes_provider.dart';
import 'package:rezepte/features/recipes/presentation/widgets/ingredient_list.dart';

class RecipeDetailScreen extends ConsumerStatefulWidget {
  final String recipeId;

  const RecipeDetailScreen({super.key, required this.recipeId});

  @override
  ConsumerState<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends ConsumerState<RecipeDetailScreen> {
  late int _currentServings;
  bool _initialized = false;

  @override
  Widget build(BuildContext context) {
    final recipeAsync = ref.watch(recipeByIdProvider(widget.recipeId));

    return recipeAsync.when(
      data: (recipe) {
        if (recipe == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: Text('Rezept nicht gefunden')),
          );
        }
        if (!_initialized) {
          _currentServings = recipe.servings;
          _initialized = true;
        }
        return _buildContent(context, recipe);
      },
      loading: () => Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(),
        body: Center(child: Text('Fehler: $e')),
      ),
    );
  }

  Widget _buildContent(BuildContext context, Recipe recipe) {
    final theme = Theme.of(context);
    final scaleFactor = _currentServings / recipe.servings;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                recipe.title,
                style: const TextStyle(shadows: [
                  Shadow(blurRadius: 8, color: Colors.black54),
                ]),
              ),
              background: recipe.imageUrl != null
                  ? CachedNetworkImage(
                      imageUrl: recipe.imageUrl!,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            theme.colorScheme.primary,
                            theme.colorScheme.secondary,
                          ],
                        ),
                      ),
                      child: const Center(
                        child: Icon(Icons.restaurant, size: 64, color: Colors.white70),
                      ),
                    ),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  recipe.isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: recipe.isFavorite ? Colors.redAccent : null,
                ),
                onPressed: () {
                  ref.read(recipeRepositoryProvider).toggleFavorite(
                        recipe.id,
                        !recipe.isFavorite,
                      );
                },
              ),
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => context.push('/recipes/${recipe.id}/edit'),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tags
                  if (recipe.tags.isNotEmpty)
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: recipe.tags
                          .map((tag) => Chip(
                                label: Text(tag, style: const TextStyle(fontSize: 12)),
                                visualDensity: VisualDensity.compact,
                              ))
                          .toList(),
                    ),
                  if (recipe.tags.isNotEmpty) const SizedBox(height: 12),

                  // Time info
                  if (recipe.prepTimeMinutes != null || recipe.cookTimeMinutes != null)
                    Row(
                      children: [
                        if (recipe.prepTimeMinutes != null) ...[
                          const Icon(Icons.timer_outlined, size: 18),
                          const SizedBox(width: 4),
                          Text('Vorbereitung: ${recipe.prepTimeMinutes} Min.'),
                          const SizedBox(width: 16),
                        ],
                        if (recipe.cookTimeMinutes != null) ...[
                          const Icon(Icons.local_fire_department_outlined, size: 18),
                          const SizedBox(width: 4),
                          Text('Kochen: ${recipe.cookTimeMinutes} Min.'),
                        ],
                      ],
                    ),
                  if (recipe.prepTimeMinutes != null || recipe.cookTimeMinutes != null)
                    const SizedBox(height: 16),

                  // Description
                  if (recipe.description != null && recipe.description!.isNotEmpty) ...[
                    Text(recipe.description!, style: theme.textTheme.bodyLarge),
                    const SizedBox(height: 16),
                  ],

                  // Servings
                  Row(
                    children: [
                      Text('Portionen:', style: theme.textTheme.titleMedium),
                      const SizedBox(width: 12),
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline),
                        onPressed: _currentServings > 1
                            ? () => setState(() => _currentServings--)
                            : null,
                      ),
                      Text(
                        '$_currentServings',
                        style: theme.textTheme.titleLarge,
                      ),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline),
                        onPressed: () => setState(() => _currentServings++),
                      ),
                    ],
                  ),
                  const Divider(height: 24),

                  // Ingredients
                  Text('Zutaten', style: theme.textTheme.titleLarge),
                  const SizedBox(height: 8),
                  IngredientListWidget(
                    ingredients: recipe.ingredients,
                    scaleFactor: scaleFactor,
                  ),
                  const Divider(height: 32),

                  // Steps
                  Text('Zubereitung', style: theme.textTheme.titleLarge),
                  const SizedBox(height: 8),
                  ...recipe.steps.map((step) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              radius: 14,
                              child: Text('${step.stepNumber}',
                                  style: const TextStyle(fontSize: 12)),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(step.instruction,
                                  style: theme.textTheme.bodyLarge),
                            ),
                          ],
                        ),
                      )),

                  // Notes
                  if (recipe.notes != null && recipe.notes!.isNotEmpty) ...[
                    const Divider(height: 32),
                    Text('Notizen', style: theme.textTheme.titleLarge),
                    const SizedBox(height: 8),
                    Text(recipe.notes!),
                  ],

                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/recipes/${recipe.id}/cook'),
        icon: const Icon(Icons.play_arrow),
        label: const Text('Kochen starten'),
      ),
    );
  }
}
