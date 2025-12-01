import 'package:clean_stream_laundry_app/Logic/Services/profile_service.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseMock extends Mock implements SupabaseClient {}
class GoTrueMock extends Mock implements GoTrueClient {}
class ProfileServiceMock extends Mock implements ProfileService{}