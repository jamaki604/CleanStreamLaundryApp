import 'package:clean_stream_laundry_app/widgets/base_page.dart';
import 'package:clean_stream_laundry_app/Logic/Services/auth_service.dart';
import 'package:clean_stream_laundry_app/Logic/Services/machine_service.dart';
import 'package:clean_stream_laundry_app/Logic/Services/profile_service.dart';
import 'package:clean_stream_laundry_app/Logic/Services/transaction_service.dart';
import 'package:flutter/material.dart';
import 'package:clean_stream_laundry_app/Logic/Payment/process_payment.dart';
import 'package:get_it/get_it.dart';
import 'package:clean_stream_laundry_app/widgets/status_dialog_box.dart';
import 'package:clean_stream_laundry_app/Logic/parsing/machine_parser.dart';
import '../Logic/Theme/theme.dart';
import 'package:clean_stream_laundry_app/Logic/Services/machine_communication_service.dart';

class PaymentPage extends StatefulWidget {
  final String machineId;

  const PaymentPage({super.key, required this.machineId});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  final bool _isConfirmed = false;
  double? _price;
  String? _machineName;
  double? _userBalance;
  bool _isLoading = true;

  final machineService = GetIt.instance<MachineService>();
  final profileService = GetIt.instance<ProfileService>();
  final authService = GetIt.instance<AuthService>();
  final transactionService = GetIt.instance<TransactionService>();
  final machineCommunicator = GetIt.instance<MachineCommunicationService>();

  @override
  void initState() {
    super.initState();
    _fetchMachineInfo();
  }

  Future<void> _fetchMachineInfo() async {

    final data = await machineService.getMachineById(widget.machineId);
    final userId = authService.getCurrentUserId;

    if (userId == null) {
      return;
    }
    final balance = await profileService.getUserBalanceById(userId);


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
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  Text(
                    'Machine $_machineName',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.fontInverted,
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

  Widget _buildAmountCard() {
    return Container(
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.cardPrimary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Icon(
            Icons.local_laundry_service,
            size: 80,
            color: Color(0xFF2073A9),
          ),
          const SizedBox(height: 20),
          Text(
            'Amount Due',
            style: TextStyle(fontSize: 16,
                color: Colors.black87,
            )
          ),
          const SizedBox(height: 10),
          Text(
            '\$${_price?.toStringAsFixed(2) ?? '0.00'}',
            style: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
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
                  final success = await processPayment(context, _price!, MachineFormatter.formatMachineType(_machineName.toString()));

                  if (success) {

                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (BuildContext dialogContext) => const Center(child: CircularProgressIndicator()),
                    );
                    final deviceAuthorized = await machineCommunicator.wakeDevice(
                        widget.machineId);
                    Navigator.of(context, rootNavigator: true).pop();

                    if (deviceAuthorized) {
                      statusDialog(
                        context,
                        title: "payment processed! Machine Ready!",
                        message: "Machine $_machineName is now active.",
                        isSuccess: true,
                      );
                    } else {
                      statusDialog(
                        context,
                        title: "Machine Error",
                        message: "payment succeeded but machine did not wake up.",
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
    profileService.updateBalanceById(updatedBalance);
    setState(() {
      _userBalance = updatedBalance;
    });
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext dialogContext) => const Center(child: CircularProgressIndicator()),
        );
        final deviceAuthorized = await machineCommunicator.wakeDevice(widget.machineId);
        Navigator.of(context, rootNavigator: true).pop();

        if (deviceAuthorized) {
          statusDialog(
            context,
            title: "Machine Ready!",
            message: "Machine $_machineName is now active.",
            isSuccess: true,
          );
          await transactionService.recordTransaction(amount: _price!, description: "Loyalty payment on ${MachineFormatter.formatMachineType(_machineName.toString())}", type: "laundry");
        } else {
          statusDialog(
            context,
            title: "Machine Error",
            message: "payment succeeded but machine did not wake up.",
            isSuccess: false,
          );
        }
    statusDialog(context,
        title: "payment Successful!",
        message: "Thank you! \$${_price?.toStringAsFixed(2)} was taken from your Loyalty Card.",
        isSuccess: true
    );
  }
}