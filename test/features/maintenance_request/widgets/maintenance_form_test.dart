import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:clean_stream_laundry_app/features/machine_payment/widgets/dryer_controls_card.dart';

ThemeData _testTheme() => ThemeData.light();

Widget _wrap({required void Function(double, int) onChanged}) {
  return MaterialApp(
    theme: _testTheme(),
    home: Scaffold(
      body: DryerControlsCard(onChanged: onChanged),
    ),
  );
}

void main() {
  group('DryerControlsCard', () {

    testWidgets('renders title text', (tester) async {
      await tester.pumpWidget(_wrap(onChanged: (_, __) {}));
      expect(find.text('Set Dry Time'), findsOneWidget);
    });

    testWidgets('renders default 30 min label', (tester) async {
      await tester.pumpWidget(_wrap(onChanged: (_, __) {}));
      expect(find.text('30 min'), findsOneWidget);
    });

    testWidgets('renders pricing hint text', (tester) async {
      await tester.pumpWidget(_wrap(onChanged: (_, __) {}));
      expect(find.text('\$0.25 per 5 minutes'), findsOneWidget);
    });

    testWidgets('renders min and max labels', (tester) async {
      await tester.pumpWidget(_wrap(onChanged: (_, __) {}));
      expect(find.text('5 min'), findsOneWidget);
      expect(find.text('90 min'), findsOneWidget);
    });

    testWidgets('renders a Slider', (tester) async {
      await tester.pumpWidget(_wrap(onChanged: (_, __) {}));
      expect(find.byType(Slider), findsOneWidget);
    });

    testWidgets('renders as a Card with elevation', (tester) async {
      await tester.pumpWidget(_wrap(onChanged: (_, __) {}));
      final card = tester.widget<Card>(find.byType(Card));
      expect(card.elevation, 4);
    });


    testWidgets('fires onChanged after first frame with default values',
            (tester) async {
          double? receivedPrice;
          int? receivedMinutes;

          await tester.pumpWidget(_wrap(onChanged: (price, minutes) {
            receivedPrice = price;
            receivedMinutes = minutes;
          }));

          await tester.pump();

          expect(receivedMinutes, 30);
          expect(receivedPrice, closeTo(1.50, 0.001));
        });


    group('price calculation', () {
      Future<void> dragToMinutes(WidgetTester tester, int minutes) async {
        final slider = find.byType(Slider);
        final sliderRect = tester.getRect(slider);

        const thumbPadding = 24.0;
        final trackLeft = sliderRect.left + thumbPadding;
        final trackWidth = sliderRect.width - thumbPadding * 2;

        final fraction = (minutes - 5) / 85.0;
        final x = trackLeft + fraction * trackWidth;

        await tester.tapAt(Offset(x, sliderRect.center.dy));
        await tester.pump();
      }

      testWidgets('5 min → \$0.25', (tester) async {
        double? price;
        await tester.pumpWidget(
            _wrap(onChanged: (p, _) => price = p));
        await dragToMinutes(tester, 5);
        expect(price, closeTo(0.25, 0.001));
      });

      testWidgets('30 min → \$1.50', (tester) async {
        double? price;
        await tester.pumpWidget(
            _wrap(onChanged: (p, _) => price = p));
        await dragToMinutes(tester, 30);
        expect(price, closeTo(1.50, 0.001));
      });

      testWidgets('60 min → \$3.00', (tester) async {
        double? price;
        await tester.pumpWidget(
            _wrap(onChanged: (p, _) => price = p));
        await dragToMinutes(tester, 60);
        expect(price, closeTo(3.00, 0.001));
      });

      testWidgets('90 min → \$4.50', (tester) async {
        double? price;
        await tester.pumpWidget(
            _wrap(onChanged: (p, _) => price = p));
        await dragToMinutes(tester, 90);
        expect(price, closeTo(4.50, 0.001));
      });
    });


    testWidgets('slider value snaps to multiples of 5', (tester) async {
      final capturedMinutes = <int>[];

      await tester.pumpWidget(
          _wrap(onChanged: (_, minutes) => capturedMinutes.add(minutes)));

      final slider = find.byType(Slider);
      final sliderBox = tester.renderObject(slider) as RenderBox;
      final sliderWidth = sliderBox.size.width;
      final center = tester.getCenter(slider);

      await tester.timedDragFrom(
        Offset(center.dx - sliderWidth / 2, center.dy),
        Offset(sliderWidth, 0),
        const Duration(milliseconds: 500),
      );
      await tester.pump();

      for (final m in capturedMinutes) {
        expect(m % 5, 0,
            reason: '$m is not a multiple of 5');
      }
    });

    testWidgets('minute label updates when slider moves', (tester) async {
      await tester.pumpWidget(_wrap(onChanged: (_, __) {}));

      final slider = find.byType(Slider);
      final sliderBox = tester.renderObject(slider) as RenderBox;
      final sliderWidth = sliderBox.size.width;
      final center = tester.getCenter(slider);

      await tester.dragFrom(
        Offset(center.dx - sliderWidth / 2, center.dy),
        Offset(sliderWidth, 0),
      );
      await tester.pump();

      expect(find.text('90 min'), findsWidgets);
    });


    testWidgets('onChanged is called when slider moves', (tester) async {
      int callCount = 0;
      await tester.pumpWidget(
          _wrap(onChanged: (_, __) => callCount++));

      await tester.pump();
      callCount = 0;

      final slider = find.byType(Slider);
      final sliderBox = tester.renderObject(slider) as RenderBox;
      final sliderWidth = sliderBox.size.width;
      final center = tester.getCenter(slider);

      await tester.dragFrom(
        Offset(center.dx - sliderWidth / 2, center.dy),
        Offset(sliderWidth * 0.5, 0),
      );
      await tester.pump();

      expect(callCount, greaterThan(0));
    });

    testWidgets('onChanged price and minutes are consistent', (tester) async {
      double? lastPrice;
      int? lastMinutes;

      await tester.pumpWidget(_wrap(onChanged: (price, minutes) {
        lastPrice = price;
        lastMinutes = minutes;
      }));

      final slider = find.byType(Slider);
      final sliderBox = tester.renderObject(slider) as RenderBox;
      final sliderWidth = sliderBox.size.width;
      final center = tester.getCenter(slider);

      await tester.dragFrom(
        Offset(center.dx - sliderWidth / 2, center.dy),
        Offset(sliderWidth * 0.35, 0), // somewhere in the middle
      );
      await tester.pump();

      expect(lastMinutes, isNotNull);
      expect(lastPrice, isNotNull);
      final expectedPrice = (lastMinutes! / 5) * 0.25;
      expect(lastPrice, closeTo(expectedPrice, 0.001));
    });
  });
}