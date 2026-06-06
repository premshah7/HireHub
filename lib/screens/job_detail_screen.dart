import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:get/get.dart';
import '../models/job_model.dart';
import '../utils/html_parser.dart';
import '../services/translation_service.dart';

class JobDetailScreen extends StatelessWidget {
  final JobModel job;

  const JobDetailScreen({super.key, required this.job});

  Color _getAvatarColor(String name) {
    const colors = [
      Color(0xFF312E81),
      Color(0xFF1E3A5F),
      Color(0xFF3730A3),
      Color(0xFF1E40AF),
      Color(0xFF4338CA),
      Color(0xFF0F4C75),
      Color(0xFF374151),
      Color(0xFF4C1D95),
    ];
    return colors[name.hashCode.abs() % colors.length];
  }

  Future<void> _launchUrl() async {
    if (job.url.isEmpty) {
      Get.snackbar(
        'Unavailable',
        'No application link was provided for this job.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF475569),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 10,
      );
      return;
    }

    final Uri url = Uri.parse(job.url);
    try {
      final bool launched = await launchUrl(url, mode: LaunchMode.externalApplication);
      if (!launched) throw 'Failed to open browser';
    } catch (e) {
      Get.snackbar(
        'Error',
        'Could not open the application link.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFDC2626),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 10,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final companyInitial = job.companyName.isNotEmpty ? job.companyName[0].toUpperCase() : 'J';

    // Reactive translation state
    final isTranslated = false.obs;
    final isTranslating = false.obs;
    final translatedText = ''.obs;

    Future<void> handleTranslate() async {
      if (isTranslating.value) return;

      if (isTranslated.value) {
        // Toggle back to original
        isTranslated.value = false;
        return;
      }

      // Translate if not already translated
      if (translatedText.value.isNotEmpty) {
        isTranslated.value = true;
        return;
      }

      isTranslating.value = true;
      try {
        final result = await TranslationService.translateToEnglish(job.description);
        translatedText.value = result;
        isTranslated.value = true;
      } catch (e) {
        Get.snackbar(
          'Translation Failed',
          'Could not translate the description. Please try again.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFFDC2626),
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
          borderRadius: 10,
        );
      } finally {
        isTranslating.value = false;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Job Details'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Get.back(),
        ),
        actions: [
          Obx(() => IconButton(
                icon: Icon(
                  isTranslated.value ? Icons.translate_rounded : Icons.translate_rounded,
                  color: isTranslated.value
                      ? theme.colorScheme.primary
                      : (isDark ? Colors.grey[500] : Colors.grey[600]),
                  size: 22,
                ),
                tooltip: isTranslated.value ? 'Show Original' : 'Translate to English',
                onPressed: handleTranslate,
              )),
          IconButton(
            icon: Icon(
              isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
              color: theme.colorScheme.primary,
              size: 22,
            ),
            tooltip: 'Toggle Theme',
            onPressed: () {
              Get.changeThemeMode(isDark ? ThemeMode.light : ThemeMode.dark);
            },
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Column(
        children: [
          // Scrollable content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: _getAvatarColor(job.companyName),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          companyInitial,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              job.title,
                              style: theme.textTheme.titleLarge?.copyWith(height: 1.25),
                            ),
                            const SizedBox(height: 4),
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

                  // Metadata
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                      ),
                    ),
                    child: Column(
                      children: [
                        _buildMetaRow(
                          icon: Icons.location_on_outlined,
                          text: job.location,
                          theme: theme,
                          isDark: isDark,
                        ),
                        Divider(
                          height: 20,
                          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                        ),
                        _buildMetaRow(
                          icon: Icons.schedule_outlined,
                          text: 'Posted ${job.timeAgo}',
                          theme: theme,
                          isDark: isDark,
                        ),
                        if (job.remote) ...[
                          Divider(
                            height: 20,
                            color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                          ),
                          _buildMetaRow(
                            icon: Icons.laptop_mac_rounded,
                            text: 'Remote position',
                            theme: theme,
                            isDark: isDark,
                            highlight: true,
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Tags
                  if (job.tags.isNotEmpty) ...[
                    Text('Skills & Tags', style: theme.textTheme.titleMedium),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: job.tags.map((tag) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF1E293B)
                                : const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            tag,
                            style: TextStyle(
                              fontSize: 13,
                              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Description header with translate toggle
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('About This Role', style: theme.textTheme.titleLarge),
                      Obx(() => TextButton.icon(
                            onPressed: handleTranslate,
                            icon: isTranslating.value
                                ? SizedBox(
                                    width: 14,
                                    height: 14,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          theme.colorScheme.primary),
                                    ),
                                  )
                                : Icon(
                                    isTranslated.value
                                        ? Icons.language_rounded
                                        : Icons.translate_rounded,
                                    size: 16,
                                    color: theme.colorScheme.primary,
                                  ),
                            label: Text(
                              isTranslating.value
                                  ? 'Translating...'
                                  : isTranslated.value
                                      ? 'Show Original'
                                      : 'Translate',
                              style: TextStyle(
                                fontSize: 13,
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                            ),
                          )),
                    ],
                  ),

                  // Translated banner
                  Obx(() => isTranslated.value
                      ? Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: isDark
                                ? theme.colorScheme.primary.withValues(alpha: 0.1)
                                : const Color(0xFFEEF2FF),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.check_circle_outline_rounded,
                                  size: 16, color: theme.colorScheme.primary),
                              const SizedBox(width: 8),
                              Text(
                                'Translated to English',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        )
                      : const SizedBox.shrink()),
                  const SizedBox(height: 4),

                  // Description content - original or translated
                  Obx(() {
                    if (isTranslated.value && translatedText.value.isNotEmpty) {
                      return Text(
                        translatedText.value,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.85),
                          height: 1.6,
                        ),
                      );
                    }
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: HtmlParser.parse(job.description, theme),
                    );
                  }),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),

          // Bottom CTA
          Container(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 14,
              bottom: Get.mediaQuery.padding.bottom > 0 ? Get.mediaQuery.padding.bottom : 14,
            ),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              border: Border(
                top: BorderSide(
                  color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                ),
              ),
            ),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _launchUrl,
                child: const Text('Apply Now'),
              ),
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
    bool highlight = false,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: highlight
              ? theme.colorScheme.primary
              : (isDark ? Colors.grey[500] : Colors.grey[500]),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: highlight
                  ? theme.colorScheme.primary
                  : (isDark ? Colors.grey[300] : Colors.grey[700]),
              fontWeight: highlight ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
      ],
    );
  }
}
