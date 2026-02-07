import '../models/dashboard_stats_model.dart';
import '../services/api_service.dart';

class StatsRepository {
  final ApiService _apiService;

  StatsRepository(this._apiService);

  Future<DashboardStatsModel> getDashboardStats() async {
    try {
      final response = await _apiService.getDashboardStats();
      return DashboardStatsModel.fromJson(response);
    } catch (e) {
      throw Exception('Erreur récupération stats: ${e.toString()}');
    }
  }
}
