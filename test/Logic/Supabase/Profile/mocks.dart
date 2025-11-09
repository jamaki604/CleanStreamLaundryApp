import 'dart:async';

import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseMock extends Mock implements SupabaseClient {}
class QueryBuilderMock extends Mock implements SupabaseQueryBuilder {}

class FakeFilterBuilder extends Fake implements PostgrestFilterBuilder<PostgrestList> {
  final Map<String, dynamic> fakeData;

  FakeFilterBuilder(this.fakeData);

  @override
  PostgrestTransformBuilder<Map<String, dynamic>> single() {
    return FakeTransformBuilder(fakeData);
  }

  @override
  Future<U> then<U>(FutureOr<U> Function(PostgrestList) onValue, {Function? onError,}) async {
    try {
      final result = onValue([fakeData] as PostgrestList);
      return Future.value(result);
    } catch (e) {
      if (onError != null) onError(e);
      return Future.error(e);
    }
  }

  @override
  PostgrestFilterBuilder<PostgrestList> eq(String column, dynamic value) {
    return this;
  }
}

class FakeTransformBuilder extends Fake implements PostgrestTransformBuilder<Map<String, dynamic>> {
  final Map<String, dynamic> fakeData;
  FakeTransformBuilder(this.fakeData);

  @override
  Future<U> then<U>(FutureOr<U> Function(Map<String, dynamic>) onValue, {Function? onError,}) async {
    try {
      final result = onValue(fakeData);
      return Future.value(result);
    } catch (e) {
      if (onError != null) onError(e);
      return Future.error(e);
    }
  }

  @override
  Map<String, dynamic> eq(String column, dynamic value) {
    return fakeData;
  }

  @override
  PostgrestTransformBuilder<PostgrestMap> single() {
    return this as PostgrestTransformBuilder<PostgrestMap>;
  }
}
