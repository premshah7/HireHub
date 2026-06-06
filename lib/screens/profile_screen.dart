import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/job_controller.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<JobController>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
        ),
        actions: [
          IconButton(
            icon: Icon(
              isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
              color: theme.colorScheme.primary,
            ),
            tooltip: 'Toggle Theme',
            onPressed: () {
              Get.changeThemeMode(
                isDark ? ThemeMode.light : ThemeMode.dark,
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 8),

            // Profile Avatar
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0D9488), Color(0xFF7C3AED)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(28),
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.person_rounded,
                size: 48,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),

            // Name
            Text(
              'Job Seeker',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'seeker@hirehub.app',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
            const SizedBox(height: 28),

            // Stats Row
            Obx(() => Container(
                  padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStat(
                        context,
                        count: controller.jobs.length.toString(),
                        label: 'Jobs Found',
                        icon: Icons.work_rounded,
                      ),
                      Container(
                        width: 1,
                        height: 40,
                        color: isDark ? Colors.grey[700] : Colors.grey[300],
                      ),
                      _buildStat(
                        context,
                        count: controller.bookmarkedJobSlugs.length.toString(),
                        label: 'Saved',
                        icon: Icons.favorite_rounded,
                      ),
                    ],
                  ),
                )),
            const SizedBox(height: 28),

            // Settings options
            _buildSettingsTile(
              context,
              icon: Icons.notifications_outlined,
              title: 'Notifications',
              subtitle: 'Job alerts and updates',
              isDark: isDark,
            ),
            _buildSettingsTile(
              context,
              icon: Icons.description_outlined,
              title: 'My Resume',
              subtitle: 'Upload and manage your CV',
              isDark: isDark,
            ),
            _buildSettingsTile(
              context,
              icon: Icons.help_outline_rounded,
              title: 'Help & Support',
              subtitle: 'FAQs and contact us',
              isDark: isDark,
            ),
            _buildSettingsTile(
              context,
              icon: Icons.info_outline_rounded,
              title: 'About HireHub',
              subtitle: 'Version 1.0.0',
              isDark: isDark,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStat(BuildContext context,
      {required String count, required String label, required IconData icon}) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Icon(icon, color: theme.colorScheme.primary, size: 24),
        const SizedBox(height: 8),
        Text(
          count,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: theme.textTheme.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildSettingsTile(BuildContext context,
      {required IconData icon,
      required String title,
      required String subtitle,
      required bool isDark}) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
        ),
      ),
      child: ListTile(
        leading: Icon(icon, color: theme.colorScheme.primary),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: isDark ? Colors.grey[500] : Colors.grey[500],
            fontSize: 13,
          ),
        ),
        trailing: Icon(
          Icons.chevron_right_rounded,
          color: isDark ? Colors.grey[600] : Colors.grey[400],
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }
}
