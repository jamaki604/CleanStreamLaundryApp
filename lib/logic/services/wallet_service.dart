import 'package:clean_stream_laundry_app/logic/models/wallet_balance.dart';
import 'package:clean_stream_laundry_app/logic/models/wallet_ledger_entry.dart';

abstract class WalletService {
  Future<WalletBalance> getBalance();
  Future<void> loadCard(int amountCents);
  Future<Map<String, dynamic>> redeemForMachine({
    required int machineId,
    required int amountCents,
    String? note,
  });
  Future<List<WalletLedgerEntry>> getLedger();
}
