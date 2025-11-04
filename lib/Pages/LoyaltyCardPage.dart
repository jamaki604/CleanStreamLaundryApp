import 'package:flutter/material.dart';
import 'package:clean_stream_laundry_app/Components/BasePage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:clean_stream_laundry_app/Middleware/DatabaseService.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:clean_stream_laundry_app/Logic/Payment/processPayment.dart';

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
  final userId = Supabase.instance.client.auth.currentUser?.id;

  @override
  void initState() {
    super.initState();
    _fetchBalance();
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
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400, maxHeight: 250),
            child: Card(
                elevation: 10,
                margin: const EdgeInsets.symmetric(horizontal: 24),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: SizedBox(
                    height: 225,
                    child: Stack(
                      children: [
                        Positioned(
                          top: -30,
                          left: 15,
                          child: Image.asset("assets/Slogan.png", width: 200, height: 150),
                        ),
                        Positioned(
                          top: -3,
                          right: 0,
                          child: Image.asset("assets/Icon.png", height: 95, width: 95),
                        ),
                        Positioned(
                          left: 15,
                          top: 80,
                          child: SvgPicture.asset("assets/CardChip.svg", width: 60, height: 45),
                        ),
                        Positioned(
                          left: -4,
                          right: 0,
                          top: 130,
                          child: Text(
                            "1234    5678    9012    3456",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w300,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        Positioned(
                          left: 15,
                          top: 170,
                          child: Text(
                            (_userName == null || _userName!.isEmpty) ? 'John Doe' : _userName!,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        Positioned(
                          right: 15,
                          bottom: 10,
                          top: 165,
                          child: Image.asset("assets/Mastercard.png", width: 85, height: 60),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ),
              SizedBox(height: 50),
              Text(
                'Current Balance: \$${_userBalance?.toStringAsFixed(2)?? '0.00'}',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
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
              )
            ]
          ),
        ),
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
        backgroundColor: Colors.blue[25],
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