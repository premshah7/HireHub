import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/job_controller.dart';
import 'job_dashboard_screen.dart';
import 'wishlist_screen.dart';
import 'profile_screen.dart';

class NavigationController extends GetxController {
  final RxInt currentIndex = 0.obs;
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(JobController());
    final nav = Get.put(NavigationController());
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final List<Widget> pages = const [
      JobDashboardScreen(),
      WishlistScreen(),
      ProfileScreen(),
    ];

    return Obx(() => Scaffold(
          body: IndexedStack(
            index: nav.currentIndex.value,
            children: pages,
          ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: nav.currentIndex.value,
            onDestinationSelected: (index) => nav.currentIndex.value = index,
            backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
            surfaceTintColor: Colors.transparent,
            indicatorColor: theme.colorScheme.primary.withValues(alpha: 0.1),
            animationDuration: const Duration(milliseconds: 300),
            height: 64,
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
            destinations: [
              NavigationDestination(
                icon: Icon(Icons.work_outline_rounded, size: 22, color: isDark ? Colors.grey[600] : Colors.grey[400]),
                selectedIcon: Icon(Icons.work_rounded, size: 22, color: theme.colorScheme.primary),
                label: 'Jobs',
              ),
              NavigationDestination(
                icon: Icon(Icons.bookmark_border_rounded, size: 22, color: isDark ? Colors.grey[600] : Colors.grey[400]),
                selectedIcon: Icon(Icons.bookmark_rounded, size: 22, color: theme.colorScheme.primary),
                label: 'Saved',
              ),
              NavigationDestination(
                icon: Icon(Icons.person_outline_rounded, size: 22, color: isDark ? Colors.grey[600] : Colors.grey[400]),
                selectedIcon: Icon(Icons.person_rounded, size: 22, color: theme.colorScheme.primary),
                label: 'Account',
              ),
            ],
          ),
        ));
  }
}
