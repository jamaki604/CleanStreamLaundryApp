import 'dart:async';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseMock extends Mock implements SupabaseClient {}
class GoTrueMock extends Mock implements GoTrueClient {}

class QueryBuilderMock extends Mock implements SupabaseQueryBuilder {

  @override
  PostgrestFilterBuilder<dynamic> insert(Object values, {bool defaultToNull = false}) {
    return FakeFilterBuilder([{'status': 'success', 'inserted': values}]);
  }

}

class FakeFilterBuilder extends Fake implements PostgrestFilterBuilder<PostgrestList> {
  final List<Map<String, dynamic>> fakeData;

  FakeFilterBuilder(this.fakeData);

  @override
  Future<U> then<U>(FutureOr<U> Function(PostgrestList) onValue, {Function? onError,}) {
    try {

      final result = onValue(fakeData);
      return Future.value(result);
    } catch (e) {
      if (onError != null) {
        onError(e);
        return Future.error(e);
      }
      return Future.error(e);
    }
  }

  @override
  Future<PostgrestList> catchError(Function onError, {bool Function(Object)? test}) {
    return Future.value(fakeData);
  }

  @override
  PostgrestFilterBuilder<PostgrestList> eq(String column, dynamic value) {
    return this;
  }

  @override
  PostgrestTransformBuilder<List<Map<String, dynamic>>> order(String column, {bool ascending = true, bool nullsFirst = false, String? referencedTable}) {
    return this;
  }

}
