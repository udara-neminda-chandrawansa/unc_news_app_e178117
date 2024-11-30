// imports
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'news_item.dart';

class NewsService {
  // my api key to NewsApi service
  static const String apiKey = '151039145e7a425488f5d5220a771e28';

  // this method is used to load news items from api using below attribs
  static Future<NewsItems> fetchNews({
    String category = 'general',
    String searchTerm = 'any',
    String sortBy = 'publishedAt',
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    try {
      // Determine endpoint based on date params and requirements
      // * 'everything' works with some params, 'top-headlines' with some else
      // * there are some params u cannot mix with others
      bool useEverythingEndpoint = fromDate != null || toDate != null;

      String url =
          useEverythingEndpoint
              ? 'https://newsapi.org/v2/everything?'
              : 'https://newsapi.org/v2/top-headlines?';

      // Build URL parameters
      List<String> params = ['apiKey=$apiKey'];

      if (useEverythingEndpoint) {
        // Everything endpoint parameters
        params.add('q=$searchTerm');
        if (fromDate != null) params.add('from=${fromDate.toIso8601String()}');
        if (toDate != null) params.add('to=${toDate.toIso8601String()}');
        params.add('sortBy=$sortBy');
      } else {
        // Top Headlines endpoint parameters
        if (category.isNotEmpty) params.add('category=$category');
      }

      // Combine URL and parameters
      url += params.join('&');

      final response = await http.get(Uri.parse(url));
      print('Fetched URL: $url'); // show this for debug purposes

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['totalResults'] > 0) {
          return NewsItems.fromJson(jsonData);
        } else {
          return NewsItems.withError("No news articles available.");
        }
      } else {
        return NewsItems.withError(
          'Failed to load news: ${response.statusCode}\n $url',
        );
      }
    } catch (e) {
      return NewsItems.withError('Error fetching news: $e');
    }
  }
}
