import '../models/message_model.dart';
import '../services/api_service.dart';

class ChatRepository {
  final ApiService _apiService;

  ChatRepository(this._apiService);

  Future<Map<String, MessageModel>> sendMessage(String message) async {
    try {
      final response = await _apiService.sendChatMessage(message);
      return {
        'userMessage': MessageModel.fromJson(response['userMessage']),
        'miraResponse': MessageModel.fromJson(response['miraResponse']),
      };
    } catch (e) {
      throw Exception('Erreur envoi message: ${e.toString()}');
    }
  }

  Future<List<MessageModel>> getHistory() async {
    try {
      final response = await _apiService.getChatHistory();
      return response.map((json) => MessageModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Erreur historique chat: ${e.toString()}');
    }
  }

  Future<void> clearHistory() async {
    try {
      await _apiService.clearChatHistory();
    } catch (e) {
      throw Exception('Erreur réinitialisation chat: ${e.toString()}');
    }
  }
}
