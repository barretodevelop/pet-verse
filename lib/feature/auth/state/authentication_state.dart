// --- Authentication State ---
// Define o estado da autenticação (o que a UI vai observar).
import 'package:firebase_auth/firebase_auth.dart';
import 'package:petverse/core/model/user_model.dart';

class AuthenticationState {
  final User? user; // O objeto User do Firebase Authentication
  final UserModel? userModel; // O modelo de dados do usuário salvo no Firestore
  final bool isLoading; // Indica se uma operação está em andamento
  final String? error; // Mensagem de erro, se houver

  const AuthenticationState({
    this.user,
    this.userModel,
    this.isLoading = true,
    this.error,
  });

  bool get isAuthenticated => user != null;

  AuthenticationState copyWith({
    User? user,
    UserModel? userModel,
    bool? isLoading,
    String? error,
  }) {
    return AuthenticationState(
      user: user ?? this.user,
      userModel: userModel ?? this.userModel,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}
