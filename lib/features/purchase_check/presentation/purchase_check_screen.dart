import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PurchaseCheckScreen extends StatelessWidget {
	const PurchaseCheckScreen({super.key});

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			appBar: AppBar(
				title: const Text('Purchase Check'),
			),
			body: Center(
				child: Column(
					mainAxisSize: MainAxisSize.min,
					children: [
						const Text('Purchase check screen'),
						const SizedBox(height: 12),
						ElevatedButton(
							onPressed: () => context.go('/'),
							child: const Text('Back to Home'),
						),
					],
				),
			),
		);
	}
}

