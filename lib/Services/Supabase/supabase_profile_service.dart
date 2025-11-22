import 'package:clean_stream_laundry_app/Logic/Services/profile_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseProfileService extends ProfileService{

  late final SupabaseClient _client;

  SupabaseProfileService({required SupabaseClient client}){
    _client = client;
  }

  @override
  Future<void> createAccount({required String name}) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      return;
    }

    await _client.from('profiles').insert({
      'id': user.id,
      'full_name': name,
    });

  }

  @override
  Future<Map<String, dynamic>?> getUserBalanceById(String userId) async {
    try {
      final response = await _client
          .from('profiles')
          .select("full_name, balance")
          .eq('id', userId)
          .single();
      return response;
    } on PostgrestException {
      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> updateBalanceById(double balance) async {
    final userId = _client.auth.currentUser?.id;

    if (userId == null) {
      return;
    }
    try {
      await _client
          .from("profiles")
          .update({"balance": balance})
          .eq("id", userId);
    } on PostgrestException {
      return;
    } catch (e) {
      return;
    }
  }

  @override
  Future<String?> getUserNameById(String userId) async {
    try {
      final response = await _client
          .from('profiles')
          .select("full_name")
          .eq('id', userId)
          .single();
      return response["full_name"];
    } on PostgrestException {
      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<String?> getUserRefundAttempts(String userId) async {
    try {
      final response = await _client
          .from('profiles')
          .select("refund_attempts")
          .eq('id', userId)
          .single();
      return response["refund_attempts"].toString();
    } on PostgrestException {
      return null;
    } catch (e) {
      return null;
    }
  }
}