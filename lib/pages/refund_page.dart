import 'package:clean_stream_laundry_app/widgets/status_dialog_box.dart';
import 'package:clean_stream_laundry_app/logic/services/auth_service.dart';
import 'package:clean_stream_laundry_app/logic/services/edge_function_service.dart';
import 'package:clean_stream_laundry_app/logic/services/profile_service.dart';
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

  final FocusNode _focusNode = FocusNode();

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
      final transactions = await transactionService.getTransactionsForUser();
      setState(() {
        recentTransactions = TransactionParser.formatTransactionsList(
          transactions.take(100),
          "refundHistory",
        );
        recentTransactions.removeWhere((e) => e.isEmpty);
        recentTransactionIDs = TransactionParser.createTransactionIDList(
          transactions.take(100),
        );
        recentTransactionIDs.removeWhere((e) => e.isNegative);
      });
    } catch (e) {
      print(e.toString());
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
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: Icon(
            Icons.arrow_back,
            color: Theme.of(context).colorScheme.fontPrimary,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Text(
          "Request Refund",
          style: TextStyle(color: Theme.of(context).colorScheme.fontPrimary),
        ),
        centerTitle: true,
      ),
      body: Scaffold(
        body: KeyboardListener(
          focusNode: _focusNode,
          autofocus: kIsWeb,
          onKeyEvent: (keyEvent) {
            if (keyEvent is KeyDownEvent &&
                keyEvent.logicalKey == LogicalKeyboardKey.enter) {
              _handleRefund();
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DropdownButtonFormField<int>(
                  initialValue: selectedTransactionIndex,
                  hint: Text('Select a Transaction'),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.fontInverted,
                  ),
                  decoration: InputDecoration(
                    hintStyle: TextStyle(color: Colors.white),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.fontInverted,
                        width: 2,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.fontSecondary,
                        width: 2,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.blue, width: 2),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  isExpanded: true,
                  menuMaxHeight: 250,
                  items: List.generate(recentTransactions.length, (index) {
                    return DropdownMenuItem<int>(
                      value: index,
                      child: Text(
                        recentTransactions[index],
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.fontInverted,
                        ),
                      ),
                    );
                  }),

                  onChanged: (int? newIndex) {
                    setState(() {
                      selectedTransactionIndex = newIndex;
                      selectedTransaction = newIndex != null
                          ? recentTransactions[newIndex]
                          : null;
                    });
                  },
                ),

                const SizedBox(height: 20),

                TextField(
                  controller: descriptionController,
                  minLines: 3,
                  maxLines: null,
                  keyboardType: TextInputType.multiline,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.fontInverted,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Please explain your reason for the refund...',
                    hintStyle: TextStyle(
                      color: Theme.of(context).colorScheme.fontSecondary,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.fontInverted,
                        width: 2,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.fontSecondary,
                        width: 2,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.blue, width: 2),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                Center(
                  child: ElevatedButton(
                    onPressed: isFormValid()
                        ? () async {
                            _handleRefund();
                          }
                        : null,

                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.transparent,
                      disabledForegroundColor: Colors.transparent,
                    ),
                    child: const Text("Submit Refund"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleRefund() async {
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
  }

  void _showRefundDialog() {
    statusDialog(
      context,
      title: "Success",
      message: 'Your refund request has been submitted',
      isSuccess: true,
    );
    context.go("/settings");
  }
}
