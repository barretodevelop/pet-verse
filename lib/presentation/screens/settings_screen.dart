// lib/presentation/screens/settings_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petverse/core/service/settings_service.dart';
import 'package:petverse/data/models/user_currency.dart';
import 'package:petverse/presentation/providers/currency_provider.dart';
import 'package:petverse/presentation/providers/settings_provider.dart';
import 'package:petverse/presentation/providers/theme_provider.dart';
import 'package:url_launcher/url_launcher.dart';

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

/// Tela de configurações completa e moderna com Firebase
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
    final userSettings = ref.watch(userSettingsStreamProvider);
    final settingsActions = ref.watch(settingsActionsProvider);

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
              child: userSettings.when(
                data: (settings) => _buildBody(isLightTheme, userCurrency, settings),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => Center(
                  child: Text('Erro ao carregar configurações: $error'),
                ),
              ),
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
  Widget _buildBody(bool isLightTheme, UserCurrency userCurrency, UserSettings settings) {
    final settingsActions = ref.watch(settingsActionsProvider);

    // Mostra loading ou erro se houver
    if (settingsActions is AsyncLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Perfil do usuário
              _buildUserProfile(isLightTheme, userCurrency, settings),
              const SizedBox(height: 24),

              // Seções de configurações
              _buildSettingsSection(
                'Aparência',
                Icons.palette_outlined,
                [
                  _buildThemeSelector(isLightTheme, settings.themeMode),
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
                    settings.notificationsEnabled,
                    (value) => _updateNotificationSettings(enabled: value),
                    isLightTheme,
                  ),
                  _buildSwitchTile(
                    'Sons',
                    'Reproduzir sons para notificações',
                    settings.soundEnabled,
                    (value) => _updateNotificationSettings(sound: value),
                    isLightTheme,
                    enabled: settings.notificationsEnabled,
                  ),
                  _buildSwitchTile(
                    'Vibração',
                    'Vibrar no recebimento de notificações',
                    settings.vibrationEnabled,
                    (value) => _updateNotificationSettings(vibration: value),
                    isLightTheme,
                    enabled: settings.notificationsEnabled,
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
                    settings.analyticsEnabled,
                    (value) => _updatePrivacySettings(analytics: value),
                    isLightTheme,
                  ),
                  _buildSwitchTile(
                    'Relatórios de Erro',
                    'Enviar relatórios de erro automaticamente',
                    settings.crashReportsEnabled,
                    (value) => _updatePrivacySettings(crashReports: value),
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
                    'Sair da Conta',
                    'Fazer logout do aplicativo',
                    Icons.logout,
                    () => _showLogoutDialog(),
                    isLightTheme,
                    isDestructive: true,
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
        ),

        // Mensagem de erro se houver
        if (settingsActions is AsyncError)
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: Material(
              elevation: 6,
              borderRadius: BorderRadius.circular(8),
              color: Colors.red[600],
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    const Icon(Icons.error, color: Colors.white),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        settingsActions.error.toString(),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  /// Constrói o perfil do usuário
  Widget _buildUserProfile(bool isLightTheme, UserCurrency userCurrency, UserSettings settings) {
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
              border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
            ),
            child: settings.profileImageUrl != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.network(
                      settings.profileImageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.person,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                  )
                : const Icon(
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
                Text(
                  settings.displayName,
                  style: const TextStyle(
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
            onPressed: () => _editProfile(settings),
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
  Widget _buildThemeSelector(bool isLightTheme, ThemeMode currentTheme) {
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
                  () => _updateTheme(ThemeMode.light),
                  isLightTheme,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildThemeOption(
                  'Escuro',
                  Icons.dark_mode,
                  currentTheme == ThemeMode.dark,
                  () => _updateTheme(ThemeMode.dark),
                  isLightTheme,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildThemeOption(
                  'Sistema',
                  Icons.brightness_auto,
                  currentTheme == ThemeMode.system,
                  () => _updateTheme(ThemeMode.system),
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
    bool isLightTheme, {
    bool enabled = true,
  }) {
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
                    color: enabled
                        ? (isLightTheme ? Colors.grey[800] : Colors.grey[100])
                        : (isLightTheme ? Colors.grey[400] : Colors.grey[600]),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: enabled
                        ? (isLightTheme ? Colors.grey[600] : Colors.grey[400])
                        : (isLightTheme ? Colors.grey[400] : Colors.grey[600]),
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: enabled ? onChanged : null,
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
                          : (isLightTheme ? Colors.grey[800] : Colors.grey[100]),
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

  /// Atualiza o tema
  void _updateTheme(ThemeMode themeMode) {
    ref.read(settingsActionsProvider.notifier).updateTheme(themeMode);
  }

  /// Atualiza configurações de notificação
  void _updateNotificationSettings({bool? enabled, bool? sound, bool? vibration}) {
    ref.read(settingsActionsProvider.notifier).updateNotifications(
          enabled: enabled,
          sound: sound,
          vibration: vibration,
        );
  }

  /// Atualiza configurações de privacidade
  void _updatePrivacySettings({bool? analytics, bool? crashReports}) {
    ref.read(settingsActionsProvider.notifier).updatePrivacy(
          analytics: analytics,
          crashReports: crashReports,
        );
  }

  /// Edita o perfil
  void _editProfile(UserSettings currentSettings) {
    showDialog(
      context: context,
      builder: (context) => _EditProfileDialog(
        currentName: currentSettings.displayName,
        onSave: (newName) {
          ref.read(settingsActionsProvider.notifier).updateProfile(
                displayName: newName,
              );
        },
      ),
    );
  }

  /// Mostra diálogo de logout
  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sair da Conta'),
        content: const Text('Tem certeza que deseja sair da sua conta?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await ref.read(settingsActionsProvider.notifier).logout();
              // Navegar para tela de login será feito pelo sistema de navegação
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Sair'),
          ),
        ],
      ),
    );
  }

  /// Mostra diálogo de ajuda
  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ajuda'),
        content:
            const Text('Para suporte, entre em contato conosco pelo email: suporte@petadote.com'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  /// Abre política de privacidade
  void _openPrivacyPolicy() async {
    final url = Uri.parse('https://petadote.com/privacy');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  /// Exporta dados do usuário
  void _exportUserData() async {
    await ref.read(settingsActionsProvider.notifier).exportUserData(context);
  }

  /// Mostra diálogo de exclusão de conta
  void _showDeleteAccountDialog() async {
    // Verifica se pode deletar
    final canDelete = await ref.read(canDeleteAccountProvider.future);

    if (!canDelete && mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Não é possível excluir'),
          content: const Text(
            'Você não pode excluir sua conta enquanto tiver pets adotados ou solicitações de adoção ativas.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Entendi'),
            ),
          ],
        ),
      );
      return;
    }

    if (mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Excluir Conta'),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ATENÇÃO: Esta ação é irreversível!',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Ao excluir sua conta:\n'
                '• Todos os seus dados serão permanentemente apagados\n'
                '• Você perderá acesso a todos os seus pets\n'
                '• Suas moedas e progresso serão perdidos\n'
                '• Esta ação NÃO pode ser desfeita',
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();

                // Confirma novamente
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Última confirmação'),
                    content: const Text(
                      'Digite "EXCLUIR" para confirmar a exclusão da conta:',
                    ),
                    actions: [
                      TextField(
                        onSubmitted: (value) {
                          Navigator.of(context).pop(value == 'EXCLUIR');
                        },
                      ),
                    ],
                  ),
                );

                if (confirm == true) {
                  final deleted = await ref.read(settingsActionsProvider.notifier).deleteAccount();

                  if (deleted) {
                    // Navegar para tela de login será feito pelo sistema
                  }
                }
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Excluir Permanentemente'),
            ),
          ],
        ),
      );
    }
  }

  /// Abre termos de uso
  void _openTermsOfService() async {
    final url = Uri.parse('https://petadote.com/terms');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  /// Avalia o app
  void _rateApp() async {
    // Implementar redirecionamento para loja de apps
    final url = Uri.parse('https://play.google.com/store/apps/details?id=com.petadote');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }
}

/// Diálogo para editar perfil
class _EditProfileDialog extends StatefulWidget {
  final String currentName;
  final Function(String) onSave;

  const _EditProfileDialog({
    required this.currentName,
    required this.onSave,
  });

  @override
  State<_EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends State<_EditProfileDialog> {
  late TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.currentName);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Editar Perfil'),
      content: TextField(
        controller: _nameController,
        decoration: const InputDecoration(
          labelText: 'Nome de exibição',
          hintText: 'Digite seu nome',
        ),
        autofocus: true,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        TextButton(
          onPressed: () {
            if (_nameController.text.trim().isNotEmpty) {
              widget.onSave(_nameController.text.trim());
              Navigator.of(context).pop();
            }
          },
          child: const Text('Salvar'),
        ),
      ],
    );
  }
}
