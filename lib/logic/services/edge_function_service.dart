import 'package:supabase_flutter/supabase_flutter.dart';

abstract class EdgeFunctionService{
  Future<FunctionResponse?> runEdgeFunction({required String name,required Map<String,dynamic> body});
}