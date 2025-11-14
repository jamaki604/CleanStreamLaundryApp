import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import 'package:mocktail/mocktail.dart';
import 'package:clean_stream_laundry_app/Services/Supabase/supabase_check_availability_service.dart';

class MockDio extends Mock implements Dio {}

void main() {
  late MockDio mockDio;
  late SupabaseAvailabilityCheckService service;

  setUpAll(() async {
    await dotenv.load(fileName: '.env');
  });

  setUp(() {

    mockDio = MockDio();
    service = SupabaseAvailabilityCheckService(dio: mockDio);
  });

  test('Returns pass when machine is idle', () async {
    final mockResponse = Response(
      requestOptions: RequestOptions(path: '/ping-device'),
      data: {'success': true, 'message': 'idle'},
      statusCode: 200,
    );

    when(() => mockDio.post(
      any(),
      data: any(named: 'data'),
      options: any(named: 'options'),
    )).thenAnswer((_) async => mockResponse);

    final result = await service.checkAvailability('10000000');

    expect(result, equals('pass'));
  });

  test('Returns phrase when machine is in-use', () async {
    final mockResponse = Response(
      requestOptions: RequestOptions(path: '/ping-device'),
      data: {'success': true, 'message': 'in-use'},
      statusCode: 200,
    );

    when(() => mockDio.post(
      any(),
      data: any(named: 'data'),
      options: any(named: 'options'),
    )).thenAnswer((_) async => mockResponse);

    final result = await service.checkAvailability('10000001');

    expect(result, equals("Machine is in use right now."));
  });

  test('Returns phrase when machine is offline or has an error', () async {
    final mockResponse = Response(
      requestOptions: RequestOptions(path: '/ping-device'),
      data: {'success': true, 'message': 'offline'},
      statusCode: 200,
    );

    when(() => mockDio.post(
      any(),
      data: any(named: 'data'),
      options: any(named: 'options'),
    )).thenAnswer((_) async => mockResponse);

    final result = await service.checkAvailability('10000002');

    expect(result, equals("Machine is offline right now."));
  });
}