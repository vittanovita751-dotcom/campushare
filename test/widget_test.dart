import 'package:flutter_test/flutter_test.dart';
import 'package:campushare/main.dart';

void main() {
  testWidgets('CampuShare Login Screen Smoke Test', (WidgetTester tester) async {
    // 1. Build aplikasi CampuShareApp kita ke dalam sistem test.
    await tester.pumpWidget(const CampuShareApp());

    // 2. Cek apakah teks judul di halaman login muncul dengan benar.
    expect(find.text('🏫 CampuShare Hub'), findsOneWidget);
    
    // 3. Cek apakah tombol masuk aplikasi sudah ada di layar.
    expect(find.text('Masuk Aplikasi'), findsOneWidget);
  });
}