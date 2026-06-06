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
    // Initialize controllers at the top level so they persist across tabs
    Get.put(JobController());
    final nav = Get.put(NavigationController());
    final theme = Theme.of(context);

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
            backgroundColor: theme.brightness == Brightness.dark
                ? const Color(0xFF1E293B)
                : Colors.white,
            indicatorColor: theme.colorScheme.primary.withValues(alpha: 0.15),
            animationDuration: const Duration(milliseconds: 400),
            destinations: [
              NavigationDestination(
                icon: const Icon(Icons.work_outline_rounded),
                selectedIcon: Icon(Icons.work_rounded, color: theme.colorScheme.primary),
                label: 'Jobs',
              ),
              NavigationDestination(
                icon: const Icon(Icons.favorite_border_rounded),
                selectedIcon: Icon(Icons.favorite_rounded, color: theme.colorScheme.primary),
                label: 'Wishlist',
              ),
              NavigationDestination(
                icon: const Icon(Icons.person_outline_rounded),
                selectedIcon: Icon(Icons.person_rounded, color: theme.colorScheme.primary),
                label: 'Profile',
              ),
            ],
          ),
        ));
  }
}
