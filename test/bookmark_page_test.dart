import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_news_app/models/article.dart';
import 'package:flutter_news_app/pages/bookmark_page.dart';
import 'package:flutter_news_app/services/bookmark_service.dart';

Article buildArticle(String title, {required String url}) {
  return Article(
    title: title,
    description: 'Deskripsi $title',
    imageUrl: '',
    sourceName: 'Sumber $title',
    publishedAt: '2026-01-01T12:00:00Z',
    url: url,
  );
}

Widget wrap(Widget child) => MaterialApp(home: child);

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('menampilkan empty state saat belum ada bookmark', (
    tester,
  ) async {
    final service = BookmarkService();
    await service.load();

    await tester.pumpWidget(wrap(BookmarkPage(bookmarkService: service)));

    expect(find.text('Belum ada artikel tersimpan.'), findsOneWidget);
  });

  testWidgets('menampilkan daftar artikel tersimpan', (tester) async {
    final service = BookmarkService();
    await service.load();
    await service.add(
      buildArticle('Berita Simpan Satu', url: 'https://example.com/1'),
    );
    await service.add(
      buildArticle('Berita Simpan Dua', url: 'https://example.com/2'),
    );

    await tester.pumpWidget(wrap(BookmarkPage(bookmarkService: service)));

    expect(find.text('Berita Simpan Satu'), findsOneWidget);
    expect(find.text('Berita Simpan Dua'), findsOneWidget);
    expect(find.text('2 artikel'), findsOneWidget);
  });

  testWidgets('menghapus bookmark dari halaman bookmark', (tester) async {
    final service = BookmarkService();
    await service.load();
    final article = buildArticle(
      'Berita Akan Dihapus',
      url: 'https://example.com/hapus',
    );
    await service.add(article);

    await tester.pumpWidget(wrap(BookmarkPage(bookmarkService: service)));
    expect(find.text('Berita Akan Dihapus'), findsOneWidget);

    await tester.tap(
      find.byKey(const ValueKey('remove-bookmark-https://example.com/hapus')),
    );
    await tester.pumpAndSettle();

    expect(service.bookmarks, isEmpty);
    expect(find.text('Berita Akan Dihapus'), findsNothing);
    expect(find.text('Belum ada artikel tersimpan.'), findsOneWidget);
  });

  testWidgets('membuka artikel dari bookmark menuju halaman detail', (
    tester,
  ) async {
    final service = BookmarkService();
    await service.load();
    await service.add(
      buildArticle('Berita Bookmark', url: 'https://example.com/detail'),
    );

    await tester.pumpWidget(wrap(BookmarkPage(bookmarkService: service)));
    await tester.tap(find.text('Berita Bookmark'));
    await tester.pumpAndSettle();

    expect(find.text('Detail Berita'), findsOneWidget);
    expect(find.text('Berita Bookmark'), findsOneWidget);
    expect(find.text('Sumber Berita Bookmark'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('detail-back-button')));
    await tester.pumpAndSettle();

    expect(find.text('Bookmark'), findsOneWidget);
    expect(find.text('Berita Bookmark'), findsOneWidget);
  });
}
