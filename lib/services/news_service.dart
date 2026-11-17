import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import '../models/article.dart';

class NewsService {
  NewsService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<List<Article>> fetchTopHeadlines({String category = 'general'}) async {
    final uri = Uri.https('newsapi.org', '/v2/top-headlines', {
      'country': 'us',
      'category': category,
      'pageSize': '20',
    });
    return _getArticles(uri, category: category);
  }

  Future<List<Article>> searchArticles({required String query}) async {
    final uri = Uri.https('newsapi.org', '/v2/everything', {
      'q': query,
      'pageSize': '20',
      'sortBy': 'publishedAt',
    });
    return _getArticles(uri);
  }

  Future<List<Article>> _getArticles(Uri uri, {String category = ''}) async {
    final apiKey = dotenv.env['NEWS_API_KEY'] ?? '';

    if (apiKey.isEmpty) {
      throw Exception('NEWS_API_KEY belum diatur. Periksa file .env.');
    }

    final response = await _client.get(uri, headers: {'X-Api-Key': apiKey});

    if (response.statusCode != 200) {
      throw Exception(
        'Permintaan berita gagal. Kode HTTP: ${response.statusCode}',
      );
    }

    final Map<String, dynamic> data;

    try {
      data = jsonDecode(response.body) as Map<String, dynamic>;
    } on FormatException {
      throw Exception('Respons berita tidak valid.');
    }

    if (data['status'] != 'ok') {
      throw Exception(data['message'] ?? 'NewsAPI mengembalikan kesalahan.');
    }

    final articlesJson = data['articles'] as List<dynamic>? ?? [];
    return articlesJson
        .map(
          (json) => Article.fromJson(
            json as Map<String, dynamic>,
            category: category,
          ),
        )
        .toList();
  }
}
