import 'package:clean_stream_laundry_app/Logic/Supabase/Function/edgeFunction.dart';
import 'package:clean_stream_laundry_app/Logic/Supabase/Profile/profile_handler.dart';
import 'package:clean_stream_laundry_app/Logic/Supabase/Transaction/transaction_handler.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:core';
import 'Authentication/auth_system.dart';
import 'Authentication/authenticator.dart';
import 'Location/location_handler.dart';
import 'Location/location_service.dart';
import 'Machine/machine_handler.dart';
import 'Machine/machine_service.dart';
import 'Profile/profile_service.dart';
import 'Transaction/transaction_service.dart';
import 'Function/function_runner.dart';

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