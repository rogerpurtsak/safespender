enum HomeInsightTone {
  neutral,
  positive,
  warning,
  danger,
}

class HomeInsight {
  const HomeInsight({
    required this.title,
    required this.message,
    required this.tone,
  });

  final String title;
  final String message;
  final HomeInsightTone tone;
}
