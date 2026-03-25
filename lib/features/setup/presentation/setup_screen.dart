import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:safespender/features/navigation/presentation/main_shell_screen.dart';
import 'package:safespender/shared/widgets/app_bottom_nav.dart';

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
					onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => const MainShellScreen(),
              ),
            );
          },
          child: const Text('j2tka'),
				),
			),
      
		);
	}
}

