import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Custom App Drawer / Hamburger Menu
class AppDrawer extends StatelessWidget {
  final String? userEmail;
  final String? userName;
  final String? selectedCrop;
  final String? selectedSeason;
  final String? selectedDistrict;
  final String? selectedProvince;
  final VoidCallback onLogout;
  final VoidCallback onUpdateProfile;

  const AppDrawer({
    super.key,
    this.userEmail,
    this.userName,
    this.selectedCrop,
    this.selectedSeason,
    this.selectedDistrict,
    this.selectedProvince,
    required this.onLogout,
    required this.onUpdateProfile,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            // Header with user info
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(color: Color(0xFF0C4D32)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // User Avatar
                  CircleAvatar(
                    radius: 35,
                    backgroundColor: const Color(0xFF3FAE4A),
                    child: Text(
                      userName != null && userName!.isNotEmpty
                          ? userName![0].toUpperCase()
                          : 'U',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // User Name
                  Text(
                    userName ?? 'Welcome!',
                    style: GoogleFonts.sourceSans3(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // User Email
                  Text(
                    userEmail ?? 'Sign in to access your profile',
                    style: GoogleFonts.sourceSans3(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),

            // Farm Details Summary (if available)
            if (selectedCrop != null || selectedDistrict != null)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.all(12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF6F4EB),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.grass,
                          color: Color(0xFF3FAE4A),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Your Farm',
                          style: GoogleFonts.sourceSans3(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (selectedCrop != null)
                      _buildInfoRow(Icons.eco, 'Crop: $selectedCrop'),
                    if (selectedSeason != null)
                      _buildInfoRow(
                        Icons.calendar_today,
                        'Season: $selectedSeason',
                      ),
                    if (selectedDistrict != null)
                      _buildInfoRow(
                        Icons.location_on,
                        'Location: $selectedDistrict',
                      ),
                    if (selectedProvince != null)
                      _buildInfoRow(Icons.map, 'Province: $selectedProvince'),
                  ],
                ),
              ),

            // Menu Items
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  // Update Profile / Farm Details
                  _buildDrawerItem(
                    context: context,
                    icon: Icons.edit_note,
                    title: 'Update Farm Details',
                    subtitle: 'Change crop, season, location',
                    onTap: () {
                      Navigator.pop(context);
                      onUpdateProfile();
                    },
                  ),

                  // Weather
                  _buildDrawerItem(
                    context: context,
                    icon: Icons.wb_sunny,
                    title: 'Weather',
                    subtitle: 'View weather for your location',
                    onTap: () {
                      Navigator.pop(context);
                      // Navigate to weather tab
                    },
                  ),

                  // About
                  _buildDrawerItem(
                    context: context,
                    icon: Icons.info,
                    title: 'About',
                    subtitle: 'App version 1.0.0',
                    onTap: () {
                      Navigator.pop(context);
                      _showAboutDialog(context);
                    },
                  ),

                  const Divider(height: 24),

                  // Logout
                  _buildDrawerItem(
                    context: context,
                    icon: Icons.logout,
                    title: 'Sign Out',
                    subtitle: 'Sign out of your account',
                    textColor: Colors.red,
                    onTap: () {
                      Navigator.pop(context);
                      _showLogoutDialog(context);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(icon, size: 14, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Text(text, style: TextStyle(fontSize: 13, color: Colors.grey[700])),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? textColor,
  }) {
    return ListTile(
      leading: Icon(icon, color: textColor ?? const Color(0xFF3FAE4A)),
      title: Text(
        title,
        style: TextStyle(fontWeight: FontWeight.w600, color: textColor),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 12,
          color: textColor?.withOpacity(0.7) ?? Colors.grey,
        ),
      ),
      trailing: Icon(Icons.chevron_right, color: textColor ?? Colors.grey[400]),
      onTap: onTap,
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(context);
              onLogout();
            },
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Image.asset('lib/images/logo.png', width: 30, height: 30),
            const SizedBox(width: 8),
            const Text('UMUHINZI+'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Version: 1.0.0'),
            SizedBox(height: 8),
            Text(
              'UMUHINZI+ is your smart farming companion, providing real-time weather data, market prices, and expert farming tips tailored to your location and crops.',
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
}
