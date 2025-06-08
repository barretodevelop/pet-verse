// File: lib/presentation/widgets/common/custom_app_bar.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petverse/core/config/theme_config.dart';
import 'package:petverse/presentation/providers/user_provider.dart';

import 'currency_display.dart';
import 'user_profile_widget.dart';

/// Custom app bar with gradient background and user info
class CustomAppBar extends ConsumerWidget implements PreferredSizeWidget {
  final VoidCallback? onSettingsClick;
  final VoidCallback? onNotificationsClick;
  final bool showBackButton;
  final String? title;
  final String? userDisplayName;

  const CustomAppBar({
    super.key,
    this.onSettingsClick,
    this.onNotificationsClick,
    this.showBackButton = false,
    this.title,
    this.userDisplayName,
  });

  @override
  Size get preferredSize => const Size.fromHeight(180);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userGameData = ref.watch(userGameDataProvider);

    return Container(
      height: 180,
      decoration: const BoxDecoration(
        gradient: ThemeConfig.primaryGradient,
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Main app bar section
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: ThemeConfig.spacing16,
                  vertical: ThemeConfig.spacing8,
                ),
                child: Row(
                  children: [
                    // Back button or user profile
                    if (showBackButton)
                      IconButton(
                        icon: const Icon(
                          Icons.arrow_back_ios_new,
                          color: Colors.white,
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                      )
                    else
                      const Expanded(
                        child: UserProfileWidget(
                          showEmail: true,
                          avatarRadius: 22,
                        ),
                      ),

                    // Title in center if provided
                    if (title != null && showBackButton) ...[
                      Expanded(
                        child: Text(
                          title!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: ThemeConfig.fontSize20,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],

                    // Action buttons
                    if (!showBackButton)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Notifications button
                          IconButton(
                            icon: Stack(
                              children: [
                                const Icon(
                                  Icons.notifications_outlined,
                                  color: Colors.white,
                                  size: ThemeConfig.iconSize24,
                                ),
                                // Notification badge
                                Positioned(
                                  right: 0,
                                  top: 0,
                                  child: Container(
                                    padding: const EdgeInsets.all(2),
                                    decoration: BoxDecoration(
                                      color: ThemeConfig.errorColor,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    constraints: const BoxConstraints(
                                      minWidth: 12,
                                      minHeight: 12,
                                    ),
                                    child: const Text(
                                      '2',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 8,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            onPressed: onNotificationsClick ?? () => _showNotifications(context),
                            tooltip: 'Notifications',
                          ),

                          // Settings button
                          IconButton(
                            icon: const Icon(
                              Icons.settings_outlined,
                              color: Colors.white,
                              size: ThemeConfig.iconSize24,
                            ),
                            onPressed: onSettingsClick ?? () => _showSettings(context),
                            tooltip: 'Settings',
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),

            // Currency status bar
            if (!showBackButton && userGameData.hasUser)
              Container(
                height: 40,
                padding: const EdgeInsets.symmetric(
                  horizontal: ThemeConfig.spacing16,
                  vertical: ThemeConfig.spacing8,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.15),
                  border: Border(
                    top: BorderSide(
                      color: Colors.white.withOpacity(0.1),
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    CurrencyDisplay(
                      icon: '💰',
                      value: userGameData.user!.coins,
                      color: ThemeConfig.coinsColor,
                    ),
                    CurrencyDisplay(
                      icon: '💎',
                      value: userGameData.user!.gems,
                      color: ThemeConfig.gemsColor,
                    ),
                    CurrencyDisplay(
                      icon: '⭐',
                      value: userGameData.user!.totalXp,
                      color: ThemeConfig.xpColor,
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showNotifications(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Notifications'),
        content: const Text('No new notifications'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showSettings(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(ThemeConfig.borderRadius20),
        ),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(ThemeConfig.spacing20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: ThemeConfig.spacing20),
            const Text(
              'Settings',
              style: TextStyle(
                fontSize: ThemeConfig.fontSize20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: ThemeConfig.spacing20),
            ListTile(
              leading: const Icon(Icons.palette),
              title: const Text('Theme'),
              onTap: () {
                Navigator.pop(context);
                // Navigate to theme settings
              },
            ),
            ListTile(
              leading: const Icon(Icons.notifications),
              title: const Text('Notifications'),
              onTap: () {
                Navigator.pop(context);
                // Navigate to notification settings
              },
            ),
            const SizedBox(height: ThemeConfig.spacing20),
          ],
        ),
      ),
    );
  }
}
