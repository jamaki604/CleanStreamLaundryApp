import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:clean_stream_laundry_app/services/supabase/supabase_location_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'mocks.dart';

void main() {
  const locationFields =
      'id, Address, Latitude, Longitude, Name, Hours, OpenHour, CloseHour, '
      'AfterHoursAvailable, Details';
  const legacyLocationFields = 'id, Address, Latitude, Longitude';

  late SupabaseMock supabaseMock;
  late QueryBuilderMock queryBuilderMock;

  setUp(() {
    supabaseMock = SupabaseMock();
    queryBuilderMock = QueryBuilderMock();

    when(
      () => supabaseMock.from('Locations'),
    ).thenAnswer((_) => queryBuilderMock);
  });

  test('getLocations returns fake addresses', () async {
    final fakeLocations = [
      {
        'id': 1,
        'Address': '49687 Made Up Drive, Muncie, IN',
        'Latitude': 32,
        'Longitude': 32,
        'Name': 'Muncie Laundry Center',
        'Hours': '6:00 AM - 10:00 PM',
        'OpenHour': 6,
        'CloseHour': 22,
        'AfterHoursAvailable': false,
        'Details': 'Self-service laundry',
      },
      {
        'id': 2,
        'Address': '39853 Fake Avenue, Muncie, IN',
        'Latitude': 44,
        'Longitude': 44,
        'Name': 'Fake Avenue Laundry',
        'Hours': '7:00 AM - 9:00 PM',
        'OpenHour': 7,
        'CloseHour': 21,
        'AfterHoursAvailable': true,
        'Details': 'After-hours entry available',
      },
    ];

    when(
      () => queryBuilderMock.select(locationFields),
    ).thenAnswer((_) => FakeFilterBuilder(fakeLocations));

    final locationHandler = SupabaseLocationHandler(client: supabaseMock);

    final locations = await locationHandler.getLocations();

    expect(locations.length, 2);
  });

  test('getLocations returns no data', () async {
    final List<Map<String, dynamic>> fakeLocations = [];

    when(
      () => queryBuilderMock.select(locationFields),
    ).thenAnswer((_) => FakeFilterBuilder(fakeLocations));

    final locationHandler = SupabaseLocationHandler(client: supabaseMock);

    final locations = await locationHandler.getLocations();

    expect(locations.length, 0);
  });

  test(
    'getLocations falls back to legacy columns on PostgrestException',
    () async {
      final fakeLocations = [
        {
          'id': 1,
          'Address': '49687 Made Up Drive, Muncie, IN',
          'Latitude': 32,
          'Longitude': 32,
        },
      ];

      when(
        () => queryBuilderMock.select(locationFields),
      ).thenThrow(const PostgrestException(message: 'Test error'));
      when(
        () => queryBuilderMock.select(legacyLocationFields),
      ).thenAnswer((_) => FakeFilterBuilder(fakeLocations));

      final locationHandler = SupabaseLocationHandler(client: supabaseMock);
      final result = await locationHandler.getLocations();
      expect(result.length, 1);
    },
  );

  test('getLocations returns empty when fallback also fails', () async {
    when(
      () => queryBuilderMock.select(locationFields),
    ).thenThrow(const PostgrestException(message: 'Test error'));
    when(
      () => queryBuilderMock.select(legacyLocationFields),
    ).thenThrow(const PostgrestException(message: 'Legacy error'));

    final locationHandler = SupabaseLocationHandler(client: supabaseMock);
    final result = await locationHandler.getLocations();
    expect(result.length, 0);
  });

  test('getLocations returns empty for any other exception', () async {
    when(
      () => supabaseMock.from('Locations'),
    ).thenThrow(Exception('Random test exception'));

    final locationHandler = SupabaseLocationHandler(client: supabaseMock);
    final result = await locationHandler.getLocations();
    expect(result.length, 0);
  });
}
