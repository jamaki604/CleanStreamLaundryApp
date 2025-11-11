import 'package:clean_stream_laundry_app/Logic/Services/edgeFunction.dart';
import 'package:clean_stream_laundry_app/Logic/Supabase/profile_handler.dart';
import 'package:clean_stream_laundry_app/Logic/Supabase/transaction_handler.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:core';
import '../Services/auth_service.dart';
import 'authenticator.dart';
import 'location_handler.dart';
import '../Services/location_service.dart';
import 'machine_handler.dart';
import '../Services/machine_service.dart';
import '../Services/profile_service.dart';
import '../Services/transaction_service.dart';
import 'function_runner.dart';

class DatabaseService{
  static final DatabaseService instance = DatabaseService._();

  final SupabaseClient _client = Supabase.instance.client;
  late final TransactionService transactionHandler;
  late final MachineService machineHandler;
  late final ProfileService profileHandler;
  late final LocationService locationHandler;
  late final AuthSystem authenticator;
  late final EdgeFunction functionRunner;

  DatabaseService._() {
    transactionHandler = TransactionHandler(client: _client);
    machineHandler = MachineHandler(client: _client);
    profileHandler = ProfileHandler(client: _client);
    locationHandler = LocationHandler(client: _client);
    authenticator = Authenticator(_client);
    functionRunner = FunctionRunner(client: _client);
  }

}