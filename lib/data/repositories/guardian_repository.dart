import '../services/api_service.dart';

class GuardianRepository {
  final ApiService _apiService;

  GuardianRepository(this._apiService);

  Future<List<Map<String, dynamic>>> getChildren() async {
    try {
      final response = await _apiService.getLinkedChildren();
      return response.cast<Map<String, dynamic>>();
    } catch (e) {
      throw Exception('Erreur récupération enfants: ${e.toString()}');
    }
  }

  Future<Map<String, dynamic>> linkChild(String childCode) async {
    try {
      final response = await _apiService.linkChild(childCode);
      return response;
    } catch (e) {
      throw Exception('Erreur liaison enfant: ${e.toString()}');
    }
  }

  Future<Map<String, dynamic>> getChildStats(String childId) async {
    try {
      final response = await _apiService.getChildStats(childId);
      return response;
    } catch (e) {
      throw Exception('Erreur stats enfant: ${e.toString()}');
    }
  }
}
