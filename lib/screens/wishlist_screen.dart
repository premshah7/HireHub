import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/job_controller.dart';
import '../widgets/job_card.dart';

class WishlistScreen extends StatelessWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<JobController>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.favorite_rounded, color: Colors.redAccent, size: 22),
            const SizedBox(width: 10),
            const Text(
              'Wishlist',
              style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
            ),
          ],
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
      body: Obx(() {
        // Filter jobs that are bookmarked
        final wishlistJobs = controller.jobs
            .where((job) => controller.isBookmarked(job.slug))
            .toList();

        if (wishlistJobs.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.favorite_border_rounded,
                    size: 72,
                    color: isDark ? Colors.grey[600] : Colors.grey[300],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'No Saved Jobs Yet',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Tap the heart icon on any job to save it here for later.',
                    style: TextStyle(
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                      fontSize: 15,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          itemCount: wishlistJobs.length,
          itemBuilder: (context, index) {
            return JobCard(job: wishlistJobs[index]);
          },
        );
      }),
    );
  }
}
