import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_news_app/models/article.dart';
import 'package:flutter_news_app/services/bookmark_service.dart';

Article buildArticle(
  String title, {
  String url = '',
  String source = 'Sumber',
}) {
  return Article(
    title: title,
    description: 'Deskripsi $title',
    imageUrl: '',
    sourceName: source,
    publishedAt: '2026-01-01T12:00:00Z',
    url: url,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('menambahkan bookmark', () async {
    final service = BookmarkService();
    await service.load();

    final article = buildArticle('Berita Satu', url: 'https://example.com/1');
    final added = await service.add(article);

    expect(added, isTrue);
    expect(service.bookmarks, hasLength(1));
    expect(service.isBookmarked(article), isTrue);
  });

  test('menghapus bookmark', () async {
    final service = BookmarkService();
    await service.load();

    final article = buildArticle('Berita Satu', url: 'https://example.com/1');
    await service.add(article);

    final removed = await service.remove(article);

    expect(removed, isTrue);
    expect(service.bookmarks, isEmpty);
    expect(service.isBookmarked(article), isFalse);
  });

  test('mencegah bookmark duplikat berdasarkan URL', () async {
    final service = BookmarkService();
    await service.load();

    final article = buildArticle('Judul Awal', url: 'https://example.com/1');
    final duplicate = buildArticle(
      'Judul Berbeda',
      url: 'https://example.com/1',
    );

    expect(await service.add(article), isTrue);
    expect(await service.add(duplicate), isFalse);
    expect(service.bookmarks, hasLength(1));
    expect(service.bookmarks.single.title, 'Judul Awal');
  });

  test('memakai judul dan sumber saat URL kosong sebagai identitas', () async {
    final service = BookmarkService();
    await service.load();

    final article = buildArticle('Tanpa URL', source: 'Media');
    final duplicate = buildArticle('Tanpa URL', source: 'Media');

    expect(await service.add(article), isTrue);
    expect(await service.add(duplicate), isFalse);
    expect(service.bookmarks, hasLength(1));
  });

  test('memuat bookmark yang tersimpan setelah service dibuat ulang', () async {
    final first = BookmarkService();
    await first.load();
    await first.add(buildArticle('Berita Satu', url: 'https://example.com/1'));
    await first.add(buildArticle('Berita Dua', url: 'https://example.com/2'));

    final second = BookmarkService();
    await second.load();

    expect(second.isLoaded, isTrue);
    expect(second.bookmarks, hasLength(2));
    expect(second.bookmarks.first.title, 'Berita Satu');
  });

  test('toggle menambahkan lalu menghapus bookmark', () async {
    final service = BookmarkService();
    await service.load();
    final article = buildArticle('Berita', url: 'https://example.com/1');

    expect(await service.toggle(article), isTrue);
    expect(service.isBookmarked(article), isTrue);

    expect(await service.toggle(article), isFalse);
    expect(service.isBookmarked(article), isFalse);
  });
}
