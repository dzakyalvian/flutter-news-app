import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/article.dart';

/// Menyimpan daftar artikel yang di-bookmark dan menyinkronkan statusnya
/// ke seluruh halaman melalui [ChangeNotifier].
///
/// Data dipersistensikan ke `shared_preferences` sehingga bookmark tetap
/// tersedia setelah aplikasi ditutup dan dibuka kembali.
class BookmarkService extends ChangeNotifier {
  BookmarkService();

  /// Instance bersama yang dipakai aplikasi secara default.
  static final BookmarkService instance = BookmarkService();

  static const String storageKey = 'bookmarked_articles_v1';

  final List<Article> _bookmarks = [];
  bool _isLoaded = false;

  List<Article> get bookmarks => List.unmodifiable(_bookmarks);

  bool get isLoaded => _isLoaded;

  /// URL adalah identitas utama. Jika URL tidak tersedia, gunakan
  /// kombinasi judul, sumber, dan tanggal agar artikel tetap unik.
  static String identityOf(Article article) {
    final url = article.url.trim();
    if (url.isNotEmpty) {
      return url;
    }
    return '${article.title.trim()}|${article.sourceName.trim()}|'
        '${article.publishedAt.trim()}';
  }

  bool isBookmarked(Article article) {
    final id = identityOf(article);
    return _bookmarks.any((item) => identityOf(item) == id);
  }

  /// Membaca bookmark dari penyimpanan lokal. Entri duplikat atau rusak
  /// diabaikan agar daftar tetap konsisten.
  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getStringList(storageKey) ?? const [];

    _bookmarks.clear();
    for (final encoded in stored) {
      try {
        final json = jsonDecode(encoded) as Map<String, dynamic>;
        final article = Article.fromJson(json);
        final isDuplicate = _bookmarks.any(
          (item) => identityOf(item) == identityOf(article),
        );
        if (!isDuplicate) {
          _bookmarks.add(article);
        }
      } on FormatException {
        // Lewati entri yang tidak bisa dibaca.
      } on TypeError {
        // Lewati entri dengan struktur JSON yang tidak sesuai.
      }
    }

    _isLoaded = true;
    notifyListeners();
  }

  /// Menambahkan artikel. Mengembalikan `false` jika artikel sudah ada.
  Future<bool> add(Article article) async {
    if (isBookmarked(article)) {
      return false;
    }
    _bookmarks.add(article);
    notifyListeners();
    await _persist();
    return true;
  }

  /// Menghapus artikel. Mengembalikan `false` jika tidak ditemukan.
  Future<bool> remove(Article article) async {
    final id = identityOf(article);
    final lengthBefore = _bookmarks.length;
    _bookmarks.removeWhere((item) => identityOf(item) == id);
    if (_bookmarks.length == lengthBefore) {
      return false;
    }
    notifyListeners();
    await _persist();
    return true;
  }

  /// Mengembalikan status bookmark terbaru: `true` jika tersimpan.
  Future<bool> toggle(Article article) async {
    if (isBookmarked(article)) {
      await remove(article);
      return false;
    }
    await add(article);
    return true;
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = _bookmarks
        .map((article) => jsonEncode(article.toJson()))
        .toList();
    await prefs.setStringList(storageKey, encoded);
  }
}
