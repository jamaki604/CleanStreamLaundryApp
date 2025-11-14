import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:dio/dio.dart';

class SupabaseMock extends Mock implements SupabaseClient {}
class GoTrueMock extends Mock implements GoTrueClient {}
class FunctionsMock extends Mock implements FunctionsClient {}
class MockDio extends Mock implements Dio {}
