import 'package:flutter/material.dart';

import '../models/article.dart';
import '../services/news_service.dart';
import 'article_detail_page.dart';

class NewsPage extends StatefulWidget {
  const NewsPage({super.key, this.newsService});

  final NewsService? newsService;

  @override
  State<NewsPage> createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage> {
  late final NewsService _newsService = widget.newsService ?? NewsService();
  late Future<List<Article>> _newsFuture;
  String _selectedCategory = 'general';
  String _lastQuery = '';
  final List<Map<String, String>> _categories = [
    {'label': 'Umum', 'value': 'general'},
    {'label': 'Bisnis', 'value': 'business'},
    {'label': 'Hiburan', 'value': 'entertainment'},
    {'label': 'Kesehatan', 'value': 'health'},
    {'label': 'Sains', 'value': 'science'},
    {'label': 'Olahraga', 'value': 'sports'},
    {'label': 'Teknologi', 'value': 'technology'},
  ];
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _localFilterController = TextEditingController();
  String _localKeyword = '';

  void _selectCategory(String category) {
    setState(() {
      _selectedCategory = category;
      _lastQuery = '';
      _newsFuture = _newsService.fetchTopHeadlines(category: category);
    });
  }

  void _searchNews() {
    final query = _searchController.text.trim();
    if (query.isEmpty) {
      _selectCategory(_selectedCategory);
      return;
    }
    setState(() {
      _lastQuery = query;
      _newsFuture = _newsService.searchArticles(query: query);
    });
  }

  void _retry() {
    setState(() {
      _newsFuture = _lastQuery.isEmpty
          ? _newsService.fetchTopHeadlines(category: _selectedCategory)
          : _newsService.searchArticles(query: _lastQuery);
    });
  }

  List<Article> filterByTitle(List<Article> articles, String keyword) {
    final trimmed = keyword.trim().toLowerCase();
    if (trimmed.isEmpty) {
      return articles;
    }
    return articles
        .where((article) => article.title.toLowerCase().contains(trimmed))
        .toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _localFilterController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _newsFuture = _newsService.fetchTopHeadlines();
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: 'Cari berita...',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: IconButton(
          icon: const Icon(Icons.arrow_forward),
          onPressed: _searchNews,
        ),
        border: const OutlineInputBorder(),
        isDense: true,
      ),
      onSubmitted: (_) => _searchNews(),
    );
  }

  Widget _buildCategoryChips() {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final category = _categories[index];
          final value = category['value']!;
          return ChoiceChip(
            label: Text(category['label']!),
            selected: _selectedCategory == value,
            onSelected: (_) => _selectCategory(value),
          );
        },
      ),
    );
  }

  Widget _buildLocalFilterField() {
    return TextField(
      controller: _localFilterController,
      decoration: InputDecoration(
        labelText: 'Filter judul berita',
        hintText: 'AI, technology, sports',
        prefixIcon: const Icon(Icons.filter_list),
        suffixIcon: _localKeyword.isEmpty
            ? null
            : IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _localFilterController.clear();
                  setState(() {
                    _localKeyword = '';
                  });
                },
              ),
        border: const OutlineInputBorder(),
        isDense: true,
      ),
      onChanged: (value) {
        setState(() {
          _localKeyword = value;
        });
      },
    );
  }

  Widget _buildArticleCard(Article article) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ArticleDetailPage(article: article),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (article.imageUrl.isNotEmpty)
              Image.network(
                article.imageUrl,
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const SizedBox(
                    height: 120,
                    child: Center(child: Icon(Icons.broken_image, size: 40)),
                  );
                },
              ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    article.sourceName,
                    style: const TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    article.title,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    article.description.isEmpty
                        ? 'Deskripsi tidak tersedia.'
                        : article.description,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    return FutureBuilder<List<Article>>(
      future: _newsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, size: 48),
                  const SizedBox(height: 12),
                  const Text('Gagal mengambil berita'),
                  const SizedBox(height: 8),
                  Text('${snapshot.error}', textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _retry,
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            ),
          );
        }
        final articles = snapshot.data ?? [];
        if (articles.isEmpty) {
          return const Center(child: Text('Tidak ada berita tersedia.'));
        }
        final filteredArticles = filterByTitle(articles, _localKeyword);
        if (filteredArticles.isEmpty) {
          return const Center(child: Text('Tidak ada berita yang cocok.'));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: filteredArticles.length,
          itemBuilder: (context, index) =>
              _buildArticleCard(filteredArticles[index]),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('News App'), centerTitle: true),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
            child: _buildSearchField(),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: _buildCategoryChips(),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
            child: _buildLocalFilterField(),
          ),
          Expanded(child: _buildContent()),
        ],
      ),
    );
  }
}
