import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:get/get.dart';
import '../models/job_model.dart';
import '../utils/html_parser.dart';

class JobDetailScreen extends StatelessWidget {
  final JobModel job;

  const JobDetailScreen({super.key, required this.job});

  static const List<Color> _avatarColors = [
    Color(0xFF0D9488), // Teal
    Color(0xFF7C3AED), // Violet
    Color(0xFF2563EB), // Blue
    Color(0xFFEA580C), // Orange
    Color(0xFFDB2777), // Pink
    Color(0xFF059669), // Emerald
    Color(0xFFD97706), // Amber
    Color(0xFF4F46E5), // Indigo
  ];

  Gradient _getCompanyGradient(String companyName) {
    final int hash = companyName.hashCode;
    final int index1 = hash.abs() % _avatarColors.length;
    final int index2 = (hash.abs() + 2) % _avatarColors.length;
    return LinearGradient(
      colors: [
        _avatarColors[index1],
        _avatarColors[index2 == index1 ? (index1 + 1) % _avatarColors.length : index2],
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  Future<void> _launchUrl() async {
    if (job.url.isEmpty) {
      Get.snackbar(
        'Unavailable',
        'No application link was provided for this job.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.amber[800],
        colorText: Colors.white,
      );
      return;
    }

    final Uri url = Uri.parse(job.url);
    try {
      final bool launched = await launchUrl(
        url,
        mode: LaunchMode.externalApplication,
      );
      if (!launched) {
        throw 'Failed to open web browser';
      }
    } catch (e) {
      Get.snackbar(
        'Error Launching Link',
        'Could not open the job application link. Please check your browser.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[600],
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final companyInitial = job.companyName.isNotEmpty ? job.companyName[0].toUpperCase() : 'J';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Job Details'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Get.back(),
        ),
      ),
      body: Column(
        children: [
          // Scrollable Job Information
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Company logo, job title, and company name header card
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          gradient: _getCompanyGradient(job.companyName),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          companyInitial,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              job.title,
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                height: 1.2,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              job.companyName,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Metadata list: location, date, remote
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        _buildMetaRow(
                          icon: Icons.location_on_rounded,
                          text: job.location,
                          theme: theme,
                          isDark: isDark,
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8.0),
                          child: Divider(height: 1, thickness: 0.5, color: Colors.grey),
                        ),
                        _buildMetaRow(
                          icon: Icons.access_time_filled_rounded,
                          text: 'Posted ${job.timeAgo}',
                          theme: theme,
                          isDark: isDark,
                        ),
                        if (job.remote) ...[
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 8.0),
                            child: Divider(height: 1, thickness: 0.5, color: Colors.grey),
                          ),
                          _buildMetaRow(
                            icon: Icons.wifi_rounded,
                            text: 'Remote Work Allowed',
                            theme: theme,
                            isDark: isDark,
                            accentColor: theme.colorScheme.primary,
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Tags Wrap
                  if (job.tags.isNotEmpty) ...[
                    Text(
                      'Keywords & Tags',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: job.tags.map((tag) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: theme.colorScheme.primary.withValues(alpha: 0.3),
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            tag,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontSize: 13,
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Description Title
                  Text(
                    'Job Description',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Job HTML description parser
                  ...HtmlParser.parse(job.description, theme),
                  
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),

          // Bottom sticky CTA action bar
          Container(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 16,
              bottom: Get.mediaQuery.padding.bottom > 0 ? Get.mediaQuery.padding.bottom : 16,
            ),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              border: Border(
                top: BorderSide(
                  color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _launchUrl,
                    icon: const Icon(Icons.launch_rounded, size: 20),
                    label: const Text('Apply on Website'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetaRow({
    required IconData icon,
    required String text,
    required ThemeData theme,
    required bool isDark,
    Color? accentColor,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: accentColor ?? (isDark ? Colors.grey[400] : Colors.grey[600]),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: accentColor ?? (isDark ? Colors.grey[200] : Colors.grey[800]),
              fontWeight: accentColor != null ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ],
    );
  }
}
