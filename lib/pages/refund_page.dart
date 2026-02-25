import 'package:clean_stream_laundry_app/widgets/status_dialog_box.dart';
import 'package:clean_stream_laundry_app/logic/services/auth_service.dart';
import 'package:clean_stream_laundry_app/logic/services/edge_function_service.dart';
import 'package:clean_stream_laundry_app/logic/services/profile_service.dart';
import 'package:clean_stream_laundry_app/widgets/transactions_search_sheet.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:clean_stream_laundry_app/logic/services/transaction_service.dart';
import 'package:clean_stream_laundry_app/logic/parsing/transaction_parser.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:clean_stream_laundry_app/logic/theme/theme.dart';

class RefundPage extends StatefulWidget {
  const RefundPage({super.key});

  @override
  State<RefundPage> createState() => RefundPageState();
}

class RefundPageState extends State<RefundPage> {
  String? selectedTransaction;
  int? selectedTransactionIndex;
  List<String> recentTransactions = [];
  List<int> recentTransactionIDs = [];
  final descriptionController = TextEditingController();
  final transactionService = GetIt.instance<TransactionService>();
  final edgeFunctionService = GetIt.instance<EdgeFunctionService>();
  final profileService = GetIt.instance<ProfileService>();
  final authService = GetIt.instance<AuthService>();
  bool _attemptedSubmit = false;
  final FocusNode _focusNode = FocusNode();
  bool _isLoading = false;
  bool _isFetchingTransactions = true;

  @override
  void initState() {
    super.initState();
    _fetchTransactions();

    descriptionController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    super.dispose();
    _focusNode.dispose();
  }

  Future<void> _fetchTransactions() async {
    try {
      final result = await transactionService.getRefundableTransactionsForUser();
      setState(() {
        recentTransactions = result.transactions;
        recentTransactionIDs = result.ids;
      });
    } catch (e) {
      print(e.toString());
    } finally {
      if (mounted) setState(() => _isFetchingTransactions = false);
    }
  }

  String getTransactionID() {
    return recentTransactionIDs[selectedTransactionIndex!].toString();
  }

  Future<String?> getUserName() async {
    String? userId = authService.getCurrentUserId;
    return profileService.getUserNameById(userId!);
  }

  bool isFormValid() {
    return selectedTransaction != null &&
        descriptionController.text.trim().isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        backgroundColor: colorScheme.primary,
        title: const Text("Request Refund", style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: KeyboardListener(
        focusNode: _focusNode,
        autofocus: kIsWeb,
        onKeyEvent: (keyEvent) {
          if (keyEvent is KeyDownEvent &&
              keyEvent.logicalKey == LogicalKeyboardKey.enter) {
            _handleRefund();
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: colorScheme.primary.withOpacity(0.2),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.receipt_long_rounded,
                          color: colorScheme.primary, size: 28),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Submit a Refund Request",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: colorScheme.fontInverted,
                              )),
                          const SizedBox(height: 4),
                          Text(
                            "Select a transaction and describe your issue. Our team will review it shortly.",
                            style: TextStyle(
                              fontSize: 13,
                              color: colorScheme.fontSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // Form card
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel("Select a Transaction"),
                      const SizedBox(height: 8),
                      _isFetchingTransactions
                          ? const Center(child: CircularProgressIndicator())
                          : GestureDetector(
                        onTap: () async {
                          final selected = await showModalBottomSheet<String>(
                            context: context,
                            isScrollControlled: true,
                            builder: (_) => TransactionSearchSheet(
                              transactions: recentTransactions,
                            ),
                          );

                          if (selected != null) {
                            setState(() {
                              selectedTransaction = selected;
                              selectedTransactionIndex =
                                  recentTransactions.indexOf(selected);
                            });
                          }
                        },
                        child: AbsorbPointer(
                          child: TextFormField(
                            decoration: _inputDecoration(context).copyWith(
                              hintText: 'Select a transaction',
                              hintStyle: TextStyle(color: colorScheme.fontSecondary),
                            ),
                            controller: TextEditingController(
                              text: selectedTransaction,
                            ),
                            style: TextStyle(color: colorScheme.fontInverted),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      _buildLabel("Reason for Refund"),
                      const SizedBox(height: 8),
                      TextField(
                        controller: descriptionController,
                        minLines: 4,
                        maxLines: null,
                        keyboardType: TextInputType.multiline,
                        style: TextStyle(color: colorScheme.fontInverted),
                        decoration: _inputDecoration(context).copyWith(
                          hintText: 'Describe the issue with your transaction...',
                          hintStyle: TextStyle(color: colorScheme.fontSecondary),
                        ),
                      ),

                      if (_attemptedSubmit && !isFormValid())
                        Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: Row(
                            children: const [
                              Icon(Icons.info_outline, color: Colors.red, size: 16),
                              SizedBox(width: 6),
                              Text('Please fill in all fields',
                                  style: TextStyle(color: Colors.red, fontSize: 13)),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading
                      ? null
                      : () {
                    setState(() => _attemptedSubmit = true);
                    if (!isFormValid()) return;
                    _handleRefund();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isFormValid() ? colorScheme.primary : Colors.grey,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: isFormValid() ? 2 : 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2.5),
                  )
                      : const Text("Submit Refund Request",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 14,
        color: Theme.of(context).colorScheme.fontInverted,
      ),
    );
  }

  InputDecoration _inputDecoration(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return InputDecoration(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: colorScheme.fontSecondary, width: 1.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: colorScheme.fontSecondary, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.blue, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  void _handleRefund() async {
    setState(() => _isLoading = true);
    final transactionId = getTransactionID();
    final description = descriptionController.text;
    final userId = authService.getCurrentUserId;

    if (userId == null) {
      print("Error: No user is logged in.");
      return;
    }

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

    _showRefundDialog();
    if (mounted) setState(() => _isLoading = false);
  }

  void _showRefundDialog() {
    statusDialog(
      context,
      title: "Success",
      message: 'Your refund request has been submitted',
      isSuccess: true,
    ).then((_) {
      context.go("/settings");
    });
  }
}
