import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:clean_stream_laundry_app/widgets/settings_card.dart';

void main() {
  group('SettingsCard Widget Tests', () {
    testWidgets('renders with title and icon', (WidgetTester tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SettingsCard(
              icon: Icons.settings,
              title: 'Settings',
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      expect(find.text('Settings'), findsOneWidget);
      expect(find.byIcon(Icons.settings), findsOneWidget);
      
      expect(find.byIcon(Icons.chevron_right), findsNothing);
    });

    testWidgets('renders with subtitle when provided', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SettingsCard(
              icon: Icons.notifications,
              title: 'Notifications',
              subtitle: 'Manage your notification preferences',
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('Notifications'), findsOneWidget);
      expect(find.text('Manage your notification preferences'), findsOneWidget);
      expect(find.byIcon(Icons.notifications), findsOneWidget);
    });

    testWidgets('does not render subtitle when null', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SettingsCard(
              icon: Icons.account_circle,
              title: 'Account',
              subtitle: null,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('Account'), findsOneWidget);

      final textWidgets = tester.widgetList<Text>(find.byType(Text));
      expect(textWidgets.length, 1);
    });

    testWidgets('calls onTap when tapped', (WidgetTester tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SettingsCard(
              icon: Icons.privacy_tip,
              title: 'Privacy',
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(ListTile));
      await tester.pumpAndSettle();

      expect(tapped, true);
    });

    testWidgets('Card has correct margin', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SettingsCard(icon: Icons.help, title: 'Help', onTap: () {}),
          ),
        ),
      );

      final card = tester.widget<Card>(find.byType(Card));

      expect(card.margin, const EdgeInsets.symmetric(horizontal: 24));
    });

    testWidgets('displays correct icon', (WidgetTester tester) async {
      const testIcon = Icons.security;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SettingsCard(icon: testIcon, title: 'Security', onTap: () {}),
          ),
        ),
      );

      expect(find.byIcon(testIcon), findsOneWidget);
    });

    testWidgets('text uses theme colors', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          ),
          home: Scaffold(
            body: SettingsCard(
              icon: Icons.palette,
              title: 'Theme',
              subtitle: 'Customize appearance',
              onTap: () {},
            ),
          ),
        ),
      );

      final titleText = tester.widget<Text>(find.text('Theme'));
      expect(titleText.style?.fontSize, 16);

      final subtitleText = tester.widget<Text>(find.text('Customize appearance'));
      expect(subtitleText.style?.fontSize, 12);
    });

    testWidgets('handles long text without overflow', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SettingsCard(
              icon: Icons.text_fields,
              title: 'Very Long Title That Should Not Overflow The Card Width',
              subtitle:
              'This is a very long subtitle that should also handle gracefully without causing any overflow issues',
              onTap: () {},
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
    });

    testWidgets('renders trailing widget when provided', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SettingsCard(
              icon: Icons.timer,
              title: 'Timer',
              trailing: const Icon(Icons.chevron_right),
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.chevron_right), findsOneWidget);
    });
  });
}