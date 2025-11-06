import 'package:clean_stream_laundry_app/Logic/Supabase/Location/location_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LocationHandler extends LocationService{

  late final SupabaseClient _client;

  LocationHandler({required SupabaseClient client}){
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