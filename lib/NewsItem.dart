import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:bhutan_news_app_flutter/data/newsItem.dart';
import 'package:bhutan_news_app_flutter/WebScreen/webScreenActivity.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert'; // For JSON encoding and decoding

class NewsList extends StatelessWidget {
  final List<NewsItem> newsItems;

  const NewsList({Key? key, required this.newsItems}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: newsItems.length,
      itemBuilder: (context, index) {
        final newsItem = newsItems[index];
        bool showTopicHeader =
            index == 0 || newsItems[index].topic != newsItems[index - 1].topic;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showTopicHeader)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Text(
                  newsItem.topic,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Color.fromARGB(255, 254, 231, 27),
                  ),
                ),
              ),
            NewsCard(newsItem: newsItem),
          ],
        );
      },
    );
  }
}

class NewsCard extends StatefulWidget {
  final NewsItem newsItem;

  const NewsCard({Key? key, required this.newsItem}) : super(key: key);

  @override
  _NewsCardState createState() => _NewsCardState();
}

class _NewsCardState extends State<NewsCard> {
  bool isBookmarked = false;

  @override
  void initState() {
    super.initState();
    _checkBookmarkStatus();
  }

  void _checkBookmarkStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final bookmarkedNewsData = prefs.getStringList('bookmarkedNews') ?? [];
    setState(() {
      isBookmarked = bookmarkedNewsData.contains(json.encode(widget.newsItem.toJson()));
    });
  }

  void _toggleBookmark() async {
    final prefs = await SharedPreferences.getInstance();
    final bookmarkedNewsData = prefs.getStringList('bookmarkedNews') ?? [];

    if (isBookmarked) {
      // Remove the bookmark if it's already bookmarked
      bookmarkedNewsData.remove(json.encode(widget.newsItem.toJson()));
    } else {
      // Add the bookmark if it's not bookmarked
      bookmarkedNewsData.add(json.encode(widget.newsItem.toJson()));
    }

    await prefs.setStringList('bookmarkedNews', bookmarkedNewsData);

    setState(() {
      isBookmarked = !isBookmarked; // Toggle the bookmark status
    });
  }

  void _shareNews(BuildContext context) {
    Share.share(widget.newsItem.link);
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => WebScreenActivity(url: widget.newsItem.link),
          ),
        );
      },
      child: Card(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        elevation: 4,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.newsItem.imageUrl.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    widget.newsItem.imageUrl,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                  ),
                ),
              if (widget.newsItem.imageUrl.isNotEmpty)
                const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.newsItem.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 5),
                    Text(
                      widget.newsItem.description,
                      style: TextStyle(color: Colors.grey[600]),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          widget.newsItem.date,
                          style: TextStyle(color: Colors.grey[500], fontSize: 12),
                        ),
                        Text(
                          widget.newsItem.newsSource,
                          style: TextStyle(color: Colors.grey[500], fontSize: 12),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          icon: Icon(Icons.share, color: Colors.blue),
                          onPressed: () => _shareNews(context),
                        ),
                        IconButton(
                          icon: Icon(
                            isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                            color: isBookmarked ? Colors.yellow[700] : Colors.grey,
                          ),
                          onPressed: _toggleBookmark,
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
  }
}
