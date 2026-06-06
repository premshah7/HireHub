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

    return Obx(
      () => TextField(
        controller: _textController,
        onChanged: _controller.searchJobs,
        style: theme.textTheme.bodyLarge,
        decoration: InputDecoration(
          hintText: 'Search by title or company...',
          hintStyle: TextStyle(
            color: isDark ? Colors.grey[600] : Colors.grey[400],
            fontWeight: FontWeight.normal,
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            size: 20,
            color: _controller.searchQuery.isNotEmpty
                ? theme.colorScheme.primary
                : (isDark ? Colors.grey[600] : Colors.grey[400]),
          ),
          suffixIcon: _controller.searchQuery.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.close_rounded, size: 18, color: Colors.grey[500]),
                  onPressed: () {
                    _textController.clear();
                    _controller.clearSearch();
                    FocusScope.of(context).unfocus();
                  },
                )
              : null,
        ),
      ),
    );
  }
}
