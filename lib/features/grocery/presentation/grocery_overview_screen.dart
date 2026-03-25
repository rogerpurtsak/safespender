import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class GroceryOverviewScreen extends StatelessWidget {
  const GroceryOverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('groceryscreen'),
      )
      ,
      body: Center(
        child: Column(
          children: [
            const Text('lowk'),
            ElevatedButton(
              onPressed: () => context.go('/'),
              child: const Text('back to home'),
            ),
            ElevatedButton(
              onPressed: () => context.go('/settings'),
              child: const Text('settings?'),
            ),
          ],
        ),
      ),
    );
  }
}