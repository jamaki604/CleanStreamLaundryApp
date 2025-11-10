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

    when(() => supabaseMock.from('Machines')).thenAnswer((
        _) => queryBuilderMock);
    when(() => queryBuilderMock.select(any())).thenAnswer((
        _) => fakeFilterBuilder);
  });

  group('Transaction Tests',(){

    test("Get transaction history data",(){

    });

  });
}