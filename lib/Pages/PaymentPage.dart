import 'package:clean_stream_laundry_app/Components/BasePage.dart';
import 'package:clean_stream_laundry_app/Middleware/DatabaseService.dart';
import 'package:flutter/material.dart';
import 'package:clean_stream_laundry_app/Logic/Payment/processPayment.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:clean_stream_laundry_app/Components/PaymentResult.dart';
import 'package:clean_stream_laundry_app/Middleware/MachineCommunicator.dart';
import '../Logic/Theme/Theme.dart';

class PaymentPage extends StatefulWidget {
  final String machineId;

  const PaymentPage({Key? key, required this.machineId}) : super(key: key);

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  bool _isConfirmed = false;
  double? _price;
  String? _machineName;
  double? _userBalance;
  bool _isLoading = true;
  final SupabaseClient _client = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _fetchMachineInfo();
  }

  Future<void> _fetchMachineInfo() async {

    final data = await DatabaseService.instance.getMachineById(widget.machineId);
    final userId = _client.auth.currentUser?.id;

    if (userId == null) {
      print("User not authenticated");
      return;
    }
    final balance = await DatabaseService.instance.getUserBalanceById(userId);


    if (data != null && balance!= null) {
      setState(() {
        _userBalance = (balance['balance'] as num).toDouble();
        _machineName = data['Name'];
        _price = (data['Price'] as num).toDouble();
        _isLoading = false;
      });
    } else {

      // handle error / machine not found
      setState(() {
        _userBalance = 0;
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
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.fontColor,
                    ),
                  ),
                  const SizedBox(height: 40),
                  _buildAmountCard(),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: _buildPaymentButtons(context),
          ),
        ],
      ),
    );
  }

  // Amount due card
  Widget _buildAmountCard() {
    return Container(
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
          Text(
            'Amount Due',
            style: TextStyle(fontSize: 16,
                color: Theme.of(context).colorScheme.fontColor.withOpacity(0.6)),
          ),
          const SizedBox(height: 10),
          Text(
            '\$${_price?.toStringAsFixed(2) ?? '0.00'}',
            style: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.fontColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentButtons(BuildContext context) {
    return Row(
      children: [
        // Stripe payment button
        Expanded(
          child: ElevatedButton(
            onPressed: (_isConfirmed || _price == null || _price == 0)
                ? null
                : () async {
                  final success = await processPayment(context, _price!, "Machine");

                  if (success) {
                    final nayaxCommunicator = MachineCommunicator();
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (_) => const Center(child: CircularProgressIndicator()),
                    );
                    final deviceAuthorized = await nayaxCommunicator.wakeDevice(
                        widget.machineId);
                    Navigator.of(context).pop();

                    if (deviceAuthorized) {
                      showPaymentResult(
                        context,
                        title: "Payment processed! Machine Ready!",
                        message: "Machine ${_machineName} is now active.",
                        isSuccess: true,
                      );
                    } else {
                      showPaymentResult(
                        context,
                        title: "Machine Error",
                        message: "Payment succeeded but machine did not wake up.",
                        isSuccess: false,
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: (_isConfirmed || _price == null || _price == 0)
                      ? Colors.grey
                      : Colors.blue[700],
                  disabledBackgroundColor: Colors.grey,
                  shape:
                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 2,
                  padding: const EdgeInsets.symmetric(vertical: 16),
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

        const SizedBox(width: 16),

        // Loyalty payment button
        Expanded(
          child: ElevatedButton(
            onPressed: (_isConfirmed || _price == null || _price == 0 || (_userBalance ?? 0) < (_price ?? 0))
                ? null
                : () => _processLoyaltyPayment(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: (_isConfirmed || _price == null || _price == 0 || (_userBalance ?? 0) < (_price ?? 0))
                  ? Colors.grey
                  : Colors.green[700],
              disabledBackgroundColor: Colors.grey,
              shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 2,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text(
              'Pay with Loyalty',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _processLoyaltyPayment(BuildContext context) async {
    final updatedBalance = _userBalance! - _price!;
    DatabaseService.instance.updateBalanceById(updatedBalance);
    setState(() {
      _userBalance = updatedBalance;
    });
        final nayaxCommunicator = MachineCommunicator();
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => const Center(child: CircularProgressIndicator()),
        );
        final deviceAuthorized = await nayaxCommunicator.wakeDevice(widget.machineId);
        Navigator.of(context).pop();

        if (deviceAuthorized) {
          showPaymentResult(
            context,
            title: "Machine Ready!",
            message: "Machine ${_machineName} is now active.",
            isSuccess: true,
          );
        } else {
          showPaymentResult(
            context,
            title: "Machine Error",
            message: "Payment succeeded but machine did not wake up.",
            isSuccess: false,
          );
        }
    showPaymentResult(context,
        title: "Payment Successful!",
        message: "Thank you! \$${_price?.toStringAsFixed(2)} was taken from your Loyalty Card.",
        isSuccess: true
    );
  }
}