import 'package:clean_stream_laundry_app/services/supabase/supabase_profile_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'mocks.dart';

void main() {
  late SupabaseMock supabaseMock;
  late QueryBuilderMock queryBuilderMock;
  late FakeFilterBuilder fakeFilterBuilder;
  late SupabaseProfileService profileHandler;
  late GoTrueClient supabaseAuth;

  setUp(() {
    supabaseMock = SupabaseMock();
    queryBuilderMock = QueryBuilderMock();
    fakeFilterBuilder = FakeFilterBuilder({"full_name": "Nolan Meyer", "balance": 0});
    profileHandler = SupabaseProfileService(client: supabaseMock);
    supabaseAuth = GoTrueMock();

    when(() => supabaseMock.from('profiles')).thenAnswer((_) => queryBuilderMock);
    when(() => queryBuilderMock.select(any())).thenAnswer((_) => fakeFilterBuilder);
    when(() => supabaseMock.auth).thenReturn(supabaseAuth);

    final mockUser = User(
      id: '11111111-1111-1111-1111-111111111111',
      aud: 'authenticated',
      role: 'authenticated',
      email: 'testemail@test.com',
      emailConfirmedAt: null,
      phone: '',
      lastSignInAt: '',
      appMetadata: {},
      userMetadata: {},
      identities: [],
      createdAt: '',
      updatedAt: '',
    );

    when(() => supabaseAuth.currentUser).thenReturn(mockUser);

  });


  test('getUserBalanceById returns fake user balance', () async {
    final result = await profileHandler.getUserBalanceById("1");
    expect(result?["balance"],0);
  });

  test('getUserBalanceById throws Postgres exception', () async {
    when(() => supabaseMock.from('profiles')).thenThrow(PostgrestException(message: "Test exception"));
    final result = await profileHandler.getUserBalanceById("1");
    expect(result,null);
  });

  test('getUserBalanceById throws unknown exception', () async {
    when(() => supabaseMock.from('profiles')).thenThrow(Exception("Test execption"));
    final result = await profileHandler.getUserBalanceById("1");
    expect(result,null);
  });

  test("Tests that the logic was called correctly to create an account",() async {
    await profileHandler.createAccount(name: "Bill", id: "1");
    verify(() => supabaseMock.from("profiles"));
  });

  test("Tests that the logic was called correctly to update account balance",() async {
    await profileHandler.updateBalanceById(47.20);
    verify(() => supabaseMock.auth.currentUser!);
    verify(() => supabaseMock.from("profiles"));
  });

  test("Tests that updateBalanceID catches Postgrest exception",() async {
    when(() => supabaseMock.from('profiles')).thenThrow(PostgrestException(message: "Test exception"));
    await profileHandler.updateBalanceById(47.20);
    //Test will fail if exception was not caught
  });

  test("Tests that updateBalanceID catches unknown exception",() async {
    when(() => supabaseMock.from('profiles')).thenThrow(Exception("Test execption"));
    await profileHandler.updateBalanceById(47.20);
    //Test will fail if exception was not caught
  });

  test("Tests that getUserNameById catches Postgrest exception",() async {
    when(() => supabaseMock.from('profiles')).thenThrow(PostgrestException(message: "Test exception"));
    await profileHandler.getUserNameById("1234");
    //Test will fail if exception was not caught
  });

  test("Tests that getUserNameById catches unknown exception",() async {
    when(() => supabaseMock.from('profiles')).thenThrow(Exception("Test exception"));
    await profileHandler.getUserNameById("1234");
    //Test will fail if exception was not caught
  });

  test("Tests that getUserNameById runs successfully",() async {
    var result = await profileHandler.getUserNameById("1234");
    expect(result, "Nolan Meyer");
  });

  test("Tests that getUserRefundAttempts catches unknown exception",() async {
    when(() => supabaseMock.from('profiles')).thenThrow(Exception("Test exception"));
    await profileHandler.getUserRefundAttempts("1234");
    //Test will fail if exception was not caught
  });

  test("Tests that getUserRefundAttempts catches Postgrest exception",() async {
    fakeFilterBuilder = FakeFilterBuilder({"refund_attempts":0});
    var result = await profileHandler.getUserRefundAttempts("1234");
    expect(result, "0");
  });


}
