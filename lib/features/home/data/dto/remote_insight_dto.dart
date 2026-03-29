import '../../domain/entities/budget_mood.dart';
import '../../domain/entities/remote_insight.dart';

class RemoteInsightDto {
  const RemoteInsightDto({
    required this.title,
    required this.message,
    required this.mood,
    this.gifUrl,
  });

  final String title;
  final String message;
  final String mood;
  final String? gifUrl;

  factory RemoteInsightDto.fromJson(Map<String, dynamic> json) {
    return RemoteInsightDto(
      title: json['title'] as String,
      message: json['message'] as String,
      mood: json['mood'] as String,
      gifUrl: json['gifUrl'] as String?,
    );
  }

  RemoteInsight toDomain() {
    return RemoteInsight(
      title: title,
      message: message,
      mood: _parseMood(mood),
      gifUrl: gifUrl,
    );
  }

  static BudgetMood _parseMood(String raw) {
    switch (raw) {
      case 'good':
        return BudgetMood.good;
      case 'medium':
        return BudgetMood.medium;
      case 'critical':
        return BudgetMood.critical;
      default:
        return BudgetMood.good;
    }
  }
}
