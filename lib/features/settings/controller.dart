import 'package:clean_stream_laundry_app/logic/services/auth_service.dart';
import 'package:clean_stream_laundry_app/logic/services/profile_service.dart';
import 'package:clean_stream_laundry_app/logic/services/transaction_service.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class SettingsController extends ChangeNotifier {
  static const int maxNotificationLeadTime = 30;

  final AuthService authService;
  final ProfileService profileService;
  final TransactionService transactionService;

  SettingsController({
    AuthService? authService,
    ProfileService? profileService,
    TransactionService? transactionService,
  }) : authService = authService ?? GetIt.instance<AuthService>(),
       profileService = profileService ?? GetIt.instance<ProfileService>(),
       transactionService =
           transactionService ?? GetIt.instance<TransactionService>();

  int notificationLeadTime = 5;
  bool isLoadingDelay = true;
  bool canUseAdminWallets = false;

  Future<void> loadNotificationLeadTime() async {
    final results = await Future.wait([
      profileService.getNotificationLeadTime(),
      profileService.getCurrentUserRole(),
    ]);
    final value = results[0] as int;
    final role = results[1] as String?;
    notificationLeadTime = value;
    canUseAdminWallets = role == 'Admin' || role == 'Owner';
    isLoadingDelay = false;
    notifyListeners();
  }

  Future<void> updateLeadTime(int newValue) async {
    notificationLeadTime = newValue;
    notifyListeners();
    await profileService.setNotificationLeadTime(newValue);
  }

  Future<void> increment() async {
    if (notificationLeadTime < maxNotificationLeadTime) {
      await updateLeadTime(notificationLeadTime + 1);
    }
  }

  Future<void> decrement() async {
    if (notificationLeadTime > 0) {
      await updateLeadTime(notificationLeadTime - 1);
    }
  }

  Future<List<Map<String, dynamic>>> getTransactions() async {
    return transactionService.getTransactionsForUser();
  }

  Future<void> signOut() async {
    await authService.logout();
  }
}
