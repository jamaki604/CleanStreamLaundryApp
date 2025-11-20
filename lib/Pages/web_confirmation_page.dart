import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import '../Logic/Services/payment_service.dart';

class PaymentResultPageWeb extends StatefulWidget {
  final String? sessionId;

  const PaymentResultPageWeb({
    super.key,
    required this.sessionId,
  });

  @override
  State<PaymentResultPageWeb> createState() => _PaymentResultPageWebState();
}

class _PaymentResultPageWebState extends State<PaymentResultPageWeb> {
  final paymentService = GetIt.instance<PaymentService>();

  bool isSuccess = false;
  String title = "Payment error!";
  String message = "There was an error processing your payment!";
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkPaymentStatus();
  }

  Future<void> _checkPaymentStatus() async {
    try {
      print(widget.sessionId);
      final status = await paymentService.getTransactionResult(widget.sessionId!);

      if (!mounted) return;

      setState(() {
        isLoading = false;
        if(status == "paid") {
          title = "Payment processed! Machine Ready!";
          message = "Machine is ready to go!";
          isSuccess = true;
        }
      });
    } catch (e) {

      if (!mounted) return;
      setState(() {
        isLoading = false;
        title = "Payment error!";
        message = "There was an error processing your payment!";
        isSuccess = false;
      });

    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
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
          textAlign: TextAlign.center,
          style: const TextStyle(
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
              context.go(isSuccess ? "/homePage" : "/startPage");
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[700],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Done',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}