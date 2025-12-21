// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: MyHomePage());
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  void _increment() => setState(() => _counter++);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reporting App')),
      body: Center(child: Text('$_counter', key: const Key('counterText'))),
      floatingActionButton: FloatingActionButton(
        key: const Key('incrementFab'),
        onPressed: _increment,
        child: const Icon(Icons.add),
      ),
    );
  }
}

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that our counter starts at 0.
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    // Tap the '+' icon and trigger a frame.
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    // Verify that our counter has incremented.
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });

  testWidgets('App has AppBar title and FAB', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Reporting App'), findsOneWidget);
    expect(find.byKey(const Key('incrementFab')), findsOneWidget);
  });

  testWidgets('Multiple taps increment counter', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    final fab = find.byKey(const Key('incrementFab'));
    expect(fab, findsOneWidget);

    await tester.tap(fab);
    await tester.tap(fab);
    await tester.tap(fab);
    await tester.pump();

    expect(find.text('3'), findsOneWidget);
  });

  testWidgets('Counter text uses key and updates', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    final counterText = find.byKey(const Key('counterText'));
    expect(counterText, findsOneWidget);
    expect(find.text('0'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    expect(find.text('1'), findsOneWidget);
  });
}
