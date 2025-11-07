import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:clean_stream_laundry_app/Logic/Supabase/Location/location_handler.dart';
import 'mocks.dart';

void main() {
  late SupabaseMock supabaseMock;
  late QueryBuilderMock queryBuilderMock;

  setUp(() {

    supabaseMock = SupabaseMock();
    queryBuilderMock = QueryBuilderMock();

    when(() => supabaseMock.from('Locations')).thenAnswer((_) => queryBuilderMock);

  });

  test('getLocations returns fake addresses', () async {

    final fakeLocations = [
      {'id': 1, 'Address': '49687 Made Up Drive, Muncie, IN'},
      {'id': 2, 'Address': '39853 Fake Avenue, Muncie, IN'},
    ];

    when(() => queryBuilderMock.select('id, Address'))
        .thenAnswer((_) => FakeFilterBuilder(fakeLocations));

    final locationHandler = LocationHandler(client: supabaseMock);

    final locations = await locationHandler.getLocations();

    expect(locations.length, 2);
  });

  test('getLocations returns no data', () async {

    final List<Map<String, dynamic>> fakeLocations = [];

    when(() => queryBuilderMock.select('id, Address'))
        .thenAnswer((_) => FakeFilterBuilder(fakeLocations));

    final locationHandler = LocationHandler(client: supabaseMock);

    final locations = await locationHandler.getLocations();

    expect(locations.length, 0);
  });
}
