import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import 'package:rezepte/features/recipes/domain/models/recipe.dart';
import 'package:rezepte/features/recipes/domain/models/ingredient.dart';
import 'package:rezepte/features/recipes/domain/models/recipe_step.dart';
import 'package:rezepte/features/recipes/presentation/providers/recipes_provider.dart';

class RecipeImportScreen extends ConsumerStatefulWidget {
  const RecipeImportScreen({super.key});

  @override
  ConsumerState<RecipeImportScreen> createState() => _RecipeImportScreenState();
}

class _RecipeImportScreenState extends ConsumerState<RecipeImportScreen> {
  final _urlController = TextEditingController();
  bool _isLoading = false;
  String? _error;
  Recipe? _importedRecipe;
  final _uuid = const Uuid();

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _importRecipe() async {
    final url = _urlController.text.trim();
    if (url.isEmpty) return;

    setState(() {
      _isLoading = true;
      _error = null;
      _importedRecipe = null;
    });

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {'User-Agent': 'Mozilla/5.0 Rezepte-App/1.0'},
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode != 200) {
        throw Exception('HTTP ${response.statusCode}');
      }

      final document = html_parser.parse(response.body);
      final scripts = document.querySelectorAll('script[type="application/ld+json"]');

      Map<String, dynamic>? recipeData;

      for (final script in scripts) {
        try {
          final json = jsonDecode(script.text);
          if (json is Map<String, dynamic>) {
            if (json['@type'] == 'Recipe' || json['@type']?.toString().contains('Recipe') == true) {
              recipeData = json;
              break;
            }
            if (json['@graph'] is List) {
              for (final item in json['@graph']) {
                if (item is Map<String, dynamic> &&
                    (item['@type'] == 'Recipe' || item['@type']?.toString().contains('Recipe') == true)) {
                  recipeData = item;
                  break;
                }
              }
            }
          } else if (json is List) {
            for (final item in json) {
              if (item is Map<String, dynamic> &&
                  (item['@type'] == 'Recipe' || item['@type']?.toString().contains('Recipe') == true)) {
                recipeData = item;
                break;
              }
            }
          }
          if (recipeData != null) break;
        } catch (_) {}
      }

      if (recipeData == null) {
        throw Exception('Kein Rezept in den Seitendaten gefunden.');
      }

      final recipe = _parseRecipeData(recipeData, url);
      setState(() => _importedRecipe = recipe);
    } catch (e) {
      setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Recipe _parseRecipeData(Map<String, dynamic> data, String sourceUrl) {
    final title = data['name']?.toString() ?? 'Importiertes Rezept';
    final description = data['description']?.toString();

    // Parse image
    String? imageUrl;
    final image = data['image'];
    if (image is String) {
      imageUrl = image;
    } else if (image is Map) {
      imageUrl = image['url']?.toString();
    } else if (image is List && image.isNotEmpty) {
      final first = image.first;
      imageUrl = first is String ? first : first['url']?.toString();
    }

    // Parse ingredients
    final rawIngredients = data['recipeIngredient'] as List? ?? [];
    final ingredients = rawIngredients.asMap().entries.map((e) {
      return Ingredient(
        id: _uuid.v4(),
        name: e.value.toString(),
        originalText: e.value.toString(),
      );
    }).toList();

    // Parse steps
    final rawInstructions = data['recipeInstructions'];
    final steps = <RecipeStep>[];
    if (rawInstructions is List) {
      for (var i = 0; i < rawInstructions.length; i++) {
        final item = rawInstructions[i];
        String text;
        if (item is String) {
          text = item;
        } else if (item is Map) {
          text = item['text']?.toString() ?? item['name']?.toString() ?? '';
        } else {
          continue;
        }
        if (text.isNotEmpty) {
          steps.add(RecipeStep(
            id: _uuid.v4(),
            stepNumber: steps.length + 1,
            instruction: text,
          ));
        }
      }
    } else if (rawInstructions is String) {
      steps.add(RecipeStep(
        id: _uuid.v4(),
        stepNumber: 1,
        instruction: rawInstructions,
      ));
    }

    // Parse times
    int? prepTime = _parseDuration(data['prepTime']?.toString());
    int? cookTime = _parseDuration(data['cookTime']?.toString());

    // Parse servings
    int servings = 4;
    final yield_ = data['recipeYield'];
    if (yield_ is int) {
      servings = yield_;
    } else if (yield_ is String) {
      servings = int.tryParse(yield_.replaceAll(RegExp(r'[^0-9]'), '')) ?? 4;
    } else if (yield_ is List && yield_.isNotEmpty) {
      servings = int.tryParse(yield_.first.toString().replaceAll(RegExp(r'[^0-9]'), '')) ?? 4;
    }

    // Parse category/tags
    final tags = <String>[];
    if (data['recipeCategory'] is String) {
      tags.add(data['recipeCategory']);
    } else if (data['recipeCategory'] is List) {
      tags.addAll((data['recipeCategory'] as List).map((e) => e.toString()));
    }
    if (data['keywords'] is String) {
      tags.addAll(data['keywords'].split(',').map((s) => s.toString().trim()));
    }

    final now = DateTime.now();
    return Recipe(
      id: _uuid.v4(),
      title: title,
      description: description,
      imageUrl: imageUrl,
      ingredients: ingredients,
      steps: steps,
      prepTimeMinutes: prepTime,
      cookTimeMinutes: cookTime,
      servings: servings,
      tags: tags.where((t) => t.isNotEmpty).toSet().toList(),
      sourceUrl: sourceUrl,
      createdAt: now,
      updatedAt: now,
    );
  }

  int? _parseDuration(String? iso) {
    if (iso == null) return null;
    final match = RegExp(r'PT(?:(\d+)H)?(?:(\d+)M)?').firstMatch(iso);
    if (match == null) return null;
    final hours = int.tryParse(match.group(1) ?? '') ?? 0;
    final minutes = int.tryParse(match.group(2) ?? '') ?? 0;
    final total = hours * 60 + minutes;
    return total > 0 ? total : null;
  }

  Future<void> _saveRecipe() async {
    if (_importedRecipe == null) return;

    setState(() => _isLoading = true);
    try {
      await ref.read(recipeRepositoryProvider).insertRecipe(_importedRecipe!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Rezept gespeichert!')),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fehler: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Rezept importieren')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _urlController,
              decoration: InputDecoration(
                labelText: 'Rezept-URL eingeben',
                hintText: 'https://www.chefkoch.de/rezepte/...',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () => _urlController.clear(),
                ),
              ),
              keyboardType: TextInputType.url,
              onSubmitted: (_) => _importRecipe(),
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: _isLoading ? null : _importRecipe,
              icon: _isLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.download),
              label: Text(_isLoading ? 'Importiere...' : 'Importieren'),
            ),
            const SizedBox(height: 16),

            if (_error != null)
              Card(
                color: theme.colorScheme.errorContainer,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    'Rezept konnte nicht importiert werden:\n$_error',
                    style: TextStyle(color: theme.colorScheme.onErrorContainer),
                  ),
                ),
              ),

            if (_importedRecipe != null)
              Expanded(
                child: Card(
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      Text('Vorschau', style: theme.textTheme.titleSmall),
                      const SizedBox(height: 8),
                      Text(
                        _importedRecipe!.title,
                        style: theme.textTheme.headlineSmall,
                      ),
                      if (_importedRecipe!.description != null) ...[
                        const SizedBox(height: 8),
                        Text(_importedRecipe!.description!,
                            maxLines: 3, overflow: TextOverflow.ellipsis),
                      ],
                      const Divider(height: 24),
                      Text(
                        '${_importedRecipe!.ingredients.length} Zutaten, '
                        '${_importedRecipe!.steps.length} Schritte, '
                        '${_importedRecipe!.servings} Portionen',
                        style: theme.textTheme.bodyMedium,
                      ),
                      if (_importedRecipe!.tags.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 4,
                          children: _importedRecipe!.tags
                              .map((t) => Chip(label: Text(t, style: const TextStyle(fontSize: 11))))
                              .toList(),
                        ),
                      ],
                      const SizedBox(height: 16),
                      FilledButton.icon(
                        onPressed: _isLoading ? null : _saveRecipe,
                        icon: const Icon(Icons.save),
                        label: const Text('Speichern'),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
