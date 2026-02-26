class NewsArticle {
  final int position;
  final String title;
  final String sourceName;
  final String sourceIcon;
  final List<String> authors;
  final String link;
  final String thumbnail;
  final String isoDate;

  NewsArticle({
    required this.position,
    required this.title,
    required this.sourceName,
    required this.sourceIcon,
    required this.authors,
    required this.link,
    required this.thumbnail,
    required this.isoDate,
  });

  factory NewsArticle.fromJson(Map<String, dynamic> json) {
    return NewsArticle(
      position: json['position'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      sourceName: json['source']?['name'] as String? ?? 'Unknown',
      sourceIcon: json['source']?['icon'] as String? ?? '',
      authors: List<String>.from(json['source']?['authors'] as List? ?? []),
      link: json['link'] as String? ?? '',
      thumbnail: json['thumbnail'] as String? ?? '',
      isoDate: json['iso_date'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'position': position,
      'title': title,
      'source': {'name': sourceName, 'icon': sourceIcon, 'authors': authors},
      'link': link,
      'thumbnail': thumbnail,
      'iso_date': isoDate,
    };
  }
}
