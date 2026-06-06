import 'package:get/get.dart';
import '../models/job_model.dart';
import '../services/api_service.dart';

class JobController extends GetxController {
  final ApiService _apiService = ApiService();

  // Reactive variables
  final RxList<JobModel> jobs = <JobModel>[].obs;
  final RxList<JobModel> filteredJobs = <JobModel>[].obs;
  final RxBool loading = false.obs;
  final RxBool error = false.obs;
  final RxString errorMessage = ''.obs;

  // Bookmarks management
  final RxSet<String> bookmarkedJobSlugs = <String>{}.obs;

  // Applied jobs tracking
  final RxSet<String> appliedJobSlugs = <String>{}.obs;

  // Search query state
  final RxString searchQuery = ''.obs;

  // Pagination variables
  int _currentPage = 1;
  final RxBool hasMore = true.obs;
  final RxBool isMoreLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Load initial jobs
    fetchJobs();

    // Listen to changes in searchQuery and jobs list to automatically filter
    everAll([jobs, searchQuery], (_) {
      _applyFilter();
    });
  }

  /// Fetches jobs from the API.
  /// If [isRefresh] is true, resets pagination and clears the list.
  Future<void> fetchJobs({bool isRefresh = false}) async {
    if (isRefresh) {
      _currentPage = 1;
      hasMore.value = true;
      error.value = false;
      errorMessage.value = '';
    }

    // Prevent fetch if we are already loading or if there are no more pages
    if (loading.value || isMoreLoading.value || !hasMore.value) return;

    if (_currentPage == 1) {
      loading.value = true;
    } else {
      isMoreLoading.value = true;
    }

    try {
      final newJobs = await _apiService.fetchJobs(page: _currentPage);
      
      if (newJobs.isEmpty) {
        hasMore.value = false;
      } else {
        if (_currentPage == 1) {
          jobs.assignAll(newJobs);
        } else {
          jobs.addAll(newJobs);
        }
        _currentPage++;
      }
      error.value = false;
      errorMessage.value = '';
    } catch (e) {
      error.value = true;
      errorMessage.value = e.toString().replaceFirst('Exception: ', '');
    } finally {
      loading.value = false;
      isMoreLoading.value = false;
    }
  }

  /// Filters jobs list based on query.
  void searchJobs(String query) {
    searchQuery.value = query;
  }

  /// Retries the last failed operation
  void retry() {
    fetchJobs(isRefresh: true);
  }

  /// Toggles bookmarked job slugs
  void toggleBookmark(String slug) {
    if (bookmarkedJobSlugs.contains(slug)) {
      bookmarkedJobSlugs.remove(slug);
    } else {
      bookmarkedJobSlugs.add(slug);
    }
  }

  /// Checks if a job slug is bookmarked
  bool isBookmarked(String slug) {
    return bookmarkedJobSlugs.contains(slug);
  }

  /// Marks a job as applied
  void applyForJob(String slug) {
    appliedJobSlugs.add(slug);
  }

  /// Checks if a job has been applied to
  bool isApplied(String slug) {
    return appliedJobSlugs.contains(slug);
  }

  /// Clears the current search query
  void clearSearch() {
    searchQuery.value = '';
  }

  /// Core logic to filter jobs list based on searchQuery (by title or company).
  void _applyFilter() {
    final query = searchQuery.value.trim().toLowerCase();
    if (query.isEmpty) {
      filteredJobs.assignAll(jobs);
    } else {
      filteredJobs.assignAll(
        jobs.where((job) {
          final matchesTitle = job.title.toLowerCase().contains(query);
          final matchesCompany = job.companyName.toLowerCase().contains(query);
          final matchesLocation = job.location.toLowerCase().contains(query);
          return matchesTitle || matchesCompany || matchesLocation;
        }).toList(),
      );
    }
  }
}
