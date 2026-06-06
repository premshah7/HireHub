class JobModel {
  final String title;
  final String companyName;
  final String location;
  final String description;
  final String url;
  final String slug;
  final bool remote;
  final List<String> tags;
  final DateTime createdAt;

  JobModel({
    required this.title,
    required this.companyName,
    required this.location,
    required this.description,
    required this.url,
    required this.slug,
    required this.remote,
    required this.tags,
    required this.createdAt,
  });

  factory JobModel.fromJson(Map<String, dynamic> json) {
    // Parse created_at Unix timestamp safely
    final int timestamp = json['created_at'] is int
        ? json['created_at']
        : int.tryParse(json['created_at']?.toString() ?? '') ?? 0;
    
    final DateTime parsedDate = timestamp > 0
        ? DateTime.fromMillisecondsSinceEpoch(timestamp * 1000)
        : DateTime.now();

    return JobModel(
      title: json['title']?.toString() ?? 'No Title Specified',
      companyName: json['company_name']?.toString() ?? 'No Company Name',
      location: json['location']?.toString() ?? 'Remote / Not specified',
      description: json['description']?.toString() ?? '',
      url: json['url']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
      remote: json['remote'] is bool ? json['remote'] : false,
      tags: json['tags'] != null
          ? List<String>.from(json['tags'].map((x) => x.toString()))
          : const [],
      createdAt: parsedDate,
    );
  }

  // Get a readable string representing how long ago the job was posted
  String get timeAgo {
    final difference = DateTime.now().difference(createdAt);
    if (difference.inDays >= 30) {
      final months = (difference.inDays / 30).floor();
      return '$months month${months > 1 ? 's' : ''} ago';
    } else if (difference.inDays >= 7) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks week${weeks > 1 ? 's' : ''} ago';
    } else if (difference.inDays >= 1) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours >= 1) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes >= 1) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }
}
