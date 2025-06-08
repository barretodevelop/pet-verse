// File: lib/presentation/screens/settings/settings_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petverse/core/config/app_config.dart';
import 'package:petverse/core/config/theme_config.dart';
import 'package:petverse/core/enums/enums/app_enums.dart';
import 'package:petverse/core/utils/helpers.dart';
import 'package:petverse/presentation/providers/auth_provider.dart';
import 'package:petverse/presentation/providers/theme_provider.dart';
import 'package:petverse/presentation/providers/user_provider.dart';
import 'package:petverse/presentation/widgets/animations/slide_fade_animation.dart';

/// Settings screen for app configuration and user preferences
class SettingsScreen extends ConsumerStatefulWidget {
  final VoidCallback onBack;

  const SettingsScreen({
    super.key,
    required this.onBack,
  });

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();
  }

  void _initAnimations() {
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeState = ref.watch(themeProvider);
    final userGameData = ref.watch(userGameDataProvider);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: const Text(
          'Settings',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
          ),
          onPressed: widget.onBack,
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: ThemeConfig.primaryGradient,
          ),
        ),
      ),
      body: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: ListView(
            padding: const EdgeInsets.all(ThemeConfig.spacing16),
            children: [
              // User info section
              if (userGameData.hasUser)
                SlideFadeAnimation(
                  duration: const Duration(milliseconds: 600),
                  child: _buildUserInfoSection(context, userGameData.user!),
                ),

              const SizedBox(height: ThemeConfig.spacing20),

              // Theme section
              SlideFadeAnimation(
                duration: const Duration(milliseconds: 700),
                child: _buildThemeSection(context, themeState),
              ),

              const SizedBox(height: ThemeConfig.spacing20),

              // Preferences section
              SlideFadeAnimation(
                duration: const Duration(milliseconds: 800),
                child: _buildPreferencesSection(context),
              ),

              const SizedBox(height: ThemeConfig.spacing20),

              // Support section
              SlideFadeAnimation(
                duration: const Duration(milliseconds: 900),
                child: _buildSupportSection(context),
              ),

              const SizedBox(height: ThemeConfig.spacing20),

              // About section
              SlideFadeAnimation(
                duration: const Duration(milliseconds: 1000),
                child: _buildAboutSection(context),
              ),

              const SizedBox(height: ThemeConfig.spacing20),

              // Danger zone
              SlideFadeAnimation(
                duration: const Duration(milliseconds: 1100),
                child: _buildDangerZoneSection(context),
              ),

              const SizedBox(height: ThemeConfig.spacing40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserInfoSection(BuildContext context, user) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(ThemeConfig.spacing20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Account Information',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: ThemeConfig.spacing16),
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: ThemeConfig.primaryColor.withOpacity(0.1),
                  backgroundImage:
                      user.photoURL?.isNotEmpty == true ? NetworkImage(user.photoURL!) : null,
                  child: user.photoURL?.isEmpty != false
                      ? Text(
                          user.displayName.isNotEmpty ? user.displayName[0].toUpperCase() : 'U',
                          style: const TextStyle(
                            color: ThemeConfig.primaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: ThemeConfig.fontSize20,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: ThemeConfig.spacing16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.displayName.isNotEmpty ? user.displayName : 'Unknown User',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: ThemeConfig.spacing4),
                      Text(
                        user.email,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                      const SizedBox(height: ThemeConfig.spacing8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: ThemeConfig.spacing8,
                          vertical: ThemeConfig.spacing4,
                        ),
                        decoration: BoxDecoration(
                          color: ThemeConfig.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(ThemeConfig.borderRadius4),
                        ),
                        child: Text(
                          'Level ${user.level}',
                          style: const TextStyle(
                            fontSize: ThemeConfig.fontSize12,
                            fontWeight: FontWeight.bold,
                            color: ThemeConfig.primaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeSection(BuildContext context, ThemeState themeState) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(ThemeConfig.spacing20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Appearance',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: ThemeConfig.spacing16),

            // Theme selector
            _buildSettingsTile(
              icon: themeState.isDark ? Icons.dark_mode : Icons.light_mode,
              title: 'Theme',
              subtitle: 'Choose your preferred appearance',
              trailing: SegmentedButton<AppTheme>(
                segments: const [
                  ButtonSegment<AppTheme>(
                    value: AppTheme.light,
                    icon: Icon(Icons.light_mode, size: 16),
                    label: Text('Light', style: TextStyle(fontSize: 12)),
                  ),
                  ButtonSegment<AppTheme>(
                    value: AppTheme.dark,
                    icon: Icon(Icons.dark_mode, size: 16),
                    label: Text('Dark', style: TextStyle(fontSize: 12)),
                  ),
                  ButtonSegment<AppTheme>(
                    value: AppTheme.system,
                    icon: Icon(Icons.brightness_auto, size: 16),
                    label: Text('Auto', style: TextStyle(fontSize: 12)),
                  ),
                ],
                selected: {themeState.currentTheme},
                onSelectionChanged: (Set<AppTheme> selected) {
                  ref.read(themeProvider.notifier).setTheme(selected.first);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreferencesSection(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(ThemeConfig.spacing20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Preferences',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: ThemeConfig.spacing16),
            _buildSettingsTile(
              icon: Icons.notifications,
              title: 'Notifications',
              subtitle: 'Manage your notification preferences',
              trailing: Switch.adaptive(
                value: true,
                onChanged: (value) {
                  _showComingSoonDialog(context);
                },
                activeColor: ThemeConfig.primaryColor,
              ),
            ),
            const Divider(height: ThemeConfig.spacing24),
            _buildSettingsTile(
              icon: Icons.volume_up,
              title: 'Sound Effects',
              subtitle: 'Enable sound effects and music',
              trailing: Switch.adaptive(
                value: false,
                onChanged: (value) {
                  _showComingSoonDialog(context);
                },
                activeColor: ThemeConfig.primaryColor,
              ),
            ),
            const Divider(height: ThemeConfig.spacing24),
            _buildSettingsTile(
              icon: Icons.language,
              title: 'Language',
              subtitle: 'English (US)',
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showComingSoonDialog(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSupportSection(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(ThemeConfig.spacing20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Support',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: ThemeConfig.spacing16),
            _buildSettingsTile(
              icon: Icons.help_outline,
              title: 'Help Center',
              subtitle: 'Get help and find answers',
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showComingSoonDialog(context),
            ),
            const Divider(height: ThemeConfig.spacing24),
            _buildSettingsTile(
              icon: Icons.feedback,
              title: 'Send Feedback',
              subtitle: 'Share your thoughts with us',
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showFeedbackDialog(context),
            ),
            const Divider(height: ThemeConfig.spacing24),
            _buildSettingsTile(
              icon: Icons.star_outline,
              title: 'Rate App',
              subtitle: 'Rate us on the app store',
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showRatingDialog(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutSection(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(ThemeConfig.spacing20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'About',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: ThemeConfig.spacing16),
            _buildSettingsTile(
              icon: Icons.info_outline,
              title: 'App Version',
              subtitle: AppConfig.appVersion,
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showAppInfoDialog(context),
            ),
            const Divider(height: ThemeConfig.spacing24),
            _buildSettingsTile(
              icon: Icons.privacy_tip_outlined,
              title: 'Privacy Policy',
              subtitle: 'Read our privacy policy',
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showComingSoonDialog(context),
            ),
            const Divider(height: ThemeConfig.spacing24),
            _buildSettingsTile(
              icon: Icons.gavel,
              title: 'Terms of Service',
              subtitle: 'Read our terms of service',
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showComingSoonDialog(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDangerZoneSection(BuildContext context) {
    return Card(
      color: ThemeConfig.errorColor.withOpacity(0.05),
      child: Padding(
        padding: const EdgeInsets.all(ThemeConfig.spacing20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Account Actions',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: ThemeConfig.errorColor,
                  ),
            ),
            const SizedBox(height: ThemeConfig.spacing16),
            _buildSettingsTile(
              icon: Icons.logout,
              title: 'Sign Out',
              subtitle: 'Sign out of your account',
              titleColor: ThemeConfig.errorColor,
              trailing: const Icon(Icons.chevron_right, color: ThemeConfig.errorColor),
              onTap: () => _showSignOutDialog(context),
            ),
            const Divider(height: ThemeConfig.spacing24),
            _buildSettingsTile(
              icon: Icons.delete_forever,
              title: 'Delete Account',
              subtitle: 'Permanently delete your account',
              titleColor: ThemeConfig.errorColor,
              trailing: const Icon(Icons.chevron_right, color: ThemeConfig.errorColor),
              onTap: () => _showDeleteAccountDialog(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
    Color? titleColor,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(ThemeConfig.spacing8),
        decoration: BoxDecoration(
          color: (titleColor ?? ThemeConfig.primaryColor).withOpacity(0.1),
          borderRadius: BorderRadius.circular(ThemeConfig.borderRadius8),
        ),
        child: Icon(
          icon,
          color: titleColor ?? ThemeConfig.primaryColor,
          size: ThemeConfig.iconSize20,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: titleColor,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: Colors.grey[600],
          fontSize: ThemeConfig.fontSize12,
        ),
      ),
      trailing: trailing,
      onTap: onTap,
    );
  }

  void _showComingSoonDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.info, color: ThemeConfig.primaryColor),
            SizedBox(width: ThemeConfig.spacing8),
            Text('Coming Soon'),
          ],
        ),
        content: const Text(
          'This feature is under development and will be available in a future update.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showFeedbackDialog(BuildContext context) {
    final TextEditingController feedbackController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Send Feedback'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('We value your feedback! Let us know how we can improve.'),
            const SizedBox(height: ThemeConfig.spacing16),
            TextField(
              controller: feedbackController,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Enter your feedback here...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Helpers.showSnackBar(
                context,
                'Thank you for your feedback!',
                backgroundColor: ThemeConfig.successColor,
              );
            },
            child: const Text('Send'),
          ),
        ],
      ),
    );
  }

  void _showRatingDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rate Our App'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Enjoying Pet Game Deluxe? Rate us on the app store!'),
            SizedBox(height: ThemeConfig.spacing16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.star, color: ThemeConfig.accentColor, size: 32),
                Icon(Icons.star, color: ThemeConfig.accentColor, size: 32),
                Icon(Icons.star, color: ThemeConfig.accentColor, size: 32),
                Icon(Icons.star, color: ThemeConfig.accentColor, size: 32),
                Icon(Icons.star, color: ThemeConfig.accentColor, size: 32),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Later'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Helpers.showSnackBar(
                context,
                'Thank you! Redirecting to app store...',
                backgroundColor: ThemeConfig.successColor,
              );
            },
            child: const Text('Rate Now'),
          ),
        ],
      ),
    );
  }

  void _showAppInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(AppConfig.appName),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Version: ${AppConfig.appVersion}'),
            SizedBox(height: ThemeConfig.spacing8),
            Text(AppConfig.appDescription),
            SizedBox(height: ThemeConfig.spacing16),
            Text(
              'Developed with ❤️ using Flutter and Clean Architecture',
              style: TextStyle(
                fontStyle: FontStyle.italic,
                fontSize: ThemeConfig.fontSize12,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showSignOutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out of your account?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref.read(authProvider.notifier).signOut();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: ThemeConfig.errorColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'This action cannot be undone. All your data will be permanently deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showComingSoonDialog(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: ThemeConfig.errorColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
