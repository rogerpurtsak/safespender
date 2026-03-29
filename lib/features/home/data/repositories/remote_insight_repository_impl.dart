import '../../domain/entities/budget_mood.dart';
import '../../domain/entities/remote_insight.dart';
import '../../domain/repositories/remote_insight_repository.dart';
import '../datasources/remote_insight_data_source.dart';

class RemoteInsightRepositoryImpl implements RemoteInsightRepository {
  const RemoteInsightRepositoryImpl(this._dataSource);

  final RemoteInsightDataSource _dataSource;

  @override
  Future<RemoteInsight> fetchInsight(BudgetMood mood) async {
    final dto = await _dataSource.fetchInsight(mood);
    return dto.toDomain();
  }
}
