
import 'package:flutter_test/flutter_test.dart';
import 'package:uts_mobile/main.dart';

void main() {
  testWidgets('Aplikasi Cuaca Malang dapat dibuka', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const WeatherApp());

    expect(find.text('Cuaca Malang'), findsOneWidget);
  });
}
