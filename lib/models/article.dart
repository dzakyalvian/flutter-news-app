class Article {
  final String title;
  final String description;
  final String imageUrl;
  final String sourceName;
  final String publishedAt;
  final String url;

  /// Kategori artikel bila diketahui dari feed yang dipilih.
  /// NewsAPI tidak mengirim kategori per artikel, sehingga nilai ini
  /// diisi oleh [NewsService] sesuai kategori request.
  final String category;

  Article({
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.sourceName,
    required this.publishedAt,
    required this.url,
    this.category = '',
  });

  factory Article.fromJson(Map<String, dynamic> json, {String category = ''}) {
    final source = json['source'] as Map<String, dynamic>?;
    return Article(
      title: json['title'] ?? 'Judul tidak tersedia',
      description: json['description'] ?? '',
      imageUrl: json['urlToImage'] ?? '',
      sourceName: source?['name'] ?? 'Sumber tidak diketahui',
      publishedAt: json['publishedAt'] ?? '',
      url: json['url'] ?? '',
      category: category,
    );
  }

  /// Serialisasi dipakai untuk menyimpan bookmark secara lokal.
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'urlToImage': imageUrl,
      'source': {'name': sourceName},
      'publishedAt': publishedAt,
      'url': url,
      'category': category,
    };
  }
}
