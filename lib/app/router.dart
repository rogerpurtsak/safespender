import 'package:go_router/go_router.dart';
import 'package:safespender/features/expenses/presentation/add_expense_screen.dart';
import 'package:safespender/features/grocery/presentation/grocery_overview_screen.dart';
import 'package:safespender/features/home/presentation/home_screen.dart';
import 'package:safespender/features/settings/presentation/settings_screen.dart';
import 'package:safespender/features/setup/presentation/setup_screen.dart';
import 'package:safespender/features/purchase_check/presentation/purchase_check_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/setup',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(
      path: '/addexpense',
      builder: (context, state) => const AddExpenseScreen(),
    ),
    GoRoute(
      path: '/groceryoverview',
      builder: (context, state) => const GroceryOverviewScreen(),
    ),
    GoRoute(
      path: '/setup',
      builder: (context, state) => const SetupScreen(),
    ),
    GoRoute(
      path: '/purchase_check',
      builder: (context, state) => const PurchaseCheckScreen(),
    ),
  ],
);