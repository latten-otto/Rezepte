import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rezepte/features/recipes/presentation/screens/recipes_list_screen.dart';
import 'package:rezepte/features/recipes/presentation/screens/recipe_detail_screen.dart';
import 'package:rezepte/features/recipes/presentation/screens/recipe_edit_screen.dart';
import 'package:rezepte/features/recipes/presentation/screens/recipe_import_screen.dart';
import 'package:rezepte/features/recipes/presentation/screens/cooking_mode_screen.dart';
import 'package:rezepte/features/meal_planning/presentation/screens/meal_plan_screen.dart';
import 'package:rezepte/features/meal_planning/presentation/screens/preferences_screen.dart';
import 'package:rezepte/features/shopping_list/presentation/screens/shopping_list_screen.dart';
import 'package:rezepte/features/settings/presentation/screens/settings_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKeyRecipes =
    GlobalKey<NavigatorState>(debugLabel: 'recipes');
final _shellNavigatorKeyMealPlan =
    GlobalKey<NavigatorState>(debugLabel: 'mealPlan');
final _shellNavigatorKeyShoppingList =
    GlobalKey<NavigatorState>(debugLabel: 'shoppingList');
final _shellNavigatorKeySettings =
    GlobalKey<NavigatorState>(debugLabel: 'settings');

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return ScaffoldWithNavBar(navigationShell: navigationShell);
        },
        branches: [
          // Tab 1: Rezepte
          StatefulShellBranch(
            navigatorKey: _shellNavigatorKeyRecipes,
            routes: [
              GoRoute(
                path: '/',
                builder: (context, state) => const RecipesListScreen(),
                routes: [
                  GoRoute(
                    path: 'recipes/new',
                    builder: (context, state) => const RecipeEditScreen(),
                  ),
                  GoRoute(
                    path: 'recipes/:id',
                    builder: (context, state) {
                      final id = state.pathParameters['id']!;
                      return RecipeDetailScreen(recipeId: id);
                    },
                    routes: [
                      GoRoute(
                        path: 'cook',
                        parentNavigatorKey: _rootNavigatorKey,
                        builder: (context, state) {
                          final id = state.pathParameters['id']!;
                          return CookingModeScreen(recipeId: id);
                        },
                      ),
                      GoRoute(
                        path: 'edit',
                        builder: (context, state) {
                          final id = state.pathParameters['id']!;
                          return RecipeEditScreen(recipeId: id);
                        },
                      ),
                    ],
                  ),
                  GoRoute(
                    path: 'import',
                    builder: (context, state) => const RecipeImportScreen(),
                  ),
                ],
              ),
            ],
          ),
          // Tab 2: Wochenplan
          StatefulShellBranch(
            navigatorKey: _shellNavigatorKeyMealPlan,
            routes: [
              GoRoute(
                path: '/meal-plan',
                builder: (context, state) => const MealPlanScreen(),
                routes: [
                  GoRoute(
                    path: 'preferences',
                    builder: (context, state) => const PreferencesScreen(),
                  ),
                ],
              ),
            ],
          ),
          // Tab 3: Einkaufsliste
          StatefulShellBranch(
            navigatorKey: _shellNavigatorKeyShoppingList,
            routes: [
              GoRoute(
                path: '/shopping-list',
                builder: (context, state) => const ShoppingListScreen(),
              ),
            ],
          ),
          // Tab 4: Einstellungen
          StatefulShellBranch(
            navigatorKey: _shellNavigatorKeySettings,
            routes: [
              GoRoute(
                path: '/settings',
                builder: (context, state) => const SettingsScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});

class ScaffoldWithNavBar extends StatelessWidget {
  const ScaffoldWithNavBar({
    super.key,
    required this.navigationShell,
  });

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) => navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
        ),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.restaurant_menu_outlined),
            selectedIcon: Icon(Icons.restaurant_menu),
            label: 'Rezepte',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_today_outlined),
            selectedIcon: Icon(Icons.calendar_today),
            label: 'Wochenplan',
          ),
          NavigationDestination(
            icon: Icon(Icons.shopping_cart_outlined),
            selectedIcon: Icon(Icons.shopping_cart),
            label: 'Einkaufsliste',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Einstellungen',
          ),
        ],
      ),
    );
  }
}
