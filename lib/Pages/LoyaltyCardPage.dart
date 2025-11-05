import 'package:flutter/material.dart';
import 'package:clean_stream_laundry_app/Components/BasePage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:clean_stream_laundry_app/Middleware/DatabaseService.dart';
import 'package:go_router/go_router.dart';
import 'package:clean_stream_laundry_app/Logic/Payment/processPayment.dart';
import '../Logic/Theme/Theme.dart';
import 'package:clean_stream_laundry_app/Logic/Transaction/TransactionParser.dart';
import 'package:clean_stream_laundry_app/Components/CreditCard.dart';

class LoyaltyPage extends StatefulWidget {
  const LoyaltyPage({super.key});

  @override
  State<LoyaltyPage> createState() => LoyaltyCardPage();
}

class LoyaltyCardPage extends State<LoyaltyPage> {
  double? _userBalance;
  bool _isLoading = true;
  String? _userName;
  String? _errorMessage;
  List<String> _recentTransactions = [];
  final userId = Supabase.instance.client.auth.currentUser?.id;
  bool _showPastTransactions = false;

  @override
  void initState() {
    super.initState();
    _fetchBalance();
    _fetchTransactions();
  }

  Future<void> _fetchBalance() async {
    final currentUserId = userId;

    if (currentUserId == null) {
      setState(() {
        _errorMessage = 'User not known';
        _isLoading = false;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showErrorDialog(context, _errorMessage);
      });
      return;
    }

    try {
      final data = await DatabaseService.instance.getUserBalanceById(currentUserId);

      if (data != null) {
        setState(() {
          _userBalance = (data['balance'] as num).toDouble();
          _userName = (data['full_name'] );
          _isLoading = false;
        });
      } else {
        setState(() {
          _userBalance = 0;
          _userName = "John Doe";
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to fetch balance';
        _isLoading = false;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showErrorDialog(context, _errorMessage);
      });
    }

  }

  Future<void> _fetchTransactions() async {
    try {
      final transactions = await DatabaseService.instance.getTransactionsForUser();
      final limit = _showPastTransactions ? 100 : 3;
      setState(() {
        _recentTransactions = TransactionParser.formatTransactionsList(transactions.take(limit));
        _recentTransactions.removeWhere((e) => e.isEmpty);
      });
    } catch (e) {
      print('Failed to fetch transactions: $e');
    }
  }

  void _toggleTransactionView() {
    setState(() {
      _showPastTransactions = !_showPastTransactions;
    });
    _fetchTransactions();
  }

  @override
  Widget build(BuildContext context) {
    return BasePage(
      body:  _isLoading
        ? const Center(child: CircularProgressIndicator())
        : Center(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              SizedBox(height:20),
              CreditCard(username: _userName),
              SizedBox(height: 50),
              Text(
                  'Current Balance: \$${_userBalance?.toStringAsFixed(2)?? '0.00'}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.fontPrimary,
                  ),
                ),
              SizedBox(height: 25),
              ElevatedButton(
                  onPressed: () => _loadCard(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    disabledBackgroundColor: Colors.grey,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: Text(
                    "Load card",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              SizedBox(height: 40),
              Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Transactions',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.fontPrimary,
                            ),
                          ),
                          TextButton.icon(
                            onPressed: _toggleTransactionView,
                            icon: Icon(
                              _showPastTransactions ? Icons.expand_less : Icons.expand_more,
                              color: Colors.blue,
                            ),
                            label: Text(
                              _showPastTransactions ? 'Show Less' : 'Show More',
                              style: TextStyle(color: Colors.blue),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      _recentTransactions.isEmpty
                          ? Text(
                        'No recent transactions',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      )
                          : Column(
                        children: _recentTransactions.map((transaction) {
                          return Card(
                            margin: EdgeInsets.only(bottom: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            elevation: 7,
                            color: Theme.of(context).colorScheme.cardPrimary,
                            child: ListTile(
                              leading: Icon(
                                Icons.receipt_long,
                                color: Color(0xFF2073A9),
                              ),
                              title: Text(
                                transaction.toString(),
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              SizedBox(height: 20),
            ],
          ),
        )
    );
  }

  void _showErrorDialog(BuildContext context, String? message) {
    showDialog(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: const Text('Error'),
              content: Text(message ?? ''),
              icon: Icon(Icons.error),
              actions: [
                TextButton(onPressed: () {
                  Navigator.of(dialogContext).pop();
                  if (message == "Failed to fetch balance") {
                    context.go("/scanner");
                  } else {
                    context.go("/login");
                  }
                }, child: const Text('OK'),
                ),
              ]
          );
        }
    );
  }

  void _loadCard() {
    TextEditingController _amountController = TextEditingController();
    showDialog(
        context: context,
        builder: (_) => AlertDialog(
            backgroundColor: Theme.of(context).colorScheme.background,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Center(
              child: Text(
                "Enter load amount",
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[900]
                ),
              ),
            ),
            content: TextField(
              controller: _amountController,
              autofocus: true,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                prefixText: '\$',
                prefixStyle: TextStyle(
                  color: Colors.blue[800],
                  fontWeight: FontWeight.bold,
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue[700]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue[300]!),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              style: TextStyle(color: Colors.blue[900]),
            ),
            actions: <Widget>[
              TextButton(
                child: Text('Cancel', style: TextStyle(color: Colors.blue[700])),
                onPressed: () {
                  Navigator.of(context).pop(null);
                },
              ),
              ElevatedButton(
                child: Text('Pay', style: TextStyle(color: Colors.blue[700])),
                onPressed: () async {
                  final amountText = _amountController.text;
                  final amount = double.tryParse(amountText) ?? 0;

                  Navigator.of(context).pop();

                  if (amount > 0) {
                    bool result = await processPayment(context, amount, "Loyalty Card");
                    if (result) {
                      final newBalance = _userBalance! + amount;
                      DatabaseService.instance.updateBalanceById(newBalance);
                      setState(() {
                        _userBalance = newBalance;
                      });
                      _fetchTransactions();
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please enter a valid amount')),
                    );
                  }
                },
              )
            ]
        )
    );
  }
}