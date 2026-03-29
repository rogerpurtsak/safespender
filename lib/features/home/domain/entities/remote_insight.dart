import 'budget_mood.dart';

class RemoteInsight {
  const RemoteInsight({
    required this.title,
    required this.message,
    required this.mood,
    this.gifUrl,
  });

  final String title;
  final String message;
  final BudgetMood mood;
  final String? gifUrl;
}