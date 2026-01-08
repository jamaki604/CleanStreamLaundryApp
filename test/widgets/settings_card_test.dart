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
      expect(find.byIcon(Icons.chevron_right), findsOneWidget);
    });

    testWidgets('renders with subtitle when provided', (
      WidgetTester tester,
    ) async {
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

    testWidgets('does not render subtitle when null', (
      WidgetTester tester,
    ) async {
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
      expect(find.byType(Text), findsNWidgets(1)); // Only title text
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

      await tester.tap(find.byType(SettingsCard));
      await tester.pumpAndSettle();

      expect(tapped, true);
    });

    testWidgets('has correct Card styling', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SettingsCard(icon: Icons.help, title: 'Help', onTap: () {}),
          ),
        ),
      );

      final card = tester.widget<Card>(find.byType(Card));

      expect(card.elevation, 2);
      expect(
        card.margin,
        const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      );
      expect(card.shape, isA<RoundedRectangleBorder>());
    });

    testWidgets('has InkWell with correct border radius', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SettingsCard(icon: Icons.info, title: 'About', onTap: () {}),
          ),
        ),
      );

      final inkWell = tester.widget<InkWell>(find.byType(InkWell));

      expect(inkWell.borderRadius, BorderRadius.circular(14));
    });

    testWidgets('icon container has correct styling', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SettingsCard(
              icon: Icons.language,
              title: 'Language',
              onTap: () {},
            ),
          ),
        ),
      );

      final containers = tester.widgetList<Container>(find.byType(Container));
      final iconContainer = containers.firstWhere(
        (container) => container.constraints?.maxWidth == 40,
      );

      expect(iconContainer.constraints?.maxWidth, 40);
      expect(iconContainer.constraints?.maxHeight, 40);
      expect(
        (iconContainer.decoration as BoxDecoration).borderRadius,
        BorderRadius.circular(10),
      );
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

    testWidgets('text uses correct theme styles', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
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
      expect(titleText.style?.fontWeight, FontWeight.w600);

      final subtitleText = tester.widget<Text>(
        find.text('Customize appearance'),
      );
      expect(subtitleText.style, isNotNull);
    });

    testWidgets('chevron icon is always displayed', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SettingsCard(
              icon: Icons.backup,
              title: 'Backup',
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.chevron_right), findsOneWidget);

      final chevronIcon = tester.widget<Icon>(find.byIcon(Icons.chevron_right));
      expect(chevronIcon.color, Colors.grey);
    });

    testWidgets('can tap on any part of the card', (WidgetTester tester) async {
      int tapCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SettingsCard(
              icon: Icons.download,
              title: 'Downloads',
              subtitle: 'Manage downloads',
              onTap: () => tapCount++,
            ),
          ),
        ),
      );

      // Tap on title
      await tester.tap(find.text('Downloads'));
      await tester.pumpAndSettle();
      expect(tapCount, 1);

      // Tap on subtitle
      await tester.tap(find.text('Manage downloads'));
      await tester.pumpAndSettle();
      expect(tapCount, 2);

      // Tap on icon
      await tester.tap(find.byIcon(Icons.download));
      await tester.pumpAndSettle();
      expect(tapCount, 3);
    });

    testWidgets('respects theme colors', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.purple),
          ),
          home: Scaffold(
            body: SettingsCard(
              icon: Icons.color_lens,
              title: 'Colors',
              onTap: () {},
            ),
          ),
        ),
      );

      final icon = tester.widget<Icon>(find.byIcon(Icons.color_lens));
      expect(icon.color, isNotNull);
    });

    testWidgets('handles long text without overflow', (
      WidgetTester tester,
    ) async {
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
  });
}
