import 'package:material_ui/material_ui.dart';
import 'package:share_plus/share_plus.dart';

import '../models/article.dart';
import '../services/bookmark_service.dart';
import '../theme/editorial_theme.dart';

/// Halaman detail satu artikel dengan aksi kembali, bagikan, bookmark,
/// dan daftar berita terkait.
class ArticleDetailPage extends StatelessWidget {
  const ArticleDetailPage({
    super.key,
    required this.article,
    this.bookmarkService,
    this.relatedArticles = const [],
    this.onShare,
  });

  final Article article;
  final BookmarkService? bookmarkService;

  /// Kumpulan artikel yang tersedia untuk bagian berita terkait.
  /// Halaman ini hanya memakai data yang memang sudah dimuat aplikasi.
  final List<Article> relatedArticles;

  /// Opsional untuk pengujian; jika null, memakai `share_plus`.
  final Future<void> Function(Article article)? onShare;

  BookmarkService get _bookmarks => bookmarkService ?? BookmarkService.instance;

  void _showMessage(BuildContext context, String message) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    messenger?.hideCurrentSnackBar();
    messenger?.showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  Future<void> _shareArticle(BuildContext context) async {
    final title = article.title.trim();
    final url = article.url.trim();

    if (title.isEmpty && url.isEmpty) {
      _showMessage(
        context,
        'Informasi artikel tidak tersedia untuk dibagikan.',
      );
      return;
    }

    final buffer = StringBuffer();
    if (title.isNotEmpty) {
      buffer.write(title);
    }
    if (url.isNotEmpty) {
      if (buffer.isNotEmpty) {
        buffer.write('\n\n');
      }
      buffer.write(url);
    }

    try {
      if (onShare != null) {
        await onShare!(article);
        return;
      }
      await SharePlus.instance.share(
        ShareParams(
          text: buffer.toString(),
          subject: title.isEmpty ? null : title,
        ),
      );
    } catch (_) {
      if (context.mounted) {
        _showMessage(context, 'Gagal membagikan artikel.');
      }
    }
  }

  Future<void> _toggleBookmark(BuildContext context) async {
    final saved = await _bookmarks.toggle(article);
    if (context.mounted) {
      _showMessage(
        context,
        saved ? 'Disimpan ke bookmark.' : 'Dihapus dari bookmark.',
      );
    }
  }

  List<Article> _resolveRelated() {
    final currentId = BookmarkService.identityOf(article);
    final seen = <String>{};
    final candidates = <Article>[];

    for (final candidate in relatedArticles) {
      final id = BookmarkService.identityOf(candidate);
      if (id == currentId || !seen.add(id)) {
        continue;
      }
      candidates.add(candidate);
    }

    if (article.category.isEmpty) {
      return candidates;
    }

    // Kategori yang sama diprioritaskan tanpa membuang artikel lain.
    final sameCategory = candidates
        .where((candidate) => candidate.category == article.category)
        .toList();
    final otherCategory = candidates
        .where((candidate) => candidate.category != article.category)
        .toList();
    return [...sameCategory, ...otherCategory];
  }

  Widget _buildImage() {
    if (article.imageUrl.isEmpty) {
      return _ImagePlaceholder(
        icon: Icons.image_not_supported_outlined,
        height: 210,
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: Image.network(
        article.imageUrl,
        width: double.infinity,
        height: 220,
        fit: BoxFit.cover,
        frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
          if (wasSynchronouslyLoaded || frame != null) {
            return child;
          }
          return const _ImagePlaceholder(
            icon: Icons.image_outlined,
            height: 220,
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return const _ImagePlaceholder(
            icon: Icons.broken_image_outlined,
            height: 220,
          );
        },
      ),
    );
  }

  Widget _buildMeta() {
    final date = formatEditorialDate(article.publishedAt);
    return Row(
      children: [
        Flexible(
          child: Text(
            article.sourceName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              height: 1.2,
              fontWeight: FontWeight.w700,
              color: kEditorialAccent,
            ),
          ),
        ),
        if (date.isNotEmpty) ...[
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              '·',
              style: TextStyle(fontSize: 13, color: kEditorialMuted),
            ),
          ),
          Flexible(
            child: Text(
              date,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
                height: 1.2,
                color: kEditorialMuted,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildRelatedSection(BuildContext context, List<Article> related) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(width: 14, height: 2, color: kEditorialAccent),
            const SizedBox(width: 8),
            const Text(
              'BERITA TERKAIT',
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
          ],
        ),
        const SizedBox(height: 12),
        if (related.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 22),
            decoration: BoxDecoration(
              color: kEditorialSoft,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: kEditorialLine),
            ),
            child: const Column(
              children: [
                Icon(Icons.article_outlined, size: 22, color: kEditorialMuted),
                SizedBox(height: 8),
                Text(
                  'Belum ada berita terkait.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12.5,
                    height: 1.4,
                    color: kEditorialMuted,
                  ),
                ),
              ],
            ),
          )
        else
          ...related.map(
            (relatedArticle) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _RelatedArticleTile(
                article: relatedArticle,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ArticleDetailPage(
                        article: relatedArticle,
                        bookmarkService: _bookmarks,
                        relatedArticles: relatedArticles,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final related = _resolveRelated();

    return Scaffold(
      backgroundColor: kEditorialBackground,
      appBar: AppBar(
        backgroundColor: kEditorialSurface,
        foregroundColor: kEditorialInk,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: BackButton(
          key: const ValueKey('detail-back-button'),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: const Text(
          'Detail Berita',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.2,
          ),
        ),
        actions: [
          IconButton(
            key: const ValueKey('detail-share-button'),
            tooltip: 'Bagikan',
            icon: const Icon(Icons.share_outlined),
            onPressed: () => _shareArticle(context),
          ),
          ListenableBuilder(
            listenable: _bookmarks,
            builder: (context, child) {
              final saved = _bookmarks.isBookmarked(article);
              return IconButton(
                key: const ValueKey('detail-bookmark-button'),
                tooltip: saved ? 'Hapus bookmark' : 'Simpan bookmark',
                icon: Icon(saved ? Icons.bookmark : Icons.bookmark_border),
                onPressed: () => _toggleBookmark(context),
              );
            },
          ),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: kEditorialLine),
        ),
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildImage(),
                    const SizedBox(height: 18),
                    if (article.category.isNotEmpty) ...[
                      Text(
                        article.category.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 10,
                          height: 1,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2,
                          color: kEditorialAccent,
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                    Text(
                      article.title,
                      style: const TextStyle(
                        fontSize: 26,
                        height: 1.18,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.6,
                        color: kEditorialInk,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildMeta(),
                    const SizedBox(height: 16),
                    const Divider(height: 1, color: kEditorialLine),
                    const SizedBox(height: 16),
                    Text(
                      article.description.isEmpty
                          ? 'Deskripsi tidak tersedia.'
                          : article.description,
                      style: const TextStyle(
                        fontSize: 15,
                        height: 1.6,
                        color: kEditorialBodyText,
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildRelatedSection(context, related),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RelatedArticleTile extends StatelessWidget {
  const _RelatedArticleTile({required this.article, required this.onTap});

  final Article article;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: kEditorialSurface,
      borderRadius: BorderRadius.circular(14),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 72,
                height: 66,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: article.imageUrl.isEmpty
                      ? const _ImagePlaceholder(
                          icon: Icons.image_outlined,
                          height: 66,
                          iconSize: 20,
                        )
                      : Image.network(
                          article.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const _ImagePlaceholder(
                              icon: Icons.broken_image_outlined,
                              height: 66,
                              iconSize: 20,
                            );
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
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.3,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.2,
                        color: kEditorialInk,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      article.sourceName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        height: 1.2,
                        fontWeight: FontWeight.w600,
                        color: kEditorialMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder({
    required this.icon,
    required this.height,
    this.iconSize = 32,
  });

  final IconData icon;
  final double height;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: double.infinity,
      color: kEditorialSoft,
      child: Center(
        child: Icon(icon, size: iconSize, color: kEditorialMuted),
      ),
    );
  }
}
