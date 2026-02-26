import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/news_article.dart';
import '../services/news_service.dart';
import '../widgets/news_card.dart';

class NewsListScreen extends StatefulWidget {
  const NewsListScreen({super.key});

  @override
  State<NewsListScreen> createState() => _NewsListScreenState();
}

class _NewsListScreenState extends State<NewsListScreen> {
  late NewsService _newsService;
  late ScrollController _scrollController;

  List<NewsArticle> _articles = [];
  int _currentPage = 1;
  bool _isLoading = false;
  bool _hasMore = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _newsService = NewsService();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
    _loadNews();
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      if (_hasMore && !_isLoading) {
        _loadMoreNews();
      }
    }
  }

  Future<void> _loadNews() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final news = await _newsService.fetchNews(page: _currentPage);

      setState(() {
        _articles = news;
        _isLoading = false;
        _hasMore = news.length >= 10; // Assuming 10 items per page
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMoreNews() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      _currentPage++;
      final news = await _newsService.fetchNews(page: _currentPage);

      setState(() {
        _articles.addAll(news);
        _isLoading = false;
        _hasMore = news.length >= 10; // Assuming 10 items per page
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
        _currentPage--; // Revert page if error
      });
    }
  }

  Future<void> _openArticle(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Could not open article')));
      }
    }
  }

  void _refreshNews() {
    setState(() {
      _currentPage = 1;
      _articles.clear();
      _hasMore = true;
      _errorMessage = null;
    });
    _loadNews();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('AI News Search'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshNews,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading && _articles.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null && _articles.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Error Loading News',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage!,
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _refreshNews,
                child: const Text('Try Again'),
              ),
            ],
          ),
        ),
      );
    }

    if (_articles.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.newspaper, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              Text(
                'No news available',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        _refreshNews();
        await Future.delayed(const Duration(seconds: 1));
      },
      child: ListView.builder(
        controller: _scrollController,
        itemCount: _articles.length + (_isLoading ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _articles.length) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: _hasMore
                    ? const CircularProgressIndicator()
                    : Text(
                        'No more articles',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
              ),
            );
          }

          final article = _articles[index];
          return NewsCard(
            article: article,
            onTap: () => _openArticle(article.link),
          );
        },
      ),
    );
  }
}
