// File: lib/presentation/widgets/common/user_profile_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petverse/core/config/theme_config.dart';
import 'package:petverse/core/utils/formatters.dart';
import 'package:petverse/presentation/providers/auth_provider.dart';
import 'package:petverse/presentation/providers/user_provider.dart';

/// Widget that displays user profile information
class UserProfileWidget extends ConsumerWidget {
  final VoidCallback? onTap;
  final bool showEmail;
  final double avatarRadius;

  const UserProfileWidget({
    super.key,
    this.onTap,
    this.showEmail = true,
    this.avatarRadius = 22,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userGameData = ref.watch(userGameDataProvider);

    if (!userGameData.hasUser) {
      return _buildGuestProfile();
    }

    final user = userGameData.user!;
    final displayName = user.displayName.isNotEmpty ? user.displayName : 'User';

    return GestureDetector(
      onTap: onTap ?? () => _showUserProfile(context, ref),
      child: Row(
        children: [
          // Avatar with loading indicator
          _buildUserAvatar(user.photoURL, displayName),
          const SizedBox(width: ThemeConfig.spacing12),

          // User information
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _getGreeting(),
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: ThemeConfig.fontSize14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  displayName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: ThemeConfig.fontSize18,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (showEmail && user.email.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    user.email,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: ThemeConfig.fontSize12,
                      fontWeight: FontWeight.w400,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserAvatar(String? avatarUrl, String displayName) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: CircleAvatar(
        radius: avatarRadius,
        backgroundColor: Colors.white.withOpacity(0.2),
        backgroundImage: avatarUrl != null && avatarUrl.isNotEmpty ? NetworkImage(avatarUrl) : null,
        onBackgroundImageError: (exception, stackTrace) {
          // Handle error silently
        },
        child: avatarUrl == null || avatarUrl.isEmpty
            ? Text(
                displayName.isNotEmpty ? displayName[0].toUpperCase() : 'U',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: ThemeConfig.fontSize18,
                ),
              )
            : null,
      ),
    );
  }

  Widget _buildGuestProfile() {
    return Row(
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
              width: 2,
            ),
          ),
          child: CircleAvatar(
            radius: avatarRadius,
            backgroundColor: Colors.white.withOpacity(0.2),
            child: const Icon(
              Icons.person,
              color: Colors.white,
              size: ThemeConfig.iconSize20,
            ),
          ),
        ),
        const SizedBox(width: ThemeConfig.spacing12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _getGreeting(),
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: ThemeConfig.fontSize14,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 2),
              const Text(
                'Guest',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: ThemeConfig.fontSize18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning,';
    if (hour < 18) return 'Good afternoon,';
    return 'Good evening,';
  }

  void _showUserProfile(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(ThemeConfig.borderRadius20),
        ),
      ),
      builder: (context) => const UserProfileModal(),
    );
  }
}

/// User profile modal
class UserProfileModal extends ConsumerStatefulWidget {
  const UserProfileModal({super.key});

  @override
  ConsumerState<UserProfileModal> createState() => _UserProfileModalState();
}

class _UserProfileModalState extends ConsumerState<UserProfileModal> {
  bool _isLoggingOut = false;

  @override
  Widget build(BuildContext context) {
    final userGameData = ref.watch(userGameDataProvider);

    if (!userGameData.hasUser) {
      return Container(
        padding: const EdgeInsets.all(ThemeConfig.spacing20),
        child: const Text('No user data available'),
      );
    }

    final user = userGameData.user!;

    return Container(
      padding: const EdgeInsets.all(ThemeConfig.spacing20),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(ThemeConfig.borderRadius20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          const SizedBox(height: ThemeConfig.spacing20),

          // Title
          const Text(
            'User Profile',
            style: TextStyle(
              fontSize: ThemeConfig.fontSize20,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: ThemeConfig.spacing24),

          // Large avatar
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: ThemeConfig.primaryColor.withOpacity(0.3),
                width: 3,
              ),
            ),
            child: CircleAvatar(
              radius: 50,
              backgroundColor: ThemeConfig.primaryColor.withOpacity(0.1),
              backgroundImage:
                  user.photoURL?.isNotEmpty == true ? NetworkImage(user.photoURL!) : null,
              child: user.photoURL?.isEmpty != false
                  ? Text(
                      user.displayName.isNotEmpty ? user.displayName[0].toUpperCase() : 'U',
                      style: const TextStyle(
                        color: ThemeConfig.primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: ThemeConfig.fontSize32,
                      ),
                    )
                  : null,
            ),
          ),

          const SizedBox(height: ThemeConfig.spacing20),

          // User information
          _buildUserInfo('Name', user.displayName.isNotEmpty ? user.displayName : 'Not provided'),
          _buildUserInfo('Email', user.email.isNotEmpty ? user.email : 'Not provided'),
          _buildUserInfo('Level', user.level.toString()),
          _buildUserInfo('Total XP', Formatters.formatLargeNumber(user.totalXp)),
          _buildUserInfo('Member Since', Formatters.formatDate(user.createdAt)),

          const SizedBox(height: ThemeConfig.spacing24),

          // Profile options
          _buildProfileOption(
            icon: Icons.edit,
            title: 'Edit Profile',
            onTap: () {
              Navigator.pop(context);
              _showEditProfile();
            },
          ),

          _buildProfileOption(
            icon: Icons.help_outline,
            title: 'Help & Support',
            onTap: () {
              Navigator.pop(context);
              _showHelp();
            },
          ),

          const Divider(height: 40),

          // Logout button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isLoggingOut ? null : _handleLogout,
              icon: _isLoggingOut
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.logout),
              label: Text(_isLoggingOut ? 'Signing out...' : 'Sign Out'),
              style: ElevatedButton.styleFrom(
                backgroundColor: ThemeConfig.errorColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: ThemeConfig.spacing16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(ThemeConfig.borderRadius12),
                ),
              ),
            ),
          ),

          const SizedBox(height: ThemeConfig.spacing20),
        ],
      ),
    );
  }

  Widget _buildUserInfo(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: ThemeConfig.spacing8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontSize: ThemeConfig.fontSize14,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: ThemeConfig.fontSize14,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
    );
  }

  Future<void> _handleLogout() async {
    if (_isLoggingOut) return;

    final shouldLogout = await _showLogoutConfirmation();
    if (!shouldLogout) return;

    setState(() => _isLoggingOut = true);

    try {
      // Sign out using auth provider
      await ref.read(authProvider.notifier).signOut();

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Successfully signed out!'),
            backgroundColor: ThemeConfig.successColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error signing out: $e'),
            backgroundColor: ThemeConfig.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoggingOut = false);
      }
    }
  }

  Future<bool> _showLogoutConfirmation() async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Confirm Sign Out'),
            content: const Text('Are you sure you want to sign out of your account?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: ThemeConfig.errorColor,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Sign Out'),
              ),
            ],
          ),
        ) ??
        false;
  }

  void _showEditProfile() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Profile'),
        content: const Text('Feature coming soon'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showHelp() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Help & Support'),
        content: const Text('Contact us: support@petgame.com'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
