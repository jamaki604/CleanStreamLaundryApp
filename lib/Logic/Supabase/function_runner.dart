import 'package:clean_stream_laundry_app/Logic/Services/edgeFunction.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FunctionRunner extends EdgeFunction{

  late final SupabaseClient _client;

  FunctionRunner({required SupabaseClient client}){
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