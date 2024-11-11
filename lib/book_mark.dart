import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:bhutan_news_app_flutter/data/newsItem.dart';

class BookMarkTab extends StatefulWidget {
  const BookMarkTab({super.key});

  @override
  State<BookMarkTab> createState() => _BookMarkTabState();
}

class _BookMarkTabState extends State<BookMarkTab> {
  List<NewsItem> bookmarkedItems = [];

  @override
  void initState() {
    super.initState();
    _loadBookmarks();
  }

  Future<void> _loadBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    final bookmarkedData = prefs.getStringList('bookmarkedNews') ?? [];

    try {
      setState(() {
        // Map JSON strings to NewsItem objects, skip invalid entries
        bookmarkedItems = bookmarkedData.map((jsonString) {
          try {
            final jsonMap = json.decode(jsonString);
            return NewsItem.fromJson(jsonMap);
          } catch (e) {
            print("Failed to decode JSON: $e");
            return null; // Skip invalid entries
          }
        }).whereType<NewsItem>().toList(); // Filters out nulls
      });
    } catch (e) {
      print("Error loading bookmarks: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
      body: bookmarkedItems.isEmpty
          ? const Center(child: Text("No bookmarks available"))
          : ListView.builder(
              itemCount: bookmarkedItems.length,
              itemBuilder: (context, index) {
                final newsItem = bookmarkedItems[index];
                return ListTile(
                  title: Text(newsItem.title),
                  subtitle: Text(newsItem.date),
                  onTap: () {
                    // Navigate to the bookmarked news item's link
                  },
                );
              },
            ),
            backgroundColor: Colors.white,
    );
  }
}
