import 'package:flutter/material.dart';
import '../models/job_model.dart';
import '../screens/job_detail_screen.dart';
import '../controllers/job_controller.dart';
import 'package:get/get.dart';

class JobCard extends StatelessWidget {
  final JobModel job;

  const JobCard({super.key, required this.job});

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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final companyInitial = job.companyName.isNotEmpty ? job.companyName[0].toUpperCase() : 'J';

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {
            Get.to(
              () => JobDetailScreen(job: job),
              transition: Transition.rightToLeftWithFade,
              duration: const Duration(milliseconds: 300),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top row: Avatar + Title & Company
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Dynamic colorful avatar for company placeholder
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: _getCompanyGradient(job.companyName),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        companyInitial,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Title and Company Name
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            job.title,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              height: 1.2,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            job.companyName,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Favorite Heart Icon
                    Obx(() {
                      final controller = Get.find<JobController>();
                      final isBookmarked = controller.isBookmarked(job.slug);
                      return IconButton(
                        icon: Icon(
                          isBookmarked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                          color: isBookmarked ? Colors.redAccent : Colors.grey[400],
                        ),
                        visualDensity: VisualDensity.compact,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: () {
                          controller.toggleBookmark(job.slug);
                        },
                      );
                    }),
                  ],
                ),
                const SizedBox(height: 12),

                // Location and Remote Badge
                Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 16,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        job.location,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (job.remote) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.wifi_rounded,
                              size: 12,
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Remote',
                              style: theme.textTheme.labelLarge?.copyWith(
                                fontSize: 10,
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 12),

                // Tags (Horizontal wrapping chips)
                if (job.tags.isNotEmpty) ...[
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: job.tags.take(4).map((tag) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          tag,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontSize: 12,
                            color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                ],

                // Footer Row: Time Posted
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 14,
                          color: isDark ? Colors.grey[500] : Colors.grey[500],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          job.timeAgo,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontSize: 12,
                            color: isDark ? Colors.grey[500] : Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                    Icon(
                      Icons.arrow_forward_rounded,
                      size: 18,
                      color: theme.colorScheme.primary.withValues(alpha: 0.8),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
