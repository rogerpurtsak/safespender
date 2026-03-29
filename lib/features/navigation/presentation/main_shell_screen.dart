import 'package:flutter/material.dart';
import 'package:safespender/features/grocery/presentation/grocery_overview_screen.dart';
import '../../../shared/widgets/app_bottom_nav.dart';
import '../../home/presentation/home_screen.dart';
import '../../expenses/presentation/add_expense_screen.dart';
import '../../purchase_check/presentation/purchase_check_screen.dart';
import '../../settings/presentation/settings_screen.dart';

class MainShellScreen extends StatefulWidget {
  const MainShellScreen({super.key});

  @override
  State<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends State<MainShellScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    AddExpenseScreen(),
    GroceryOverviewScreen(),
    SettingsScreen(),
    PurchaseCheckScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        }
      )
    );
  }
}