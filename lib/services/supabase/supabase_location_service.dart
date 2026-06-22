import 'package:clean_stream_laundry_app/logic/services/location_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseLocationHandler extends LocationService {
  static const _locationFields =
      'id, Address, Latitude, Longitude, Name, Hours, OpenHour, CloseHour, '
      'AfterHoursAvailable, Details';
  static const _legacyLocationFields = 'id, Address, Latitude, Longitude';

  late final SupabaseClient _client;

  SupabaseLocationHandler({required SupabaseClient client}) {
    _client = client;
  }

  @override
  Future<List<Map<String, dynamic>>> getLocations() async {
    try {
      return await _client.from('Locations').select(_locationFields);
    } on PostgrestException {
      return _getLegacyLocations();
    } catch (e) {
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> _getLegacyLocations() async {
    try {
      return await _client.from('Locations').select(_legacyLocationFields);
    } on PostgrestException {
      return [];
    } catch (e) {
      return [];
    }
  }
}
