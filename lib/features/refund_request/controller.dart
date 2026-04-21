import 'package:clean_stream_laundry_app/logic/services/auth_service.dart';
import 'package:clean_stream_laundry_app/logic/services/edge_function_service.dart';
import 'package:clean_stream_laundry_app/logic/services/profile_service.dart';
import 'package:clean_stream_laundry_app/logic/services/transaction_service.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class RefundController extends ChangeNotifier {
  final TransactionService transactionService;
  final EdgeFunctionService edgeFunctionService;
  final ProfileService profileService;
  final AuthService authService;

  RefundController({
    TransactionService? transactionService,
    EdgeFunctionService? edgeFunctionService,
    ProfileService? profileService,
    AuthService? authService,
  })  : transactionService =
      transactionService ?? GetIt.instance<TransactionService>(),
        edgeFunctionService =
            edgeFunctionService ?? GetIt.instance<EdgeFunctionService>(),
        profileService = profileService ?? GetIt.instance<ProfileService>(),
        authService = authService ?? GetIt.instance<AuthService>();

  final TextEditingController descriptionController = TextEditingController();

  List<String> recentTransactions = [];
  List<int> recentTransactionIDs = [];

  String? selectedTransaction;
  int? selectedTransactionIndex;

  bool attemptedSubmit = false;
  bool isLoading = false;
  bool isFetchingTransactions = true;

  void disposeController() {
    descriptionController.dispose();
  }

  bool get isFormValid =>
      selectedTransaction != null &&
          descriptionController.text.trim().isNotEmpty;

  Future<void> fetchTransactions() async {
    try {
      final result =
      await transactionService.getRefundableTransactionsForUser();
      recentTransactions = result.transactions;
      recentTransactionIDs = result.ids;

      recentTransactions.removeWhere(
            (t) => t.contains('added to Loyalty Card'),
      );
    } catch (e) {
      // silently ignore — page stays usable with empty list
    } finally {
      isFetchingTransactions = false;
      notifyListeners();
    }
  }

  void selectTransaction(String transaction) {
    selectedTransaction = transaction;
    selectedTransactionIndex = recentTransactions.indexOf(transaction);
    notifyListeners();
  }

  String getTransactionID() {
    return recentTransactionIDs[selectedTransactionIndex!].toString();
  }

  Future<String?> getUserName() async {
    final userId = authService.getCurrentUserId;
    if (userId == null) return null;
    return profileService.getUserNameById(userId);
  }
  
  Future<bool> submitRefund() async {
    final userId = authService.getCurrentUserId;
    if (userId == null) return false;

    isLoading = true;
    notifyListeners();

    try {
      final transactionId = getTransactionID();
      final description = descriptionController.text;
      final username = await getUserName();

      final amount = await transactionService.recordRefundRequest(
        transaction_id: transactionId,
        description: description,
      );

      await edgeFunctionService.runEdgeFunction(
        name: 'refund-email',
        body: {
          'username': username,
          'user_id': userId,
          'transaction_id': transactionId,
          'amount': amount,
          'description': description,
        },
      );

      return true;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void markAttemptedSubmit() {
    attemptedSubmit = true;
    notifyListeners();
  }
}