import 'package:flutter/material.dart';
import 'package:safespender/app/router.dart';
import 'package:safespender/app/theme/app_theme.dart';


class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      theme: AppTheme.lightTheme,
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
      title: 'SafeSpender',
    );
  }
}