import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/news_article.dart';

class NewsService {
  // Mock API data - Replace this with your actual API endpoint
  static const int _itemsPerPage = 10;

  // Mock news data for demonstration
  static final List<Map<String, dynamic>> _mockNewsData = [
    {
      "position": 1,
      "title":
          "After half a decade, the Russian space station segment stopped leaking",
      "source": {
        "name": "Ars Technica",
        "icon":
            "https://encrypted-tbn0.gstatic.com/faviconV2?url=https://arstechnica.com&client=NEWS_360&size=96&type=FAVICON&fallback_opts=TYPE,SIZE,URL",
        "authors": ["Eric Berger"],
      },
      "link":
          "https://arstechnica.com/space/2026/01/finally-some-good-news-for-russia-the-space-station-is-no-longer-leaking/",
      "thumbnail":
          "https://cdn.arstechnica.net/wp-content/uploads/2024/11/51711929238_21004924c2_k-768x432.jpg",
      "iso_date": "2026-01-02T15:30:13Z",
    },
    {
      "position": 2,
      "title": "SpaceX launches new satellite constellation",
      "source": {
        "name": "TechCrunch",
        "icon":
            "https://encrypted-tbn0.gstatic.com/faviconV2?url=https://techcrunch.com&client=NEWS_360&size=96&type=FAVICON",
        "authors": ["Sarah Chen"],
      },
      "link": "https://techcrunch.com/2026/01/02/spacex-satellites/",
      "thumbnail":
          "https://cdn.techcrunch.com/wp-content/uploads/2024/01/spacex.jpg",
      "iso_date": "2026-01-02T14:20:00Z",
    },
    {
      "position": 3,
      "title": "NASA discovers new exoplanet",
      "source": {
        "name": "Space.com",
        "icon":
            "https://encrypted-tbn0.gstatic.com/faviconV2?url=https://space.com&client=NEWS_360&size=96&type=FAVICON",
        "authors": ["Mike Wall"],
      },
      "link": "https://space.com/2026/01/02/nasa-exoplanet/",
      "thumbnail":
          "https://cdn.space.com/wp-content/uploads/2024/01/exoplanet.jpg",
      "iso_date": "2026-01-02T13:15:00Z",
    },
    {
      "position": 4,
      "title": "International Space Station receives new modules",
      "source": {
        "name": "BBC News",
        "icon":
            "https://encrypted-tbn0.gstatic.com/faviconV2?url=https://bbc.com&client=NEWS_360&size=96&type=FAVICON",
        "authors": ["James Cook"],
      },
      "link": "https://bbc.com/news/2026/01/02/iss-modules/",
      "thumbnail": "https://cdn.bbc.com/news/2024/01/iss.jpg",
      "iso_date": "2026-01-02T12:00:00Z",
    },
    {
      "position": 5,
      "title": "China launches lunar rover mission",
      "source": {
        "name": "Reuters",
        "icon":
            "https://encrypted-tbn0.gstatic.com/faviconV2?url=https://reuters.com&client=NEWS_360&size=96&type=FAVICON",
        "authors": ["Zhang Wei"],
      },
      "link": "https://reuters.com/2026/01/02/china-lunar-rover/",
      "thumbnail": "https://cdn.reuters.com/news/2024/01/lunar.jpg",
      "iso_date": "2026-01-02T11:30:00Z",
    },
    {
      "position": 6,
      "title": "JWST observes distant galaxy",
      "source": {
        "name": "Science Daily",
        "icon":
            "https://encrypted-tbn0.gstatic.com/faviconV2?url=https://sciencedaily.com&client=NEWS_360&size=96&type=FAVICON",
        "authors": ["John Smith"],
      },
      "link": "https://sciencedaily.com/2026/01/02/jwst-galaxy/",
      "thumbnail": "https://cdn.sciencedaily.com/news/2024/01/galaxy.jpg",
      "iso_date": "2026-01-01T16:45:00Z",
    },
    {
      "position": 7,
      "title": "Blue Origin tests new spacecraft",
      "source": {
        "name": "The Verge",
        "icon":
            "https://encrypted-tbn0.gstatic.com/faviconV2?url=https://theverge.com&client=NEWS_360&size=96&type=FAVICON",
        "authors": ["Andrew Liptak"],
      },
      "link": "https://theverge.com/2026/01/01/blue-origin-spacecraft/",
      "thumbnail": "https://cdn.theverge.com/news/2024/01/blue-origin.jpg",
      "iso_date": "2026-01-01T15:20:00Z",
    },
    {
      "position": 8,
      "title": "Virgin Galactic completes suborbital flight",
      "source": {
        "name": "CNN",
        "icon":
            "https://encrypted-tbn0.gstatic.com/faviconV2?url=https://cnn.com&client=NEWS_360&size=96&type=FAVICON",
        "authors": ["Rachel Crane"],
      },
      "link": "https://cnn.com/2026/01/01/virgin-galactic/",
      "thumbnail": "https://cdn.cnn.com/news/2024/01/virgin-galactic.jpg",
      "iso_date": "2026-01-01T14:00:00Z",
    },
    {
      "position": 9,
      "title": "Axiom Station expansion continues",
      "source": {
        "name": "Space News",
        "icon":
            "https://encrypted-tbn0.gstatic.com/faviconV2?url=https://spacenews.com&client=NEWS_360&size=96&type=FAVICON",
        "authors": ["Caleb Henry"],
      },
      "link": "https://spacenews.com/2026/01/01/axiom-expansion/",
      "thumbnail": "https://cdn.spacenews.com/news/2024/01/axiom.jpg",
      "iso_date": "2026-01-01T13:30:00Z",
    },
    {
      "position": 10,
      "title": "ESA announces Mars mission timeline",
      "source": {
        "name": "ESA News",
        "icon":
            "https://encrypted-tbn0.gstatic.com/faviconV2?url=https://esa.int&client=NEWS_360&size=96&type=FAVICON",
        "authors": ["Pierre Dubois"],
      },
      "link": "https://esa.int/2026/01/01/mars-mission/",
      "thumbnail": "https://cdn.esa.int/news/2024/01/mars.jpg",
      "iso_date": "2026-01-01T12:15:00Z",
    },
    {
      "position": 11,
      "title": "India's space program achieves milestone",
      "source": {
        "name": "ISRO",
        "icon":
            "https://encrypted-tbn0.gstatic.com/faviconV2?url=https://isro.gov.in&client=NEWS_360&size=96&type=FAVICON",
        "authors": ["Rajesh Kumar"],
      },
      "link": "https://isro.gov.in/2026/01/01/milestone/",
      "thumbnail": "https://cdn.isro.gov.in/news/2024/01/isro.jpg",
      "iso_date": "2026-01-01T11:00:00Z",
    },
    {
      "position": 12,
      "title": "Starship makes progress toward Mars",
      "source": {
        "name": "SpaceX Blog",
        "icon":
            "https://encrypted-tbn0.gstatic.com/faviconV2?url=https://spacex.com&client=NEWS_360&size=96&type=FAVICON",
        "authors": ["Elon Musk"],
      },
      "link": "https://spacex.com/2026/01/01/starship-mars/",
      "thumbnail": "https://cdn.spacex.com/news/2024/01/starship.jpg",
      "iso_date": "2026-01-01T10:30:00Z",
    },
  ];

  Future<List<NewsArticle>> fetchNews({required int page}) async {
    try {
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 500));

      // Calculate pagination
      final startIndex = (page - 1) * _itemsPerPage;
      final endIndex = startIndex + _itemsPerPage;

      // Get paginated data
      final paginatedData = _mockNewsData.sublist(
        startIndex,
        endIndex > _mockNewsData.length ? _mockNewsData.length : endIndex,
      );

      return paginatedData.map((json) => NewsArticle.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load news: $e');
    }
  }

  Future<List<NewsArticle>> fetchNewsFromUrl(
    String url, {
    required int page,
  }) async {
    try {
      final response = await http
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);

        // Adjust parsing based on your actual API response structure
        List<dynamic> articles = jsonData['articles'] ?? [];

        final startIndex = (page - 1) * _itemsPerPage;
        final endIndex = startIndex + _itemsPerPage;

        final paginatedData = articles.sublist(
          startIndex,
          endIndex > articles.length ? articles.length : endIndex,
        );

        return paginatedData
            .map((json) => NewsArticle.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception(
          'Failed to load news. Status code: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Failed to load news: $e');
    }
  }

  int getTotalPages() {
    return (_mockNewsData.length / _itemsPerPage).ceil();
  }
}
