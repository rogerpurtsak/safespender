import '../entities/budget_mood.dart';
import '../entities/remote_insight.dart';

abstract interface class RemoteInsightRepository {
  Future<RemoteInsight> fetchInsight(BudgetMood mood);
}