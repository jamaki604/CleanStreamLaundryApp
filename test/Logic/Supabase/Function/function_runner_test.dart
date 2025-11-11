import 'package:clean_stream_laundry_app/Logic/Supabase/Function/function_runner.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'mocks.dart';

void main() {
  late SupabaseMock supabaseMock;
  late FunctionsClientMock functionClient;
  late FunctionRunner functionRunner;

  setUpAll(() {
    registerFallbackValue(<String, dynamic>{});
  });

  setUp(() {
    supabaseMock = SupabaseMock();
    functionClient = FunctionsClientMock();
    functionRunner = FunctionRunner(client: supabaseMock);

    when(() => supabaseMock.functions).thenReturn(functionClient);

    when(() => functionClient.invoke(any(), body: any(named: 'body')))
        .thenAnswer((_) async => FunctionResponse(status: 200));
  });

  group("Function Runner tests", () {
    test("Tests that the function response was returned correctly", () async {
      final result = await functionRunner.runEdgeFunction(
        name: "test",
        body: {"test": 23},
      );

      expect(result?.status, 200);
    });

    test("Tests that exception is caught and null returned", () async {
      when(() => functionClient.invoke(any(), body: any(named: 'body')))
          .thenThrow(PostgrestException(message: 'Function failed'));

      final result = await functionRunner.runEdgeFunction(
        name: "errorFunc",
        body: {"data": 42},
      );

      expect(result, isNull);
    });
  });
}
