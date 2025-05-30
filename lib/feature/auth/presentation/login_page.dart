import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:petverse/feature/auth/providers/authentication_provider.dart';
import 'package:petverse/feature/auth/state/authentication_state.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _displayNameController =
      TextEditingController(); // Novo controller para o nome de exibição
  bool _isLogin = true; // true para Login, false para Cadastro
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _displayNameController
        .dispose(); // Não esqueça de liberar o novo controller
    super.dispose();
  }

  Future<void> _submit() async {
    // Valida todos os campos do formulário
    if (!_formKey.currentState!.validate()) {
      return; // Se a validação falhar, para a execução.
    }

    // Acessa a instância do AuthenticationNotifier para chamar os métodos
    final controller = ref.read(authenticationNotifierProvider.notifier);

    // Lógica condicional para Login ou Cadastro
    if (_isLogin) {
      await controller.signInWithEmail(
        email: _emailController.text.trim(), // Remove espaços em branco
        password: _passwordController.text.trim(),
      );
    } else {
      // No modo de cadastro, chama createAccount e passa o nome de exibição
      await controller.createAccount(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        displayName: _displayNameController.text.trim(),
      );
    }
  }

  Future<void> _signInWithGoogle() async {
    // Chama o método de login com Google do seu notifier
    await ref.read(authenticationNotifierProvider.notifier).signInWithGoogle();
  }

  @override
  Widget build(BuildContext context) {
    // Observa o estado da autenticação para reconstruir a UI quando houver mudanças
    final authState = ref.watch(authenticationNotifierProvider);

    // Listener para lidar com efeitos colaterais, como mostrar SnackBar de erro ou navegar
    ref.listen<AuthenticationState>(
      authenticationNotifierProvider,
      (previousState, newState) {
        // --- Lógica de Erros ---
        // Verifica se o novo estado tem um erro e se esse erro é diferente do estado anterior.
        // Isso evita que a SnackBar seja exibida múltiplas vezes para o mesmo erro.
        if (newState.error != null && previousState?.error != newState.error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(newState
                  .error!), // O Notifier já retorna a mensagem de erro traduzida
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 4), // Duração da SnackBar
            ),
          );
        }

        // --- Lógica de Sucesso (Navegação) ---
        // Se o usuário não estava autenticado e agora está, navegue para a próxima tela.
        if (newState.isAuthenticated &&
            !(previousState?.isAuthenticated ?? false)) {
          // Exemplo de navegação para a tela 'home'. Ajuste conforme seu sistema de roteamento.
          // Por exemplo, usando GoRouter: context.go('/home');
          // Ou com Navigator.pushReplacement:
          // Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const HomePage()));
          print(
              'Usuário logado/cadastrado com sucesso: ${newState.userModel?.displayName}');
          // Adicione sua navegação aqui
        }
      },
    );

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo do PetVerse
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.pets,
                      size: 70,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Título da Aplicação
                  Text(
                    'PetVerse',
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _isLogin ? 'Bem-vindo de volta!' : 'Crie sua conta',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 32),

                  // Campo de Nome de Exibição (apenas para cadastro)
                  if (!_isLogin) ...[
                    TextFormField(
                      controller: _displayNameController,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                        labelText: 'Nome de Exibição',
                        prefixIcon: const Icon(Icons.person_outline),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, insira seu nome de exibição';
                        }
                        if (value.length < 3) {
                          return 'Nome deve ter pelo menos 3 caracteres';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Campo de Email
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      prefixIcon: const Icon(Icons.email_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, insira seu email';
                      }
                      // Regex simples para validação de formato de email
                      if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                        return 'Email inválido';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Campo de Senha
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: 'Senha',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() => _obscurePassword = !_obscurePassword);
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, insira sua senha';
                      }
                      if (value.length < 6) {
                        return 'Senha deve ter pelo menos 6 caracteres';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // Botão Principal (Login ou Criar Conta)
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      // Desabilita o botão enquanto uma operação está em andamento
                      onPressed: authState.isLoading ? null : _submit,
                      child: authState.isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors
                                      .white), // Indicador branco para contraste
                            )
                          : Text(
                              _isLogin ? 'Entrar' : 'Criar Conta',
                              style: const TextStyle(fontSize: 16),
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Botão para alternar entre Login e Cadastro
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _isLogin = !_isLogin;
                        // Limpa os campos quando alterna entre login/cadastro
                        _emailController.clear();
                        _passwordController.clear();
                        _displayNameController.clear();
                        _formKey.currentState
                            ?.reset(); // Reseta a validação visual
                      });
                    },
                    child: Text(
                      _isLogin
                          ? 'Não tem conta? Criar agora'
                          : 'Já tem conta? Fazer login',
                    ),
                  ),

                  // Divisor visual
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      const Expanded(child: Divider()),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'ou',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ),
                      const Expanded(child: Divider()),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Botão de Login com Google
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton.icon(
                      onPressed: authState.isLoading ? null : _signInWithGoogle,
                      icon: SvgPicture.network(
                        'https://www.gstatic.com/firebasejs/ui/2.0.0/images/auth/google.svg', // Imagem do Google
                        height: 24,
                        width: 24,
                      ),
                      label: const Text(
                        'Continuar com Google',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
