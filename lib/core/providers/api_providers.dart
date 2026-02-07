import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/services/api_service.dart';
import '../../data/models/user_model.dart';
import '../../data/services/google_auth_service.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/detection_repository.dart';
import '../../data/repositories/stats_repository.dart';
import '../../data/repositories/gamification_repository.dart';
import '../../data/repositories/chat_repository.dart';
import '../../data/repositories/guardian_repository.dart';


final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService();
});

final googleAuthServiceProvider = Provider<GoogleAuthService>((ref) {
  return GoogleAuthService();
});


final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return AuthRepository(apiService);
});

final detectionRepositoryProvider = Provider<DetectionRepository>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return DetectionRepository(apiService);
});

final statsRepositoryProvider = Provider<StatsRepository>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return StatsRepository(apiService);
});


final gamificationRepositoryProvider = Provider<GamificationRepository>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return GamificationRepository(apiService);
});


final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return ChatRepository(apiService);
});


final guardianRepositoryProvider = Provider<GuardianRepository>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return GuardianRepository(apiService);
});


final currentUserProvider = FutureProvider<UserModel>((ref) async {
  final authRepo = ref.watch(authRepositoryProvider);
  return await authRepo.getCurrentUser();
});
