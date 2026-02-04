import 'package:clean_stream_laundry_app/logic/services/auth_service.dart';
import 'package:clean_stream_laundry_app/logic/services/location_service.dart';
import 'package:clean_stream_laundry_app/logic/services/machine_service.dart';
import 'package:clean_stream_laundry_app/logic/services/profile_service.dart';
import 'package:clean_stream_laundry_app/logic/services/transaction_service.dart';
import 'package:clean_stream_laundry_app/middleware/app_router.dart';
import 'package:clean_stream_laundry_app/logic/theme/theme_manager.dart';
import 'package:mocktail/mocktail.dart';
import 'package:clean_stream_laundry_app/logic/services/machine_communication_service.dart';
import 'package:clean_stream_laundry_app/logic/services/edge_function_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:async';

class MockAuthService extends Mock implements AuthService {}

class MockTransactionService extends Mock implements TransactionService {}

class MockLocationService extends Mock implements LocationService {}

class MockMachineService extends Mock implements MachineService {}

class MockThemeManager extends Mock implements ThemeManager {}

class MockProfileService extends Mock implements ProfileService {}

class MockRouterService extends Mock implements RouterService {}

class MockMachineCommunicationService extends Mock implements MachineCommunicationService {}

class FakeAuthService extends Fake implements AuthService {}

class MockEdgeFunctionService extends Mock implements EdgeFunctionService {}

// Supabase mocks
class SupabaseMock extends Mock implements SupabaseClient {}

class QueryBuilderMock extends Mock implements SupabaseQueryBuilder {}

class GoTrueMock extends Mock implements GoTrueClient {}

// Custom implementation that actually works like a Future
class FakeTransformBuilder implements PostgrestTransformBuilder<Map<String, dynamic>> {
  final Map<String, dynamic> data;

  FakeTransformBuilder(this.data);

  @override
  Future<T> then<T>(FutureOr<T> Function(Map<String, dynamic>) onValue, {Function? onError}) async {
    return onValue(data);
  }

  @override
  PostgrestTransformBuilder<Map<String, dynamic>> limit(int count, {String? referencedTable}) => this;

  @override
  PostgrestTransformBuilder<Map<String, dynamic>> order(String column, {bool ascending = false, bool nullsFirst = false, String? referencedTable}) => this;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeTransformBuilderNullable implements PostgrestTransformBuilder<Map<String, dynamic>?> {
  final Map<String, dynamic>? data;

  FakeTransformBuilderNullable(this.data);

  @override
  Future<T> then<T>(FutureOr<T> Function(Map<String, dynamic>?) onValue, {Function? onError}) async {
    return onValue(data);
  }

  @override
  PostgrestTransformBuilder<Map<String, dynamic>?> limit(int count, {String? referencedTable}) => this;

  @override
  PostgrestTransformBuilder<Map<String, dynamic>?> order(String column, {bool ascending = false, bool nullsFirst = false, String? referencedTable}) => this;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeFilterBuilderList extends Fake implements PostgrestFilterBuilder<PostgrestList> {
  final dynamic data;

  FakeFilterBuilderList(this.data);

  @override
  PostgrestFilterBuilder<PostgrestList> eq(String column, Object value) {
    return this;
  }

  @override
  PostgrestTransformBuilder<Map<String, dynamic>?> maybeSingle() {
    return FakeTransformBuilderNullable(data is Map ? data as Map<String, dynamic>? : null);
  }

  @override
  PostgrestTransformBuilder<Map<String, dynamic>> single() {
    if (data is Map) {
      return FakeTransformBuilder(data as Map<String, dynamic>);
    }
    if (data is List && (data as List).isNotEmpty) {
      return FakeTransformBuilder((data as List).first as Map<String, dynamic>);
    }
    return FakeTransformBuilder({});
  }

  @override
  Future<U> then<U>(FutureOr<U> Function(List<Map<String, dynamic>>) onValue, {Function? onError}) async {
    if (data == null) return onValue([]);
    if (data is Map) return onValue([data as Map<String, dynamic>]);
    if (data is List<Map<String, dynamic>>) return onValue(data);
    return onValue([]);
  }
}