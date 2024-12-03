// this class demonstrate what a 'News' is
class News {
  final String title;
  final String description;
  final String content;
  final String url;
  final String urlToImage;
  final String author;
  final String publishedAt;
  final String source;

  News({
    required this.title,
    required this.description,
    required this.content,
    required this.url,
    required this.urlToImage,
    required this.author,
    required this.publishedAt,
    required this.source,
  });

  // this method is used to convert json data to 'News' objects
  factory News.fromJson(Map<String, dynamic> json) {
    return News(
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      content: json['content'] ?? '',
      url: json['url'] ?? '',
      urlToImage: json['urlToImage'] ?? '',
      author: json['author'] ?? 'Unknown Author',
      publishedAt: json['publishedAt'] ?? '',
      source: json['source']['name'] ?? 'Unknown Source',
    );
  }
}

// class for making news list objects
class NewsItems {
  final List<News> data;
  final String? errorMessage; // New optional error message property

  NewsItems({
    required this.data,
    this.errorMessage, // Make it optional
  });

  factory NewsItems.fromJson(Map<String, dynamic> json) {
    return NewsItems(
      data: List<News>.from(
        (json['articles'] ?? []).map((item) => News.fromJson(item)),
      ),
    );
  }

  // Factory constructor for error cases
  factory NewsItems.withError(String message) {
    return NewsItems(data: [], errorMessage: message);
  }
}
