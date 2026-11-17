import 'package:material_ui/material_ui.dart';

/// Palet Modern Editorial yang dipakai halaman Bookmark dan Detail.
/// Nilainya sama dengan palet di `news_page.dart` agar tampilan konsisten.
const Color kEditorialBackground = Color(0xFFF8F8F6);
const Color kEditorialSurface = Color(0xFFFFFFFF);
const Color kEditorialInk = Color(0xFF171717);
const Color kEditorialMuted = Color(0xFF777777);
const Color kEditorialAccent = Color(0xFFC83B32);
const Color kEditorialLine = Color(0xFFE9E7E1);
const Color kEditorialSoft = Color(0xFFF1F0EC);
const Color kEditorialBodyText = Color(0xFF5F5F5F);

/// Format tanggal editorial singkat: `17 Nov 2026`.
String formatEditorialDate(String raw) {
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
