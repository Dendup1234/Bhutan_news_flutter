import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html_parser;
import 'package:bhutan_news_app_flutter/data/newsItem.dart';
import 'package:bhutan_news_app_flutter/WebScreen/webScreenActivity.dart';
import 'dart:async';

class NationTab extends StatefulWidget {
  const NationTab({super.key});

  @override
  State<NationTab> createState() => _NationTabState();
}

class _NationTabState extends State<NationTab> {
  List <NewsItem> newsItems = [];
  bool isLoading = false;
  Future <void> scrapeNews() async{
    setState(() {
      isLoading = true;
    });
    final response = await http.get(Uri.parse("https://kuenselonline.com/category/elections2024/"));
    if (response.statusCode == 200) {
      var document = html_parser.parse(response.body);
      // Helper function to extract Highlighted News section from Kuensel
      final highlightedNews = document.querySelector("div.highlight");
      final highlightedTitle = highlightedNews?.querySelector("h5.mt-0.post-title")?.text.trim() ??"No Title";
      final highlightedDate = highlightedNews?.querySelector("p.post-date")?.text.trim() ?? "No Date";
      final highlightedDescription =highlightedNews?.querySelector("p.post-date + p + p")?.text.trim() ??"No Description";
      // Extracting the image URL from the inline style
      String? highlightedImageUrl = highlightedNews
            ?.querySelector("div.media-left")
            ?.attributes['style']
            ?.split('url(')
            .last
            .split(')')
            .first ??
        '';
      // Ensure absolute URL if needed
      if (highlightedImageUrl.isNotEmpty && highlightedImageUrl.startsWith('/')) {
        highlightedImageUrl = 'https://kuenselonline.com/category/business/' + highlightedImageUrl;
    }
      final highlightedNewsUrl = highlightedNews?.querySelector("h5.mt-0.post-title a")?.attributes['href'] ?? "";

    // Adding the highlighted news item to the news list
    newsItems.add(NewsItem(
      topic: "",
      title: highlightedTitle,
      imageUrl: highlightedImageUrl,
      date: highlightedDate,
      description: highlightedDescription,
      link: highlightedNewsUrl,
      newsSource: "Kuensel",
    ));
    // Helper function to extract other featured news in the media section
    final categorySection = document.querySelector("div.category");
    final mediaNews = categorySection?.querySelectorAll("div.col-md-6") ?? [];
    for (var article in mediaNews) {
      final title = article.querySelector("h5.mt-0.post-title")?.text.trim() ?? "No Title";
      final date = article.querySelector("p.post-date")?.text.trim() ?? "No Date";
      final description = article.querySelector("p.post-date + p")?.text.trim() ?? "";

      // Extracting the image URL from the inline style
      String? imageUrl = article.querySelector("div.media-left")?.attributes['style']
          ?.split('url(')
          .last
          .split(')')
          .first ?? '';
      
      // Ensure absolute URL if needed
      if (imageUrl.isNotEmpty && imageUrl.startsWith('/')) {
        imageUrl = 'https://kuenselonline.com' + imageUrl;
      }

      final newsUrl = article.querySelector("h5.mt-0.post-title a")?.attributes['href'] ?? "";

      // Adding the featured news item to the news list
      newsItems.add(NewsItem(
        topic: "",
        title: title,
        imageUrl: imageUrl,
        date: date,
        description: description,
        link: newsUrl,
        newsSource: "Kuensel",
      ));
    }
      setState(() {
        isLoading = false;  // Hide loading indicator
      });
    } else {
      setState(() {
        isLoading = false;  // Hide loading indicator in case of failure
      });
      throw Exception('Failed to load news');
    }
  }
  @override
  void initState() {
    super.initState();
    scrapeNews();
     // Start scraping news when the app initializes
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : newsItems.isEmpty
              ? Center(child: Text('No news found'))
              : ListView.builder(
                  itemCount: newsItems.length,
                  itemBuilder: (context, index) {
                    final newsItem = newsItems[index];

                    // Display the topic header if it’s the first item or if the topic differs from the previous item
                    bool showTopicHeader = index == 0 ||
                        newsItems[index].topic != newsItems[index - 1].topic;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Show the topic header when necessary
                        if (showTopicHeader)
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 10),
                            child: Text(
                              newsItem.topic,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                                color: Color.fromARGB(255, 254, 231, 27),
                              ),
                            ),
                          ),
                        InkWell(
                          onTap: () {
                            // Navigate to WebScreenActivity with the news link
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => WebScreenActivity(
                                  url: newsItem.link,
                                ), // Pass the URL here
                              ),
                            );
                          },
                          child: Card(
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            elevation: 4,
                            margin: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            child: Padding(
                              padding: const EdgeInsets.all(8),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Image section (only show if imageUrl is not empty)
                                  if (newsItem.imageUrl.isNotEmpty)
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Image.network(
                                        newsItem.imageUrl,
                                        width: 80,
                                        height: 80,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  if (newsItem.imageUrl.isNotEmpty)
                                    const SizedBox(width: 10),

                                  // Text section
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          newsItem.title,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 5),
                                        Text(
                                          newsItem.description,
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 5),

                                        // Date and Source
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              newsItem.date,
                                              style: TextStyle(
                                                color: Colors.grey[500],
                                                fontSize: 12,
                                              ),
                                            ),
                                            Text(
                                              newsItem.newsSource,
                                              style: TextStyle(
                                                color: Colors.grey[500],
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 5),

                                        // Like icon
                                        const Align(
                                          alignment: Alignment.bottomRight,
                                          child: Icon(
                                            Icons.thumb_up_alt_outlined,
                                            size: 20,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
    );
  }
}