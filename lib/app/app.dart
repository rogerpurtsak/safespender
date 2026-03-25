import 'package:flutter/material.dart';
import 'package:safespender/app/router.dart';

import '/router.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: appRouter,
    );
  }
}