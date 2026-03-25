import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('yoyoyoyo')
      ),
      body: Center(
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () => context.go('/addexpense'),
              child: const Text('go to settings'),
        ),
            ElevatedButton(
              onPressed: () => context.go('/settings'),
              child: const Text('go to settings'),
        ),
        ],
        )
      ),
    );  
  }
}