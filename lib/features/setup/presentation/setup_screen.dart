import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SetupScreen extends StatelessWidget {
	const SetupScreen({super.key});

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			appBar: AppBar(
				title: const Text('Setup'),
			),
			body: Center(
				child: ElevatedButton(
					onPressed: () => context.go('/'),
					child: const Text('Back to Home'),
				),
			),
		);
	}
}

