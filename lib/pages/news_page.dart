import 'package:material_ui/material_ui.dart';

import '../models/article.dart';
import '../services/bookmark_service.dart';
import '../services/news_service.dart';
import 'article_detail_page.dart';
import 'bookmark_page.dart';

// Palet Modern Editorial (light mode).
const Color _background = Color(0xFFF8F8F6);
const Color _surface = Color(0xFFFFFFFF);
const Color _ink = Color(0xFF171717);
const Color _muted = Color(0xFF777777);
const Color _accent = Color(0xFFC83B32);
const Color _line = Color(0xFFE9E7E1);
const Color _soft = Color(0xFFF1F0EC);
const Color _bodyText = Color(0xFF5F5F5F);

/// Mengubah tanggal ISO dari API menjadi format editorial singkat.
/// String yang tidak bisa diparse dikembalikan apa adanya.
String _formatPublishedAt(String raw) {
  final parsed = DateTime.tryParse(raw);
  if (parsed == null) {
    return raw;
  }
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'Mei',
    'Jun',
    'Jul',
    'Agu',
    'Sep',
    'Okt',
    'Nov',
    'Des',
  ];
  final date = parsed.toLocal();
  return '${date.day} ${months[date.month - 1]} ${date.year}';
}

class NewsPage extends StatefulWidget {
  const NewsPage({super.key, this.newsService, this.bookmarkService});

  final NewsService? newsService;
  final BookmarkService? bookmarkService;

  @override
  State<NewsPage> createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage> {
  late final NewsService _newsService = widget.newsService ?? NewsService();
  late final BookmarkService _bookmarkService =
      widget.bookmarkService ?? BookmarkService.instance;
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

  void _openArticle(Article article, List<Article> pool) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ArticleDetailPage(
          article: article,
          bookmarkService: _bookmarkService,
          relatedArticles: pool,
        ),
      ),
    );
  }

  void _openBookmarks() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BookmarkPage(bookmarkService: _bookmarkService),
      ),
    );
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

  String _categoryLabel(String value) {
    for (final category in _categories) {
      if (category['value'] == value) {
        return category['label']!;
      }
    }
    return 'Umum';
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

  Widget _buildMasthead() {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 10),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: _line, width: 1),
          top: BorderSide(color: _accent, width: 18),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 26,
            decoration: BoxDecoration(
              color: _accent,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'News App',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 23,
                    height: 1.05,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.8,
                    color: _ink,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'EDISI DIGITAL · BERITA PILIHAN',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 9,
                    height: 1.1,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.3,
                    color: _muted.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          ListenableBuilder(
            listenable: _bookmarkService,
            builder: (context, child) {
              final count = _bookmarkService.bookmarks.length;
              return Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _line),
                ),
                child: Material(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    key: const ValueKey('open-bookmarks-button'),
                    borderRadius: BorderRadius.circular(12),
                    onTap: _openBookmarks,
                    child: Tooltip(
                      message: 'Bookmark',
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          const Icon(
                            Icons.bookmark_border,
                            size: 20,
                            color: _ink,
                          ),
                          if (count > 0)
                            Positioned(
                              top: 5,
                              right: 5,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 3,
                                  vertical: 1,
                                ),
                                decoration: BoxDecoration(
                                  color: _accent,
                                  borderRadius: BorderRadius.circular(7),
                                ),
                                child: Text(
                                  count > 9 ? '9+' : '$count',
                                  style: const TextStyle(
                                    fontSize: 7.5,
                                    height: 1.1,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return Container(
      height: 44,
      padding: const EdgeInsets.only(left: 13, right: 5),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _line),
      ),
      child: Row(
        children: [
          const Icon(Icons.search, size: 20, color: _muted),
          const SizedBox(width: 9),
          Expanded(
            child: TextField(
              controller: _searchController,
              textInputAction: TextInputAction.search,
              style: const TextStyle(fontSize: 14, color: _ink),
              decoration: const InputDecoration(
                isCollapsed: true,
                border: InputBorder.none,
                hintText: 'Cari berita...',
                hintStyle: TextStyle(fontSize: 14, color: _muted),
              ),
              onSubmitted: (_) => _searchNews(),
            ),
          ),
          const SizedBox(width: 8),
          Material(
            color: _accent,
            borderRadius: BorderRadius.circular(10),
            child: InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: _searchNews,
              child: const SizedBox(
                width: 32,
                height: 32,
                child: Icon(Icons.arrow_forward, size: 18, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChips() {
    return SizedBox(
      height: 34,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        itemCount: _categories.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final category = _categories[index];
          final value = category['value']!;
          final selected = _selectedCategory == value;
          return ChoiceChip(
            label: Text(category['label']!),
            selected: selected,
            onSelected: (_) => _selectCategory(value),
            showCheckmark: false,
            backgroundColor: _surface,
            selectedColor: _accent,
            side: BorderSide(color: selected ? _accent : _line),
            shape: const StadiumBorder(),
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            visualDensity: VisualDensity.compact,
            labelStyle: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.1,
              color: selected ? Colors.white : _ink,
            ),
          );
        },
      ),
    );
  }

  Widget _buildLocalFilterField() {
    return Container(
      height: 32,
      padding: const EdgeInsets.only(left: 11, right: 3),
      decoration: BoxDecoration(
        color: _soft,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const Icon(Icons.tune, size: 15, color: _muted),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _localFilterController,
              style: const TextStyle(fontSize: 12.5, color: _ink),
              decoration: const InputDecoration(
                isCollapsed: true,
                border: InputBorder.none,
                hintText: 'Saring berdasarkan judul...',
                hintStyle: TextStyle(fontSize: 12.5, color: _muted),
              ),
              onChanged: (value) {
                setState(() {
                  _localKeyword = value;
                });
              },
            ),
          ),
          if (_localKeyword.isNotEmpty)
            InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () {
                _localFilterController.clear();
                setState(() {
                  _localKeyword = '';
                });
              },
              child: const SizedBox(
                width: 28,
                height: 28,
                child: Icon(Icons.close, size: 15, color: _muted),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildContent(bool isWide) {
    return FutureBuilder<List<Article>>(
      future: _newsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 26,
                  height: 26,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.4,
                    color: _accent,
                  ),
                ),
                SizedBox(height: 14),
                Text(
                  'Memuat berita terbaru...',
                  style: TextStyle(fontSize: 12.5, color: _muted),
                ),
              ],
            ),
          );
        }
        if (snapshot.hasError) {
          return _StateMessage(
            icon: Icons.error_outline,
            title: 'Gagal mengambil berita',
            message: '${snapshot.error}',
            action: FilledButton(
              onPressed: _retry,
              style: FilledButton.styleFrom(
                backgroundColor: _accent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                textStyle: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              child: const Text('Coba Lagi'),
            ),
          );
        }
        final articles = snapshot.data ?? [];
        if (articles.isEmpty) {
          return const _StateMessage(
            icon: Icons.article_outlined,
            title: 'Tidak ada berita tersedia.',
            message: 'Coba pilih kategori lain untuk melihat berita lainnya.',
          );
        }
        final filteredArticles = filterByTitle(articles, _localKeyword);
        if (filteredArticles.isEmpty) {
          return const _StateMessage(
            icon: Icons.search_off,
            title: 'Tidak ada berita yang cocok.',
            message: 'Ubah kata kunci filter judul atau hapus filternya.',
          );
        }
        return _buildFeed(filteredArticles, isWide);
      },
    );
  }

  Widget _buildFeed(List<Article> articles, bool isWide) {
    final featured = articles.first;
    final latest = articles.skip(1).toList();
    final editorialLabel = _lastQuery.isEmpty
        ? _categoryLabel(_selectedCategory).toUpperCase()
        : 'HASIL PENCARIAN';

    return ListenableBuilder(
      listenable: _bookmarkService,
      builder: (context, child) {
        final bookmarkedIds = _bookmarkService.bookmarks
            .map(BookmarkService.identityOf)
            .toSet();

        return CustomScrollView(
          slivers: [
            const SliverToBoxAdapter(
              child: _SectionHeader(label: 'BERITA UTAMA', topPadding: 4),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 8,
                ),
                child: _FeaturedArticle(
                  article: featured,
                  label: editorialLabel,
                  isWide: isWide,
                  isBookmarked: bookmarkedIds.contains(
                    BookmarkService.identityOf(featured),
                  ),
                  onTap: () => _openArticle(featured, articles),
                ),
              ),
            ),
            if (latest.isNotEmpty) ...[
              SliverToBoxAdapter(
                child: _SectionHeader(
                  label: 'BERITA TERBARU',
                  trailing: '${latest.length} artikel',
                ),
              ),
              SliverList.builder(
                itemCount: latest.length,
                itemBuilder: (context, index) {
                  final article = latest[index];
                  return Column(
                    children: [
                      if (index > 0)
                        Container(
                          height: 1,
                          margin: const EdgeInsets.symmetric(horizontal: 18),
                          color: _line,
                        ),
                      _LatestArticleTile(
                        article: article,
                        isBookmarked: bookmarkedIds.contains(
                          BookmarkService.identityOf(article),
                        ),
                        onTap: () => _openArticle(article, articles),
                      ),
                    ],
                  );
                },
              ),
            ],
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.sizeOf(context).width >= 600;
    return Scaffold(
      backgroundColor: _background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildMasthead(),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 6, 18, 11),
              child: _buildSearchField(),
            ),
            _buildCategoryChips(),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 9, 18, 5),
              child: _buildLocalFilterField(),
            ),
            Expanded(child: _buildContent(isWide)),
          ],
        ),
      ),
    );
  }
}

/// Judul bagian dengan garis tipis bergaya koran.
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.label,
    this.trailing,
    this.topPadding = 16,
  });

  final String label;
  final String? trailing;
  final double topPadding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(18, topPadding, 18, 10),
      child: SizedBox(
        height: 14,
        child: Row(
          children: [
            Container(width: 14, height: 2, color: _accent),
            const SizedBox(width: 8),
            Expanded(
              child: Row(
                children: [
                  Flexible(
                    child: Text(
                      label,
                      maxLines: 1,
                      softWrap: false,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 10.5,
                        height: 1,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.3,
                        color: _ink,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(child: Divider(height: 1, color: _line)),
                ],
              ),
            ),
            if (trailing != null) ...[
              const SizedBox(width: 10),
              Text(
                trailing!,
                maxLines: 1,
                softWrap: false,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 10.5,
                  height: 1,
                  fontWeight: FontWeight.w500,
                  color: _muted,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Artikel utama: gambar dominan dengan hierarki judul yang kuat.
class _FeaturedArticle extends StatelessWidget {
  const _FeaturedArticle({
    required this.article,
    required this.label,
    required this.isWide,
    required this.isBookmarked,
    required this.onTap,
  });

  final Article article;
  final String label;
  final bool isWide;
  final bool isBookmarked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final image = _ArticleImage(
      article: article,
      height: isWide ? 168 : 190,
      radius: 0,
      iconSize: 34,
    );
    final details = Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 10,
                    height: 1,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                    color: _accent,
                  ),
                ),
              ),
              if (isBookmarked)
                const Padding(
                  padding: EdgeInsets.only(left: 8),
                  child: Icon(Icons.bookmark, size: 15, color: _accent),
                ),
            ],
          ),
          const SizedBox(height: 7),
          Text(
            article.title,
            maxLines: isWide ? 2 : 3,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: isWide ? 21 : 24,
              height: 1.16,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.6,
              color: _ink,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            article.description.isEmpty
                ? 'Deskripsi tidak tersedia.'
                : article.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12.5,
              height: 1.45,
              color: _bodyText,
            ),
          ),
          const SizedBox(height: 10),
          _MetaLine(article: article),
        ],
      ),
    );

    return Material(
      color: _surface,
      borderRadius: BorderRadius.circular(18),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: isWide
            ? SizedBox(
                height: 168,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(width: 300, child: image),
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: details,
                      ),
                    ),
                  ],
                ),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [image, details],
              ),
      ),
    );
  }
}

/// Artikel pendukung: layout horizontal dengan thumbnail.
class _LatestArticleTile extends StatelessWidget {
  const _LatestArticleTile({
    required this.article,
    required this.isBookmarked,
    required this.onTap,
  });

  final Article article;
  final bool isBookmarked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      article.title,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        height: 1.3,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.2,
                        color: _ink,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Row(
                      children: [
                        Expanded(child: _MetaLine(article: article)),
                        if (isBookmarked)
                          const Padding(
                            padding: EdgeInsets.only(left: 8),
                            child: Icon(
                              Icons.bookmark,
                              size: 14,
                              color: _accent,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              SizedBox(
                width: 76,
                child: _ArticleImage(
                  article: article,
                  height: 76,
                  radius: 14,
                  iconSize: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Sumber dan tanggal publikasi.
class _MetaLine extends StatelessWidget {
  const _MetaLine({required this.article});

  final Article article;

  @override
  Widget build(BuildContext context) {
    final date = _formatPublishedAt(article.publishedAt);
    return Row(
      children: [
        Flexible(
          flex: 3,
          child: Text(
            article.sourceName,
            maxLines: 1,
            softWrap: false,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 11.5,
              height: 1,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.1,
              color: _ink,
            ),
          ),
        ),
        if (date.isNotEmpty) ...[
          const Text(
            '  ·  ',
            style: TextStyle(fontSize: 11.5, height: 1, color: _muted),
          ),
          Flexible(
            flex: 2,
            child: Text(
              date,
              maxLines: 1,
              softWrap: false,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 11.5,
                height: 1,
                fontWeight: FontWeight.w400,
                color: _muted,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// Gambar artikel dengan placeholder saat memuat dan ikon saat gagal.
class _ArticleImage extends StatelessWidget {
  const _ArticleImage({
    required this.article,
    required this.height,
    required this.radius,
    required this.iconSize,
  });

  final Article article;
  final double height;
  final double radius;
  final double iconSize;

  Widget _placeholder(IconData icon) {
    return Container(
      height: height,
      width: double.infinity,
      color: _soft,
      child: Center(
        child: Icon(icon, size: iconSize, color: _muted),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Widget image;
    if (article.imageUrl.isEmpty) {
      image = _placeholder(Icons.image_outlined);
    } else {
      image = Image.network(
        article.imageUrl,
        height: height,
        width: double.infinity,
        fit: BoxFit.cover,
        frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
          if (wasSynchronouslyLoaded || frame != null) {
            return child;
          }
          return _placeholder(Icons.image_outlined);
        },
        errorBuilder: (context, error, stackTrace) {
          return _placeholder(Icons.broken_image);
        },
      );
    }
    if (radius == 0) {
      return image;
    }
    return ClipRRect(borderRadius: BorderRadius.circular(radius), child: image);
  }
}

/// Tampilan terpusat untuk empty state dan error state.
class _StateMessage extends StatelessWidget {
  const _StateMessage({
    required this.icon,
    required this.title,
    required this.message,
    this.action,
  });

  final IconData icon;
  final String title;
  final String message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: _surface,
                shape: BoxShape.circle,
                border: Border.all(color: _line),
              ),
              child: Icon(icon, size: 24, color: _accent),
            ),
            const SizedBox(height: 14),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                height: 1.2,
                fontWeight: FontWeight.w700,
                color: _ink,
              ),
            ),
            if (message.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12.5,
                  height: 1.45,
                  color: _muted,
                ),
              ),
            ],
            if (action != null) ...[const SizedBox(height: 18), action!],
          ],
        ),
      ),
    );
  }
}
