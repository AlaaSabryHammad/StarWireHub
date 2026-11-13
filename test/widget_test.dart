import 'package:flutter_test/flutter_test.dart';
import 'package:new_repo/main.dart';

void main() {
  testWidgets('Starwire app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const StarwireApp());

    // Verify that the splash title exists.
    expect(find.text('StarWireHub'), findsOneWidget);
  });
}
