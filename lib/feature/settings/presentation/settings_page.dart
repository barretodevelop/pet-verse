import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:petverse/core/model/user_settings.dart';
import 'package:petverse/feature/auth/providers/authentication_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Provider
final settingsProvider =
    StateNotifierProvider<SettingsNotifier, UserSettings>((ref) {
  return SettingsNotifier();
});

// Notifier
class SettingsNotifier extends StateNotifier<UserSettings> {
  SettingsNotifier() : super(UserSettings.defaultSettings()) {
    _loadSettings();
  }

  static const String _settingsKey = 'user_settings';

  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final settingsJson = prefs.getString(_settingsKey);
      if (settingsJson != null) {
        state = UserSettings.fromJson(settingsJson);
      }
    } catch (e) {
      // Se houver erro, mantém configurações padrão
      state = UserSettings.defaultSettings();
    }
  }

  Future<void> _saveSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_settingsKey, state.toJson());
    } catch (e) {
      // Tratar erro de salvamento se necessário
    }
  }

  // Notification Settings
  Future<void> updateNotificationSetting(String setting, bool value) async {
    NotificationSettings notifications;

    switch (setting) {
      case 'feeding':
        notifications = state.notifications.copyWith(feeding: value);
        break;
      case 'playing':
        notifications = state.notifications.copyWith(playing: value);
        break;
      case 'cleaning':
        notifications = state.notifications.copyWith(cleaning: value);
        break;
      case 'luckyHour':
        notifications = state.notifications.copyWith(luckyHour: value);
        break;
      case 'collaboration':
        notifications = state.notifications.copyWith(collaboration: value);
        break;
      case 'missions':
        notifications = state.notifications.copyWith(missions: value);
        break;
      case 'achievements':
        notifications = state.notifications.copyWith(achievements: value);
        break;
      case 'social':
        notifications = state.notifications.copyWith(social: value);
        break;
      default:
        return;
    }

    state = state.copyWith(notifications: notifications);
    await _saveSettings();
  }

  // Privacy Settings
  Future<void> updatePrivacySetting(String setting, bool value) async {
    PrivacySettings privacy;

    switch (setting) {
      case 'showOnlineStatus':
        privacy = state.privacy.copyWith(showOnlineStatus: value);
        break;
      case 'allowCollaboration':
        privacy = state.privacy.copyWith(allowCollaboration: value);
        break;
      case 'showInLeaderboards':
        privacy = state.privacy.copyWith(showInLeaderboards: value);
        break;
      case 'allowFriendRequests':
        privacy = state.privacy.copyWith(allowFriendRequests: value);
        break;
      default:
        return;
    }

    state = state.copyWith(privacy: privacy);
    await _saveSettings();
  }

  // Gameplay Settings
  Future<void> updateGameplaySetting(String setting, dynamic value) async {
    GameplaySettings gameplay;

    switch (setting) {
      case 'autoSave':
        gameplay = state.gameplay.copyWith(autoSave: value as bool);
        break;
      case 'soundEffects':
        gameplay = state.gameplay.copyWith(soundEffects: value as bool);
        break;
      case 'animations':
        gameplay = state.gameplay.copyWith(animations: value as bool);
        break;
      case 'hapticFeedback':
        gameplay = state.gameplay.copyWith(hapticFeedback: value as bool);
        break;
      case 'volume':
        gameplay = state.gameplay.copyWith(volume: value as double);
        break;
      default:
        return;
    }

    state = state.copyWith(gameplay: gameplay);
    await _saveSettings();
  }

  // Reset to defaults
  Future<void> resetToDefaults() async {
    state = UserSettings.defaultSettings();
    await _saveSettings();
  }
}

// Settings Page
class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileSection(context),
            SizedBox(height: 24.h),
            _buildNotificationsSection(context, ref, settings.notifications),
            SizedBox(height: 24.h),
            _buildPrivacySection(context, ref, settings.privacy),
            SizedBox(height: 24.h),
            _buildGameplaySection(context, ref, settings.gameplay),
            SizedBox(height: 24.h),
            _buildAboutSection(context, ref),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: Icon(
          Icons.arrow_back,
          color: const Color(0xFF0F172A),
          size: 24.sp,
        ),
      ),
      title: Text(
        'Configurações',
        style: TextStyle(
          fontSize: 20.sp,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF0F172A),
        ),
      ),
    );
  }

  Widget _buildProfileSection(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF3B82F6),
            Color(0xFF1E40AF),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        children: [
          Container(
            width: 60.w,
            height: 60.w,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2.w),
            ),
            child: Center(
              child: Text(
                'GA', // Guardian Azul
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Guardian Azul',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Lv.12 • guardian.azul@petverse.com',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              // TODO: Editar perfil
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Editar perfil em breve...'),
                  backgroundColor: Color(0xFF3B82F6),
                ),
              );
            },
            icon: Icon(
              Icons.edit,
              color: Colors.white,
              size: 20.sp,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.2, end: 0);
  }

  Widget _buildNotificationsSection(
      BuildContext context, WidgetRef ref, NotificationSettings notifications) {
    return _buildSettingsSection(
      title: 'Notificações',
      icon: Icons.notifications_outlined,
      children: [
        _buildSettingTile(
          context: context,
          ref: ref,
          title: 'Alimentação',
          subtitle: 'Quando pets estão com fome',
          icon: Icons.restaurant,
          value: notifications.feeding,
          onChanged: (value) => ref
              .read(settingsProvider.notifier)
              .updateNotificationSetting('feeding', value),
        ),
        _buildSettingTile(
          context: context,
          ref: ref,
          title: 'Brincadeiras',
          subtitle: 'Lembrete para interagir com pets',
          icon: Icons.sports_tennis,
          value: notifications.playing,
          onChanged: (value) => ref
              .read(settingsProvider.notifier)
              .updateNotificationSetting('playing', value),
        ),
        _buildSettingTile(
          context: context,
          ref: ref,
          title: 'Limpeza',
          subtitle: 'Quando pets precisam de higiene',
          icon: Icons.cleaning_services,
          value: notifications.cleaning,
          onChanged: (value) => ref
              .read(settingsProvider.notifier)
              .updateNotificationSetting('cleaning', value),
        ),
        _buildSettingTile(
          context: context,
          ref: ref,
          title: 'Hora da Sorte',
          subtitle: 'Bônus especiais disponíveis',
          icon: Icons.star,
          value: notifications.luckyHour,
          onChanged: (value) => ref
              .read(settingsProvider.notifier)
              .updateNotificationSetting('luckyHour', value),
        ),
        _buildSettingTile(
          context: context,
          ref: ref,
          title: 'Colaboração',
          subtitle: 'Atividades de co-guardiões',
          icon: Icons.people,
          value: notifications.collaboration,
          onChanged: (value) => ref
              .read(settingsProvider.notifier)
              .updateNotificationSetting('collaboration', value),
        ),
        _buildSettingTile(
          context: context,
          ref: ref,
          title: 'Missões',
          subtitle: 'Novas adoções disponíveis',
          icon: Icons.assignment,
          value: notifications.missions,
          onChanged: (value) => ref
              .read(settingsProvider.notifier)
              .updateNotificationSetting('missions', value),
        ),
        _buildSettingTile(
          context: context,
          ref: ref,
          title: 'Conquistas',
          subtitle: 'Badges e recompensas',
          icon: Icons.emoji_events,
          value: notifications.achievements,
          onChanged: (value) => ref
              .read(settingsProvider.notifier)
              .updateNotificationSetting('achievements', value),
        ),
        _buildSettingTile(
          context: context,
          ref: ref,
          title: 'Social',
          subtitle: 'Novos seguidores e mensagens',
          icon: Icons.forum,
          value: notifications.social,
          onChanged: (value) => ref
              .read(settingsProvider.notifier)
              .updateNotificationSetting('social', value),
        ),
      ],
    );
  }

  Widget _buildPrivacySection(
      BuildContext context, WidgetRef ref, PrivacySettings privacy) {
    return _buildSettingsSection(
      title: 'Privacidade',
      icon: Icons.privacy_tip_outlined,
      children: [
        _buildSettingTile(
          context: context,
          ref: ref,
          title: 'Status Online',
          subtitle: 'Mostrar quando estou online',
          icon: Icons.online_prediction,
          value: privacy.showOnlineStatus,
          onChanged: (value) => ref
              .read(settingsProvider.notifier)
              .updatePrivacySetting('showOnlineStatus', value),
        ),
        _buildSettingTile(
          context: context,
          ref: ref,
          title: 'Permitir Colaboração',
          subtitle: 'Outros podem me convidar',
          icon: Icons.handshake,
          value: privacy.allowCollaboration,
          onChanged: (value) => ref
              .read(settingsProvider.notifier)
              .updatePrivacySetting('allowCollaboration', value),
        ),
        _buildSettingTile(
          context: context,
          ref: ref,
          title: 'Ranking Público',
          subtitle: 'Aparecer nos rankings',
          icon: Icons.leaderboard,
          value: privacy.showInLeaderboards,
          onChanged: (value) => ref
              .read(settingsProvider.notifier)
              .updatePrivacySetting('showInLeaderboards', value),
        ),
        _buildSettingTile(
          context: context,
          ref: ref,
          title: 'Solicitações de Amizade',
          subtitle: 'Permitir pedidos de conexão',
          icon: Icons.person_add,
          value: privacy.allowFriendRequests,
          onChanged: (value) => ref
              .read(settingsProvider.notifier)
              .updatePrivacySetting('allowFriendRequests', value),
        ),
      ],
    );
  }

  Widget _buildGameplaySection(
      BuildContext context, WidgetRef ref, GameplaySettings gameplay) {
    return _buildSettingsSection(
      title: 'Jogo',
      icon: Icons.gamepad_outlined,
      children: [
        _buildSettingTile(
          context: context,
          ref: ref,
          title: 'Salvamento Automático',
          subtitle: 'Salvar progresso automaticamente',
          icon: Icons.save,
          value: gameplay.autoSave,
          onChanged: (value) => ref
              .read(settingsProvider.notifier)
              .updateGameplaySetting('autoSave', value),
        ),
        _buildSettingTile(
          context: context,
          ref: ref,
          title: 'Efeitos Sonoros',
          subtitle: 'Sons de ações e feedback',
          icon: Icons.volume_up,
          value: gameplay.soundEffects,
          onChanged: (value) => ref
              .read(settingsProvider.notifier)
              .updateGameplaySetting('soundEffects', value),
        ),
        _buildSettingTile(
          context: context,
          ref: ref,
          title: 'Animações',
          subtitle: 'Transições e efeitos visuais',
          icon: Icons.auto_awesome,
          value: gameplay.animations,
          onChanged: (value) => ref
              .read(settingsProvider.notifier)
              .updateGameplaySetting('animations', value),
        ),
        _buildSettingTile(
          context: context,
          ref: ref,
          title: 'Vibração',
          subtitle: 'Feedback tátil do dispositivo',
          icon: Icons.vibration,
          value: gameplay.hapticFeedback,
          onChanged: (value) => ref
              .read(settingsProvider.notifier)
              .updateGameplaySetting('hapticFeedback', value),
        ),
        _buildVolumeSlider(context, ref, gameplay.volume),
      ],
    );
  }

  Widget _buildAboutSection(BuildContext context, WidgetRef ref) {
    return _buildSettingsSection(
      title: 'Sobre',
      icon: Icons.info_outline,
      children: [
        _buildActionTile(
          context: context,
          title: 'Tutorial',
          subtitle: 'Revisar como usar o app',
          icon: Icons.help_outline,
          onTap: () {
            HapticFeedback.lightImpact();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Tutorial em breve...')),
            );
          },
        ),
        _buildActionTile(
          context: context,
          title: 'Termos de Uso',
          subtitle: 'Política de privacidade e termos',
          icon: Icons.description,
          onTap: () {
            HapticFeedback.lightImpact();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Termos em breve...')),
            );
          },
        ),
        _buildActionTile(
          context: context,
          title: 'Enviar Feedback',
          subtitle: 'Sugestões e reportar problemas',
          icon: Icons.feedback,
          onTap: () {
            HapticFeedback.lightImpact();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Feedback em breve...')),
            );
          },
        ),
        _buildActionTile(
          context: context,
          title: 'Versão',
          subtitle: 'PetVerse v1.0.0',
          icon: Icons.info,
          onTap: null,
        ),
        _buildActionTile(
          context: context,
          title: 'Sair da Conta',
          subtitle: 'Fazer logout do aplicativo',
          icon: Icons.logout,
          color: const Color(0xFFEF4444),
          onTap: () => _showLogoutDialog(context, ref),
        ),
        _buildActionTile(
          context: context,
          title: 'Restaurar Padrões',
          subtitle: 'Voltar configurações originais',
          icon: Icons.restore,
          color: const Color(0xFFEF4444),
          onTap: () => _showResetDialog(context, ref),
        ),
      ],
    );
  }

  Widget _buildSettingsSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF64748B).withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(20.w),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: const Color(0xFF3B82F6),
                  size: 24.sp,
                ),
                SizedBox(width: 12.w),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
          ),
          ...children.asMap().entries.map((entry) {
            final index = entry.key;
            final child = entry.value;
            return Column(
              children: [
                if (index > 0)
                  Divider(
                    height: 1.h,
                    color: const Color(0xFFE2E8F0),
                    indent: 20.w,
                    endIndent: 20.w,
                  ),
                child,
              ],
            );
          }),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.2, end: 0);
  }

  Widget _buildSettingTile({
    required BuildContext context,
    required WidgetRef ref,
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 4.h),
      leading: Container(
        width: 40.w,
        height: 40.w,
        decoration: BoxDecoration(
          color: const Color(0xFF3B82F6).withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: const Color(0xFF3B82F6),
          size: 20.sp,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF0F172A),
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 12.sp,
          color: const Color(0xFF64748B),
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: (newValue) {
          HapticFeedback.lightImpact();
          onChanged(newValue);
        },
        activeColor: const Color(0xFF10B981),
        inactiveThumbColor: const Color(0xFF94A3B8),
        inactiveTrackColor: const Color(0xFFE2E8F0),
      ),
    );
  }

  Widget _buildVolumeSlider(
      BuildContext context, WidgetRef ref, double volume) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40.w,
                height: 40.w,
                decoration: BoxDecoration(
                  color: const Color(0xFF3B82F6).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.volume_up,
                  color: const Color(0xFF3B82F6),
                  size: 20.sp,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Volume Geral',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    Text(
                      '${(volume * 100).round()}%',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: const Color(0xFF10B981),
              inactiveTrackColor: const Color(0xFFE2E8F0),
              thumbColor: const Color(0xFF10B981),
              overlayColor: const Color(0xFF10B981).withOpacity(0.2),
              trackHeight: 4.h,
            ),
            child: Slider(
              value: volume,
              min: 0.0,
              max: 1.0,
              divisions: 10,
              onChanged: (newValue) {
                HapticFeedback.lightImpact();
                ref
                    .read(settingsProvider.notifier)
                    .updateGameplaySetting('volume', newValue);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    Color? color,
    VoidCallback? onTap,
  }) {
    final tileColor = color ?? const Color(0xFF3B82F6);

    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 4.h),
      leading: Container(
        width: 40.w,
        height: 40.w,
        decoration: BoxDecoration(
          color: tileColor.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: tileColor,
          size: 20.sp,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w600,
          color:
              onTap != null ? const Color(0xFF0F172A) : const Color(0xFF64748B),
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 12.sp,
          color: const Color(0xFF64748B),
        ),
      ),
      trailing: onTap != null
          ? Icon(
              Icons.chevron_right,
              color: const Color(0xFF94A3B8),
              size: 20.sp,
            )
          : null,
      onTap: onTap,
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Row(
          children: [
            Icon(
              Icons.logout,
              color: const Color(0xFFEF4444),
              size: 24.sp,
            ),
            SizedBox(width: 12.w),
            Text(
              'Sair da Conta',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF0F172A),
              ),
            ),
          ],
        ),
        content: Text(
          'Tem certeza que deseja sair da sua conta? Você precisará fazer login novamente para acessar o aplicativo.',
          style: TextStyle(
            fontSize: 14.sp,
            color: const Color(0xFF64748B),
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancelar',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF64748B),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              ref.read(authenticationNotifierProvider.notifier).signOut();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
              elevation: 0,
            ),
            child: Text(
              'Sair',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ).animate().scale(
            begin: const Offset(0.8, 0.8),
            end: const Offset(1.0, 1.0),
            duration: 300.ms,
            curve: Curves.easeOutBack,
          ),
    );
  }

  void _showResetDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Row(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: const Color(0xFFEF4444),
              size: 24.sp,
            ),
            SizedBox(width: 12.w),
            Text(
              'Restaurar Padrões',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF0F172A),
              ),
            ),
          ],
        ),
        content: Text(
          'Tem certeza que deseja restaurar todas as configurações para os valores padrão? Esta ação não pode ser desfeita.',
          style: TextStyle(
            fontSize: 14.sp,
            color: const Color(0xFF64748B),
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancelar',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF64748B),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref.read(settingsProvider.notifier).resetToDefaults();
              HapticFeedback.mediumImpact();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Configurações restauradas com sucesso!'),
                  backgroundColor: Color(0xFF10B981),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
              elevation: 0,
            ),
            child: Text(
              'Restaurar',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ).animate().scale(
            begin: const Offset(0.8, 0.8),
            end: const Offset(1.0, 1.0),
            duration: 300.ms,
            curve: Curves.easeOutBack,
          ),
    );
  }

  Future<void> _performLogout(BuildContext context, WidgetRef ref) async {
    try {
      HapticFeedback.mediumImpact();

      // Mostrar loading
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 16.w,
                height: 16.w,
                child: CircularProgressIndicator(
                  strokeWidth: 2.w,
                  color: Colors.white,
                ),
              ),
              SizedBox(width: 12.w),
              const Text('Saindo da conta...'),
            ],
          ),
          backgroundColor: const Color(0xFF3B82F6),
          duration: const Duration(seconds: 2),
        ),
      );

      // Limpar configurações locais (opcional)
      await ref.read(settingsProvider.notifier).resetToDefaults();

      // TODO: Integrar com authenticationNotifierProvider quando conectar Firebase
      // await ref.read(authenticationNotifierProvider.notifier).signOut();

      // Simular delay de logout
      await Future.delayed(const Duration(seconds: 1));

      // Navegar para tela de login (placeholder)
      // Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Logout realizado com sucesso!'),
          backgroundColor: Color(0xFF10B981),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao fazer logout: ${e.toString()}'),
          backgroundColor: const Color(0xFFEF4444),
        ),
      );
    }
  }
}
