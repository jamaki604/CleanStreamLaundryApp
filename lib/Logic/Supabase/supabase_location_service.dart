import 'package:clean_stream_laundry_app/Logic/Services/location_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseLocationHandler extends LocationService{

  late final SupabaseClient _client;

  SupabaseLocationHandler({required SupabaseClient client}){
    _client = client;
  }

  @override
  Future<List<Map<String, dynamic>>> getLocations() async {
    try {
      final response = await _client
          .from('Locations')
          .select('id, Address');

      return response;
    } on PostgrestException  {
      return [];
    } catch (e) {
      return [];
    }
  }

}