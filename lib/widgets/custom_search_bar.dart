import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/job_controller.dart';

class CustomSearchBar extends StatefulWidget {
  const CustomSearchBar({super.key});

  @override
  State<CustomSearchBar> createState() => _CustomSearchBarState();
}

class _CustomSearchBarState extends State<CustomSearchBar> {
  final JobController _controller = Get.find<JobController>();
  late final TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: _controller.searchQuery.value);

    // Sync TextController with Rx string if it gets cleared externally
    _controller.searchQuery.listen((val) {
      if (val.isEmpty && _textController.text.isNotEmpty) {
        _textController.clear();
      }
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: isDark 
                ? Colors.black.withValues(alpha: 0.2) 
                : Colors.grey.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Obx(
        () => TextField(
          controller: _textController,
          onChanged: _controller.searchJobs,
          style: theme.textTheme.bodyLarge,
          decoration: InputDecoration(
            hintText: 'Search by title or company...',
            hintStyle: TextStyle(
              color: isDark ? Colors.grey[500] : Colors.grey[400],
            ),
            prefixIcon: Icon(
              Icons.search_rounded,
              color: _controller.searchQuery.isNotEmpty 
                  ? theme.colorScheme.primary 
                  : Colors.grey,
            ),
            suffixIcon: _controller.searchQuery.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear_rounded),
                    color: Colors.grey,
                    onPressed: () {
                      _textController.clear();
                      _controller.clearSearch();
                      FocusScope.of(context).unfocus();
                    },
                  )
                : null,
            filled: true,
            fillColor: isDark ? theme.colorScheme.surface : Colors.white,
            contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: theme.colorScheme.primary,
                width: 1.5,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
