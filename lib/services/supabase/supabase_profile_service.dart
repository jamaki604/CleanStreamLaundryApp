import 'package:clean_stream_laundry_app/logic/services/profile_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseProfileService extends ProfileService {
  late final SupabaseClient _client;

  SupabaseProfileService({required SupabaseClient client}) {
    _client = client;
  }

  @override
  Future<void> createAccount({required String id, required String name}) async {
    try {
      final existingProfile = await _client
          .from('profiles')
          .select('id')
          .eq('id', id)
          .maybeSingle();

      if (existingProfile == null) {
        await _client
            .from('profiles')
            .upsert(
          {'id': id, 'full_name': name},
          onConflict: 'id',
          ignoreDuplicates: true,
        );
      }
    } catch (e) {
      print(e);
    }
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
  Future<void> updateName(String name) async {
    final userId = _client.auth.currentUser?.id;

    if (userId == null) {
      throw Exception('No user logged in');
    }

    try {
      await _client
          .from('profiles')
          .update({"full_name": name})
          .eq('id', userId);
    } catch (e) {
      throw Exception('Failed to update name: $e');
    }
  }

  @override
  Future<void> updateBalanceById(String userId, double balance) async {
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

  @override
  Future<int> getNotificationLeadTime() async {
    final user = _client.auth.currentUser;
    if (user == null) return 5;

    final response = await _client
        .from('profiles')
        .select('notif_lead_time')
        .eq('id', user.id)
        .single();

    return (response['notif_lead_time'] as int?) ?? 5;
  }

  @override
  Future<void> setNotificationLeadTime(int value) async {
    final user = _client.auth.currentUser;
    if (user == null) return;

    await _client
        .from('profiles')
        .update({'notif_lead_time': value})
        .eq('id', user.id);
  }
}
