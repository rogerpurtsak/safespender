import 'package:go_router/go_router.dart';
import 'package:safespender/features/expenses/presentation/add_expense_screen.dart';
import 'package:safespender/features/navigation/presentation/main_shell_screen.dart';
import 'package:safespender/features/purchase_check/presentation/purchase_check_screen.dart';
import 'package:safespender/features/setup/presentation/setup_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/setup',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const MainShellScreen(),
    ),
    GoRoute(
      path: '/setup',
      builder: (context, state) => const SetupScreen(),
    ),
    GoRoute(
      path: '/addexpense',
      builder: (context, state) => const AddExpenseScreen(),
    ),
    GoRoute(
      path: '/purchase_check',
      builder: (context, state) => const PurchaseCheckScreen(),
    ),
  ],
);