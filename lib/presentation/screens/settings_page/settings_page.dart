// lib/pages/settings_page.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:test_flutter/common/theme/app_colors.dart';
import 'package:test_flutter/domain/services/player_service.dart';
import 'package:test_flutter/presentation/splash/splash.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _isGaplessEnabled = false;
  bool _isDataSaverEnabled = false;
  @override
  Widget build(BuildContext context) {
    final playerService = context.watch<PlayerService>();
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: const Text(
          'Settings',
          style: TextStyle(
            color: AppColors.primaryText,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView(
        children: [
          _buildProfileSection(),
          _buildSectionHeader('Playback'),
          _buildGaplessSwitch(),
          _buildNavigationTile(
            title: 'Crossfade',
            subtitle: playerService.crossfadeDuration == Duration.zero
                ? 'Off'
                : '${playerService.crossfadeDuration.inSeconds} seconds',
            onTap: () => _showCrossfadeDialog(playerService),
          ),
          _buildNavigationTile(
            title: 'Audio Quality',
            subtitle: 'Automatic',
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Coming Soon'),
                  content: const Text('Will be available in a future update.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('OK'),
                    ),
                  ],
                ),
              );
            },
          ),
          _buildSectionHeader('Data Saver'),
          _buildDataSaverSwitch(),
          _buildNavigationTile(
            title: 'Video Podcasts',
            subtitle: 'Audio only on mobile data',
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Coming Soon'),
                  content: const Text('Will be available in a future update.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('OK'),
                    ),
                  ],
                ),
              );
            },
          ),
          _buildSectionHeader('Account'),
          _buildNavigationTile(
            title: 'Email',
            subtitle: context.watch<User?>()?.email ?? 'Not signed in',
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Email'),
                  content: const Text('Your email is used for storing your favorites and playlists.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('OK'),
                    ),
                  ],
                ),
              );
            },
          ),
          _buildNavigationTile(
            title: 'Password',
            subtitle: 'Change your password',
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Coming Soon'),
                  content: const Text('Will be available in a future update.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('OK'),
                    ),
                  ],
                ),
              );
            },
          ),
          _buildLogoutTile(),
          _buildSectionHeader('About'),
          _buildInfoTile('Version', '1.0.0 (Build 2025)'),
        ],
      ),
    );
  }

  Widget _buildProfileSection() {
    final user = context.watch<User?>();
    final displayName = user?.displayName ?? 'Guest User';    
  
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 32,
            backgroundImage: NetworkImage('https://th.bing.com/th/id/R.11a65d7c5bf953b4e0dc9a9e92bfefb8?rik=1lFA9aLuInjHug&pid=ImgRaw&r=0'),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName,
                  style: const TextStyle(
                    color: AppColors.primaryText,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'View profile',
                  style: TextStyle(color: AppColors.secondaryText),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.chevron_right, color: AppColors.secondaryText),
            onPressed: () {
              // Chức năng xem hồ sơ sẽ được triển khai sau
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Coming Soon'),
                  content: const Text('Profile viewing will be available in a future update.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('OK'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _showCrossfadeDialog(PlayerService playerService) async {
    // Lấy giá trị hiện tại để thao tác trong dialog
    Duration selectedDuration = playerService.crossfadeDuration;

    return showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateInDialog) {
            return AlertDialog(
              backgroundColor: AppColors.surface,
              title: const Text('Crossfade', style: TextStyle(color: AppColors.primaryText)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    selectedDuration == Duration.zero ? 'Off' : '${selectedDuration.inSeconds} seconds',
                    style: const TextStyle(color: AppColors.primaryText, fontSize: 16),
                  ),
                  Slider(
                    value: selectedDuration.inSeconds.toDouble(),
                    min: 0,
                    max: 12,
                    divisions: 12,
                    label: '${selectedDuration.inSeconds}',
                    activeColor: AppColors.accent,
                    inactiveColor: Colors.grey.shade700,
                    onChanged: (value) {
                      setStateInDialog(() {
                        selectedDuration = Duration(seconds: value.toInt());
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel', style: TextStyle(color: AppColors.secondaryText)),
                ),
                TextButton(
                  onPressed: () {
                    // Chỉ lưu khi người dùng nhấn "Save"
                    playerService.setCrossfade(selectedDuration);
                    Navigator.of(context).pop();
                  },
                  child: const Text('Save', style: TextStyle(color: AppColors.accent)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 8.0),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          color: AppColors.secondaryText,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildGaplessSwitch() {
    return SwitchListTile(
      tileColor: AppColors.surface,
      title: const Text('Gapless Playback', style: TextStyle(color: AppColors.primaryText)),
      subtitle: const Text('Allows gapless playback.', style: TextStyle(color: AppColors.secondaryText)),
      value: _isGaplessEnabled,
      onChanged: (bool value) {
        setState(() {
          _isGaplessEnabled = value;
        });
      },
      activeColor: AppColors.accent,
    );
  }
  
  Widget _buildDataSaverSwitch() {
     return SwitchListTile(
      tileColor: AppColors.surface,
      title: const Text('Data Saver', style: TextStyle(color: AppColors.primaryText)),
      subtitle: const Text('Sets your audio quality to low.', style: TextStyle(color: AppColors.secondaryText)),
      value: _isDataSaverEnabled,
      onChanged: (bool value) {
        setState(() {
          _isDataSaverEnabled = value;
        });
      },
      activeColor: AppColors.accent,
    );
  }

  Widget _buildNavigationTile({required String title, required String subtitle, required VoidCallback onTap}) {
    return ListTile(
      tileColor: AppColors.surface,
      title: Text(title, style: const TextStyle(color: AppColors.primaryText)),
      subtitle: Text(subtitle, style: const TextStyle(color: AppColors.secondaryText)),
      trailing: const Icon(Icons.chevron_right, color: AppColors.secondaryText),
      onTap: onTap,
    );
  }
  
  Widget _buildLogoutTile() {
    return ListTile(
      tileColor: AppColors.surface,
      title: const Text(
        'Log Out',
        style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600),
      ),
      onTap: _showLogoutConfirmationDialog,
    );
  }
  
  Future<void> _showLogoutConfirmationDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Log Out'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Are you sure you want to log out?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(dialogContext).pop(); 
              },
            ),
            TextButton(
              child: const Text(
                'Log Out',
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () {
                Navigator.of(dialogContext).pop(); 
                _performLogout(); 
              },
            ),
          ],
        );
      },
    );
  }
  Future<void> _performLogout() async {
    try {
      final playerService = Provider.of<PlayerService>(context, listen: false);
      await playerService.reset();
      await FirebaseAuth.instance.signOut();

      if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const SplashPage()),
        (route) => false, // Remove tất cả routes
      );
    }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to log out: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Widget cho các mục chỉ hiển thị thông tin
  Widget _buildInfoTile(String title, String value) {
     return ListTile(
      tileColor: AppColors.surface,
      title: Text(title, style: const TextStyle(color: AppColors.primaryText)),
      trailing: Text(value, style: const TextStyle(color: AppColors.secondaryText)),
    );
  }
}