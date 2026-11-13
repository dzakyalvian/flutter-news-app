// Smoke test dasar untuk News App.
// Tes template bawaan Flutter (counter) diganti karena widget MyApp
// tidak pernah ada di proyek ini.

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_news_app/main.dart';

void main() {
  setUpAll(() {
    dotenv.loadFromString(envString: 'NEWS_API_KEY=test-key');
  });

  testWidgets('NewsApp menampilkan halaman berita', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const NewsApp());

    expect(find.text('News App'), findsOneWidget);
  });
}
