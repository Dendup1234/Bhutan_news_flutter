import 'package:flutter/material.dart';
import 'package:bhutan_news_app_flutter/data/newsItem.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html_parser;
import 'package:bhutan_news_app_flutter/WebScreen/webScreenActivity.dart';
import 'package:intl/intl.dart';
import 'NewsItem.dart';
class NewsTab extends StatefulWidget {
  const NewsTab({super.key});

  @override
  State<NewsTab> createState() => _NewsTabState();
}

class _NewsTabState extends State<NewsTab> {
  List<NewsItem> newsItems = [];
  bool isLoading = false;
  // Datetime to the string conversion
  String formatDateTime(DateTime date) {
    final DateFormat formatter = DateFormat('MMMM d, yyyy');
    return formatter.format(date);
  }

  // Function to clean and parse formatted dates, with added error handling
  DateTime? parseFormattedDate(String date) {
  try {
    // Remove any ordinal suffixes (st, nd, rd, th) from the date string
    String cleanedDate = date.replaceAllMapped(RegExp(r'(\d+)(st|nd|rd|th)'), (match) => match.group(1)!);

    final DateFormat formatter = DateFormat('MMMM d, yyyy');
    return formatter.parse(cleanedDate);
  } catch (e) {
    return null; // Return null if parsing fails
  }
}



  // Convert relative dates (like "2 days ago") to absolute dates
  DateTime convertRelativeDate(String relativeDate) {
    final now = DateTime.now();

    if (relativeDate.contains("day")) {
      int daysAgo = int.parse(relativeDate.split(" ")[0]);
      return now.subtract(Duration(days: daysAgo));
    } else if (relativeDate.contains("week")) {
      int weeksAgo = int.parse(relativeDate.split(" ")[0]);
      return now.subtract(Duration(days: weeksAgo * 7));
    } else if (relativeDate.contains("month")) {
      int monthsAgo = int.parse(relativeDate.split(" ")[0]);
      return DateTime(now.year, now.month - monthsAgo, now.day);
    } else if (relativeDate.contains("year")) {
      int yearsAgo = int.parse(relativeDate.split(" ")[0]);
      return DateTime(now.year - yearsAgo, now.month, now.day);
    }

    return now; // Default to current date if parsing fails
  }

  // Sorting news by parseDate in descending order
  void sortNewsListByDate() {
    newsItems.sort((a, b) => (b.parseDate ?? DateTime(0)).compareTo(a.parseDate ?? DateTime(0)));
  }

  Future<void> scrapeNews() async {
    setState(() {
      isLoading = true;
    });

    final response = await http.get(Uri.parse("https://kuenselonline.com/category/news/"));
    final response2 = await http.get(Uri.parse("https://thebhutanese.bt/category/news/"));
    final response3 = await http.get(Uri.parse("https://thebhutanese.bt/category/gewogs-and-dzongkhags/"));
    if (response.statusCode == 200 && response2.statusCode == 200 && response3.statusCode==200) {
      var document = html_parser.parse(response.body);
      var document2 = html_parser.parse(response2.body);
      var document3 = html_parser.parse(response3.body);
      // Kuensel news
      final highlightedNews = document.querySelector("div.highlight");
      final highlightedTitle = highlightedNews?.querySelector("h5.mt-0.post-title")?.text.trim() ?? "No Title";
      final highlightedDate = highlightedNews?.querySelector("p.post-date")?.text.trim() ?? "No Date";
      DateTime? highlightedParsedDate = parseFormattedDate(highlightedDate) ?? DateTime(0);
      final highlightedDescription = highlightedNews?.querySelector("p.post-date + p + p")?.text.trim() ?? "No Description";
      String? highlightedImageUrl = highlightedNews?.querySelector("div.media-left")?.attributes['style']?.split('url(').last.split(')').first ?? '';
      if (highlightedImageUrl.isNotEmpty && highlightedImageUrl.startsWith('/')) {
        highlightedImageUrl = 'https://kuenselonline.com' + highlightedImageUrl;
      }
      final highlightedNewsUrl = highlightedNews?.querySelector("h5.mt-0.post-title a")?.attributes['href'] ?? "";

      newsItems.add(NewsItem(
        topic: "",
        title: highlightedTitle,
        imageUrl: highlightedImageUrl,
        date: highlightedDate,
        description: highlightedDescription,
        link: highlightedNewsUrl,
        newsSource: "Kuensel",
        parseDate: highlightedParsedDate,
      ));

      // Additional Kuensel news articles
      final categorySection = document.querySelector("div.category");
      final mediaNews = categorySection?.querySelectorAll("div.col-md-6") ?? [];
      for (var article in mediaNews) {
        final title = article.querySelector("h5.mt-0.post-title")?.text.trim() ?? "No Title";
        final date = article.querySelector("p.post-date")?.text.trim() ?? "No Date";
        DateTime parsedDate = parseFormattedDate(date) ?? DateTime(0);
        final description = article.querySelector("p.post-date + p")?.text.trim() ?? "";
        String? imageUrl = article.querySelector("div.media-left")?.attributes['style']?.split('url(').last.split(')').first ?? '';
        if (imageUrl.isNotEmpty && imageUrl.startsWith('/')) {
          imageUrl = 'https://kuenselonline.com' + imageUrl;
        }
        final newsUrl = article.querySelector("h5.mt-0.post-title a")?.attributes['href'] ?? "";

        newsItems.add(NewsItem(
          topic: "",
          title: title,
          imageUrl: imageUrl,
          date: date,
          description: description,
          link: newsUrl,
          newsSource: "Kuensel",
          parseDate: parsedDate,
        ));
      }

      // Bhutanese news
      final bhutaneseNewsSection = document2.querySelector("div.post-listing.archive-box");
      final bhutaneseNews = bhutaneseNewsSection?.querySelectorAll("article.item-list");

      if (bhutaneseNews != null) {
        for (var article in bhutaneseNews) {
          final title = article.querySelector("h2.post-box-title")?.text.trim() ?? "";
          final date = article.querySelector("span.tie-date")?.text.trim() ?? "";
          DateTime parsedDate = convertRelativeDate(date);
          final formattedDate = formatDateTime(parsedDate);
          final description = article.querySelector("div.entry p")?.text.trim() ?? "";
          final imageUrl = article.querySelector("div.post-thumbnail img")?.attributes['src'] ?? '';
          final newsUrl = article.querySelector("h2.post-box-title a")?.attributes['href'] ?? "";

          newsItems.add(NewsItem(
            topic: "",
            title: title,
            imageUrl: imageUrl,
            date: formattedDate,
            description: description,
            link: newsUrl,
            newsSource: "From Bhutanese News",
            parseDate: parsedDate,
          ));
        }
      }
      // Bhutanese news
      final bhutaneseNewsSection_2 = document3.querySelector("div.post-listing.archive-box");
      final bhutaneseNews_2 = bhutaneseNewsSection_2?.querySelectorAll("article.item-list");

      if (bhutaneseNews_2 != null) {
        for (var article in bhutaneseNews_2) {
          final title = article.querySelector("h2.post-box-title")?.text.trim() ?? "";
          final date = article.querySelector("span.tie-date")?.text.trim() ?? "";
          DateTime parsedDate = convertRelativeDate(date);
          final formattedDate = formatDateTime(parsedDate);
          final description = article.querySelector("div.entry p")?.text.trim() ?? "";
          final imageUrl = article.querySelector("div.post-thumbnail img")?.attributes['src'] ?? '';
          final newsUrl = article.querySelector("h2.post-box-title a")?.attributes['href'] ?? "";

          newsItems.add(NewsItem(
            topic: "",
            title: title,
            imageUrl: imageUrl,
            date: formattedDate,
            description: description,
            link: newsUrl,
            newsSource: "From Bhutanese News",
            parseDate: parsedDate,
          ));
        }
      }

      // Call the sorting function
      sortNewsListByDate();
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
              : NewsList(newsItems: newsItems),
    );
  }
}