import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/dio_provider.dart';
import '../../data/datasources/remote_insight_data_source.dart';
import '../../data/repositories/remote_insight_repository_impl.dart';
import '../../domain/entities/remote_insight.dart';
import '../../domain/repositories/remote_insight_repository.dart';
import '../../domain/services/budget_mood_evaluator.dart';
import 'home_summary_provider.dart';

final budgetMoodEvaluatorProvider = Provider<BudgetMoodEvaluator>(
  (_) => BudgetMoodEvaluator(),
);

final remoteInsightDataSourceProvider = Provider<RemoteInsightDataSource>(
  (ref) => DioRemoteInsightDataSource(ref.read(dioProvider)),
);

final remoteInsightRepositoryProvider = Provider<RemoteInsightRepository>((ref) {
  return RemoteInsightRepositoryImpl(
    ref.read(remoteInsightDataSourceProvider),
  );
});


final remoteInsightProvider = FutureProvider<RemoteInsight?>((ref) async {
  final summaryAsync = ref.watch(homeSummaryProvider);
  final summary = summaryAsync.value?.summary;
  if (summary == null) return null;

  final mood = ref.read(budgetMoodEvaluatorProvider)
      .evaluate(summary.categorySummaries);

  final repository = ref.read(remoteInsightRepositoryProvider);
  return repository.fetchInsight(mood);
});
