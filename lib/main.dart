import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rezepte/app.dart';
import 'package:rezepte/core/database/app_database.dart' show AppDatabase;
import 'package:rezepte/core/database/database_seeder.dart';
import 'package:rezepte/features/recipes/presentation/providers/recipes_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final db = AppDatabase();
  await DatabaseSeeder(db).seedIfEmpty();

  runApp(ProviderScope(
    overrides: [
      // Provide the already-opened database instance to all providers
      databaseOverrideProvider.overrideWithValue(db),
    ],
    child: const RezepteApp(),
  ));
}
