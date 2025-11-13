import 'package:clean_stream_laundry_app/Components/status_dialog_box.dart';
import 'package:flutter/material.dart';
import 'package:clean_stream_laundry_app/Components/base_page.dart';
import 'package:clean_stream_laundry_app/Logic/Services/transaction_service.dart';
import 'package:clean_stream_laundry_app/Logic/Parser/transaction_parser.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import '../Logic/Theme/theme.dart';

class RefundPage extends StatefulWidget {
  const RefundPage({super.key});

  @override
  State<RefundPage> createState() => _RefundPageState();
}

class _RefundPageState extends State<RefundPage> {
  String? selectedTransaction;
  int? selectedTransactionIndex;
  List<String> recentTransactions = [];
  List<int> recentTransactionIDs = [];
  final transactionService = GetIt.instance<TransactionService>();

  @override
  void initState() {
    super.initState();
    _fetchTransactions();
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

  int? getTransactionID() {
    if (selectedTransactionIndex != null &&
        selectedTransactionIndex! < recentTransactionIDs.length) {
      return recentTransactionIDs[selectedTransactionIndex!];
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return BasePage(
      body: Scaffold(
        appBar: AppBar(
          title: Text(
            'Refund Page',
            style: TextStyle(
              color: Theme.of(context).colorScheme.fontSecondary,
            ),
          ),
          elevation: 2,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DropdownButtonFormField<int>(
                initialValue: selectedTransactionIndex,
                hint: Text('Select a Transaction'),
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                isExpanded: true,
                items: List.generate(recentTransactions.length, (index) {
                  return DropdownMenuItem<int>(
                    value: index,
                    child: Text(recentTransactions[index], style: TextStyle(color: Theme.of(context).colorScheme.fontSecondary),),
                  );
                }),
                onChanged: (int? newIndex) {
                  setState(() {
                    selectedTransactionIndex = newIndex;
                    if (newIndex != null) {
                      selectedTransaction = recentTransactions[newIndex];
                    } else {
                      selectedTransaction = null;
                    }
                  });
                },
              ),
              SizedBox(height: 20),
              TextField(
                minLines: 3,
                maxLines: null,
                keyboardType: TextInputType.multiline,
                decoration: InputDecoration(
                  hintText: 'Please explain your reason for the refund...',
                  hintStyle: TextStyle(
                    color:  Theme.of(context).colorScheme.fontSecondary
                  ),
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: selectedTransaction != null
                      ? () async {
                    _showRefundDialog();
                    context.go("/homePage");
                  }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.transparent,
                    disabledForegroundColor: Colors.transparent,
                  ),
                  child: Text("Submit refund"),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void _showRefundDialog() {
    statusDialog(
      context,
      title: "Success",
      message: 'Your refund request has been submitted',
      isSuccess: true,
    );
  }
}