import '../models/detection_model.dart';
import '../services/api_service.dart';

class DetectionRepository {
  final ApiService _apiService;

  DetectionRepository(this._apiService);

  Future<Map<String, dynamic>> analyzeText(String text) async {
    try {
      final response = await _apiService.detectHateSpeech(text);
      return {
        'isHateSpeech': response['isHateSpeech'] ?? false,
        'confidence': response['confidence'] ?? 0.0,
        'category': response['category'],
        'explanation': response['explanation'],
      };
    } catch (e) {
      throw Exception('Erreur d\'analyse: ${e.toString()}');
    }
  }

  Future<String> reformulateText(String text) async {
    try {
      final response = await _apiService.reformulateText(text);
      return response['reformulatedText'] ?? text;
    } catch (e) {
      throw Exception('Erreur de reformulation: ${e.toString()}');
    }
  }

  Future<List<DetectionModel>> getHistory() async {
    try {
      final response = await _apiService.getUserDetections();
      return response
          .map((json) => DetectionModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Erreur de récupération historique: ${e.toString()}');
    }
  }
}
