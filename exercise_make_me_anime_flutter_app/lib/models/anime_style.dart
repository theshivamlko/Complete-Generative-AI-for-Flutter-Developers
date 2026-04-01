class AnimeStyle {
  final String name;
  final String description;

  const AnimeStyle({required this.name, this.description = ''});

  static List<String> get defaultFilters => [
    'Studio Ghibli',
    'Cyberpunk Edgerunners',
    'Makoto Shinkai (Your Name)',
    'Dragon Ball Z',
    'Naruto',
    'Watercolor Anime',
    'Retro 90s Anime',
  ];
}
