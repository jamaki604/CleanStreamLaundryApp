import 'package:clean_stream_laundry_app/logic/parsing/location_parser.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:clean_stream_laundry_app/widgets/map_marker.dart';



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

    test('parseLocations handles locations with extra fields', () {
      final locations = [
        {
          'Latitude': 40.7128,
          'Longitude': -74.0060,
          'Name': 'New York',
          'Population': 8000000
        },
      ];

      final result = LocationParser.parseLocations(locations);

      expect(result.length, 1);
      expect(result[0].point.latitude, 40.7128);
      expect(result[0].point.longitude, -74.0060);
    });
  });
}