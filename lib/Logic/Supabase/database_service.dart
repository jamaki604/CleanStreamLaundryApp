import 'package:clean_stream_laundry_app/Logic/Supabase/Profile/profile_handler.dart';
import 'package:clean_stream_laundry_app/Logic/Supabase/Transaction/transaction_handler.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:core';

import 'Authentication/authenticator.dart';
import 'Location/location_handler.dart';
import 'Machine/machine_handler.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._();

  final SupabaseClient _client = Supabase.instance.client;
  late final TransactionHandler transactionHandler;
  late final MachineHandler machineHandler;
  late final ProfileHandler profileHandler;
  late final LocationHandler locationHandler;
  late final Authenticator authenticator;

  DatabaseService._() {
    transactionHandler = TransactionHandler(client: _client);
    machineHandler = MachineHandler(client: _client);
    profileHandler = ProfileHandler(client: _client);
    locationHandler = LocationHandler(client: _client);
    authenticator = Authenticator(_client);
  }

}