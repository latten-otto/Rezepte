import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rezepte/features/meal_planning/domain/models/meal_preferences.dart';
import 'package:rezepte/features/meal_planning/presentation/providers/meal_plan_provider.dart';

class PreferencesScreen extends ConsumerStatefulWidget {
  const PreferencesScreen({super.key});

  @override
  ConsumerState<PreferencesScreen> createState() => _PreferencesScreenState();
}

class _PreferencesScreenState extends ConsumerState<PreferencesScreen> {
  late int _mealsPerWeek;
  late int _maxMeat;
  late int _maxFish;
  late int _defaultServings;
  final _excludedController = TextEditingController();
  bool _isLoaded = false;

  @override
  void dispose() {
    _excludedController.dispose();
    super.dispose();
  }

  void _initFromPrefs(MealPreferences prefs) {
    if (_isLoaded) return;
    _mealsPerWeek = prefs.mealsPerWeek;
    _maxMeat = prefs.maxMeatMeals;
    _maxFish = prefs.maxFishMeals;
    _defaultServings = prefs.defaultServings;
    _excludedController.text = prefs.excludedIngredients.join(', ');
    _isLoaded = true;
  }

  Future<void> _save() async {
    final excluded = _excludedController.text
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    final prefs = MealPreferences(
      mealsPerWeek: _mealsPerWeek,
      maxMeatMeals: _maxMeat,
      maxFishMeals: _maxFish,
      defaultServings: _defaultServings,
      excludedIngredients: excluded,
    );

    await ref.read(mealPlanRepositoryProvider).savePreferences(prefs);
    ref.invalidate(mealPreferencesProvider);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vorlieben gespeichert!')),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final prefsAsync = ref.watch(mealPreferencesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Vorlieben'),
        actions: [
          TextButton(
            onPressed: _save,
            child: const Text('Speichern'),
          ),
        ],
      ),
      body: prefsAsync.when(
        data: (prefs) {
          _initFromPrefs(prefs);
          return _buildForm();
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Fehler: $e')),
      ),
    );
  }

  Widget _buildForm() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSlider(
          label: 'Mahlzeiten pro Woche',
          value: _mealsPerWeek,
          min: 1,
          max: 7,
          onChanged: (v) => setState(() => _mealsPerWeek = v),
        ),
        const SizedBox(height: 16),
        _buildSlider(
          label: 'Davon max. Fleisch',
          value: _maxMeat,
          min: 0,
          max: _mealsPerWeek,
          onChanged: (v) => setState(() => _maxMeat = v),
        ),
        const SizedBox(height: 16),
        _buildSlider(
          label: 'Davon max. Fisch',
          value: _maxFish,
          min: 0,
          max: _mealsPerWeek - _maxMeat,
          onChanged: (v) => setState(() => _maxFish = v),
        ),
        const SizedBox(height: 16),
        _buildSlider(
          label: 'Standard-Portionen',
          value: _defaultServings,
          min: 1,
          max: 8,
          onChanged: (v) => setState(() => _defaultServings = v),
        ),
        const SizedBox(height: 24),
        Text('Ausgeschlossene Zutaten',
            style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        TextField(
          controller: _excludedController,
          decoration: const InputDecoration(
            hintText: 'z.B. Nüsse, Sellerie, Milch',
            border: OutlineInputBorder(),
            helperText: 'Kommagetrennt eingeben',
          ),
        ),
        const SizedBox(height: 24),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Zusammenfassung',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                Text('$_mealsPerWeek Mahlzeiten/Woche'),
                Text('Max. $_maxMeat× Fleisch, $_maxFish× Fisch'),
                Text(
                    'Min. ${_mealsPerWeek - _maxMeat - _maxFish}× Vegetarisch/Vegan'),
                Text('$_defaultServings Portionen pro Mahlzeit'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSlider({
    required String label,
    required int value,
    required int min,
    required int max,
    required ValueChanged<int> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: Theme.of(context).textTheme.titleSmall),
            Text('$value', style: Theme.of(context).textTheme.titleMedium),
          ],
        ),
        Slider(
          value: value.toDouble(),
          min: min.toDouble(),
          max: max.toDouble(),
          divisions: max - min > 0 ? max - min : 1,
          onChanged: (v) => onChanged(v.round()),
        ),
      ],
    );
  }
}
