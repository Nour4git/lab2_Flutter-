import 'package:appwrite/appwrite.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'appwrite_config.dart';

class AuthService {
  final Client _client = getClient();
  late final Account _account;

  AuthService() {
    _account = Account(_client);
  }

  // S'inscrire
  Future<void> register(String email, String password, String name) async {
    try {
      await _account.create(
        userId: ID.unique(),
        email: email,
        password: password,
        name: name,
      );
      print('✅ User registered successfully: $email');
    } catch (e) {
      print('❌ Error during registration: $e');
      throw e;
    }
  }

  // Se connecter
  Future<dynamic> login(String email, String password) async {
    try {
      final session = await _account.createEmailSession(
        email: email,
        password: password,
      );
      print('✅ User logged in successfully: $email');
      return session;
    } catch (e) {
      print('❌ Error during login: $e');
      throw e;
    }
  }

  // Se déconnecter
  Future<void> logout() async {
    try {
      await _account.deleteSession(sessionId: 'current');
      print('✅ User logged out successfully');
    } catch (e) {
      print('❌ Error during logout: $e');
      throw e;
    }
  }

  // Vérifier si l'utilisateur est connecté
  Future<dynamic> getCurrentUser() async {
    try {
      final user = await _account.get();
      print('✅ Current user: ${user.email}');
      return user;
    } catch (e) {
      print('❌ Error getting current user: $e');
      return null;
    }
  }
}