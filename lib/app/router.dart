import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/services/supabase_service.dart';
import '../features/auth/presentation/providers/auth_provider.dart';
import '../features/auth/presentation/screens/edit_profile_screen.dart';
import '../features/auth/presentation/screens/forgot_password_screen.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/auth/presentation/screens/onboarding_screen.dart';
import '../features/auth/presentation/screens/register_screen.dart';
import '../features/auth/presentation/screens/splash_screen.dart';
import '../features/budget/presentation/screens/budget_allocation_screen.dart';
import '../features/budget/presentation/screens/income_entry_screen.dart';
import '../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../features/expenses/presentation/screens/add_edit_expense_screen.dart';
import '../features/expenses/presentation/screens/expenses_screen.dart';
import '../features/expenses/presentation/screens/recurring_expenses_screen.dart';
import '../features/ingredients/presentation/screens/add_edit_ingredient_screen.dart';
import '../features/ingredients/presentation/screens/ingredients_screen.dart';
import '../features/meals/presentation/screens/add_meal_item_screen.dart';
import '../features/meals/presentation/screens/meal_plan_screen.dart';
import '../features/meals/presentation/screens/meal_preferences_screen.dart';
import '../features/notifications/presentation/screens/notifications_screen.dart';
import '../features/profile/presentation/more_menu_screen.dart';
import '../features/reports/presentation/screens/reports_screen.dart';
import '../features/settings/presentation/screens/settings_screen.dart';
import '../features/shopping/presentation/screens/shopping_list_screen.dart';
import 'main_shell.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

/// true จนกว่า Supabase auth stream จะยิงค่าครั้งแรก (ใช้กัน Splash กระพริบ)
final _authReadyProvider = StateProvider<bool>((ref) => false);

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateChangesProvider);

  authState.whenData((_) {
    final notifier = ref.read(_authReadyProvider.notifier);
    if (!notifier.state) notifier.state = true;
  });

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/splash',
    refreshListenable: GoRouterRefreshStream(
      ref.watch(authRepositoryProvider).authStateChanges,
    ),
    redirect: (context, state) {
      final loggedIn = SupabaseService.isLoggedIn;
      final isReady = ref.read(_authReadyProvider);
      final loc = state.matchedLocation;

      if (!isReady) {
        return loc == '/splash' ? null : '/splash';
      }

      final authRoutes = {'/login', '/register', '/forgot-password', '/onboarding'};

      if (!loggedIn) {
        if (loc == '/splash') return '/onboarding';
        if (authRoutes.contains(loc)) return null;
        return '/onboarding';
      }

      // Logged in
      if (loc == '/splash' || authRoutes.contains(loc)) return '/home';
      return null;
    },
    routes: [
      GoRoute(path: '/splash', builder: (context, state) => const SplashScreen()),
      GoRoute(path: '/onboarding', builder: (context, state) => const OnboardingScreen()),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(path: '/register', builder: (context, state) => const RegisterScreen()),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/edit-profile',
        builder: (context, state) => const EditProfileScreen(),
      ),
      // ---------------- Budget flow ----------------
      GoRoute(
        path: '/income-entry',
        builder: (context, state) => const IncomeEntryScreen(),
      ),
      GoRoute(
        path: '/budget-allocation',
        builder: (context, state) => const BudgetAllocationScreen(),
      ),
      // ---------------- Expenses flow ----------------
      GoRoute(
        path: '/expenses/add',
        builder: (context, state) => const AddEditExpenseScreen(),
      ),
      GoRoute(
        path: '/expenses/edit/:id',
        builder: (context, state) => AddEditExpenseScreen(
          expenseId: state.pathParameters['id'],
        ),
      ),
      GoRoute(
        path: '/expenses/recurring',
        builder: (context, state) => const RecurringExpensesScreen(),
      ),
      // ---------------- Ingredients flow ----------------
      GoRoute(
        path: '/ingredients',
        builder: (context, state) => const IngredientsScreen(),
      ),
      GoRoute(
        path: '/ingredients/add',
        builder: (context, state) => const AddEditIngredientScreen(),
      ),
      GoRoute(
        path: '/ingredients/edit/:id',
        builder: (context, state) => AddEditIngredientScreen(
          ingredientId: state.pathParameters['id'],
        ),
      ),
      // ---------------- Meal plan flow ----------------
      GoRoute(
        path: '/meal-preferences',
        builder: (context, state) => const MealPreferencesScreen(),
      ),
      GoRoute(
        path: '/meals/add-item',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          return AddMealItemScreen(
            mealPlanId: extra['mealPlanId'] as String,
            mealDate: extra['mealDate'] as DateTime,
            mealType: extra['mealType'] as String,
          );
        },
      ),
      // ---------------- Reports & Notifications ----------------
      GoRoute(
        path: '/reports',
        builder: (context, state) => const ReportsScreen(),
      ),
      GoRoute(
        path: '/notifications',
        builder: (context, state) => const NotificationsScreen(),
      ),
      // ---------------- Settings ----------------
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            MainShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(path: '/home', builder: (context, state) => const DashboardScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/expenses', builder: (context, state) => const ExpensesScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/meals', builder: (context, state) => const MealPlanScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/shopping', builder: (context, state) => const ShoppingListScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/more', builder: (context, state) => const MoreMenuScreen()),
          ]),
        ],
      ),
    ],
  );
});

/// แปลง Stream ของ Supabase ให้เป็น Listenable สำหรับ GoRouter refreshListenable
class GoRouterRefreshStream extends ChangeNotifier {
  late final Stream<dynamic> _stream;

  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _stream = stream.asBroadcastStream();
    _stream.listen((_) => notifyListeners());
  }
}
