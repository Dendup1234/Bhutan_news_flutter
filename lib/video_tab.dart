import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:bhutan_news_app_flutter/videoPlayerPage.dart';
import 'package:bhutan_news_app_flutter/data/youtubeVideo.dart';

class VideoTab extends StatefulWidget {
  const VideoTab({super.key});

  @override
  State<VideoTab> createState() => _VideoTabState();
}

class _VideoTabState extends State<VideoTab> {
  late Future<List<YouTubeVideo>> futureVideos;

  Future<List<YouTubeVideo>> fetchYouTubeVideos() async {
    const String apiKey = 'AIzaSyDJU7cWYrOHn2kytEtaCvVewmTPxtQ-FHg'; // Replace with your YouTube API key
    const String channelId = 'UCzZIEQX2fWAmsvztJjIb7eA'; // Bhutan Broadcasting Service Channel ID
    const int maxResults = 20;

    final url = Uri.parse(
        'https://www.googleapis.com/youtube/v3/search?part=snippet&channelId=$channelId&order=date&maxResults=$maxResults&key=$apiKey');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> items = data['items'];
      return items.map((json) => YouTubeVideo.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load videos');
    }
  }

  @override
  void initState() {
    super.initState();
    futureVideos = fetchYouTubeVideos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: Center(
            child: Image.asset(
              'assets/bhutan_news_logo.png', // Add your logo path here
              height: 40.0,
            ),
          ),
      ),
      body: FutureBuilder<List<YouTubeVideo>>(
        future: futureVideos,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Failed to load videos'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No videos found'));
          } else {
            final videos = snapshot.data!;
            return ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: videos.length,
              itemBuilder: (context, index) {
                final video = videos[index];
                final isLive = video.isLive; // Assuming `isLive` is a boolean in `YouTubeVideo` class

                return Card(
                  elevation: 4,
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: InkWell(
                    onTap: () {
                      // Navigate to video player page when tapped
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => VideoPlayerPage(videoId: video.videoId),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Row(
                        children: [
                          // Thumbnail image
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(
                              video.thumbnailUrl,
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(width: 10),

                          // Title, description, and live indicator
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Video title
                                Text(
                                  video.title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 5),

                                // Published time or "Live" indicator
                                Row(
                                  children: [
                                    if (isLive) ...[
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Colors.red,
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: const Text(
                                          'LIVE',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                    ],
                                    Text(
                                      video.publishedTime, // Assuming `publishedTime` is a string
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
