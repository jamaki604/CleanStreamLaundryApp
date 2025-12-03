import 'package:clean_stream_laundry_app/Services/supabase/supabase_edge_function_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'mocks.dart';

void main() {
  late SupabaseMock supabaseMock;
  late FunctionsClientMock functionClient;
  late SupabaseEdgeFunctionService functionRunner;

  setUpAll(() {
    registerFallbackValue(<String, dynamic>{});
  });

  setUp(() {
    supabaseMock = SupabaseMock();
    functionClient = FunctionsClientMock();
    functionRunner = SupabaseEdgeFunctionService(client: supabaseMock);

    when(() => supabaseMock.functions).thenReturn(functionClient);

    when(() => functionClient.invoke(any(), body: any(named: 'body')))
        .thenAnswer((_) async => FunctionResponse(status: 200));
  });

  group("function Runner tests", () {
    test("Tests that the function response was returned correctly", () async {
      final result = await functionRunner.runEdgeFunction(
        name: "test",
        body: {"test": 23},
      );

      expect(result?.status, 200);
    });

    test("Tests that exception is caught and null returned", () async {
      when(() => functionClient.invoke(any(), body: any(named: 'body')))
          .thenThrow(PostgrestException(message: 'function failed'));

      final result = await functionRunner.runEdgeFunction(
        name: "errorFunc",
        body: {"data": 42},
      );

      expect(result, isNull);
    });
  });
}
