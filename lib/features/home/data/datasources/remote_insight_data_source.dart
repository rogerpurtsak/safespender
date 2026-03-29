import 'dart:convert';

import 'package:dio/dio.dart';

import '../../domain/entities/budget_mood.dart';
import '../dto/remote_insight_dto.dart';

abstract interface class RemoteInsightDataSource {
  Future<RemoteInsightDto> fetchInsight(BudgetMood mood);
}

class DioRemoteInsightDataSource implements RemoteInsightDataSource {
  const DioRemoteInsightDataSource(this._dio);

  final Dio _dio;

  static const _urls = {
    BudgetMood.good:
        'https://gist.githubusercontent.com/rogerpurtsak/4382542916c7f25d005312792e35898d/raw',
    BudgetMood.medium:
        'https://gist.githubusercontent.com/rogerpurtsak/1377f8d620ec67cdfcab08cc83f0b23e/raw',
    BudgetMood.critical:
        'https://gist.githubusercontent.com/rogerpurtsak/55afcd265b7809eaad42deed43f7fb42/raw',
  };

  @override
  Future<RemoteInsightDto> fetchInsight(BudgetMood mood) async {
    final response = await _dio.get<String>(_urls[mood]!);
    final json = jsonDecode(response.data!) as Map<String, dynamic>;
    return RemoteInsightDto.fromJson(json);
  }
}
