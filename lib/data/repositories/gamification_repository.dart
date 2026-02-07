import '../models/badge_model.dart';
import '../models/challenge_model.dart';
import '../models/leaderboard_entry_model.dart';
import '../services/api_service.dart';

class GamificationRepository {
  final ApiService _apiService;

  GamificationRepository(this._apiService);

  Future<List<LeaderboardEntryModel>> getLeaderboard({int limit = 10}) async {
    try {
      final response = await _apiService.getLeaderboard(limit: limit);
      return response
          .map((json) => LeaderboardEntryModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Erreur leaderboard: ${e.toString()}');
    }
  }

  Future<List<BadgeModel>> getBadges() async {
    try {
      final response = await _apiService.getUserBadges();
      return response.map((json) => BadgeModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Erreur badges: ${e.toString()}');
    }
  }

  Future<ChallengeModel?> getCurrentChallenge() async {
    try {
      final response = await _apiService.getCurrentChallenge();
      if (response['challenge'] == null) return null;
      return ChallengeModel.fromJson(response['challenge']);
    } catch (e) {
      throw Exception('Erreur challenge: ${e.toString()}');
    }
  }
}
