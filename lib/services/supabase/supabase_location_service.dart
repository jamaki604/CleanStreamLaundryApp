import 'package:clean_stream_laundry_app/logic/services/location_service.dart';
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
          .select('id, Address, Latitude, Longitude');

      return response;
    } on PostgrestException  {
      return [];
    } catch (e) {
      return [];
    }
  }

}