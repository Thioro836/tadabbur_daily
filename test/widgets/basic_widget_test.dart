import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Basic Widget Tests', () {
    testWidgets('MaterialApp should render', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: Center(child: Text('Test'))),
        ),
      );

      expect(find.byType(MaterialApp), findsOneWidget);
      expect(find.text('Test'), findsOneWidget);
    });

    testWidgets('Widgets should respond to taps', (WidgetTester tester) async {
      int tapCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: FloatingActionButton(
                onPressed: () => tapCount++,
                child: const Icon(Icons.add),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(FloatingActionButton));
      expect(tapCount, 1);
    });

    testWidgets('Text widgets should display content', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: Center(child: Text('Hello World'))),
        ),
      );

      expect(find.text('Hello World'), findsOneWidget);
    });

    testWidgets('List should render items', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListView(
              children: const [
                ListTile(title: Text('Item 1')),
                ListTile(title: Text('Item 2')),
                ListTile(title: Text('Item 3')),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(ListTile), findsWidgets);
      expect(find.text('Item 1'), findsOneWidget);
      expect(find.text('Item 2'), findsOneWidget);
      expect(find.text('Item 3'), findsOneWidget);
    });
  });

  group('Widget Layout Tests', () {
    testWidgets('Column should layout children vertically', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Column(
              children: [Text('Top'), Text('Middle'), Text('Bottom')],
            ),
          ),
        ),
      );

      expect(find.text('Top'), findsOneWidget);
      expect(find.text('Middle'), findsOneWidget);
      expect(find.text('Bottom'), findsOneWidget);
    });

    testWidgets('Row should layout children horizontally', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Row(children: [Text('Left'), Text('Center'), Text('Right')]),
          ),
        ),
      );

      expect(find.text('Left'), findsOneWidget);
      expect(find.text('Center'), findsOneWidget);
      expect(find.text('Right'), findsOneWidget);
    });
  });
}
