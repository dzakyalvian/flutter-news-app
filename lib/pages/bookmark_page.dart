import 'package:material_ui/material_ui.dart';

import '../models/article.dart';
import '../services/bookmark_service.dart';
import '../theme/editorial_theme.dart';
import 'article_detail_page.dart';

/// Halaman daftar artikel yang disimpan pengguna.
class BookmarkPage extends StatelessWidget {
  const BookmarkPage({super.key, this.bookmarkService});

  final BookmarkService? bookmarkService;

  BookmarkService get _bookmarks => bookmarkService ?? BookmarkService.instance;

  void _openArticle(BuildContext context, Article article) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ArticleDetailPage(
          article: article,
          bookmarkService: _bookmarks,
          relatedArticles: _bookmarks.bookmarks,
        ),
      ),
    );
  }

  Future<void> _removeBookmark(BuildContext context, Article article) async {
    final removed = await _bookmarks.remove(article);
    if (!context.mounted) {
      return;
    }
    final messenger = ScaffoldMessenger.maybeOf(context);
    messenger?.hideCurrentSnackBar();
    messenger?.showSnackBar(
      SnackBar(
        content: Text(
          removed ? 'Dihapus dari bookmark.' : 'Artikel tidak ditemukan.',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kEditorialBackground,
      appBar: AppBar(
        backgroundColor: kEditorialSurface,
        foregroundColor: kEditorialInk,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: BackButton(
          key: const ValueKey('bookmark-back-button'),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: const Text(
          'Bookmark',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.2,
          ),
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: kEditorialLine),
        ),
      ),
      body: SafeArea(
        top: false,
        child: ListenableBuilder(
          listenable: _bookmarks,
          builder: (context, child) {
            final articles = _bookmarks.bookmarks;
            if (articles.isEmpty) {
              return const _BookmarkEmptyState();
            }
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 760),
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(18, 16, 18, 28),
                  itemCount: articles.length + 1,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return _BookmarkHeader(count: articles.length);
                    }
                    final article = articles[index - 1];
                    return _BookmarkTile(
                      article: article,
                      onTap: () => _openArticle(context, article),
                      onRemove: () => _removeBookmark(context, article),
                    );
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _BookmarkHeader extends StatelessWidget {
  const _BookmarkHeader({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Container(width: 14, height: 2, color: kEditorialAccent),
          const SizedBox(width: 8),
          const Text(
            'ARTIKEL TERSIMPAN',
            style: TextStyle(
              fontSize: 10.5,
              height: 1,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.3,
              color: kEditorialInk,
            ),
          ),
          const SizedBox(width: 10),
          const Expanded(child: Divider(height: 1, color: kEditorialLine)),
          const SizedBox(width: 10),
          Text(
            '$count artikel',
            style: const TextStyle(
              fontSize: 10.5,
              height: 1,
              fontWeight: FontWeight.w500,
              color: kEditorialMuted,
            ),
          ),
        ],
      ),
    );
  }
}

class _BookmarkTile extends StatelessWidget {
  const _BookmarkTile({
    required this.article,
    required this.onTap,
    required this.onRemove,
  });

  final Article article;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final date = formatEditorialDate(article.publishedAt);

    return Material(
      color: kEditorialSurface,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 6, 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 84,
                height: 84,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: article.imageUrl.isEmpty
                      ? const _BookmarkImagePlaceholder()
                      : Image.network(
                          article.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const _BookmarkImagePlaceholder();
                          },
                        ),
                ),
              ),
              const SizedBox(width: 12),
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
                        height: 1.28,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.2,
                        color: kEditorialInk,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      date.isEmpty
                          ? article.sourceName
                          : '${article.sourceName}  ·  $date',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        height: 1.2,
                        color: kEditorialMuted,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                key: ValueKey('remove-bookmark-${article.url}'),
                tooltip: 'Hapus dari bookmark',
                icon: const Icon(
                  Icons.delete_outline,
                  size: 20,
                  color: kEditorialMuted,
                ),
                onPressed: onRemove,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BookmarkImagePlaceholder extends StatelessWidget {
  const _BookmarkImagePlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: kEditorialSoft,
      child: const Center(
        child: Icon(Icons.image_outlined, size: 22, color: kEditorialMuted),
      ),
    );
  }
}

class _BookmarkEmptyState extends StatelessWidget {
  const _BookmarkEmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: kEditorialSurface,
                shape: BoxShape.circle,
                border: Border.all(color: kEditorialLine),
              ),
              child: const Icon(
                Icons.bookmark_border,
                size: 26,
                color: kEditorialAccent,
              ),
            ),
            const SizedBox(height: 15),
            const Text(
              'Belum ada artikel tersimpan.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                height: 1.2,
                fontWeight: FontWeight.w700,
                color: kEditorialInk,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Simpan artikel dari halaman detail untuk membacanya nanti.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12.5,
                height: 1.45,
                color: kEditorialMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
