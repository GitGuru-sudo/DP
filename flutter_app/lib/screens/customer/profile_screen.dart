import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dp_canteen/config/theme.dart';
import 'package:dp_canteen/providers/auth_provider.dart';
import 'package:dp_canteen/screens/auth/login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grey50,
      body: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          final user = auth.user;
          return CustomScrollView(
            slivers: [
              // Profile Header
              SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: const BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(32),
                    ),
                  ),
                  child: SafeArea(
                    child: Column(
                      children: [
                        const Text(
                          'Profile',
                          style: TextStyle(
                            
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Avatar
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 3),
                            color: Colors.white,
                          ),
                          child: user?.profileImage != null
                              ? ClipOval(
                                  child: Image.network(
                                    user!.profileImage!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => _buildDefaultAvatar(user.name),
                                  ),
                                )
                              : _buildDefaultAvatar(user?.name ?? 'U'),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          user?.name ?? 'User',
                          style: const TextStyle(
                            
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user?.email ?? '',
                          style: TextStyle(
                            
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                        if (user?.phone != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            user!.phone!,
                            style: TextStyle(
                              
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                        ],
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            _getRoleLabel(user?.role ?? 'customer'),
                            style: const TextStyle(
                              
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Menu Items
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    const SizedBox(height: 8),
                    _buildMenuSection('Account', [
                      _buildMenuItem(
                        icon: Icons.person_outline,
                        title: 'Edit Profile',
                        onTap: () => _showComingSoon(context),
                      ),
                      _buildMenuItem(
                        icon: Icons.notifications_outlined,
                        title: 'Notifications',
                        onTap: () => _showComingSoon(context),
                      ),
                    ]),
                    const SizedBox(height: 16),
                    _buildMenuSection('Preferences', [
                      _buildMenuItem(
                        icon: Icons.language,
                        title: 'Language',
                        trailing: 'English',
                        onTap: () => _showComingSoon(context),
                      ),
                      _buildMenuItem(
                        icon: Icons.dark_mode_outlined,
                        title: 'Dark Mode',
                        trailing: 'Off',
                        onTap: () => _showComingSoon(context),
                      ),
                    ]),
                    const SizedBox(height: 16),
                    _buildMenuSection('Support', [
                      _buildMenuItem(
                        icon: Icons.help_outline,
                        title: 'Help Center',
                        onTap: () => _showComingSoon(context),
                      ),
                      _buildMenuItem(
                        icon: Icons.privacy_tip_outlined,
                        title: 'Privacy Policy',
                        onTap: () => _showComingSoon(context),
                      ),
                      _buildMenuItem(
                        icon: Icons.description_outlined,
                        title: 'Terms of Service',
                        onTap: () => _showComingSoon(context),
                      ),
                    ]),
                    const SizedBox(height: 16),
                    _buildMenuSection('', [
                      _buildMenuItem(
                        icon: Icons.info_outline,
                        title: 'About',
                        trailing: 'v1.0.0',
                        onTap: () => _showAboutDialog(context),
                      ),
                    ]),
                    const SizedBox(height: 24),
                    // Logout Button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: OutlinedButton.icon(
                        onPressed: () => _handleLogout(context, auth),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.error,
                          side: const BorderSide(color: AppColors.error),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        icon: const Icon(Icons.logout),
                        label: const Text(
                          'Logout',
                          style: TextStyle(
                            
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ]),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDefaultAvatar(String name) {
    return Center(
      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : 'U',
        style: const TextStyle(
          
          fontSize: 40,
          fontWeight: FontWeight.bold,
          color: AppColors.primaryOrange,
        ),
      ),
    );
  }

  String _getRoleLabel(String role) {
    switch (role) {
      case 'admin':
        return 'Administrator';
      case 'manager':
        return 'Canteen Manager';
      default:
        return 'Customer';
    }
  }

  Widget _buildMenuSection(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              title,
              style: const TextStyle(
                
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.grey600,
              ),
            ),
          ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(children: items),
        ),
      ],
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    String? trailing,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primaryOrange),
      title: Text(
        title,
        style: const TextStyle(
          
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: trailing != null
          ? Text(
              trailing,
              style: const TextStyle(
                
                color: AppColors.grey500,
              ),
            )
          : const Icon(Icons.chevron_right, color: AppColors.grey400),
      onTap: onTap,
    );
  }

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Coming soon!'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Image.asset(
              'assets/images/logo.png',
              width: 40,
              height: 40,
              errorBuilder: (_, __, ___) => const Icon(
                Icons.restaurant,
                color: AppColors.primaryOrange,
                size: 40,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'DP Canteen',
              style: TextStyle(
                
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Version 1.0.0',
              style: TextStyle(fontFamily: 'Poppins'),
            ),
            SizedBox(height: 8),
            Text(
              'A modern college canteen management app with UPI payments and QR-based order verification.',
              style: TextStyle(
                
                color: AppColors.grey600,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleLogout(BuildContext context, AuthProvider auth) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Logout', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await auth.signOut();
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }
}
