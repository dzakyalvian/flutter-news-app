import 'package:material_ui/material_ui.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_news_app/models/article.dart';
import 'package:flutter_news_app/pages/news_page.dart';
import 'package:flutter_news_app/services/bookmark_service.dart';
import 'package:flutter_news_app/services/news_service.dart';

/// Service tiruan: mengembalikan data/error yang sudah ditentukan test
/// dan mencatat request yang diterima, tanpa akses jaringan.
class FakeNewsService extends NewsService {
  FakeNewsService({
    this.articles = const [],
    this.error,
    this.failFirstCallOnly = false,
    this.delay = Duration.zero,
  });

  final List<Article> articles;
  final Object? error;
  final bool failFirstCallOnly;
  final Duration delay;
  final List<String> categoryCalls = [];
  final List<String> searchCalls = [];
  int _calls = 0;

  @override
  Future<List<Article>> fetchTopHeadlines({String category = 'general'}) {
    categoryCalls.add(category);
    return _respond();
  }

  @override
  Future<List<Article>> searchArticles({required String query}) {
    searchCalls.add(query);
    return _respond();
  }

  Future<List<Article>> _respond() async {
    // Selalu melewati satu batas async agar future tidak selesai secara
    // sinkron; ini meniru request jaringan nyata dan memberi FutureBuilder
    // kesempatan memasang listener sebelum error dilaporkan.
    await Future<void>.delayed(delay);
    _calls++;
    if (error != null && (!failFirstCallOnly || _calls == 1)) {
      throw error!;
    }
    return articles;
  }
}

Article buildArticle(String title, {String imageUrl = ''}) {
  return Article(
    title: title,
    description: 'Deskripsi $title',
    imageUrl: imageUrl,
    sourceName: 'Sumber $title',
    publishedAt: '2026-01-01T12:00:00Z',
    url: 'https://example.com/$title',
  );
}

Widget wrap(Widget child) => MaterialApp(home: child);

void main() {
  setUpAll(() {
    dotenv.loadFromString(envString: 'NEWS_API_KEY=test-key');
  });

  testWidgets('menampilkan indikator loading saat data dimuat', (tester) async {
    final service = FakeNewsService(
      articles: [buildArticle('A')],
      delay: const Duration(milliseconds: 200),
    );

    await tester.pumpWidget(wrap(NewsPage(newsService: service)));
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pumpAndSettle();
    expect(find.text('A'), findsOneWidget);
  });

  testWidgets('menampilkan daftar berita (success state)', (tester) async {
    final service = FakeNewsService(
      articles: [buildArticle('Berita Satu'), buildArticle('Berita Dua')],
    );

    await tester.pumpWidget(wrap(NewsPage(newsService: service)));
    await tester.pumpAndSettle();

    expect(find.text('Berita Satu'), findsOneWidget);
    expect(find.text('Berita Dua'), findsOneWidget);
    expect(find.text('Sumber Berita Satu'), findsOneWidget);
  });

  testWidgets('menampilkan pesan data kosong (empty state)', (tester) async {
    final service = FakeNewsService(articles: const []);

    await tester.pumpWidget(wrap(NewsPage(newsService: service)));
    await tester.pumpAndSettle();

    expect(find.text('Tidak ada berita tersedia.'), findsOneWidget);
  });

  testWidgets('menampilkan error dan Coba Lagi (error state)', (tester) async {
    final service = FakeNewsService(error: Exception('Kode HTTP: 500'));

    await tester.pumpWidget(wrap(NewsPage(newsService: service)));
    await tester.pumpAndSettle();

    expect(find.text('Gagal mengambil berita'), findsOneWidget);
    expect(find.textContaining('Kode HTTP: 500'), findsOneWidget);
    expect(find.text('Coba Lagi'), findsOneWidget);
  });

  testWidgets('Coba Lagi mengulang kategori aktif', (tester) async {
    final service = FakeNewsService(
      error: Exception('gagal'),
      failFirstCallOnly: true,
      articles: [buildArticle('Setelah Coba Lagi')],
    );

    await tester.pumpWidget(wrap(NewsPage(newsService: service)));
    await tester.pumpAndSettle();

    expect(find.text('Coba Lagi'), findsOneWidget);
    expect(service.categoryCalls, ['general']);

    await tester.tap(find.text('Coba Lagi'));
    await tester.pumpAndSettle();

    expect(service.categoryCalls, ['general', 'general']);
    expect(find.text('Setelah Coba Lagi'), findsOneWidget);
  });

  testWidgets('mengganti kategori memanggil API kategori yang dipilih', (
    tester,
  ) async {
    final service = FakeNewsService(articles: [buildArticle('A')]);

    await tester.pumpWidget(wrap(NewsPage(newsService: service)));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Bisnis'));
    await tester.pumpAndSettle();

    expect(service.categoryCalls.last, 'business');
    expect(find.text('A'), findsOneWidget);
  });

  testWidgets('pencarian mengirim query dan filter lokal menyaring judul', (
    tester,
  ) async {
    final service = FakeNewsService(
      articles: [
        buildArticle('AI mengguncang industri'),
        buildArticle('Olahraga malam'),
      ],
    );

    await tester.pumpWidget(wrap(NewsPage(newsService: service)));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byType(TextField).first,
      'artificial intelligence',
    );
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pumpAndSettle();

    expect(service.searchCalls, ['artificial intelligence']);

    await tester.enterText(find.byType(TextField).at(1), 'AI');
    await tester.pumpAndSettle();

    expect(find.text('AI mengguncang industri'), findsOneWidget);
    expect(find.text('Olahraga malam'), findsNothing);
  });

  testWidgets('filter lokal tanpa kecocokan menampilkan pesan', (tester) async {
    final service = FakeNewsService(articles: [buildArticle('Berita A')]);

    await tester.pumpWidget(wrap(NewsPage(newsService: service)));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).at(1), 'zzz');
    await tester.pumpAndSettle();

    expect(find.text('Tidak ada berita yang cocok.'), findsOneWidget);
  });

  testWidgets('membuka detail berita yang dipilih dan kembali', (tester) async {
    final service = FakeNewsService(
      articles: [buildArticle('Berita Pertama'), buildArticle('Berita Kedua')],
    );

    await tester.pumpWidget(wrap(NewsPage(newsService: service)));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Berita Kedua'));
    await tester.pumpAndSettle();

    expect(find.text('Detail Berita'), findsOneWidget);
    expect(find.text('Berita Kedua'), findsOneWidget);
    expect(find.text('Sumber Berita Kedua'), findsOneWidget);
    expect(find.text('1 Jan 2026'), findsOneWidget);
    expect(find.text('Deskripsi Berita Kedua'), findsOneWidget);
    // Berita lain tetap tersedia sebagai rekomendasi "Berita Terkait".
    expect(find.text('Berita Pertama'), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();

    expect(find.text('News App'), findsOneWidget);
    expect(find.text('Berita Pertama'), findsOneWidget);
  });

  testWidgets('membuka tiga halaman detail berbeda lalu kembali', (
    tester,
  ) async {
    final service = FakeNewsService(
      articles: [
        buildArticle('Berita Satu'),
        buildArticle('Berita Dua'),
        buildArticle('Berita Tiga'),
      ],
    );

    await tester.pumpWidget(wrap(NewsPage(newsService: service)));
    await tester.pumpAndSettle();

    for (final title in ['Berita Satu', 'Berita Dua', 'Berita Tiga']) {
      await tester.ensureVisible(find.text(title));
      await tester.pumpAndSettle();
      await tester.tap(find.text(title));
      await tester.pumpAndSettle();

      expect(find.text('Detail Berita'), findsOneWidget);
      expect(find.text('Deskripsi $title'), findsOneWidget);

      await tester.pageBack();
      await tester.pumpAndSettle();

      expect(find.text('News App'), findsOneWidget);
    }
  });

  testWidgets('gambar gagal dimuat menampilkan ikon pengganti', (tester) async {
    final service = FakeNewsService(
      articles: [
        buildArticle(
          'Berita Bergambar',
          imageUrl: 'https://invalid.local/x.jpg',
        ),
      ],
    );

    await tester.pumpWidget(wrap(NewsPage(newsService: service)));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.broken_image), findsOneWidget);
  });

  testWidgets('deskripsi kosong memakai teks pengganti', (tester) async {
    final service = FakeNewsService(
      articles: [
        Article(
          title: 'Tanpa Deskripsi',
          description: '',
          imageUrl: '',
          sourceName: 'Sumber',
          publishedAt: '',
          url: '',
        ),
      ],
    );

    await tester.pumpWidget(wrap(NewsPage(newsService: service)));
    await tester.pumpAndSettle();

    expect(find.text('Deskripsi tidak tersedia.'), findsOneWidget);
  });

  testWidgets('menampilkan status bookmark dan membuka halaman bookmark', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final bookmarkService = BookmarkService();
    await bookmarkService.load();

    final savedArticle = buildArticle('Berita Disimpan');
    await bookmarkService.add(savedArticle);

    final service = FakeNewsService(
      articles: [savedArticle, buildArticle('Berita Lain')],
    );

    await tester.pumpWidget(
      wrap(NewsPage(newsService: service, bookmarkService: bookmarkService)),
    );
    await tester.pumpAndSettle();

    // Status bookmark tampil pada kartu berita utama.
    expect(find.byIcon(Icons.bookmark), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('open-bookmarks-button')));
    await tester.pumpAndSettle();

    expect(find.text('Bookmark'), findsOneWidget);
    expect(find.text('Berita Disimpan'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('bookmark-back-button')));
    await tester.pumpAndSettle();

    expect(find.text('News App'), findsOneWidget);
  });
}
