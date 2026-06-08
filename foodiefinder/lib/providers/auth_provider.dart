import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/user.dart';
import '../repositories/auth_repository.dart';

part 'auth_provider.g.dart';

@riverpod
AuthRepository authRepository(AuthRepositoryRef ref) {
  return AuthRepository();
}

@riverpod
class AuthNotifier extends _$AuthNotifier {
  @override
  User? build() {
    return null; // Will be initialized from cache/API later
  }

  Future<void> login(String email, String password) async {
    final result = await ref.read(authRepositoryProvider).login(email, password);
    state = result.user;
  }

  Future<void> loadProfile() async {
    final user = await ref.read(authRepositoryProvider).getProfile();
    state = user;
  }

  Future<void> register(String name, String email, String password) async {
    await ref.read(authRepositoryProvider).register(name, email, password);
  }

  Future<void> logout() async {
    await ref.read(authRepositoryProvider).logout();
    state = null;
  }

  void setUser(User user) {
    state = user;
  }
}
