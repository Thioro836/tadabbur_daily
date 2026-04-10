import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Screen Integration Tests', () {
    testWidgets('Basic Material App should render without errors', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: AppBar(title: const Text('Test')),
            body: const Center(child: Text('Test Body')),
          ),
        ),
      );

      expect(find.text('Test'), findsWidgets);
      expect(find.text('Test Body'), findsOneWidget);
    });

    testWidgets('Navigation between screens should work', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: AppBar(title: const Text('Screen 1')),
            body: Center(
              child: ElevatedButton(
                onPressed: () {},
                child: const Text('Go to Screen 2'),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Screen 1'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('ListTile interaction should work', (
      WidgetTester tester,
    ) async {
      int tapCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: AppBar(title: const Text('List')),
            body: ListView(
              children: [
                ListTile(title: const Text('Item 1'), onTap: () => tapCount++),
                ListTile(title: const Text('Item 2'), onTap: () => tapCount++),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(ListTile), findsWidgets);
      expect(find.text('Item 1'), findsOneWidget);
      expect(find.text('Item 2'), findsOneWidget);

      // Tap on first item
      await tester.tap(find.text('Item 1'));
      await tester.pumpAndSettle();
    });

    testWidgets('Form input should work correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: AppBar(title: const Text('Form')),
            body: const Center(
              child: TextField(
                decoration: InputDecoration(hintText: 'Enter text'),
              ),
            ),
          ),
        ),
      );

      expect(find.byType(TextField), findsOneWidget);

      // Type in text field
      await tester.enterText(find.byType(TextField), 'Test input');
      await tester.pumpAndSettle();

      expect(find.text('Test input'), findsOneWidget);
    });

    testWidgets('Column layout should render correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: AppBar(title: const Text('Column')),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Top'),
                  const SizedBox(height: 20),
                  const Text('Middle'),
                  const SizedBox(height: 20),
                  const Text('Bottom'),
                ],
              ),
            ),
          ),
        ),
      );

      expect(find.text('Top'), findsOneWidget);
      expect(find.text('Middle'), findsOneWidget);
      expect(find.text('Bottom'), findsOneWidget);
    });

    testWidgets('Row layout should render correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: AppBar(title: const Text('Row')),
            body: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  const Text('Left'),
                  const Text('Center'),
                  const Text('Right'),
                ],
              ),
            ),
          ),
        ),
      );

      expect(find.text('Left'), findsOneWidget);
      expect(find.text('Center'), findsOneWidget);
      expect(find.text('Right'), findsOneWidget);
    });

    testWidgets('Drawer should open and close', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: AppBar(title: const Text('Drawer Demo')),
            drawer: Drawer(
              child: ListView(
                children: [
                  const DrawerHeader(child: Text('Drawer Header')),
                  ListTile(title: const Text('Item 1'), onTap: () {}),
                ],
              ),
            ),
            body: const Center(child: Text('Main')),
          ),
        ),
      );

      expect(find.text('Main'), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('Tab navigation should work', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: DefaultTabController(
            length: 3,
            child: Scaffold(
              appBar: AppBar(
                title: const Text('Tabs'),
                bottom: const TabBar(
                  tabs: [
                    Tab(icon: Icon(Icons.home), text: 'Home'),
                    Tab(icon: Icon(Icons.search), text: 'Search'),
                    Tab(icon: Icon(Icons.settings), text: 'Settings'),
                  ],
                ),
              ),
              body: const TabBarView(
                children: [
                  Center(child: Text('Home Screen')),
                  Center(child: Text('Search Screen')),
                  Center(child: Text('Settings Screen')),
                ],
              ),
            ),
          ),
        ),
      );

      expect(find.byType(TabBar), findsOneWidget);
      expect(find.text('Home Screen'), findsOneWidget);
    });

    testWidgets('Card widget should display content', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: AppBar(title: const Text('Cards')),
            body: Center(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Card Title'),
                      const SizedBox(height: 10),
                      const Text('Card Content'),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () {},
                        child: const Text('Action'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.byType(Card), findsOneWidget);
      expect(find.text('Card Title'), findsOneWidget);
      expect(find.text('Card Content'), findsOneWidget);
    });
  });
}
