import 'package:clean_stream_laundry_app/widgets/map_marker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MapMarker Widget Tests', () {
    testWidgets('renders correctly with Image asset', (WidgetTester tester) async {
      await tester.pumpWidget(
        const CupertinoApp(
          home: MapMarker(),
        ),
      );

      // Verify Container exists
      expect(find.byType(Container), findsOneWidget);

      // Verify Image exists with correct key
      expect(find.byKey(const Key('app_Icon')), findsOneWidget);

      // Verify Image widget
      final imageFinder = find.byType(Image);
      expect(imageFinder, findsOneWidget);

      // Verify Image properties
      final Image imageWidget = tester.widget(imageFinder);
      final AssetImage assetImage = imageWidget.image as AssetImage;
      expect(assetImage.assetName, 'assets/Icon.png');
      expect(imageWidget.height, 20);
      expect(imageWidget.width, 20);
    });

    testWidgets('Container has correct decoration', (WidgetTester tester) async {
      await tester.pumpWidget(
        const CupertinoApp(
          home: MapMarker(),
        ),
      );

      final Container container = tester.widget(find.byType(Container));
      final BoxDecoration decoration = container.decoration as BoxDecoration;

      expect(decoration.shape, BoxShape.rectangle);
      expect(decoration.color, CupertinoColors.transparent);
    });
  });
}