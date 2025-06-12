import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/app_notifier.dart';
import '../../models/user.dart';

class LoginScreen extends ConsumerStatefulWidget {
  final Function(User) onLogin;

  const LoginScreen({super.key, required this.onLogin});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();

  // Função para gerar um avatar aleatório (replicando a lógica do React)
  String _generateAvatar() {
    final avatars = ['👨', '👩', '🧑', '👱', '👨‍💻', '👩‍💻'];
    return avatars[DateTime.now().millisecond %
        avatars.length]; // Usando milissegundos para pseudo-aleatoriedade
  }

  void _handleLogin() {
    final username = _usernameController.text.trim();
    if (username.isNotEmpty) {
      final newUser = User(
        username: username,
        avatar: _generateAvatar(),
        level: 1,
        xp: 0,
        id: DateTime.now().millisecondsSinceEpoch, // ID único
      );
      widget.onLogin(newUser); // Chama o callback para logar o usuário no AppNotifier
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(appServiceProvider.select((state) => state.isDark));

    return Scaffold(
      // Background (equivalente ao min-h-screen bg-gray-900 ou bg-gradient-to-br)
      body: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A202C) : null, // gray-900
          gradient: isDark
              ? null
              : const LinearGradient(
                  colors: [
                    Color(0xFFF3E8FF), // purple-100
                    Color(0xFFE0F2FE), // blue-100
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0), // p-6
            child: Material(
              color: isDark ? const Color(0xFF2D3748) : Colors.white, // bg-gray-800 ou bg-white
              borderRadius: BorderRadius.circular(24.0), // rounded-3xl
              elevation: 12.0, // shadow-2xl
              child: Padding(
                padding: const EdgeInsets.all(32.0), // p-8
                child: Column(
                  mainAxisSize: MainAxisSize.min, // Ocupa o mínimo de espaço
                  children: [
                    // Cabeçalho
                    const Text(
                      '🐾',
                      style: TextStyle(fontSize: 48), // text-6xl (aproximado)
                    ),
                    const SizedBox(height: 16), // mb-4
                    Text(
                      'PetCare',
                      style: TextStyle(
                        fontSize: 28, // text-3xl
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? Colors.white
                            : const Color(0xFF2D3748), // text-white ou text-gray-800
                      ),
                    ),
                    const SizedBox(height: 8), // mb-2
                    Text(
                      'Entre com Google', // Mock, já que não estamos com autenticação real
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark
                            ? Colors.grey[400]
                            : Colors.grey[600], // text-gray-300 ou text-gray-600
                      ),
                    ),
                    const SizedBox(height: 32), // mb-8

                    // Campo de entrada
                    TextField(
                      controller: _usernameController,
                      decoration: InputDecoration(
                        hintText: 'Nome de usuário (demo)',
                        hintStyle: TextStyle(
                          color: isDark ? Colors.grey[500] : Colors.grey[400],
                        ),
                        filled: true,
                        fillColor: isDark
                            ? const Color(0xFF4A5568)
                            : const Color(0xFFF7FAFC), // bg-gray-700 ou bg-gray-50
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16.0), // rounded-2xl
                          borderSide: BorderSide(
                            color: isDark
                                ? const Color(0xFF4A5568)
                                : const Color(0xFFE2E8F0), // border-gray-600 ou border-gray-200
                            width: 2.0,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16.0),
                          borderSide: BorderSide(
                            color: isDark ? const Color(0xFF4A5568) : const Color(0xFFE2E8F0),
                            width: 2.0,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16.0),
                          borderSide: const BorderSide(
                            color: Color(0xFF8B5CF6), // focus:border-purple-500
                            width: 2.0,
                          ),
                        ),
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0), // p-4
                      ),
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.grey[800],
                      ),
                      onChanged: (text) {
                        setState(() {}); // Força a reconstrução para atualizar o estado do botão
                      },
                      onSubmitted: (_) => _handleLogin(), // Permite login ao pressionar Enter
                    ),
                    const SizedBox(height: 16), // space-y-4

                    // Botão de Entrar
                    ElevatedButton(
                      onPressed: _usernameController.text.trim().isEmpty ? null : _handleLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8B5CF6), // from-purple-600
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16.0), // p-4
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.0), // rounded-2xl
                        ),
                        elevation: 4.0, // shadow-lg
                        textStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold, // font-semibold
                        ),
                      ).copyWith(
                        backgroundColor: MaterialStateProperty.resolveWith<Color?>(
                          (Set<MaterialState> states) {
                            if (states.contains(MaterialState.disabled)) {
                              return const Color(0xFF8B5CF6)
                                  .withOpacity(0.5); // disabled:opacity-50
                            }
                            return const Color(0xFF8B5CF6);
                          },
                        ),
                      ),
                      child: const Text('Entrar (Demo)'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
