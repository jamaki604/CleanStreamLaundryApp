import 'package:clean_stream_laundry_app/Components/BasePage.dart';
import 'package:clean_stream_laundry_app/Middleware/DatabaseQueries.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:clean_stream_laundry_app/Logic/Stripe/Stripe_service.dart';

class ConfirmationPage extends StatefulWidget {
  final String machineId;


  const ConfirmationPage({Key? key, required this.machineId}) : super(key: key);

  @override
  State<ConfirmationPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<ConfirmationPage> {
  bool _isConfirmed = false;
  double? _price;
  String? _machineName;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchMachineInfo();
  }

  Future<void> _fetchMachineInfo() async {

    final data = await DatabaseService.instance.getMachineById(widget.machineId);

    if (data != null) {
      setState(() {
        _machineName = data['Name'];
        _price = (data['Price'] as num).toDouble();
        _isLoading = false;
      });
    } else {

      // handle error / machine not found
      setState(() {
        _machineName = 'Unknown';
        _price = 0;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BasePage(
      body: _isLoading
        ? const Center(child: CircularProgressIndicator())
        : Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  Text(
                    'Machine ${_machineName}',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 40),
                  Container(
                    padding: const EdgeInsets.all(30),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.local_laundry_service,
                          size: 80,
                          color: Colors.blue[700],
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Amount Due',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          '\$${_price?.toStringAsFixed(2) ?? '0.00'}',
                          style: TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: (_isConfirmed || _price == null || _price == 0)
                    ? null
                    : () => _processPayment(_price!),
                style: ElevatedButton.styleFrom(
                  backgroundColor: (_isConfirmed || _price == null || _price == 0)
                      ? Colors.grey
                      : Colors.blue,
                  disabledBackgroundColor: Colors.grey,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                child: _isConfirmed
                    ? const SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.5,
                  ),
                )
                    : Text(
                  _price != null && _price! > 0
                      ? 'Pay \$${_price!.toStringAsFixed(2)}'
                      : 'Pay',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _processPayment(double amount) async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator())
    );

    final int status = await StripeService.instance.makePayment(amount);

    Navigator.of(context).pop();

    if(status == 200) {
      _showPaymentResult(context,
          title: "Payment Successful!",
          message: "Thank you! Your payment was processed successfully.",
          isSuccess: true
      );
      DatabaseService.instance.recordTransaction(amount: amount, description: "Payment for machine", type: "Laundry");
    } else if (status == 401) {
      _showPaymentResult(context,
          title: "Payment Failed!",
          message: "The payment was canceled or declined.",
          isSuccess: false
      );
    } else {
      _showPaymentResult(context,
          title: "Payment Failed!",
          message: "An unexpected error occurred.",
          isSuccess: false
      );
    }
  }

  void _showPaymentResult(
      BuildContext, {
        required String title,
        required String message,
        required bool isSuccess
      }){
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green[50],
                shape: BoxShape.circle,
              ),
              child: Icon(
                isSuccess ? Icons.check_circle : Icons.error,
                color: isSuccess ? Colors.green : Colors.red,
                size: 64,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  if(isSuccess) {
                    context.go("/scanner");
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[700],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Done'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}