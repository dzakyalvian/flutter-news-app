import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:flutter_news_app/models/article.dart';
import 'package:flutter_news_app/services/news_service.dart';

void main() {
  setUpAll(() {
    dotenv.loadFromString(envString: 'NEWS_API_KEY=test-key');
  });

  group('Article.fromJson', () {
    test('memetakan semua field dengan benar', () {
      final article = Article.fromJson({
        'title': 'Judul',
        'description': 'Deskripsi',
        'urlToImage': 'https://example.com/a.jpg',
        'source': {'name': 'Sumber'},
        'publishedAt': '2026-01-01T00:00:00Z',
        'url': 'https://example.com/a',
      });

      expect(article.title, 'Judul');
      expect(article.description, 'Deskripsi');
      expect(article.imageUrl, 'https://example.com/a.jpg');
      expect(article.sourceName, 'Sumber');
      expect(article.publishedAt, '2026-01-01T00:00:00Z');
      expect(article.url, 'https://example.com/a');
    });

    test('memakai fallback untuk field yang hilang', () {
      final article = Article.fromJson({});

      expect(article.title, 'Judul tidak tersedia');
      expect(article.description, '');
      expect(article.imageUrl, '');
      expect(article.sourceName, 'Sumber tidak diketahui');
      expect(article.publishedAt, '');
      expect(article.url, '');
    });
  });

  group('NewsService', () {
    test('melempar pesan kode HTTP untuk respons non-200', () async {
      final service = NewsService(
        client: MockClient((request) async {
          return http.Response('Internal Server Error', 500);
        }),
      );

      expect(
        service.fetchTopHeadlines(),
        throwsA(predicate((e) => e.toString().contains('Kode HTTP: 500'))),
      );
    });

    test('tidak crash saat body error bukan JSON', () async {
      final service = NewsService(
        client: MockClient((request) async {
          return http.Response('<html>bad gateway</html>', 502);
        }),
      );

      expect(
        service.fetchTopHeadlines(),
        throwsA(predicate((e) => e.toString().contains('Kode HTTP: 502'))),
      );
    });

    test('melempar pesan API saat status bukan ok', () async {
      final service = NewsService(
        client: MockClient((request) async {
          return http.Response(
            jsonEncode({'status': 'error', 'message': 'apiKeyInvalid'}),
            200,
            headers: {'content-type': 'application/json'},
          );
        }),
      );

      expect(
        service.searchArticles(query: 'flutter'),
        throwsA(predicate((e) => e.toString().contains('apiKeyInvalid'))),
      );
    });

    test('mengembalikan list kosong jika articles tidak ada', () async {
      final service = NewsService(
        client: MockClient((request) async {
          return http.Response(
            jsonEncode({'status': 'ok'}),
            200,
            headers: {'content-type': 'application/json'},
          );
        }),
      );

      expect(await service.fetchTopHeadlines(), isEmpty);
    });

    test('memetakan articles menjadi objek Article', () async {
      final service = NewsService(
        client: MockClient((request) async {
          expect(request.headers['X-Api-Key'], isNotEmpty);
          return http.Response(
            jsonEncode({
              'status': 'ok',
              'articles': [
                {
                  'title': 'Berita uji',
                  'source': {'name': 'Sumber uji'},
                },
              ],
            }),
            200,
            headers: {'content-type': 'application/json'},
          );
        }),
      );

      final articles = await service.fetchTopHeadlines();

      expect(articles, hasLength(1));
      expect(articles.first.title, 'Berita uji');
      expect(articles.first.sourceName, 'Sumber uji');
    });
  });
}
