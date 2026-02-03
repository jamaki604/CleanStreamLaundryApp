import 'dart:async';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseMock extends Mock implements SupabaseClient {}
class QueryBuilderMock extends Mock implements SupabaseQueryBuilder {}

class FakeFilterBuilder extends Fake implements PostgrestFilterBuilder<PostgrestList> {
  final int fakeCount;

  FakeFilterBuilder(this.fakeCount);

  @override
  PostgrestFilterBuilder<PostgrestList> eq(String column, dynamic value) {
    return this;
  }

  @override
  ResponsePostgrestBuilder<PostgrestResponse<PostgrestList>, PostgrestList, PostgrestList> count([CountOption? option]) {
    return FakeCountBuilder(fakeCount);
  }

  @override
  Future<U> then<U>(
      FutureOr<U> Function(PostgrestList) onValue, {
        Function? onError,
      }) async {
    try {
      final result = onValue([] as PostgrestList);
      return Future.value(result);
    } catch (e) {
      if (onError != null) onError(e);
      return Future.error(e);
    }
  }
}

class FakeCountBuilder extends Fake implements ResponsePostgrestBuilder<PostgrestResponse<PostgrestList>, PostgrestList, PostgrestList> {
  final int fakeCount;

  FakeCountBuilder(this.fakeCount);

  @override
  Future<U> then<U>(
      FutureOr<U> Function(PostgrestResponse<PostgrestList>) onValue, {
        Function? onError,
      }) async {
    try {
      final response = PostgrestResponse<PostgrestList>(
        data: [],
        count: fakeCount,
      );
      final result = onValue(response);
      return Future.value(result);
    } catch (e) {
      if (onError != null) onError(e);
      return Future.error(e);
    }
  }
}

class FakeFilterBuilderMap extends Fake implements PostgrestFilterBuilder<PostgrestList> {
  final Map<String, dynamic> fakeData;

  FakeFilterBuilderMap(this.fakeData);

  @override
  PostgrestTransformBuilder<Map<String, dynamic>> single() {
    return FakeTransformBuilder(fakeData);
  }

  @override
  Future<U> then<U>(FutureOr<U> Function(PostgrestList) onValue, {Function? onError,}) async {
    try {
      final result = onValue([fakeData]);
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

  Map<String, dynamic> eq(String column, dynamic value) {
    return fakeData;
  }

  @override
  PostgrestTransformBuilder<PostgrestMap> single() {
    return this as PostgrestTransformBuilder<PostgrestMap>;
  }
}
