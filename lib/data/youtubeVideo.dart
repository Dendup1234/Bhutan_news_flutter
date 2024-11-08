class YouTubeVideo {
  final String videoId;
  final String title;
  final String description;
  final String thumbnailUrl;
  final bool isLive;
  final String publishedTime;

  YouTubeVideo({
    required this.videoId,
    required this.title,
    required this.description,
    required this.thumbnailUrl,
    required this.isLive,
    required this.publishedTime,
  });

  factory YouTubeVideo.fromJson(Map<String, dynamic> json) {
    // Check if the video is live
    final isLiveContent = json['snippet']['liveBroadcastContent'] == 'live';

    // Format the published date
    final rawPublishedTime = json['snippet']['publishedAt'];
    final formattedPublishedTime = _formatPublishedTime(rawPublishedTime);

    return YouTubeVideo(
      videoId: json['id']['videoId'],
      title: json['snippet']['title'],
      description: json['snippet']['description'],
      thumbnailUrl: json['snippet']['thumbnails']['high']['url'],
      isLive: isLiveContent,
      publishedTime: formattedPublishedTime,
    );
  }

  // Helper function to format the published date
  static String _formatPublishedTime(String publishedAt) {
    DateTime dateTime = DateTime.parse(publishedAt);
    Duration difference = DateTime.now().difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minutes ago';
    } else {
      return 'Just now';
    }
  }
}
