import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html_parser;
import 'package:bhutan_news_app_flutter/data/newsItem.dart';
import 'package:bhutan_news_app_flutter/WebScreen/webScreenActivity.dart';
import 'dart:async';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  List<NewsItem> newsItems =
      []; // List to hold news data (title, image, description, link)
  bool isLoading = false; // To manage the loading state
  // Function to scrape news data from the website
  Future<void> scrapeNews() async {
    setState(() {
      isLoading = true; // Show loading indicator while fetching data
    });

    final response = await http.get(
        Uri.parse('https://kuenselonline.com/')); // Fetch HTML from Kuensel

    if (response.statusCode == 200) {
      var document = html_parser.parse(response.body); // Parse the HTML content

      // Extract news articles from Kuensel's top stories section
      final topStoriesSection = document.querySelector('div.top-stories');
      final editorialSection = document.querySelector('div.editorial');

      // Extract highlighted news from Top Stories
      final topStoriesHighlighted =
          topStoriesSection?.querySelector("div.highlight");
      final highlightedTitle =
          topStoriesHighlighted?.querySelector("h3.post-title")?.text.trim() ??
              "No Title";
      final highlightedDate =
          topStoriesHighlighted?.querySelector("p.post-date")?.text.trim() ??
              "No date";
      final highlightedDescription = topStoriesHighlighted
              ?.querySelector("p.post-date + p")
              ?.text
              .trim() ??
          "No Description";
      String? highlightedImageUrl = topStoriesHighlighted
              ?.querySelector("div.featured-img img")
              ?.attributes['src'] ??
          '';
      String? highlightedNewsUrl = topStoriesHighlighted
              ?.querySelector("h3.post-title a")
              ?.attributes['href'] ??
          '';

      // Create a NewsItem for highlighted news and add to the list
      final highlightedNewsItem = NewsItem(
          topic: "Top Stories",
          title: highlightedTitle,
          imageUrl: highlightedImageUrl,
          description: highlightedDescription,
          link: highlightedNewsUrl,
          date: highlightedDate,
          newsSource: "Kuensel");
      newsItems.add(highlightedNewsItem);

      // For the kuensel Editorial news highlight
      final editorialHighlight = editorialSection?.querySelector("div.row");
      final editorialHighlightedTitle =
          editorialHighlight?.querySelector("h3.post-title")?.text.trim() ??
              "No Title";
      final editorialHighlightedDate =
          editorialHighlight?.querySelector("p.post-date")?.text.trim() ??
              "No date";
      final editorialHighlightedDescription =
          editorialHighlight?.querySelector("p.post-date + p")?.text.trim() ??
              "No Description";
      String? editorialHighlightedImageUrl = editorialHighlight
              ?.querySelector("div.featured-img img")
              ?.attributes['src'] ??
          '';
      String? editorialHighlightedNewsUrl = editorialHighlight
              ?.querySelector("h3.post-title a")
              ?.attributes['href'] ??
          '';

      final editorialHighlightedNewsItem = NewsItem(
          topic: "Editorial",
          title: editorialHighlightedTitle,
          imageUrl: editorialHighlightedImageUrl,
          description: editorialHighlightedDescription,
          link: editorialHighlightedNewsUrl,
          date: editorialHighlightedDate,
          newsSource: "Kuensel");

      // Extract other news articles under Top Stories
      final newsArticles =
          topStoriesSection?.querySelectorAll('div.media-body') ?? [];
      // Iterate over the media body of the highlighted news
      newsItems.addAll(newsArticles.map((article) {
        final titleElement = article.querySelector('h5.post-title a');
        final title = titleElement?.text.trim() ?? 'No Title';
        final link = titleElement?.attributes['href'] ?? '';
        final date =
            article.querySelector("p.post-date")?.text.trim() ?? "No Date";
        final descriptionElement = article.querySelector('p.post-date + p');
        final description = descriptionElement?.text.trim() ?? 'No Description';
        final imageElement = article.querySelector('div.featured-img img');
        String? imageUrl = imageElement?.attributes['src'] ?? '';
        // Check if the image URL is relative and convert to absolute
        if (imageUrl.isNotEmpty && imageUrl.startsWith('/')) {
          imageUrl = 'https://kuenselonline.com' + imageUrl;
        }
        return NewsItem(
            topic: "Top Stories",
            title: title,
            imageUrl: imageUrl,
            description: description,
            link: link,
            date: date,
            newsSource: "Kuensel");
      }).toList());
      // For the editorial news under the media body
      final editorialArticle =
          editorialSection?.querySelectorAll('div.media-body') ?? [];
      // Add Editorial news item
      newsItems.add(editorialHighlightedNewsItem);
      newsItems.addAll(editorialArticle.map((article) {
        final titleElement = article.querySelector('h5.post-title a');
        final title = titleElement?.text.trim() ?? 'No Title';
        final link = titleElement?.attributes['href'] ?? '';
        final date =
            article.querySelector("p.post-date")?.text.trim() ?? "No Date";
        final descriptionElement = article.querySelector('p.post-date + p');
        final description = descriptionElement?.text.trim() ?? 'No Description';
        final imageElement = article.querySelector('div.featured-img img');
        String? imageUrl = imageElement?.attributes['src'] ?? '';
        // Check if the image URL is relative and convert to absolute
        if (imageUrl.isNotEmpty && imageUrl.startsWith('/')) {
          imageUrl = 'https://kuenselonline.com' + imageUrl;
        }
        return NewsItem(
            title: title,
            imageUrl: imageUrl,
            description: description,
            link: link,
            date: date,
            newsSource: "Kuensel");
      }));
      //Extracting Sports and Features sections from Kuensel
      final sportsSections = document.querySelectorAll("div.sports");
      for (int index = 0; index < sportsSections.length; index++) {
        final sportsSection = sportsSections[index];
        final sectionTitle = index == 0 ? "Features" : "Sports";
        // Extracting the highlighted news for the features
        final featuredHighlighted =
            sportsSection.querySelector("div.highlight");
        final featureHighlightedTitle =
            featuredHighlighted?.querySelector("h3.post-title")?.text.trim() ??
                "No Title";
        final featureHighlightedDate =
            featuredHighlighted?.querySelector("p.post-date")?.text.trim() ??
                "No date";
        final featureHighlightedDescription = featuredHighlighted
                ?.querySelector("p.post-date + p")
                ?.text
                .trim() ??
            "No description";
        final imageElement =
            featuredHighlighted?.querySelector("div.featured-img img");
        String? featureHighlightedImageUrl =
            imageElement?.attributes['src'] ?? '';
        final featureHighlightedNewsUrl = featuredHighlighted
                ?.querySelector("h3.post-title a")
                ?.attributes['href'] ??
            '';

        newsItems.add(NewsItem(
            topic: sectionTitle,
            title: featureHighlightedTitle,
            imageUrl: featureHighlightedImageUrl,
            description: featureHighlightedDescription,
            link: featureHighlightedNewsUrl,
            date: featureHighlightedDate,
            newsSource: "Kuensel"));

        // Extract the media body from the sports section
        final featureMediaArticles =
            sportsSection.querySelectorAll("div.media-body") ?? [];

        for (var article in featureMediaArticles) {
          final title = article.querySelector("h5.post-title a")?.text.trim() ??
              "No title";
          final date =
              article.querySelector("p.post-date")?.text.trim() ?? "No Date";
          final description =
              article.querySelector("p.post-date + p")?.text.trim() ??
                  "No description";
          final newsUrl =
              article.querySelector("h5.post-title a")?.attributes['href'] ??
                  '';

          newsItems.add(NewsItem(
              title: title,
              imageUrl:
                  '', // No image provided in this section, so leave it empty
              description: description,
              link: newsUrl,
              date: date,
              newsSource: "Kuensel"));
        }
      }
      // Extract Business section from Kuensel
      final businessSections = document.querySelectorAll("div.business");

      for (int index = 0; index < businessSections.length; index++) {
        final businessSection = businessSections[index];
        final sectionTitle = index == 0
            ? "Business"
            : index == 1
                ? "LifeStyle"
                : "ANN";

        final businessTitleText =
            businessSection.querySelector("div.title h1")?.text.trim() ??
                sectionTitle;

        // Extracting highlighted news for the business section
        final businessHighlighted =
            businessSection.querySelector("div.highlight");
        final businessHighlightedTitle =
            businessHighlighted?.querySelector("h3.post-title")?.text.trim() ??
                "No Title";
        final businessHighlightedDate =
            businessHighlighted?.querySelector("p.post-date")?.text.trim() ??
                "No date";
        final businessHighlightedDescription = businessHighlighted
                ?.querySelector("p.post-date + p")
                ?.text
                .trim() ??
            "No description";
        String? businessHighlightedImageUrl = businessHighlighted
                ?.querySelector("div.featured-img img")
                ?.attributes['src'] ??
            '';
        String? businessHighlightedNewsUrl = businessHighlighted
                ?.querySelector("h3.post-title a")
                ?.attributes['href'] ??
            '';

        if (businessHighlightedImageUrl.isNotEmpty &&
            businessHighlightedImageUrl.startsWith('/')) {
          businessHighlightedImageUrl =
              'https://kuenselonline.com' + businessHighlightedImageUrl;
        }

        newsItems.add(NewsItem(
            topic: businessTitleText,
            title: businessHighlightedTitle,
            imageUrl: businessHighlightedImageUrl,
            description: businessHighlightedDescription,
            link: businessHighlightedNewsUrl,
            date: businessHighlightedDate,
            newsSource: "Kuensel"));

        // Extracting other articles from the business section
        final businessMediaArticles =
            businessSection.querySelectorAll("div.media-body") ?? [];
        for (var article in businessMediaArticles) {
          final title = article.querySelector("h5.post-title a")?.text.trim() ??
              "No title";
          final date =
              article.querySelector("p.post-date")?.text.trim() ?? "No Date";
          final description =
              article.querySelector("p.post-date + p")?.text.trim() ??
                  "No description";
          String? newsUrl =
              article.querySelector("h5.post-title a")?.attributes['href'] ??
                  '';

          newsItems.add(NewsItem(
              topic: '',
              title: title,
              imageUrl: '', // No image for this section, so leave it empty
              description: description,
              link: newsUrl,
              date: date,
              newsSource: "Kuensel"));
        }
      }

      // Helper function to extract Opinion section from Kuensel
      final opinionSection = document.querySelector("div.opinions");

      if (opinionSection != null) {
        final opinionTitle =
            opinionSection.querySelector("div.title h1")?.text.trim() ??
                "Opinions";

        // Extracting articles under the Opinion section
        final opinionMediaArticles =
            opinionSection.querySelectorAll("div.media-body") ?? [];
        for (var article in opinionMediaArticles) {
          final title = article.querySelector("h5.post-title a")?.text.trim() ??
              "No title";
          final date =
              article.querySelector("p.post-date")?.text.trim() ?? "No Date";
          final description =
              article.querySelector("p.post-date + p")?.text.trim() ??
                  "No description";
          String? newsUrl =
              article.querySelector("h5.post-title a")?.attributes['href'] ??
                  '';

          newsItems.add(NewsItem(
              topic: opinionTitle,
              title: title,
              imageUrl: '', // No image for this section, so leave it empty
              description: description,
              link: newsUrl,
              date: date,
              newsSource: "Kuensel"));
        }
      }

      setState(() {
        isLoading = false; // Hide loading indicator
      });
    } else {
      setState(() {
        isLoading = false; // Hide loading indicator in case of failure
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
