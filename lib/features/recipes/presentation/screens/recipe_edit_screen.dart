import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import 'package:rezepte/features/recipes/domain/models/recipe.dart';
import 'package:rezepte/features/recipes/domain/models/ingredient.dart';
import 'package:rezepte/features/recipes/domain/models/recipe_step.dart';
import 'package:rezepte/features/recipes/presentation/providers/recipes_provider.dart';

const _units = ['g', 'kg', 'ml', 'l', 'Stück', 'EL', 'TL', 'Prise', 'Bund', 'Dose', 'Packung', ''];

class RecipeEditScreen extends ConsumerStatefulWidget {
  final String? recipeId;

  const RecipeEditScreen({super.key, this.recipeId});

  @override
  ConsumerState<RecipeEditScreen> createState() => _RecipeEditScreenState();
}

class _RecipeEditScreenState extends ConsumerState<RecipeEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _uuid = const Uuid();

  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _prepTimeController;
  late TextEditingController _cookTimeController;
  late TextEditingController _servingsController;
  late TextEditingController _tagsController;
  late TextEditingController _notesController;
  late TextEditingController _sourceUrlController;

  RecipeCategory _category = RecipeCategory.vegetarian;
  final List<_IngredientEntry> _ingredients = [];
  final List<_StepEntry> _steps = [];
  bool _isLoading = false;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _descriptionController = TextEditingController();
    _prepTimeController = TextEditingController();
    _cookTimeController = TextEditingController();
    _servingsController = TextEditingController(text: '4');
    _tagsController = TextEditingController();
    _notesController = TextEditingController();
    _sourceUrlController = TextEditingController();

    if (widget.recipeId != null) {
      _isEditing = true;
      _loadRecipe();
    } else {
      _ingredients.add(_IngredientEntry());
      _steps.add(_StepEntry());
    }
  }

  Future<void> _loadRecipe() async {
    final recipe = await ref.read(recipeRepositoryProvider).getRecipeById(widget.recipeId!);
    if (recipe != null && mounted) {
      setState(() {
        _titleController.text = recipe.title;
        _descriptionController.text = recipe.description ?? '';
        _prepTimeController.text = recipe.prepTimeMinutes?.toString() ?? '';
        _cookTimeController.text = recipe.cookTimeMinutes?.toString() ?? '';
        _servingsController.text = recipe.servings.toString();
        _tagsController.text = recipe.tags.join(', ');
        _notesController.text = recipe.notes ?? '';
        _sourceUrlController.text = recipe.sourceUrl ?? '';
        _category = recipe.category;
        _ingredients.clear();
        for (final ing in recipe.ingredients) {
          _ingredients.add(_IngredientEntry(
            id: ing.id,
            nameController: TextEditingController(text: ing.name),
            amountController: TextEditingController(
              text: ing.amount?.toString() ?? '',
            ),
            unit: ing.unit ?? '',
          ));
        }
        _steps.clear();
        for (final step in recipe.steps) {
          _steps.add(_StepEntry(
            id: step.id,
            controller: TextEditingController(text: step.instruction),
          ));
        }
        if (_ingredients.isEmpty) _ingredients.add(_IngredientEntry());
        if (_steps.isEmpty) _steps.add(_StepEntry());
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _prepTimeController.dispose();
    _cookTimeController.dispose();
    _servingsController.dispose();
    _tagsController.dispose();
    _notesController.dispose();
    _sourceUrlController.dispose();
    for (final i in _ingredients) {
      i.nameController.dispose();
      i.amountController.dispose();
    }
    for (final s in _steps) {
      s.controller.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final now = DateTime.now();
    final ingredients = _ingredients
        .where((i) => i.nameController.text.isNotEmpty)
        .toList()
        .asMap()
        .entries
        .map((e) => Ingredient(
              id: e.value.id,
              name: e.value.nameController.text.trim(),
              amount: double.tryParse(e.value.amountController.text),
              unit: e.value.unit.isNotEmpty ? e.value.unit : null,
            ))
        .toList();

    final steps = _steps
        .where((s) => s.controller.text.isNotEmpty)
        .toList()
        .asMap()
        .entries
        .map((e) => RecipeStep(
              id: e.value.id,
              stepNumber: e.key + 1,
              instruction: e.value.controller.text.trim(),
            ))
        .toList();

    final tags = _tagsController.text
        .split(',')
        .map((t) => t.trim())
        .where((t) => t.isNotEmpty)
        .toList();

    final recipe = Recipe(
      id: widget.recipeId ?? _uuid.v4(),
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim().isNotEmpty
          ? _descriptionController.text.trim()
          : null,
      ingredients: ingredients,
      steps: steps,
      prepTimeMinutes: int.tryParse(_prepTimeController.text),
      cookTimeMinutes: int.tryParse(_cookTimeController.text),
      servings: int.tryParse(_servingsController.text) ?? 4,
      tags: tags,
      category: _category,
      sourceUrl: _sourceUrlController.text.trim().isNotEmpty
          ? _sourceUrlController.text.trim()
          : null,
      notes: _notesController.text.trim().isNotEmpty
          ? _notesController.text.trim()
          : null,
      createdAt: _isEditing ? now : now,
      updatedAt: now,
    );

    try {
      final repo = ref.read(recipeRepositoryProvider);
      if (_isEditing) {
        await repo.updateRecipe(recipe);
      } else {
        await repo.insertRecipe(recipe);
      }
      if (mounted) context.pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fehler beim Speichern: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Rezept bearbeiten' : 'Neues Rezept'),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _save,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Speichern'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Titel *',
                border: OutlineInputBorder(),
              ),
              validator: (v) => v == null || v.trim().isEmpty ? 'Titel erforderlich' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Beschreibung',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 12),

            // Category
            DropdownButtonFormField<RecipeCategory>(
              value: _category,
              decoration: const InputDecoration(
                labelText: 'Kategorie',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: RecipeCategory.meat, child: Text('Fleisch')),
                DropdownMenuItem(value: RecipeCategory.fish, child: Text('Fisch')),
                DropdownMenuItem(value: RecipeCategory.vegetarian, child: Text('Vegetarisch')),
                DropdownMenuItem(value: RecipeCategory.vegan, child: Text('Vegan')),
              ],
              onChanged: (v) => setState(() => _category = v!),
            ),
            const SizedBox(height: 12),

            // Time and servings
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _prepTimeController,
                    decoration: const InputDecoration(
                      labelText: 'Vorbereitung (Min)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _cookTimeController,
                    decoration: const InputDecoration(
                      labelText: 'Kochzeit (Min)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _servingsController,
                    decoration: const InputDecoration(
                      labelText: 'Portionen',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Ingredients
            Text('Zutaten', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            ..._ingredients.asMap().entries.map((e) => _buildIngredientRow(e.key)),
            TextButton.icon(
              onPressed: () => setState(() => _ingredients.add(_IngredientEntry())),
              icon: const Icon(Icons.add),
              label: const Text('Zutat hinzufügen'),
            ),
            const SizedBox(height: 20),

            // Steps
            Text('Zubereitung', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            ..._steps.asMap().entries.map((e) => _buildStepRow(e.key)),
            TextButton.icon(
              onPressed: () => setState(() => _steps.add(_StepEntry())),
              icon: const Icon(Icons.add),
              label: const Text('Schritt hinzufügen'),
            ),
            const SizedBox(height: 12),

            // Tags
            TextFormField(
              controller: _tagsController,
              decoration: const InputDecoration(
                labelText: 'Tags (kommagetrennt)',
                hintText: 'z.B. schnell, italienisch, Pasta',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),

            // Source URL
            TextFormField(
              controller: _sourceUrlController,
              decoration: const InputDecoration(
                labelText: 'Quell-URL',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),

            // Notes
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notizen',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildIngredientRow(int index) {
    final entry = _ingredients[index];
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 60,
            child: TextField(
              controller: entry.amountController,
              decoration: const InputDecoration(
                hintText: 'Menge',
                isDense: true,
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
          ),
          const SizedBox(width: 6),
          SizedBox(
            width: 80,
            child: DropdownButtonFormField<String>(
              value: entry.unit,
              decoration: const InputDecoration(
                isDense: true,
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              ),
              items: _units.map((u) => DropdownMenuItem(
                value: u,
                child: Text(u.isEmpty ? '-' : u, style: const TextStyle(fontSize: 13)),
              )).toList(),
              onChanged: (v) => setState(() => entry.unit = v ?? ''),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: TextField(
              controller: entry.nameController,
              decoration: const InputDecoration(
                hintText: 'Zutat',
                isDense: true,
                border: OutlineInputBorder(),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.remove_circle_outline, size: 20),
            onPressed: _ingredients.length > 1
                ? () => setState(() => _ingredients.removeAt(index))
                : null,
          ),
        ],
      ),
    );
  }

  Widget _buildStepRow(int index) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(radius: 14, child: Text('${index + 1}')),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _steps[index].controller,
              decoration: const InputDecoration(
                hintText: 'Schritt beschreiben...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              minLines: 2,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.remove_circle_outline, size: 20),
            onPressed: _steps.length > 1
                ? () => setState(() => _steps.removeAt(index))
                : null,
          ),
        ],
      ),
    );
  }
}

class _IngredientEntry {
  final String id;
  final TextEditingController nameController;
  final TextEditingController amountController;
  String unit;

  _IngredientEntry({
    String? id,
    TextEditingController? nameController,
    TextEditingController? amountController,
    this.unit = '',
  })  : id = id ?? const Uuid().v4(),
        nameController = nameController ?? TextEditingController(),
        amountController = amountController ?? TextEditingController();
}

class _StepEntry {
  final String id;
  final TextEditingController controller;

  _StepEntry({
    String? id,
    TextEditingController? controller,
  })  : id = id ?? const Uuid().v4(),
        controller = controller ?? TextEditingController();
}
