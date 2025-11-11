import 'package:clean_stream_laundry_app/Logic/Services/edge_function_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseEdgeFunctionService extends EdgeFunctionService{

  late final SupabaseClient _client;

  SupabaseEdgeFunctionService({required SupabaseClient client}){
    _client = client;
  }

  Future<FunctionResponse?> runEdgeFunction({required String name,required Map<String,dynamic> body}) async{
    try {
      final response = await _client.functions.invoke(name, body: body);
      return response;
    } catch (e) {
      print(e);
      return null;
    }
  }

}