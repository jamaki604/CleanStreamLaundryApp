import 'package:clean_stream_laundry_app/features/edit_profile/widgets/section_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget buildWidget({required String title}) {
    return MaterialApp(
      home: Scaffold(
        body: SectionHeader(title: title),
      ),
    );
  }

  group('SectionHeader', () {
    testWidgets('displays the title', (tester) async {
      await tester.pumpWidget(buildWidget(title: 'Full Name'));

      expect(find.text('Full Name'), findsOneWidget);
    });

    testWidgets('displays different title values correctly', (tester) async {
      await tester.pumpWidget(buildWidget(title: 'Email Address'));

      expect(find.text('Email Address'), findsOneWidget);
    });

    testWidgets('renders as a Text widget', (tester) async {
      await tester.pumpWidget(buildWidget(title: 'Full Name'));

      expect(find.byType(Text), findsOneWidget);
    });
  });
}