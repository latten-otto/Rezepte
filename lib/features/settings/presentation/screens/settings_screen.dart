import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Einstellungen')),
      body: ListView(
        children: [
          const _SectionHeader(title: 'Essensplanung'),
          ListTile(
            leading: const Icon(Icons.tune),
            title: const Text('Vorlieben'),
            subtitle: const Text('Mahlzeiten/Woche, Fleischanteil, Ausschlüsse'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/meal-plan/preferences'),
          ),
          const Divider(),
          const _SectionHeader(title: 'App'),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('Über Rezepte'),
            subtitle: const Text('Version 1.0.0'),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: 'Rezepte',
                applicationVersion: '1.0.0',
                applicationLegalese: '© 2026',
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 16),
                    child: Text(
                      'Deine Rezeptsammlung mit Wochenplanung und Einkaufsliste.',
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        title,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
      ),
    );
  }
}
