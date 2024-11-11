import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html_parser;
import 'package:bhutan_news_app_flutter/data/newsItem.dart';
import 'package:bhutan_news_app_flutter/WebScreen/webScreenActivity.dart';
import 'dart:async';
import 'NewsItem.dart';
class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  List<NewsItem> newsItems =
      [];// List to hold news data (title, image, description, link)
  bool isLoading = false; // To manage the loading state
  // Function to scrape news data from the website
  Future<void> scrapeNews() async {
    setState(() {
      isLoading = true; // Show loading indicator while fetching data
    });

    final response = await http.get(
        Uri.parse('https://kuenselonline.com/')); // Fetch HTML from Kuensel
    final response_2 = await http
        .get(Uri.parse("https://thebhutanese.bt/category/headline-stories/"));
    final response_3 = await http.get(Uri.parse("https://thebhutanese.bt/"));
    if (response.statusCode == 200 &&
        response_2.statusCode == 200 &&
        response_3.statusCode == 200) {
      var document = html_parser.parse(response.body);
      var document2 = html_parser.parse(response_2.body);
      var document3 = html_parser.parse(response_3.body);
      // Parse the HTML content

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

      //Bhutanese news headline news
      // Extracting the Bhutanese news articles
      final headlineArticles =
          document2.querySelector('div.post-listing.archive-box');
      final headlineMedia =
          headlineArticles?.querySelectorAll('article.item-list') ?? [];

      for (var article in headlineMedia) {
        final title = article.querySelector('h2.post-box-title')?.text.trim() ??
            'No title';
        final date =
            article.querySelector('span.tie-date')?.text.trim() ?? 'No Date';
        final description = article.querySelector('div.entry p')?.text.trim() ??
            'No Description';
        final newsUrl =
            article.querySelector('h2.post-box-title a')?.attributes['href'] ??
                'No url';
        final imageUrl = article
                .querySelector('div.post-thumbnail img')
                ?.attributes['src'] ??
            'No image url';

        // Create a NewsItem for each article and add to newsItems list
        final newsItem = NewsItem(
          title: title,
          imageUrl: imageUrl,
          description: description,
          link: newsUrl,
          date: date,
          newsSource: "From The Bhutanese News",
        );

        newsItems.add(newsItem);
      }

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
            topic: "",
            title: title,
            imageUrl: imageUrl,
            description: description,
            link: link,
            date: date,
            newsSource: "Kuensel");
      }).toList());
      // For the editorial news under the media body

      // Add Editorial news item
      newsItems.add(editorialHighlightedNewsItem);
      // Extracting the editorial section from the Bhutanese news
      final bhutaneseEditorialSection =
          document3.querySelector("section.cat-box.column2.tie-cat-27");

      // Highlighted news for the Bhutanese editorial section
      final bhutaneseHighlighted =
          bhutaneseEditorialSection?.querySelector("li.first-news");
      final bhutaneseHighlightedTitle = bhutaneseHighlighted
              ?.querySelector("h2.post-box-title")
              ?.text
              .trim() ??
          "No title";
      final bhutaneseHighlightedDate =
          bhutaneseHighlighted?.querySelector("span.tie-date")?.text.trim() ??
              "No date";
      final bhutaneseHighlightedDescription =
          bhutaneseHighlighted?.querySelector("div.entry p")?.text.trim() ??
              "No Description";
      final bhutaneseHighlightedNewsUrl = bhutaneseHighlighted
              ?.querySelector("h2.post-box-title a")
              ?.attributes['href'] ??
          "No news url";
      // Create a NewsItem object and add it to the list
      newsItems.add(NewsItem(
        topic: "",
        title: bhutaneseHighlightedTitle,
        imageUrl: "",
        date: bhutaneseHighlightedDate,
        description: bhutaneseHighlightedDescription,
        link: bhutaneseHighlightedNewsUrl,
        newsSource: "From The Bhutanese News",
      ));

      // Kuensel editorial news article
      final editorialArticle =
          editorialSection?.querySelectorAll('div.media-body') ?? [];
      newsItems.addAll(editorialArticle.map((article) {
        final titleElement = article.querySelector('h5.post-title a');
        final title = titleElement?.text.trim() ?? 'No Title';
        final link = titleElement?.attributes['href'] ?? '';
        final date =
            article.querySelector("p.post-date")?.text.trim() ?? "No Date";
        final descriptionElement = article.querySelector('p.post-date + p');
        final description = descriptionElement?.text.trim() ?? 'No Description';
        return NewsItem(
            title: title,
            description: description,
            imageUrl: '',
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
        // Extracting the news form the bhutanese news
        if (index == 0) {
          // Extracting the feature section from the Bhutanese news
          final featureSectionBhutaneseNews =
              document3.querySelector("section.cat-box.list-box.tie-cat-35");

          // Highlighted news for the Bhutanese featured section
          final highlighted =
              featureSectionBhutaneseNews?.querySelector("li.first-news");

          final title =
              highlighted?.querySelector("h2.post-box-title")?.text.trim() ??
                  "No title";
          final date =
              highlighted?.querySelector("span.tie-date")?.text.trim() ??
                  "No date";
          final description =
              highlighted?.querySelector("div.entry p")?.text.trim() ??
                  "No Description";
          final newsUrl = highlighted
                  ?.querySelector("h2.post-box-title a")
                  ?.attributes['href'] ??
              "No news url";

          // Creating a NewsItem and adding it to the list
          newsItems.add(NewsItem(
            topic: "",
            title: title,
            imageUrl: '',
            date: date,
            description: description,
            link: newsUrl,
            newsSource: "From The Bhutanese News",
          ));
        }
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

        //Extracting from the bhutanese news
        // Select the business section
        final bhutaneseBusinessSection =
            document3.querySelector("section.cat-box.list-box.tie-cat-5");
        // Create a NewsItem and add it to the list
        if (index == 0) {
          // Get the highlighted article within the business section
          final highlighted =
              bhutaneseBusinessSection?.querySelector("li.first-news");

          // Extract information from the highlighted article
          final title =
              highlighted?.querySelector("h2.post-box-title")?.text.trim() ??
                  "No title";
          final date =
              highlighted?.querySelector("span.tie-date")?.text.trim() ??
                  "No date";

          final description =
              highlighted?.querySelector("div.entry p")?.text.trim() ??
                  "No Description";
          final newsUrl = highlighted
                  ?.querySelector("h2.post-box-title a")
                  ?.attributes['href'] ??
              "No news url";
          newsItems.add(NewsItem(
            topic: "Business",
            title: title,
            imageUrl: "", // Update with actual image URL if available
            date: date,
            description: description,
            link: newsUrl,
            newsSource: "From The Bhutanese News",
          ));
        }

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
        // Select the opinion section
        final opinionSectionBhutanese = document3
            .querySelector("section.cat-box.column2.tie-cat-4.last-column");

        // Get the highlighted article within the opinion section
        final highlighted =
            opinionSectionBhutanese?.querySelector("li.first-news");

        // Extract information from the highlighted article
        final titleBhutanese =
            highlighted?.querySelector("h2.post-box-title")?.text.trim() ??
                "No title";
        final dateBhutanese =
            highlighted?.querySelector("span.tie-date")?.text.trim() ??
                "No date";
        final descriptionBhutanese =
            highlighted?.querySelector("div.entry p")?.text.trim() ??
                "No Description";
        final newsUrlBhutanese = highlighted
                ?.querySelector("h2.post-box-title a")
                ?.attributes['href'] ??
            "No news url";

        // Add the news item to the list
        newsItems.add(NewsItem(
          topic: "",
          title: titleBhutanese,
          imageUrl: "", // Update with actual image URL if available
          date: dateBhutanese,
          description: descriptionBhutanese,
          link: newsUrlBhutanese,
          newsSource: "From The Bhutanese News",
        ));
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
              : NewsList(newsItems: newsItems),
    );
  }
}
