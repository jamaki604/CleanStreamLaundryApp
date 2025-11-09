import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:clean_stream_laundry_app/Logic/Supabase/Machine/machine_handler.dart';
import 'mocks.dart';

void main() {
  late SupabaseMock supabaseMock;
  late QueryBuilderMock queryBuilderMock;
  late FakeFilterBuilder fakeFilterBuilder;
  late MachineHandler machineHandler;

  setUp(() {
    supabaseMock = SupabaseMock();
    queryBuilderMock = QueryBuilderMock();
    fakeFilterBuilder = FakeFilterBuilder(5);
    machineHandler = MachineHandler(client: supabaseMock);

    when(() => supabaseMock.from('Machines')).thenAnswer((_) => queryBuilderMock);
    when(() => queryBuilderMock.select(any())).thenAnswer((_) => fakeFilterBuilder);
  });

  test('getDryerCountByLocation returns correct count', () async {
    final result = await machineHandler.getDryerCountByLocation('1');
    expect(result, 5);
  });

  test('getIdleDryerCountByLocation returns correct count', () async {
    final result = await machineHandler.getIdleDryerCountByLocation('1');
    expect(result, 5);
  });

  test('getWasherCountByLocation returns correct count', () async {
    final result = await machineHandler.getWasherCountByLocation('1');
    expect(result, 5);
  });

  test('getIdleWasherCountByLocation returns correct count', () async {
    final result = await machineHandler.getIdleWasherCountByLocation('1');
    expect(result, 5);
  });
}
