import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_news_app/models/article.dart';
import 'package:flutter_news_app/pages/article_detail_page.dart';
import 'package:flutter_news_app/services/bookmark_service.dart';

Article buildArticle(
  String title, {
  String url = '',
  String category = '',
  String imageUrl = '',
  String description = '',
}) {
  return Article(
    title: title,
    description: description.isEmpty ? 'Deskripsi $title' : description,
    imageUrl: imageUrl,
    sourceName: 'Sumber $title',
    publishedAt: '2026-01-01T12:00:00Z',
    url: url,
    category: category,
  );
}

Widget wrap(Widget child) => MaterialApp(home: child);

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('menampilkan detail dan kembali ke halaman sebelumnya', (
    tester,
  ) async {
    final service = BookmarkService();
    await service.load();
    final article = buildArticle('Berita Detail', url: 'https://example.com');

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ArticleDetailPage(
                      article: article,
                      bookmarkService: service,
                    ),
                  ),
                );
              },
              child: const Text('Buka Detail'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Buka Detail'));
    await tester.pumpAndSettle();

    expect(find.text('Detail Berita'), findsOneWidget);
    expect(find.text('Berita Detail'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('detail-back-button')));
    await tester.pumpAndSettle();

    expect(find.text('Buka Detail'), findsOneWidget);
    expect(find.text('Detail Berita'), findsNothing);
  });

  testWidgets('menyimpan dan menghapus bookmark dari halaman detail', (
    tester,
  ) async {
    final service = BookmarkService();
    await service.load();
    final article = buildArticle('Berita Bookmark', url: 'https://example.com');

    await tester.pumpWidget(
      wrap(ArticleDetailPage(article: article, bookmarkService: service)),
    );

    expect(find.byTooltip('Simpan bookmark'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('detail-bookmark-button')));
    await tester.pumpAndSettle();

    expect(service.isBookmarked(article), isTrue);
    expect(find.byTooltip('Hapus bookmark'), findsOneWidget);
    expect(find.byIcon(Icons.bookmark), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('detail-bookmark-button')));
    await tester.pumpAndSettle();

    expect(service.isBookmarked(article), isFalse);
    expect(find.byTooltip('Simpan bookmark'), findsOneWidget);
  });

  testWidgets('menampilkan berita terkait tanpa artikel yang sedang dibuka', (
    tester,
  ) async {
    final current = buildArticle(
      'Berita Utama',
      url: 'https://example.com/utama',
    );
    final related = buildArticle(
      'Berita Terkait',
      url: 'https://example.com/terkait',
    );

    await tester.pumpWidget(
      wrap(
        ArticleDetailPage(
          article: current,
          relatedArticles: [current, related, related],
        ),
      ),
    );

    expect(find.text('Berita Utama'), findsOneWidget);
    expect(find.text('Berita Terkait'), findsOneWidget);
    expect(find.text('Belum ada berita terkait.'), findsNothing);
  });

  testWidgets('memprioritaskan berita terkait dengan kategori yang sama', (
    tester,
  ) async {
    final current = buildArticle(
      'Berita Teknologi',
      url: 'https://example.com/teknologi',
      category: 'technology',
    );
    final other = buildArticle(
      'Berita Olahraga',
      url: 'https://example.com/olahraga',
      category: 'sports',
    );
    final sameCategory = buildArticle(
      'Berita Teknologi Lain',
      url: 'https://example.com/teknologi-2',
      category: 'technology',
    );

    await tester.pumpWidget(
      wrap(
        ArticleDetailPage(
          article: current,
          relatedArticles: [other, sameCategory],
        ),
      ),
    );

    final sameCategoryY = tester
        .getTopLeft(find.text('Berita Teknologi Lain'))
        .dy;
    final otherY = tester.getTopLeft(find.text('Berita Olahraga')).dy;

    expect(sameCategoryY, lessThan(otherY));
  });

  testWidgets('menampilkan empty state jika tidak ada berita terkait', (
    tester,
  ) async {
    final article = buildArticle('Berita Tanpa Terkait');

    await tester.pumpWidget(wrap(ArticleDetailPage(article: article)));

    expect(find.text('Belum ada berita terkait.'), findsOneWidget);
  });

  testWidgets('membuka artikel terkait menuju halaman detail', (tester) async {
    final current = buildArticle(
      'Berita Utama',
      url: 'https://example.com/utama',
    );
    final related = buildArticle(
      'Berita Terkait',
      url: 'https://example.com/terkait',
    );

    await tester.pumpWidget(
      wrap(
        ArticleDetailPage(
          article: current,
          relatedArticles: [current, related],
        ),
      ),
    );

    await tester.tap(find.text('Berita Terkait'));
    await tester.pumpAndSettle();

    expect(find.text('Detail Berita'), findsOneWidget);
    expect(find.text('Deskripsi Berita Terkait'), findsOneWidget);
  });

  testWidgets('menangani share saat informasi artikel tidak tersedia', (
    tester,
  ) async {
    final article = Article(
      title: '',
      description: '',
      imageUrl: '',
      sourceName: '',
      publishedAt: '',
      url: '',
    );

    await tester.pumpWidget(wrap(ArticleDetailPage(article: article)));

    await tester.tap(find.byKey(const ValueKey('detail-share-button')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(
      find.text('Informasi artikel tidak tersedia untuk dibagikan.'),
      findsOneWidget,
    );
  });
}
