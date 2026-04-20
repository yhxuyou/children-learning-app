import 'package:flutter_test/flutter_test.dart';
import 'package:children_learning_app/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const ChildrenLearningApp());
    expect(find.text('儿童学习乐园'), findsOneWidget);
  });
}
