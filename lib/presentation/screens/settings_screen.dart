import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petverse/data/models/user_currency.dart';
import 'package:petverse/presentation/providers/currency_provider.dart';
import 'package:petverse/presentation/providers/theme_provider.dart';

/// Seções disponíveis nas configurações
enum SettingsSection {
  appearance('Aparência', Icons.palette_outlined),
  notifications('Notificações', Icons.notifications_outlined),
  privacy('Privacidade', Icons.privacy_tip_outlined),
  account('Conta', Icons.account_circle_outlined),
  about('Sobre', Icons.info_outline);

  const SettingsSection(this.title, this.icon);
  final String title;
  final IconData icon;
}

/// Tela de configurações completa e moderna
class SettingsScreen extends ConsumerStatefulWidget {
  final VoidCallback onBack;
  final Function(String section)? onSectionTap;

  const SettingsScreen({
    super.key,
    required this.onBack,
    this.onSectionTap,
  });

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Estados das configurações
  bool _notificationsEnabled = true;
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;
  bool _analyticsEnabled = false;
  bool _crashReportsEnabled = true;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final isLightTheme = ref.watch(isLightThemeProvider);
    final userCurrency = ref.watch(userCurrencyProvider);

    return Scaffold(
      backgroundColor: isLightTheme ? Colors.grey[50] : Colors.grey[900],
      appBar: _buildAppBar(isLightTheme),
      body: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: _buildBody(isLightTheme, userCurrency),
            ),
          );
        },
      ),
    );
  }

  /// Constrói a AppBar customizada
  PreferredSizeWidget _buildAppBar(bool isLightTheme) {
    return AppBar(
      backgroundColor: isLightTheme ? Colors.white : Colors.grey[800],
      foregroundColor: isLightTheme ? Colors.grey[800] : Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios),
        onPressed: widget.onBack,
      ),
      title: const Text(
        'Configurações',
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 20,
        ),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.help_outline),
          onPressed: () => _showHelpDialog(context),
          tooltip: 'Ajuda',
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          height: 1,
          color: isLightTheme ? Colors.grey[200] : Colors.grey[700],
        ),
      ),
    );
  }

  /// Constrói o corpo principal
  Widget _buildBody(bool isLightTheme, UserCurrency userCurrency) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Perfil do usuário
          _buildUserProfile(isLightTheme, userCurrency),
          const SizedBox(height: 24),

          // Seções de configurações
          _buildSettingsSection(
            'Aparência',
            Icons.palette_outlined,
            [
              _buildThemeSelector(isLightTheme),
            ],
            isLightTheme,
          ),

          const SizedBox(height: 16),

          _buildSettingsSection(
            'Notificações',
            Icons.notifications_outlined,
            [
              _buildSwitchTile(
                'Notificações Push',
                'Receber notificações sobre pets e adoções',
                _notificationsEnabled,
                (value) => setState(() => _notificationsEnabled = value),
                isLightTheme,
              ),
              _buildSwitchTile(
                'Sons',
                'Reproduzir sons para notificações',
                _soundEnabled,
                (value) => setState(() => _soundEnabled = value),
                isLightTheme,
              ),
              _buildSwitchTile(
                'Vibração',
                'Vibrar no recebimento de notificações',
                _vibrationEnabled,
                (value) => setState(() => _vibrationEnabled = value),
                isLightTheme,
              ),
            ],
            isLightTheme,
          ),

          const SizedBox(height: 16),

          _buildSettingsSection(
            'Privacidade',
            Icons.privacy_tip_outlined,
            [
              _buildSwitchTile(
                'Análises',
                'Ajudar a melhorar o app compartilhando dados anônimos',
                _analyticsEnabled,
                (value) => setState(() => _analyticsEnabled = value),
                isLightTheme,
              ),
              _buildSwitchTile(
                'Relatórios de Erro',
                'Enviar relatórios de erro automaticamente',
                _crashReportsEnabled,
                (value) => setState(() => _crashReportsEnabled = value),
                isLightTheme,
              ),
              _buildTapTile(
                'Política de Privacidade',
                'Leia nossa política de privacidade',
                Icons.open_in_new,
                () => _openPrivacyPolicy(),
                isLightTheme,
              ),
            ],
            isLightTheme,
          ),

          const SizedBox(height: 16),

          _buildSettingsSection(
            'Conta',
            Icons.account_circle_outlined,
            [
              _buildTapTile(
                'Exportar Dados',
                'Baixar uma cópia dos seus dados',
                Icons.download,
                () => _exportUserData(),
                isLightTheme,
              ),
              _buildTapTile(
                'Excluir Conta',
                'Excluir permanentemente sua conta',
                Icons.delete_forever,
                () => _showDeleteAccountDialog(),
                isLightTheme,
                isDestructive: true,
              ),
            ],
            isLightTheme,
          ),

          const SizedBox(height: 16),

          _buildSettingsSection(
            'Sobre',
            Icons.info_outline,
            [
              _buildInfoTile('Versão', '1.0.0', isLightTheme),
              _buildTapTile(
                'Termos de Uso',
                'Leia os termos de uso do aplicativo',
                Icons.description,
                () => _openTermsOfService(),
                isLightTheme,
              ),
              _buildTapTile(
                'Avalie o App',
                'Deixe sua avaliação na loja de apps',
                Icons.star_outline,
                () => _rateApp(),
                isLightTheme,
              ),
            ],
            isLightTheme,
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  /// Constrói o perfil do usuário
  Widget _buildUserProfile(bool isLightTheme, UserCurrency userCurrency) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isLightTheme
              ? [Colors.purple[500]!, Colors.purple[700]!]
              : [Colors.purple[800]!, Colors.purple[900]!],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
              border:
                  Border.all(color: Colors.white.withOpacity(0.3), width: 2),
            ),
            child: const Icon(
              Icons.person,
              color: Colors.white,
              size: 32,
            ),
          ),

          const SizedBox(width: 16),

          // Informações do usuário
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Usuário Pet Lover',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Nível ${userCurrency.level} • ${userCurrency.coinsFormatted} coins',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),

          // Botão de editar perfil
          IconButton(
            onPressed: () => _editProfile(),
            icon: const Icon(
              Icons.edit,
              color: Colors.white,
            ),
            tooltip: 'Editar perfil',
          ),
        ],
      ),
    );
  }

  /// Constrói uma seção de configurações
  Widget _buildSettingsSection(
    String title,
    IconData icon,
    List<Widget> items,
    bool isLightTheme,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: isLightTheme ? Colors.white : Colors.grey[800],
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Cabeçalho da seção
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: isLightTheme ? Colors.purple[600] : Colors.purple[400],
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: isLightTheme ? Colors.grey[800] : Colors.grey[100],
                  ),
                ),
              ],
            ),
          ),

          // Divider
          Container(
            height: 1,
            color: isLightTheme ? Colors.grey[200] : Colors.grey[700],
          ),

          // Items
          ...items,
        ],
      ),
    );
  }

  /// Constrói o seletor de tema
  Widget _buildThemeSelector(bool isLightTheme) {
    final themeNotifier = ref.read(themeModeProvider.notifier);
    final currentTheme = ref.watch(themeModeProvider);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tema do Aplicativo',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isLightTheme ? Colors.grey[800] : Colors.grey[100],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildThemeOption(
                  'Claro',
                  Icons.light_mode,
                  currentTheme == ThemeMode.light,
                  () => themeNotifier.setTheme(ThemeMode.light),
                  isLightTheme,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildThemeOption(
                  'Escuro',
                  Icons.dark_mode,
                  currentTheme == ThemeMode.dark,
                  () => themeNotifier.setTheme(ThemeMode.dark),
                  isLightTheme,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildThemeOption(
                  'Sistema',
                  Icons.brightness_auto,
                  currentTheme == ThemeMode.system,
                  () => themeNotifier.setTheme(ThemeMode.system),
                  isLightTheme,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Constrói uma opção de tema
  Widget _buildThemeOption(
    String label,
    IconData icon,
    bool isSelected,
    VoidCallback onTap,
    bool isLightTheme,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? (isLightTheme ? Colors.purple[100] : Colors.purple[800])
              : (isLightTheme ? Colors.grey[100] : Colors.grey[700]),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? (isLightTheme ? Colors.purple[300]! : Colors.purple[600]!)
                : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected
                  ? (isLightTheme ? Colors.purple[600] : Colors.purple[400])
                  : (isLightTheme ? Colors.grey[600] : Colors.grey[400]),
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isSelected
                    ? (isLightTheme ? Colors.purple[600] : Colors.purple[400])
                    : (isLightTheme ? Colors.grey[600] : Colors.grey[400]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Constrói um item com switch
  Widget _buildSwitchTile(
    String title,
    String subtitle,
    bool value,
    Function(bool) onChanged,
    bool isLightTheme,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: isLightTheme ? Colors.grey[800] : Colors.grey[100],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: isLightTheme ? Colors.grey[600] : Colors.grey[400],
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.purple[600],
          ),
        ],
      ),
    );
  }

  /// Constrói um item clicável
  Widget _buildTapTile(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
    bool isLightTheme, {
    bool isDestructive = false,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: isDestructive
                          ? Colors.red[600]
                          : (isLightTheme
                              ? Colors.grey[800]
                              : Colors.grey[100]),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: isLightTheme ? Colors.grey[600] : Colors.grey[400],
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              icon,
              color: isDestructive
                  ? Colors.red[600]
                  : (isLightTheme ? Colors.grey[600] : Colors.grey[400]),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  /// Constrói um item de informação
  Widget _buildInfoTile(String title, String value, bool isLightTheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: isLightTheme ? Colors.grey[800] : Colors.grey[100],
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              color: isLightTheme ? Colors.grey[600] : Colors.grey[400],
            ),
          ),
        ],
      ),
    );
  }

  // Métodos de ação
  void _editProfile() {
    // Implementar edição de perfil
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Funcionalidade em desenvolvimento')),
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ajuda'),
        content: const Text(
            'Para suporte, entre em contato conosco pelo email: suporte@petadote.com'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  void _openPrivacyPolicy() {
    // Implementar abertura da política de privacidade
  }

  void _exportUserData() {
    // Implementar exportação de dados
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir Conta'),
        content: const Text(
            'Tem certeza que deseja excluir sua conta? Esta ação não pode ser desfeita.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Implementar exclusão de conta
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }

  void _openTermsOfService() {
    // Implementar abertura dos termos de uso
  }

  void _rateApp() {
    // Implementar avaliação do app
  }
}
