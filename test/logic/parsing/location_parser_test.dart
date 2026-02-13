import 'package:clean_stream_laundry_app/logic/parsing/location_parser.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:clean_stream_laundry_app/widgets/map_marker.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:mocktail/mocktail.dart';
import 'package:geolocator/geolocator.dart';

class MockGeolocatorPlatform extends Mock implements GeolocatorPlatform {}

void main() {
  group('LocationParser', () {
    test('parseLocations returns empty list when input is empty', () {
      final result = LocationParser.parseLocations([]);
      expect(result, isEmpty);
    });

    test('parseLocations creates markers with correct coordinates', () {
      final locations = [
        {'Latitude': 40.7128, 'Longitude': -74.0060},
        {'Latitude': 34.0522, 'Longitude': -118.2437},
      ];

      final result = LocationParser.parseLocations(locations);

      expect(result.length, 2);
      expect(result[0].point.latitude, 40.7128);
      expect(result[0].point.longitude, -74.0060);
      expect(result[1].point.latitude, 34.0522);
      expect(result[1].point.longitude, -118.2437);
    });

    test('parseLocations sets correct marker dimensions', () {
      final locations = [
        {'Latitude': 40.7128, 'Longitude': -74.0060},
      ];

      final result = LocationParser.parseLocations(locations);

      expect(result[0].width, 50);
      expect(result[0].height, 50);
    });

    test('parseLocations creates MapMarker widget as child', () {
      final locations = [
        {'Latitude': 40.7128, 'Longitude': -74.0060},
      ];

      final result = LocationParser.parseLocations(locations);

      expect(result[0].child, isA<MapMarker>());
    });

    test('parseLocations skips locations without Latitude', () {
      final locations = [
        {'Longitude': -74.0060},
        {'Latitude': 34.0522, 'Longitude': -118.2437},
      ];

      final result = LocationParser.parseLocations(locations);

      expect(result.length, 1);
      expect(result[0].point.latitude, 34.0522);
    });

    test('parseLocations skips locations without Longitude', () {
      final locations = [
        {'Latitude': 40.7128},
        {'Latitude': 34.0522, 'Longitude': -118.2437},
      ];

      final result = LocationParser.parseLocations(locations);

      expect(result.length, 1);
      expect(result[0].point.latitude, 34.0522);
    });

    test('parseLocations handles integer coordinates', () {
      final locations = [
        {'Latitude': 40, 'Longitude': -74},
      ];

      final result = LocationParser.parseLocations(locations);

      expect(result.length, 1);
      expect(result[0].point.latitude, 40.0);
      expect(result[0].point.longitude, -74.0);
    });

    test('parseLocations handles mixed valid and invalid locations', () {
      final locations = [
        {'Latitude': 40.7128, 'Longitude': -74.0060},
        {'Latitude': 34.0522},
        {'Longitude': -118.2437},
        {'Latitude': 51.5074, 'Longitude': -0.1278},
      ];

      final result = LocationParser.parseLocations(locations);

      expect(result.length, 2);
      expect(result[0].point.latitude, 40.7128);
      expect(result[1].point.latitude, 51.5074);
    });

    testWidgets('parseLocations creates fully initialized Marker objects',
            (WidgetTester tester) async {
          final locations = [
            {'Latitude': 40.7128, 'Longitude': -74.0060},
          ];

          final result = LocationParser.parseLocations(locations);

          expect(result.length, 1);

          final marker = result[0];
          expect(marker.point.latitude, 40.7128);
          expect(marker.point.longitude, -74.0060);
          expect(marker.width, 50);
          expect(marker.height, 50);

          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: marker.child,
              ),
            ),
          );

          expect(find.byType(MapMarker), findsOneWidget);
        });

    test('parseLocations constructs complete Marker with all properties', () {
      final locations = [
        {'Latitude': 40.7128, 'Longitude': -74.0060},
      ];

      final result = LocationParser.parseLocations(locations);
      final marker = result[0];

      expect(marker.point, isA<LatLng>());
      expect(marker.point.latitude, 40.7128);
      expect(marker.point.longitude, -74.0060);
      expect(marker.width, 50.0);
      expect(marker.height, 50.0);
      expect(marker.child, isA<MapMarker>());
      expect(marker.point.latitude, isA<double>());
      expect(marker.point.longitude, isA<double>());
    });
  });

  group('LocationParser - Geolocator Methods', () {
    late MockGeolocatorPlatform mockGeolocator;
    late LocationParser locationParser;

    setUp(() {
      mockGeolocator = MockGeolocatorPlatform();
      locationParser = LocationParser(geolocator: mockGeolocator);
    });

    group('determinePosition', () {
      test('returns position string when permission is already granted',
              () async {
            final mockPosition = Position(
              latitude: 37.7749,
              longitude: -122.4194,
              timestamp: DateTime(2024, 1, 1),
              accuracy: 10.0,
              altitude: 0.0,
              heading: 0.0,
              speed: 0.0,
              speedAccuracy: 0.0,
              altitudeAccuracy: 0.0,
              headingAccuracy: 0.0,
            );

            when(() => mockGeolocator.checkPermission())
                .thenAnswer((_) async => LocationPermission.always);
            when(() => mockGeolocator.getCurrentPosition(
              locationSettings: any(named: 'locationSettings'),
            )).thenAnswer((_) async => mockPosition);

            final result = await locationParser.determinePosition();

            expect(result, contains('Latitude: 37.7749'));
            expect(result, contains('Longitude: -122.4194'));
            verify(() => mockGeolocator.checkPermission()).called(1);
            verify(() => mockGeolocator.getCurrentPosition(
              locationSettings: any(named: 'locationSettings'),
            )).called(1);
            verifyNever(() => mockGeolocator.requestPermission());
          });

      test('requests and grants permission when initially denied', () async {
        final mockPosition = Position(
          latitude: 37.7749,
          longitude: -122.4194,
          timestamp: DateTime(2024, 1, 1),
          accuracy: 10.0,
          altitude: 0.0,
          heading: 0.0,
          speed: 0.0,
          speedAccuracy: 0.0,
          altitudeAccuracy: 0.0,
          headingAccuracy: 0.0,
        );

        when(() => mockGeolocator.checkPermission())
            .thenAnswer((_) async => LocationPermission.denied);
        when(() => mockGeolocator.requestPermission())
            .thenAnswer((_) async => LocationPermission.whileInUse);
        when(() => mockGeolocator.getCurrentPosition(
          locationSettings: any(named: 'locationSettings'),
        )).thenAnswer((_) async => mockPosition);

        final result = await locationParser.determinePosition();

        expect(result, contains('Latitude: 37.7749'));
        verify(() => mockGeolocator.checkPermission()).called(1);
        verify(() => mockGeolocator.requestPermission()).called(1);
        verify(() => mockGeolocator.getCurrentPosition(
          locationSettings: any(named: 'locationSettings'),
        )).called(1);
      });

      test('handles whileInUse permission', () async {
        final mockPosition = Position(
          latitude: 40.7128,
          longitude: -74.0060,
          timestamp: DateTime(2024, 1, 1),
          accuracy: 15.0,
          altitude: 0.0,
          heading: 0.0,
          speed: 0.0,
          speedAccuracy: 0.0,
          altitudeAccuracy: 0.0,
          headingAccuracy: 0.0,
        );

        when(() => mockGeolocator.checkPermission())
            .thenAnswer((_) async => LocationPermission.whileInUse);
        when(() => mockGeolocator.getCurrentPosition(
          locationSettings: any(named: 'locationSettings'),
        )).thenAnswer((_) async => mockPosition);

        final result = await locationParser.determinePosition();

        expect(result, contains('Latitude: 40.7128'));
        expect(result, contains('Longitude: -74.006'));
      });
    });

    group('parseCurrentLocation', () {
      test('correctly parses position string into coordinate list', () async {
        final mockPosition = Position(
          latitude: 37.7749,
          longitude: -122.4194,
          timestamp: DateTime(2024, 1, 1),
          accuracy: 10.0,
          altitude: 0.0,
          heading: 0.0,
          speed: 0.0,
          speedAccuracy: 0.0,
          altitudeAccuracy: 0.0,
          headingAccuracy: 0.0,
        );

        when(() => mockGeolocator.checkPermission())
            .thenAnswer((_) async => LocationPermission.always);
        when(() => mockGeolocator.getCurrentPosition(
          locationSettings: any(named: 'locationSettings'),
        )).thenAnswer((_) async => mockPosition);

        final coords = await locationParser.parseCurrentLocation();

        expect(coords.length, equals(2));
        expect(coords[0], equals(37.7749));
        expect(coords[1], equals(-122.4194));
      });

      test('handles negative coordinates correctly', () async {
        final mockPosition = Position(
          latitude: -33.8688,
          longitude: 151.2093,
          timestamp: DateTime(2024, 1, 1),
          accuracy: 10.0,
          altitude: 0.0,
          heading: 0.0,
          speed: 0.0,
          speedAccuracy: 0.0,
          altitudeAccuracy: 0.0,
          headingAccuracy: 0.0,
        );

        when(() => mockGeolocator.checkPermission())
            .thenAnswer((_) async => LocationPermission.always);
        when(() => mockGeolocator.getCurrentPosition(
          locationSettings: any(named: 'locationSettings'),
        )).thenAnswer((_) async => mockPosition);

        final coords = await locationParser.parseCurrentLocation();

        expect(coords[0], equals(-33.8688));
        expect(coords[1], equals(151.2093));
      });

      test('returns list of doubles', () async {
        final mockPosition = Position(
          latitude: 51.5074,
          longitude: -0.1278,
          timestamp: DateTime(2024, 1, 1),
          accuracy: 10.0,
          altitude: 0.0,
          heading: 0.0,
          speed: 0.0,
          speedAccuracy: 0.0,
          altitudeAccuracy: 0.0,
          headingAccuracy: 0.0,
        );

        when(() => mockGeolocator.checkPermission())
            .thenAnswer((_) async => LocationPermission.always);
        when(() => mockGeolocator.getCurrentPosition(
          locationSettings: any(named: 'locationSettings'),
        )).thenAnswer((_) async => mockPosition);

        final coords = await locationParser.parseCurrentLocation();

        expect(coords[0], isA<double>());
        expect(coords[1], isA<double>());
      });
    });

    group('getNearestLocation', () {
      test('returns nearest location from multiple options', () async {
        final mockPosition = Position(
          latitude: 37.7749,
          longitude: -122.4194,
          timestamp: DateTime(2024, 1, 1),
          accuracy: 10.0,
          altitude: 0.0,
          heading: 0.0,
          speed: 0.0,
          speedAccuracy: 0.0,
          altitudeAccuracy: 0.0,
          headingAccuracy: 0.0,
        );

        when(() => mockGeolocator.checkPermission())
            .thenAnswer((_) async => LocationPermission.always);
        when(() => mockGeolocator.getCurrentPosition(
          locationSettings: any(named: 'locationSettings'),
        )).thenAnswer((_) async => mockPosition);

        final locations = [
          {
            'Name': 'Far Location',
            'Latitude': 37.7849,
            'Longitude': -122.4094,
          },
          {
            'Name': 'Nearest Location',
            'Latitude': 37.7759,
            'Longitude': -122.4184,
          },
          {
            'Name': 'Distant Location',
            'Latitude': 37.8049,
            'Longitude': -122.3994,
          },
        ];

        final nearest = await locationParser.getNearestLocation(locations);

        expect(nearest, isNotNull);
        expect(nearest!['Name'], equals('Nearest Location'));
        expect(nearest['Latitude'], equals(37.7759));
        expect(nearest['Longitude'], equals(-122.4184));
      });

      test('returns null when locations list is empty', () async {
        final mockPosition = Position(
          latitude: 37.7749,
          longitude: -122.4194,
          timestamp: DateTime(2024, 1, 1),
          accuracy: 10.0,
          altitude: 0.0,
          heading: 0.0,
          speed: 0.0,
          speedAccuracy: 0.0,
          altitudeAccuracy: 0.0,
          headingAccuracy: 0.0,
        );

        when(() => mockGeolocator.checkPermission())
            .thenAnswer((_) async => LocationPermission.always);
        when(() => mockGeolocator.getCurrentPosition(
          locationSettings: any(named: 'locationSettings'),
        )).thenAnswer((_) async => mockPosition);

        final nearest = await locationParser.getNearestLocation([]);

        expect(nearest, isNull);
      });

      test('skips locations without valid coordinates', () async {
        final mockPosition = Position(
          latitude: 37.7749,
          longitude: -122.4194,
          timestamp: DateTime(2024, 1, 1),
          accuracy: 10.0,
          altitude: 0.0,
          heading: 0.0,
          speed: 0.0,
          speedAccuracy: 0.0,
          altitudeAccuracy: 0.0,
          headingAccuracy: 0.0,
        );

        when(() => mockGeolocator.checkPermission())
            .thenAnswer((_) async => LocationPermission.always);
        when(() => mockGeolocator.getCurrentPosition(
          locationSettings: any(named: 'locationSettings'),
        )).thenAnswer((_) async => mockPosition);

        final locations = [
          {
            'Name': 'Invalid - No coords',
          },
          {
            'Name': 'Invalid - Only Lat',
            'Latitude': 37.7759,
          },
          {
            'Name': 'Valid Location',
            'Latitude': 37.7759,
            'Longitude': -122.4184,
          },
        ];

        final nearest = await locationParser.getNearestLocation(locations);

        expect(nearest, isNotNull);
        expect(nearest!['Name'], equals('Valid Location'));
      });

      test('handles single location in list', () async {
        final mockPosition = Position(
          latitude: 37.7749,
          longitude: -122.4194,
          timestamp: DateTime(2024, 1, 1),
          accuracy: 10.0,
          altitude: 0.0,
          heading: 0.0,
          speed: 0.0,
          speedAccuracy: 0.0,
          altitudeAccuracy: 0.0,
          headingAccuracy: 0.0,
        );

        when(() => mockGeolocator.checkPermission())
            .thenAnswer((_) async => LocationPermission.always);
        when(() => mockGeolocator.getCurrentPosition(
          locationSettings: any(named: 'locationSettings'),
        )).thenAnswer((_) async => mockPosition);

        final locations = [
          {
            'Name': 'Only Location',
            'Latitude': 37.7849,
            'Longitude': -122.4094,
          },
        ];

        final nearest = await locationParser.getNearestLocation(locations);

        expect(nearest, isNotNull);
        expect(nearest!['Name'], equals('Only Location'));
      });

      test('returns null when all locations have invalid coordinates',
              () async {
            final mockPosition = Position(
              latitude: 37.7749,
              longitude: -122.4194,
              timestamp: DateTime(2024, 1, 1),
              accuracy: 10.0,
              altitude: 0.0,
              heading: 0.0,
              speed: 0.0,
              speedAccuracy: 0.0,
              altitudeAccuracy: 0.0,
              headingAccuracy: 0.0,
            );

            when(() => mockGeolocator.checkPermission())
                .thenAnswer((_) async => LocationPermission.always);
            when(() => mockGeolocator.getCurrentPosition(
              locationSettings: any(named: 'locationSettings'),
            )).thenAnswer((_) async => mockPosition);

            final locations = [
              {'Name': 'No coords'},
              {'Name': 'Only Lat', 'Latitude': 37.7759},
              {'Name': 'Only Lng', 'Longitude': -122.4184},
            ];

            final nearest = await locationParser.getNearestLocation(locations);

            expect(nearest, isNull);
          });
    });
  });
}
