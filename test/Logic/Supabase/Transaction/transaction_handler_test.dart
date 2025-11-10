import 'package:clean_stream_laundry_app/Logic/Supabase/Transaction/transaction_handler.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'mocks.dart';

void main() {
  late SupabaseMock supabaseMock;
  late QueryBuilderMock queryBuilderMock;
  late FakeFilterBuilder fakeFilterBuilder;
  late TransactionHandler transactionHandler;
  late GoTrueMock supabaseAuth;

  setUp(() {
    supabaseMock = SupabaseMock();
    queryBuilderMock = QueryBuilderMock();
    fakeFilterBuilder = FakeFilterBuilder([{"amount": 2.75, "description": "Machine, created_at: 2025-11-02T16:24:51.685419+00:00"}, {"amount": 2.75, "description": "Machine, created_at: 2025-10-28T15:13:24.87605+00:00"}, {"amount": 2.75, "description": "Machine, created_at: 2025-10-28T14:27:54.429939+00:00"}, {"amount": 2.75, "description": "Machine, created_at: 2025-10-28T14:26:21.662999+00:00"}, {"amount": 2.75, "description": "Machine, created_at: 2025-10-27T18:06:40.987278+00:00"}, {"amount": 2.75, "description": "Machine, created_at: 2025-10-27T00:17:18.01511+00:00"}]);
    transactionHandler = TransactionHandler(client: supabaseMock);
    supabaseAuth = GoTrueMock();

    when(() => supabaseMock.from('transactions')).thenAnswer((_) => queryBuilderMock);
    when(() => supabaseMock.from('Refunds')).thenAnswer((_) => queryBuilderMock);
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

  group('Transaction Tests',(){

    test("Get transaction history data",() async {
      final result = await transactionHandler.getTransactionsForUser();
      expect(result.length, 6);
    });

    test("Tests if the user is null",() async{
      when(() => supabaseAuth.currentUser).thenReturn(null);
      final result = await transactionHandler.getTransactionsForUser();
      expect(result.length, 0);
    });

    test("Tests that transaction is recorded properly",() async {
      await transactionHandler.recordTransaction(amount: 27.5, description: "Test transaction", type: "test type");
      verify(() => supabaseMock.from("transactions"));
    });

    test("Tests if logic is correct for recording refunds",() async {
      await transactionHandler.recordRefundRequest(transaction_id: "3kl24jkl23", description: "Test refund");
      verify(() => supabaseMock.auth.currentUser!);
      verify(() => supabaseMock.from("Refunds"));
    });

  });
}