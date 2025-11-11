import 'package:clean_stream_laundry_app/Logic/Services/edge_function_service.dart';
import 'package:clean_stream_laundry_app/Logic/Supabase/supabase_profile_service.dart';
import 'package:clean_stream_laundry_app/Logic/Supabase/supabase_transaction_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:core';
import '../Services/auth_service.dart';
import 'supabase_auth_service.dart';
import 'supabase_location_service.dart';
import '../Services/location_service.dart';
import 'supabase_machine_service.dart';
import '../Services/machine_service.dart';
import '../Services/profile_service.dart';
import '../Services/transaction_service.dart';
import 'supabase_edge_function_service.dart';

class DatabaseService{
  static final DatabaseService instance = DatabaseService._();

  final SupabaseClient _client = Supabase.instance.client;
  late final TransactionService transactionHandler;
  late final MachineService machineHandler;
  late final ProfileService profileHandler;
  late final LocationService locationHandler;
  late final AuthService authenticator;
  late final EdgeFunctionService functionRunner;

  DatabaseService._() {
    transactionHandler = SupabaseTransactionService(client: _client);
    machineHandler = SupabaseMachineService(client: _client);
    profileHandler = SupabaseProfileService(client: _client);
    locationHandler = SupabaseLocationHandler(client: _client);
    authenticator = SupabaseAuthService(client: _client);
    functionRunner = SupabaseEdgeFunctionService(client: _client);
  }

}