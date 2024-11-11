class NewsItem {
  final String topic;
  final String title;
  final String imageUrl;
  final String description;
  final String link;
  final String date;
  final String newsSource;
  final DateTime? parseDate;
  NewsItem({
    this.topic = '',
    this.title = "",
    this.imageUrl = '',
    this.description="",
    this.link= "",
    this.date = '',
    this.newsSource="",
    this.parseDate,
  });
   // Convert a NewsItem to JSON
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'link': link,
      'date': date,
      'topic': topic,
      'newsSource': newsSource,
      'imageUrl': imageUrl,
    };
  }
  // Create a NewsItem from JSON
factory NewsItem.fromJson(Map<String, dynamic> json) {
  return NewsItem(
    title: json['title'],
    description: json['description'],
    link: json['link'],
    date: json['date'],
    topic: json['topic'],
    newsSource: json['newsSource'],
    imageUrl: json['imageUrl'],
  );
}
}
