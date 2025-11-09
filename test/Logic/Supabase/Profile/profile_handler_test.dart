import 'package:clean_stream_laundry_app/Logic/Supabase/Profile/profile_handler.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'mocks.dart';

void main() {
  late SupabaseMock supabaseMock;
  late QueryBuilderMock queryBuilderMock;
  late FakeFilterBuilder fakeFilterBuilder;
  late ProfileHandler profileHandler;

  setUp(() {
    supabaseMock = SupabaseMock();
    queryBuilderMock = QueryBuilderMock();
    fakeFilterBuilder = FakeFilterBuilder({"full_name": "Nolan Meyer", "balance": 0});
    profileHandler = ProfileHandler(client: supabaseMock);

    when(() => supabaseMock.from('profiles')).thenAnswer((_) => queryBuilderMock);
    when(() => queryBuilderMock.select(any())).thenAnswer((_) => fakeFilterBuilder);
  });


  test('getUserBalanceById returns fake user balance', () async {

    final result = await profileHandler.getUserBalanceById("1");
    expect(result?["balance"],0);

  });
}
