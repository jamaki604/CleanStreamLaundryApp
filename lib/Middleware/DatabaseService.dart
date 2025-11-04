import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:core';

class DatabaseService {
  DatabaseService._();
  static final DatabaseService instance = DatabaseService._();

  final SupabaseClient _client = Supabase.instance.client;


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


  Future<void> recordTransaction({
    required double amount,
    required String description,
    required String type,
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      return;
    }

    await _client.from('transactions').insert({
      'user_id': user.id,
      'amount': amount,
      'description': description,
      'type': type,
    });

  }

  Future<List<Map<String, dynamic>>> getTransactionsForUser() async {
    final user = _client.auth.currentUser;
    if (user == null) return [];

    final response = await _client
        .from('transactions')
        .select()
        .eq('user_id', user.id)
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  Future<Map<String, dynamic>?> getMachineById(String machineId) async {
    try {
      final response = await _client
          .from('Machines')
          .select("Name, Price")
          .eq('id', machineId)
          .single();
      return response;
    } on PostgrestException catch(e) {
      print("Postgres error: ${e.message}");
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<Map<String, dynamic>?> getUserBalanceById(String userId) async {

    try {
      final response = await _client
          .from('profiles')
          .select("full_name, balance")
          .eq('id', userId)
          .single();
      return response;
    } on PostgrestException catch(e) {
      print("Postgres error: ${e.message}");
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<void> updateBalanceById(double balance) async {
    final userId = _client.auth.currentUser?.id;

    if (userId == null) {
      print("User not authenticated");
      return;
    }
    try {
      await _client
          .from("profiles")
          .update({"balance": balance})
          .eq("id", userId);
    } on PostgrestException catch(e) {
      print("Postgres error: ${e.message}");
      return null;
    } catch (e) {
      return null;
    }

  }

  Future<int> getIdleMachineCountByLocation(String locationId) async {
    try {
      final response = await _client
          .from('Machines')
          .select('*')
          .eq('location_id', locationId)
          .eq('status', 'idle')
          .count(CountOption.exact);

      return response.count;
    } on PostgrestException catch (e) {
      print("Postgres error: ${e.message}");
      return 0;
    } catch (e) {
      return 0;
    }
  }

  Future<int> getWasherCountByLocation(String locationId) async {
    try {
      final response = await _client
          .from('Machines')
          .select('*')
          .eq('location_id', locationId)
          .eq('machine_type', 'washer')
          .count(CountOption.exact);

      return response.count;
    } on PostgrestException catch (e) {
      print("Postgres error: ${e.message}");
      return 0;
    } catch (e) {
      return 0;
    }
  }

  Future<int> getDryerCountByLocation(String locationId) async {
    try {
      final response = await _client
          .from('Machines')
          .select('id',)
          .eq('location_id', locationId)
          .eq('machine_type', 'dryer')
          .count(CountOption.exact);

      return response.count;
    } on PostgrestException catch (e) {
      print("Postgres error: ${e.message}");
      return 0;
    } catch (e) {
      return 0;
    }
  }


}