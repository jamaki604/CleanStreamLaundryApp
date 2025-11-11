import 'package:supabase_flutter/supabase_flutter.dart';

import '../Services/machine_service.dart';

class SupabaseMachineService extends MachineService{

  late final SupabaseClient _client;

  SupabaseMachineService({required SupabaseClient client}){
    _client = client;
  }

  @override
  Future<int> getDryerCountByLocation(String locationId) async {
    try {
      final response = await _client
          .from('Machines')
          .select('id',)
          .eq('Location_ID', locationId)
          .eq('Machine_type', 'Dryer')
          .count(CountOption.exact);

      return response.count;
    } on PostgrestException  {
      return 0;
    } catch (e) {
      return 0;
    }
  }

  @override
  Future<int> getIdleDryerCountByLocation(String locationId) async {
    try {
      final response = await _client
          .from('Machines')
          .select('*')
          .eq('Location_ID', locationId)
          .eq('Status', 'idle')
          .eq('Machine_type', 'Dryer')
          .count(CountOption.exact);

      return response.count;
    } on PostgrestException  {
      return 0;
    } catch (e) {
      return 0;
    }
  }

  @override
  Future<int> getIdleWasherCountByLocation(String locationId) async {
    try {
      final response = await _client
          .from('Machines')
          .select('*')
          .eq('Location_ID', locationId)
          .eq('Status', 'idle')
          .eq('Machine_type', 'Washer')
          .count(CountOption.exact);

      return response.count;
    } on PostgrestException {
      return 0;
    } catch (e) {
      return 0;
    }
  }

  @override
  Future<Map<String, dynamic>?> getMachineById(String machineId) async {
    try {
      final response = await _client
          .from('Machines')
          .select("Name, Price")
          .eq('id', machineId)
          .single();
      return response;
    } on PostgrestException {
      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<int> getWasherCountByLocation(String locationId) async {
    try {
      final response = await _client
          .from('Machines')
          .select('*')
          .eq('Location_ID', locationId)
          .eq('Machine_type', 'Washer')
          .count(CountOption.exact);

      return response.count;
    } on PostgrestException {
      return 0;
    } catch (e) {
      return 0;
    }
  }

}