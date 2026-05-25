import 'package:flutter_test/flutter_test.dart';
import 'package:miaohui/main.dart';

void main() {
  testWidgets('App should launch', (WidgetTester tester) async {
    await tester.pumpWidget(const MiaohuiApp());
    expect(find.text('秒回'), findsOneWidget);
  });
}
