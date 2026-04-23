import 'package:flutter_test/flutter_test.dart';
import 'package:mms/main.dart';

void main() {
  testWidgets('Home screen renders Inventory and Admin buttons',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MmsApp());
    expect(find.text('Inventory'), findsOneWidget);
    expect(find.text('Admin'), findsOneWidget);
  });
}
