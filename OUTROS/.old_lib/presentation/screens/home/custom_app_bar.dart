// File: lib/presentation/widgets/common/custom_app_bar.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petverse/core/config/theme_config.dart';
import 'package:petverse/presentation/providers/user_provider.dart';
import 'package:petverse/presentation/widgets/common/user_profile_widget.dart';

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
  Size get preferredSize => const Size.fromHeight(185);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userGameData = ref.watch(userGameDataProvider);

    return Container(
      height: 185,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            ThemeConfig.primaryGradient.colors.first,
            ThemeConfig.primaryGradient.colors.last.withOpacity(0.8),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            offset: const Offset(0, 4),
            blurRadius: 12,
            spreadRadius: 0,
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          children: [
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  ThemeConfig.spacing16,
                  ThemeConfig.spacing12,
                  ThemeConfig.spacing16,
                  ThemeConfig.spacing8,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (showBackButton)
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: IconButton(
                          icon: const Icon(
                            Icons.arrow_back_ios_new,
                            color: Colors.white,
                            size: 20,
                          ),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      )
                    else
                      const Expanded(
                        child: UserProfileWidget(
                          showEmail: true,
                          avatarRadius: 24,
                        ),
                      ),
                    if (title != null && showBackButton) ...[
                      Expanded(
                        child: Text(
                          title!,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: ThemeConfig.fontSize20,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                            shadows: [
                              Shadow(
                                color: Colors.black.withOpacity(0.3),
                                offset: const Offset(0, 1),
                                blurRadius: 2,
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                    if (!showBackButton)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Notifications button
                          _buildActionButton(
                            icon: Icons.notifications_outlined,
                            onPressed: onNotificationsClick ?? () => _showNotifications(context),
                            tooltip: 'Notifications',
                            showBadge: true,
                            badgeCount: '2',
                          ),

                          // Settings button
                          _buildActionButton(
                            icon: Icons.settings_outlined,
                            onPressed: onSettingsClick ?? () => _showSettings(context),
                            tooltip: 'Settings',
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),

            // Currency status bar melhorada
            if (!showBackButton && userGameData.hasUser)
              Container(
                height: 40,
                margin: const EdgeInsets.fromLTRB(
                  ThemeConfig.spacing16,
                  0,
                  ThemeConfig.spacing16,
                  ThemeConfig.spacing8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.2),
                    width: 1,
                  ),
                  // Glassmorphism effect
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      offset: const Offset(0, 2),
                      blurRadius: 8,
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: ThemeConfig.spacing12,
                    vertical: ThemeConfig.spacing4,
                  ),
                  // child: Row(
                  //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  //   children: [
                  //     Expanded(
                  //       child: _buildEnhancedCurrencyDisplay(
                  //         icon: '💰',
                  //         value: userGameData.user!.coins,
                  //         color: ThemeConfig.coinsColor,
                  //         label: 'Coins',
                  //       ),
                  //     ),
                  //     Container(
                  //       width: 1,
                  //       height: 30,
                  //       color: Colors.white.withOpacity(0.2),
                  //     ),
                  //     Expanded(
                  //       child: _buildEnhancedCurrencyDisplay(
                  //         icon: '💎',
                  //         value: userGameData.user!.gems,
                  //         color: ThemeConfig.gemsColor,
                  //         label: 'Gems',
                  //       ),
                  //     ),
                  //     Container(
                  //       width: 1,
                  //       height: 30,
                  //       color: Colors.white.withOpacity(0.2),
                  //     ),
                  //     Expanded(
                  //       child: _buildEnhancedCurrencyDisplay(
                  //         icon: '⭐',
                  //         value: userGameData.user!.totalXp,
                  //         color: ThemeConfig.xpColor,
                  //         label: 'XP',
                  //       ),
                  //     ),
                  //   ],
                  // ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      _buildStatItem('🪙', userGameData.user!.coins.toString(), () => ()),
                      SizedBox(width: 12),
                      _buildStatItem('⭐', userGameData.user!.totalXp.toString(), () => ()),
                      const SizedBox(width: 12),
                      _buildStatItem('💎', userGameData.user!.gems.toString(), () => ()),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String icon, String value, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(icon, style: const TextStyle(fontSize: 12)),
            const SizedBox(width: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback onPressed,
    required String tooltip,
    bool showBadge = false,
    String? badgeCount,
  }) {
    return IconButton(
      icon: Stack(
        clipBehavior: Clip.none,
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: ThemeConfig.iconSize24,
          ),
          // Notification badge melhorada
          if (showBadge && badgeCount != null)
            Positioned(
              right: -6,
              top: -6,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.red[600],
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: Colors.white,
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      offset: const Offset(0, 1),
                      blurRadius: 3,
                    ),
                  ],
                ),
                constraints: const BoxConstraints(
                  minWidth: 18,
                  minHeight: 18,
                ),
                child: Text(
                  badgeCount,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
      onPressed: onPressed,
      tooltip: tooltip,
    );
  }

  Widget _buildEnhancedCurrencyDisplay({
    required String icon,
    required int value,
    required Color color,
    required String label,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              icon,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(width: 4),
            Text(
              _formatNumber(value),
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
                shadows: [
                  Shadow(
                    color: Colors.black.withOpacity(0.3),
                    offset: const Offset(0, 1),
                    blurRadius: 2,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }

  void _showNotifications(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
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
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(24),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(ThemeConfig.spacing20),
              child: Column(
                children: [
                  const Text(
                    'Settings',
                    style: TextStyle(
                      fontSize: ThemeConfig.fontSize20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: ThemeConfig.spacing20),
                  _buildSettingsItem(
                    icon: Icons.palette,
                    title: 'Theme',
                    onTap: () {
                      Navigator.pop(context);
                      // Navigate to theme settings
                    },
                  ),
                  _buildSettingsItem(
                    icon: Icons.notifications,
                    title: 'Notifications',
                    onTap: () {
                      Navigator.pop(context);
                      // Navigate to notification settings
                    },
                  ),
                  const SizedBox(height: ThemeConfig.spacing20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey[50],
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: ThemeConfig.primaryGradient.colors.first.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: ThemeConfig.primaryGradient.colors.first,
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Colors.grey,
        ),
        onTap: onTap,
      ),
    );
  }
}
